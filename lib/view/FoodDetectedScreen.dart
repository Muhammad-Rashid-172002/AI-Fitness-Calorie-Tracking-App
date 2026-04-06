import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:fitmind_ai/view/AddFoodScreen.dart';
import 'package:fitmind_ai/view/MultiAdjustFoodScreen.dart';
import 'package:fitmind_ai/view/scan_result_screen.dart';

class FoodDetectedScreen extends StatefulWidget {
  final File image;
  final List<Food> foods;
  final String result;

  const FoodDetectedScreen({
    super.key,
    required this.image,
    required this.foods,
    required this.result,
  });

  @override
  State<FoodDetectedScreen> createState() => _FoodDetectedScreenState();
}

class _FoodDetectedScreenState extends State<FoodDetectedScreen> {
  List<Food> foods = [];

  @override
  void initState() {
    super.initState();

    if (widget.foods.isNotEmpty) {
      foods = widget.foods;
    } else {
      foods = _parseFoods(widget.result);
    }

    if (foods.isEmpty) {
      foods = [
        Food(
          name: "Unknown Food",
          shortMsg: "Unknown",
          calories: 100,
          grams: 100,
        ),
      ];
    }
  }

  /// ✅ SMART PARSER (FIXED)
  List<Food> _parseFoods(String result) {
    List<Food> parsed = [];

    String foodName = "Unknown Food";
    double calories = 100;

    final lines = result.split('\n');

    for (var line in lines) {
      line = line.trim().toLowerCase();

      if (line.startsWith("food:")) {
        foodName = line.replaceFirst("food:", "").trim();
      }

      if (line.startsWith("calories:")) {
        final kcalText = line
            .replaceFirst("calories:", "")
            .replaceAll("kcal", "")
            .trim();

        calories = double.tryParse(kcalText) ?? 100;
      }
    }

    parsed.add(
      Food(name: foodName, shortMsg: foodName, calories: calories, grams: 100),
    );

    return parsed;
  }

  /// CALCULATIONS
  double _calcCalories(Food f) {
    return ((f.calories ?? 0) / 100) * (f.grams ?? 100);
  }

  double _totalCalories() {
    return foods.fold(0, (sum, f) => sum + _calcCalories(f));
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Food Detected",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      widget.image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// TOTAL KCAL
                  Text(
                    "${_totalCalories().toStringAsFixed(0)} kcal",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// FOOD LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: foods.length,
                itemBuilder: (_, i) => _foodCard(foods[i], i),
              ),
            ),

            /// ADD FOOD BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.greenAccent),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final newFood = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFoodScreen()),
                  );

                  if (newFood != null) {
                    setState(() => foods.add(newFood));
                  }
                },
                child: const Text(
                  "+ Add Missing Food",
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// SAVE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: _onSave,
                child: const Text(
                  "Save Meal",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ FOOD CARD (UPDATED UI + EDIT FLOW)
  Widget _foodCard(Food food, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          /// ICON
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: food.imagePath != null && food.imagePath!.isNotEmpty
                ? Image.file(
                    File(food.imagePath!),
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.greenAccent,
                    ),
                  ),
          ),

          const SizedBox(width: 10),

          /// NAME + GRAMS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${food.grams ?? 100} g",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),

          /// KCAL
          Text(
            "${_calcCalories(food).toStringAsFixed(0)} kcal",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// EDIT BUTTON 👉 GO TO MultiAdjustFoodScreen
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedFoods = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiAdjustFoodScreen(foods: foods),
                ),
              );

              if (updatedFoods != null) {
                setState(() => foods = updatedFoods);
              }
            },
          ),

          /// DELETE
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() => foods.removeAt(index));
            },
          ),
        ],
      ),
    );
  }

  /// SAVE
  void _onSave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          image: widget.image,
          result: widget.result,
          food: foods.first,
        ),
      ),
    );
  }
}
