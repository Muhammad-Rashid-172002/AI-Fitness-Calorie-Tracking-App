import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';

class QuickAddMealScreen extends StatefulWidget {
  const QuickAddMealScreen({super.key});

  @override
  State<QuickAddMealScreen> createState() => _QuickAddMealScreenState();
}

class _QuickAddMealScreenState extends State<QuickAddMealScreen> {
  final mealNameController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  bool isSaving = false;

  Future<void> saveMeal() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showCustomSnackBar(context, "User not logged in", false);
      return;
    }

    String mealName = mealNameController.text.trim();
    String caloriesText = caloriesController.text.trim();
    String proteinText = proteinController.text.trim();
    String carbsText = carbsController.text.trim();
    String fatText = fatController.text.trim();

    if (mealName.isEmpty || caloriesText.isEmpty) {
      showCustomSnackBar(context, "Please fill required fields", false);
      return;
    }

    double calories = double.tryParse(caloriesText) ?? 0;
    double protein = double.tryParse(proteinText) ?? 0;
    double carbs = double.tryParse(carbsText) ?? 0;
    double fat = double.tryParse(fatText) ?? 0;

    setState(() => isSaving = true);

    try {
      final uid = user.uid;
      final today = DateTime.now();
      final todayId =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      /// ================= SAVE MEAL =================
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("scans")
          .add({
            "result": mealName,
            "calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fat": fat,
            "imagePath": null,
            "type": "manual",
            "timestamp": Timestamp.now(),
          });

      /// ================= UPDATE DAILY LOG =================
      final dailyRef = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("dailyLogs")
          .doc(todayId);

      await dailyRef.set({
        "totalCalories": FieldValue.increment(calories),
        "totalProtein": FieldValue.increment(protein),
        "totalCarbs": FieldValue.increment(carbs),
        "totalFat": FieldValue.increment(fat),
        "mealCount": FieldValue.increment(1),
        "createdAt": Timestamp.now(),
      }, SetOptions(merge: true));

      /// ================= 🔥 CALCULATE WEIGHT =================

      /// Get updated daily calories
      final updatedDoc = await dailyRef.get();
      double consumedCalories = (updatedDoc.data()?["totalCalories"] ?? 0)
          .toDouble();

      /// Get user target calories
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      double targetCalories = (userDoc.data()?["dailyCalories"] ?? 2000)
          .toDouble();

      /// Calculate deficit
      double deficit = targetCalories - consumedCalories;

      /// Calculate weight change
      double weightChange = deficit / 7700;

      /// Save in Firestore (PRO FEATURE)
      await dailyRef.set({
        "deficit": deficit,
        "weightChange": weightChange,
      }, SetOptions(merge: true));

      /// ================= SHOW RESULT =================

      String msg;

      if (weightChange < 0) {
        msg =
            "🔥 Losing ${weightChange.abs().toStringAsFixed(2)} kg today\nDeficit: ${deficit.toStringAsFixed(0)} kcal";
      } else {
        msg =
            "⚠️ Gaining ${weightChange.toStringAsFixed(2)} kg today\nExtra: ${deficit.abs().toStringAsFixed(0)} kcal";
      }

      showCustomSnackBar(context, msg, true);

      Navigator.pop(context);
    } catch (e) {
      showCustomSnackBar(context, "Error saving meal", false);
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget macroCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.4), color.withOpacity(0.15)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value.isEmpty ? "0g" : "$value g",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mealNameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Quick Add Meal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              buildField(
                "Meal Name",
                mealNameController,
                icon: Icons.restaurant,
              ),

              buildField(
                "Calories (kcal)",
                caloriesController,
                keyboard: TextInputType.number,
                icon: Icons.local_fire_department,
              ),

              buildField(
                "Protein (g)",
                proteinController,
                keyboard: TextInputType.number,
                icon: Icons.fitness_center,
              ),

              buildField(
                "Carbs (g)",
                carbsController,
                keyboard: TextInputType.number,
                icon: Icons.rice_bowl,
              ),

              buildField(
                "Fat (g)",
                fatController,
                keyboard: TextInputType.number,
                icon: Icons.opacity,
              ),

              const SizedBox(height: 25),

              /// Macro Preview
              Row(
                children: [
                  macroCard(
                    "Protein",
                    proteinController.text,
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                  macroCard(
                    "Carbs",
                    carbsController.text,
                    Icons.rice_bowl,
                    Colors.orange,
                  ),
                  macroCard(
                    "Fat",
                    fatController.text,
                    Icons.opacity,
                    Colors.red,
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: CustomGradientButton(
                  text: isSaving ? "Saving..." : "Save Meal",
                  onPressed: isSaving ? null : saveMeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
