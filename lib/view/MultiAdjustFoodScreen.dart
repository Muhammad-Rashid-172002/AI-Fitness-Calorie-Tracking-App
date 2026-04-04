import 'dart:io';
import 'package:flutter/material.dart';
import '../models/food_model.dart';

enum Unit { grams, piece, cup }

class MultiAdjustFoodScreen extends StatefulWidget {
  final List<Food> foods;

  const MultiAdjustFoodScreen({super.key, required this.foods});

  @override
  State<MultiAdjustFoodScreen> createState() =>
      _MultiAdjustFoodScreenState();
}

class _MultiAdjustFoodScreenState extends State<MultiAdjustFoodScreen> {
  late List<Food> foods;
  late List<Unit> units;

  @override
  void initState() {
    super.initState();
    foods = List.from(widget.foods);
    units = List.generate(foods.length, (_) => Unit.grams);
  }

  /// ---------------- CALCULATIONS ----------------

  double calcCalories(Food f) {
    final carbs = ((f.carbs ?? 0) / 100) * (f.grams ?? 0);
    final protein = ((f.protein ?? 0) / 100) * (f.grams ?? 0);
    final fats = ((f.fats ?? 0) / 100) * (f.grams ?? 0);

    final macroCalories = (carbs * 4) + (protein * 4) + (fats * 9);

    /// Fallback if macros missing
    if (macroCalories == 0) {
      return ((f.calories ?? 0) / 100) * (f.grams ?? 0);
    }

    return macroCalories;
  }

  double totalCalories() {
    return foods.fold(0, (sum, f) => sum + calcCalories(f));
  }

  /// ---------------- UNIT ----------------

  double getFactor(Unit unit) {
    switch (unit) {
      case Unit.grams:
        return 1;
      case Unit.cup:
        return 150;
      case Unit.piece:
        return 120;
    }
  }

  double toGrams(double value, Unit unit) {
    return value * getFactor(unit);
  }

  double fromGrams(double grams, Unit unit) {
    return grams / getFactor(unit);
  }

  /// ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Adjust Food Portions",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// TOTAL CALORIES (LIVE 🔥)
                  Text(
                    "${totalCalories().toStringAsFixed(0)} kcal",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: foods.length,
                itemBuilder: (_, i) => _foodCard(i),
              ),
            ),

            /// SAVE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: () {
                  Navigator.pop(context, foods);
                },
                child: const Text(
                  "Save Changes",
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

  /// ---------------- FOOD CARD ----------------

  Widget _foodCard(int index) {
    final food = foods[index];
    final unit = units[index];

    /// LIMITS
    double min = unit == Unit.grams ? 10 : 0.1;
    double max = unit == Unit.grams ? 500 : 5;

    double displayValue =
        fromGrams(food.grams ?? 100, unit).clamp(min, max);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          /// TOP
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: food.imagePath != null
                    ? Image.file(
                        File(food.imagePath!),
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.fastfood,
                        color: Colors.greenAccent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  food.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    foods.removeAt(index);
                    units.removeAt(index);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// KCAL (LIVE 🔥)
          Text(
            "${calcCalories(food).toStringAsFixed(0)} kcal",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// BIG PORTION (CENTER FOCUS)
          Text(
            "${displayValue.toStringAsFixed(1)} ${_unitLabel(unit)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// SLIDER (SMOOTH 🔥)
          Slider(
            value: displayValue,
            min: min,
            max: max,
            activeColor: Colors.greenAccent,
            onChanged: (val) {
              setState(() {
                foods[index] = foods[index].copyWith(
                  grams: toGrams(val, unit),
                );
              });
            },
          ),

          /// UNIT SWITCH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: Unit.values.map((u) {
              return ChoiceChip(
                label: Text(_unitLabel(u)),
                selected: unit == u,
                onSelected: (_) {
                  setState(() {
                    units[index] = u;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          /// MACROS (LIVE 🔥)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macro("Carbs", food, (f) => f.carbs ?? 0),
              _macro("Protein", food, (f) => f.protein ?? 0),
              _macro("Fat", food, (f) => f.fats ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  String _unitLabel(Unit u) {
    switch (u) {
      case Unit.grams:
        return "g";
      case Unit.cup:
        return "cup";
      case Unit.piece:
        return "piece";
    }
  }

  Widget _macro(
      String title, Food food, double Function(Food) getter) {
    final grams = food.grams ?? 0;
    final per100 = getter(food);
    final value = (per100 / 100) * grams;

    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white54)),
        Text(
          "${value.toStringAsFixed(1)} g",
          style:
              const TextStyle(color: Colors.greenAccent),
        ),
      ],
    );
  }
}