import 'dart:io';
import 'package:fitmind_ai/models/food_model.dart';
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
  }) {
    controller.saveScan(image, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Scan Result",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Blurred background for premium effect
          Positioned.fill(
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Floating image card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
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

                // Glassmorphism Result Card
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
                      const SizedBox(height: 20),

                      // Nutrition info cards
                      if (food.calories != null)
                        _nutritionCard("Calories", "${food.calories} kcal"),
                      if (food.protein != null)
                        _nutritionCard("Protein", "${food.protein} g"),
                      if (food.fats != null) _nutritionCard("Fat", "${food.fats} g"),
                      if (food.carbs != null) _nutritionCard("Carbs", "${food.carbs} g"),

                      const SizedBox(height: 25),

                      // Health message based on nutrition values
                      _healthMessageCard(food),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _healthMessageCard(Food food) {
    String message = "";
    Color color = Colors.green;

    // Simple logic to determine food healthiness
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
          Icon(Icons.info_outline, color: Colors.white, size: 28),
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