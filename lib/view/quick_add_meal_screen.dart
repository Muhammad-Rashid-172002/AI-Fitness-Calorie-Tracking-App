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

      // Save meal
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

      // Update daily log
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("dailyLogs")
          .doc(todayId)
          .set({
        "totalCalories": FieldValue.increment(calories),
        "totalProtein": FieldValue.increment(protein),
        "totalCarbs": FieldValue.increment(carbs),
        "totalFat": FieldValue.increment(fat),
        "mealCount": FieldValue.increment(1),
        "createdAt": Timestamp.now()
      }, SetOptions(merge: true));

      showCustomSnackBar(context, "Meal Saved Successfully", true);

      mealNameController.clear();
      caloriesController.clear();
      proteinController.clear();
      carbsController.clear();
      fatController.clear();

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Firestore Error: $e");
      showCustomSnackBar(context, "Error saving meal: $e", false);
    } finally {
      setState(() => isSaving = false);
    }
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Quick Add Meal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildField("Meal Name", mealNameController, icon: Icons.restaurant),
            _buildField("Calories (kcal)", caloriesController,
                keyboard: TextInputType.number, icon: Icons.local_fire_department),
            _buildField("Protein (g)", proteinController,
                keyboard: TextInputType.number, icon: Icons.fitness_center),
            _buildField("Carbs (g)", carbsController,
                keyboard: TextInputType.number, icon: Icons.rice_bowl),
            _buildField("Fat (g)", fatController,
                keyboard: TextInputType.number, icon: Icons.opacity),
            const SizedBox(height: 30),
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
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFFFFC107))
                : null,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}