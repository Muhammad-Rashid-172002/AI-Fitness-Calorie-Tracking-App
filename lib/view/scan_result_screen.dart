import 'dart:io';
import 'dart:ui';

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

String get foodName {
  final name = (parsedFood.name ?? "").trim();

  if (name.isEmpty ||
      name.toLowerCase() == "unknown" ||
      name.toLowerCase() == "food item" ||
      name.toLowerCase().contains("not food")) {
    return "This is not food";
  }

  return name;
}

  int get calories => (parsedFood.calories ?? 0).toInt();
  int get protein => (parsedFood.protein ?? 0).toInt();
  int get carbs => (parsedFood.carbs ?? 0).toInt();
  int get fat => (parsedFood.fats ?? 0).toInt();

  bool get isFoodDetected {
    final resultText = widget.result.toLowerCase();

    final noFoodKeywords = [
      "not food",
      "no food",
      "unable to detect food",
      "not a food item",
      "non-food",
      "cannot identify food",
      "not edible",
    ];

    final hasNoFoodText = noFoodKeywords.any(resultText.contains);

    final hasName = foodName != "No food detected";
    final hasNutrition = calories > 0 || protein > 0 || carbs > 0 || fat > 0;

    return !hasNoFoodText && hasName && hasNutrition;
  }

  double get healthScore {
    if (!isFoodDetected) return 0;

    double score = 5;

    if (calories <= 350) score += 1.5;
    if (calories > 700) score -= 2;

    if (protein >= 20) score += 2;
    if (protein < 8) score -= 1;

    if (fat <= 12) score += 1;
    if (fat > 25) score -= 1.5;

    if (carbs <= 45) score += 1;
    if (carbs > 80) score -= 1;

    return score.clamp(1, 10);
  }

 String get feedbackText {
  if (!isFoodDetected) {
    return "This image is not recognized as food. Please try again with a clear meal or drink photo.";
  }

  if (calories > 750) {
    return "This meal is high in calories. Balance it with lighter meals, vegetables, and water for the rest of the day.";
  }

  if (protein >= 20 && fat <= 12) {
    return "Great choice! This meal has good protein and controlled fat, which can support muscle recovery and healthy weight management.";
  }

  if (protein < 10) {
    return "This meal looks low in protein. Add eggs, chicken, fish, lentils, yogurt, or tofu to make it more balanced.";
  }

  if (carbs > 75) {
    return "This meal is carb-heavy. Try pairing it with protein and fiber to keep your energy more stable.";
  }

  return "This looks like a balanced meal. Keep tracking consistently to improve your nutrition habits.";
}  Future<void> _saveMeal() async {
    if (isSaving) return;

    if (!isFoodDetected) {
      showCustomSnackBar(
        context,
        "Please scan a food item before saving.",
        false,
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await controller.saveScan(
        result: widget.result,
        food: parsedFood,
      );

      if (!mounted) return;

      showCustomSnackBar(context, "Meal saved successfully ✅", true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainView()),
      );
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, "Failed to save meal. Try again.", false);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -90,
            child: _glowCircle(
              color: (isFoodDetected
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444))
                  .withOpacity(0.13),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.11),
              size: 300,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _iconBox(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      _smallBadge(
                        isFoodDetected
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        isFoodDetected ? "Food Detected" : "Not Food",
                        color: isFoodDetected
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _heroImageCard(),

                  const SizedBox(height: 26),

                  if (!isFoodDetected) ...[
                    _notFoodCard(),
                    const SizedBox(height: 22),
                  ] else ...[
                    _sectionTitle(
                      title: "Nutrition Breakdown",
                      subtitle: "Estimated values from your meal image",
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: [
                        _macroCard(
                          title: "Calories",
                          value: "$calories",
                          unit: "kcal",
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF97316),
                        ),
                        _macroCard(
                          title: "Protein",
                          value: "$protein",
                          unit: "g",
                          icon: Icons.fitness_center_rounded,
                          color: const Color(0xFF22C55E),
                        ),
                        _macroCard(
                          title: "Carbs",
                          value: "$carbs",
                          unit: "g",
                          icon: Icons.grain_rounded,
                          color: const Color(0xFF06B6D4),
                        ),
                        _macroCard(
                          title: "Fat",
                          value: "$fat",
                          unit: "g",
                          icon: Icons.opacity_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _healthScoreCard(),
                    const SizedBox(height: 22),
                  ],

                  _feedbackCard(),

                  const SizedBox(height: 30),

                  if (isFoodDetected)
                    GestureDetector(
                      onTap: _saveMeal,
                      child: Container(
                        height: 64,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF22C55E),
                              Color(0xFF06B6D4),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.30),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bookmark_added_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Save Meal",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                  if (isFoodDetected) const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 58,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.055),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isFoodDetected ? "Scan Another Food" : "Try Again",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroImageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
        boxShadow: [
          BoxShadow(
            color: (isFoodDetected
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444))
                .withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Image.file(
              widget.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.78),
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 18,
              left: 18,
              child: _smallBadge(
                isFoodDetected
                    ? Icons.auto_awesome_rounded
                    : Icons.image_not_supported_rounded,
                isFoodDetected ? "Detected" : "Not Food",
                color: isFoodDetected
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isFoodDetected
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444))
                                .withOpacity(0.18),
                          ),
                          child: Icon(
                            isFoodDetected
                                ? Icons.restaurant_menu_rounded
                                : Icons.warning_amber_rounded,
                            color: isFoodDetected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            foodName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              height: 1.15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _notFoodCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFFEF4444).withOpacity(0.08),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _roundIcon(Icons.no_food_rounded, const Color(0xFFEF4444)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This is not food",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "FitMind AI could not detect any food in this image. Please scan a clear food item like rice, chicken, fruit, snack, or drink.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}  Widget _macroCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _roundIcon(icon, color),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " $unit",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _roundIcon(
                Icons.health_and_safety_rounded,
                const Color(0xFF22C55E),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Health Score",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${healthScore.toStringAsFixed(0)}/10",
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: healthScore / 10,
              minHeight: 14,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF22C55E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isFoodDetected
              ? [
                  const Color(0xFF22C55E).withOpacity(0.12),
                  const Color(0xFF06B6D4).withOpacity(0.08),
                ]
              : [
                  const Color(0xFFEF4444).withOpacity(0.12),
                  const Color(0xFFF97316).withOpacity(0.08),
                ],
        ),
        border: Border.all(
          color: (isFoodDetected
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444))
              .withOpacity(0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _roundIcon(
            isFoodDetected
                ? Icons.lightbulb_rounded
                : Icons.info_outline_rounded,
            isFoodDetected
                ? const Color(0xFF22C55E)
                : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFoodDetected ? "AI Nutrition Insight" : "Scan Guidance",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feedbackText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.48),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roundIcon(IconData icon, Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.14),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _smallBadge(
    IconData icon,
    String text, {
    Color color = const Color(0xFF22C55E),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}