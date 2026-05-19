import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/models/FormulaRecommendation.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool isStartingJourney = false;

  Map<String, dynamic>? formulaResult;
  Map<String, dynamic>? userData;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _calculateAndSaveFormula();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _calculateAndSaveFormula() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final data = userDoc.data() ?? {};

      final formula = FormulaRecommendation(
        gender: data["gender"] ?? "Male",
        age: (data["age"] ?? 25) as int,
        height: (data["height"] ?? 170).toDouble(),
        weight: (data["weight"] ?? 70).toDouble(),
        targetWeight: (data["targetWeight"] ?? data["weight"] ?? 70).toDouble(),
        activityLevel: data["activityLevel"] ?? "Moderately Active",
        goal: data["goal"] ?? "Maintain Weight",
      );

      final result = formula.calculate();

      await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "dailyCalories": result["dailyCalories"],
        "proteinTarget": result["protein"],
        "carbsTarget": result["carbs"],
        "fatTarget": result["fat"],
        "targetWeight": result["targetWeight"],
        "estimatedWeeks": result["estimatedWeeks"],
        "formulaCalculated": true,
      });

      if (!mounted) return;

      setState(() {
        userData = data;
        formulaResult = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _startJourney() async {
    if (isStartingJourney) return;

    setState(() => isStartingJourney = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainView()),
    );
  }

  double get currentWeight => (userData?["weight"] ?? 0).toDouble();

  double get targetWeight =>
      (formulaResult?["targetWeight"] ?? userData?["targetWeight"] ?? 0)
          .toDouble();

  bool get isGain => targetWeight > currentWeight;
  bool get isLose => targetWeight < currentWeight;

  double get changeKg => (targetWeight - currentWeight).abs();

  Color get mainColor {
    if (isGain) return const Color(0xFFF59E0B);
    if (isLose) return const Color(0xFF22C55E);
    return const Color(0xFF06B6D4);
  }

  IconData get goalIcon {
    if (isGain) return Icons.trending_up_rounded;
    if (isLose) return Icons.trending_down_rounded;
    return Icons.balance_rounded;
  }

  String get goalTitle {
    if (isGain) return "Weight Gain Plan";
    if (isLose) return "Weight Loss Plan";
    return "Maintain Plan";
  }

  String get goalSubtitle {
    if (isGain) {
      return "Your plan is designed to support healthy weight gain and muscle growth.";
    }
    if (isLose) {
      return "Your plan is designed to support healthy fat loss and calorie control.";
    }
    return "Your plan is designed to maintain your current weight with balanced nutrition.";
  }

  @override
  Widget build(BuildContext context) {
    final calories = formulaResult?["dailyCalories"] ?? 0;
    final protein = formulaResult?["protein"] ?? 0;
    final carbs = formulaResult?["carbs"] ?? 0;
    final fat = formulaResult?["fat"] ?? 0;
    final weeks = formulaResult?["estimatedWeeks"] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            )
          : Stack(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, __) {
                    return Positioned(
                      top: -120 + (_animationController.value * 35),
                      right: -90,
                      child: _glowCircle(
                        color: mainColor.withOpacity(0.14),
                        size: 290,
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, __) {
                    return Positioned(
                      bottom: -150,
                      left: -110 + (_animationController.value * 45),
                      child: _glowCircle(
                        color: const Color(0xFF06B6D4).withOpacity(0.11),
                        size: 320,
                      ),
                    );
                  },
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
                            _iconBox(Icons.auto_awesome_rounded),
                            const Spacer(),
                            _badge(goalTitle, goalIcon, mainColor),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Your AI Plan\nIs Ready",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          goalSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.58),
                            fontSize: 14.5,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 26),

                        _calorieHeroCard(calories),

                        const SizedBox(height: 22),

                        _summaryCard(weeks),

                        const SizedBox(height: 26),

                        _sectionTitle(
                          title: "Daily Macro Targets",
                          subtitle: "Your personalized nutrition breakdown",
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            _macroCard(
                              title: "Protein",
                              value: "${protein}g",
                              icon: Icons.fitness_center_rounded,
                              color: const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 12),
                            _macroCard(
                              title: "Carbs",
                              value: "${carbs}g",
                              icon: Icons.rice_bowl_rounded,
                              color: const Color(0xFF06B6D4),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _macroCard(
                              title: "Fat",
                              value: "${fat}g",
                              icon: Icons.opacity_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 12),
                            _macroCard(
                              title: "Timeline",
                              value: "$weeks wk",
                              icon: Icons.calendar_month_rounded,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        _targetCard(),

                        const SizedBox(height: 30),

                        GestureDetector(
                          onTap: isStartingJourney ? null : _startJourney,
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
                                  color: const Color(0xFF06B6D4)
                                      .withOpacity(0.32),
                                  blurRadius: 26,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isStartingJourney
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Start My Journey",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _calorieHeroCard(dynamic calories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            mainColor,
            const Color(0xFF06B6D4),
            const Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.30),
            blurRadius: 34,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -45,
            child: _glowCircle(
              color: Colors.white.withOpacity(0.14),
              size: 150,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "$calories",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "daily calories / kcal",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(dynamic weeks) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              _summaryItem(
                "Current",
                "${currentWeight.toStringAsFixed(1)}kg",
                Icons.monitor_weight_rounded,
                const Color(0xFF06B6D4),
              ),
              _divider(),
              _summaryItem(
                isGain ? "Gain" : isLose ? "Lose" : "Change",
                "${changeKg.toStringAsFixed(1)}kg",
                goalIcon,
                mainColor,
              ),
              _divider(),
              _summaryItem(
                "Time",
                "$weeks wk",
                Icons.timelapse_rounded,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: mainColor.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor.withOpacity(0.14),
            ),
            child: Icon(Icons.flag_rounded, color: mainColor, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Target Weight",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${targetWeight.toStringAsFixed(1)} kg",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(goalIcon, color: mainColor),
        ],
      ),
    );
  }

  Widget _macroCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _roundIcon(icon, color),
            const SizedBox(height: 16),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 11,
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
          decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
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

  Widget _divider() {
    return Container(
      height: 46,
      width: 1,
      color: Colors.white.withOpacity(0.10),
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

  Widget _badge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
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
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}