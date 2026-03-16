// scan_result_screen.dart
import 'dart:io';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';

class ScanResultScreen extends StatelessWidget {
  final File image;
  final String result;
  final Food food;
  final ScanController controller = ScanController();

  ScanResultScreen({
    super.key,
    required this.image,
    required this.result,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned.fill(child: Image.file(image, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                /// Image Card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 25,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.file(
                      image,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Glass Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Analysis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        result,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// Calories Highlight
                      _calorieCard(food),

                      const SizedBox(height: 20),

                      /// Macro Circles
                      _macroSection(food),

                      const SizedBox(height: 25),

                      /// Health Message
                      _healthMessageCard(food),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// Done Button
                CustomGradientButton(
                  text: "Done",
                  onPressed: () async {
                    final parsedFood = controller.parseFoodFromResult(result);

                    await controller.saveScan(
                      result: result,
                      food: parsedFood,
                    );

                    showCustomSnackBar(
                      context,
                      "Scan Saved Successfully",
                      true,
                    );

                    Navigator.pop(context, {
                      "calories": parsedFood.calories ?? 0,
                      "protein": parsedFood.protein ?? 0,
                      "carbs": parsedFood.carbs ?? 0,
                      "fat": parsedFood.fats ?? 0,
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calories Big Highlight
  Widget _calorieCard(Food food) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Daily Calories",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${food.calories ?? 0}",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "kcal/day",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Macro Section (Carbs → Protein → Fat)
  Widget _macroSection(Food food) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _macroCircle("${food.carbs ?? 0} g", "Carbs"),
        _macroCircle("${food.protein ?? 0} g", "Protein"),
        _macroCircle("${food.fats ?? 0} g", "Fat"),
      ],
    );
  }

  /// Circle Widget
  Widget _macroCircle(String value, String label) {
    return Column(
      children: [
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.greenAccent,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Health Message
  Widget _healthMessageCard(Food food) {
    String message = "";
    Color color = Colors.green;

    if (food.calories != null && food.fats != null) {
      if (food.calories! <= 250 && food.fats! <= 10) {
        message = "Great choice! 🥗 This is healthy food.";
        color = Colors.green;
      } else if (food.calories! <= 500 && food.fats! <= 20) {
        message = "Moderate choice! 🍽 Try to balance with veggies.";
        color = Colors.orange;
      } else {
        message = "Caution! 🍔 High calories/fat detected.";
        color = Colors.redAccent;
      }
    } else {
      message = "Food analysis complete!";
      color = Colors.blueAccent;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}