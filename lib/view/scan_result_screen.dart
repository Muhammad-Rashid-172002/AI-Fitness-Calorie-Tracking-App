import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';

class ScanResultScreen extends StatefulWidget {
  final File image;
  final String result;
  final Food food;

  const ScanResultScreen({
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

  late Food parsedFood;

  @override
  void initState() {
    super.initState();
    parsedFood = controller.parseFoodFromResult(widget.result);
  }

  /// ---------------- MACRO CALCULATION ----------------

  double get proteinKcal => (parsedFood.protein ?? 0) * 4;
  double get carbsKcal => (parsedFood.carbs ?? 0) * 4;
  double get fatKcal => (parsedFood.fats ?? 0) * 9;

  double get totalKcal => proteinKcal + carbsKcal + fatKcal;

  double percent(double kcal) {
    if (totalKcal == 0) return 0;
    return kcal / totalKcal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔥 TOP IMAGE
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  widget.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 🔥 MAIN CARD
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP STATS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _topStat("Calories",
                            "${parsedFood.calories ?? 0} kcal"),
                        _topStat(
                            "Protein", "${parsedFood.protein ?? 0} g"),
                        _topStat(
                            "Carbs", "${parsedFood.carbs ?? 0} g"),
                        _topStat("Fat", "${parsedFood.fats ?? 0} g"),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// 🔥 MACRO CIRCLES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _circle(percent(proteinKcal), "Protein"),
                        _circle(percent(carbsKcal), "Carbs"),
                        _circle(percent(fatKcal), "Fat"),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// 🔥 FEEDBACK
                    _feedbackBox(),
                  ],
                ),
              ),
            ),

            /// 🔥 SAVE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  setState(() => isSaving = true);

                  await controller.saveScan(
                    result: widget.result,
                    food: parsedFood,
                  );

                  showCustomSnackBar(
                      context, "Saved Successfully ✅", true);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MainView()),
                  );
                },
                child: isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.black)
                    : const Text(
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

  /// ---------------- UI COMPONENTS ----------------

  Widget _topStat(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _circle(double percent, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 75,
              width: 75,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 7,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(
                    Colors.greenAccent),
              ),
            ),
            Text(
              "${(percent * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _feedbackBox() {
    List<String> feedback = [];

    /// RULES (matching your design)
    if ((parsedFood.protein ?? 0) >= 20) {
      feedback.add("Protein intake is good for this meal");
    }

    if ((parsedFood.calories ?? 0) > 500) {
      feedback.add("This meal is slightly high in calories");
    }

    if ((parsedFood.carbs ?? 0) > 50 &&
        (parsedFood.fats ?? 0) > 20) {
      feedback.add("Consider balancing your macros");
    }

    if (feedback.isEmpty) {
      feedback.add("Well balanced meal 👍");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "MyDiet Feedback",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        ...feedback.take(3).map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}