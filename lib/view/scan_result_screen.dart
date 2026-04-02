// scan_result_screen.dart
import 'dart:io';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';

class ScanResultScreen extends StatefulWidget {
  final File image;
  final String result;
  final Food food;

  ScanResultScreen({
    super.key,
    required this.image,
    required this.result,
    required this.food,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final ScanController controller = ScanController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned.fill(child: Image.file(widget.image, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Image Card
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
                      widget.image,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Glassmorphism Card
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
                        widget.result,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (widget.food.calories != null)
                        _nutritionCard("Calories", "${widget.food.calories} kcal"),
                      if (widget.food.protein != null)
                        _nutritionCard("Protein", "${widget.food.protein} g"),
                      if (widget.food.fats != null)
                        _nutritionCard("Fat", "${widget.food.fats} g"),
                      if (widget.food.carbs != null)
                        _nutritionCard("Carbs", "${widget.food.carbs} g"),

                      const SizedBox(height: 25),
                      _healthMessageCard(widget.food),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                CustomGradientButton(
                  text: isSaving ? "Saving..." : "Save Food",
                  onPressed: () async {
                    setState(() {
                      isSaving = true;
                    });
                    final parsedFood = controller.parseFoodFromResult(widget.result);

                      /// Save scan + update daily logs
                      await controller.saveScan(result: widget.result, food: parsedFood);

                      showCustomSnackBar(
                        context,
                        "Scan Saved Successfully",
                        true,
                      );

                      /// Return data to HomeScreen
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

  Widget _nutritionCard(String title, String value) => Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

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