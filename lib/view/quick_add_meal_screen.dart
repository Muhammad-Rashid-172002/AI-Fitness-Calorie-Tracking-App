import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
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

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("scans") // Subcollection
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

      showCustomSnackBar(context, "Meal Saved Successfully", true);

      // Clear fields after saving
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
      setState(() {
        isSaving = false;
      });
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text("Quick Add Meal", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField("Meal Name", mealNameController),
            buildField(
              "Calories (kcal)",
              caloriesController,
              keyboard: TextInputType.number,
            ),
            buildField(
              "Protein (g)",
              proteinController,
              keyboard: TextInputType.number,
            ),
            buildField(
              "Carbs (g)",
              carbsController,
              keyboard: TextInputType.number,
            ),
            buildField(
              "Fat (g)",
              fatController,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomGradientButton(text: "Save Meal", onPressed: saveMeal)
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}