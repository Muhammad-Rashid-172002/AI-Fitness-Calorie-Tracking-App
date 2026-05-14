import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/models/FormulaRecommendation.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
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

  AnimationController? _animationController;

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
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _calculateAndSaveFormula() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!userDoc.exists) return;

      final data = userDoc.data()!;

      final formula = FormulaRecommendation(
        gender: data["gender"] ?? "Male",
        age: data["age"] ?? 25,
        height: (data["height"] ?? 170).toDouble(),
        weight: (data["weight"] ?? 70).toDouble(),
        targetWeight:
            (data["targetWeight"] ?? data["weight"] ?? 70).toDouble(),
        activityLevel: data["activityLevel"] ?? "Moderately Active",
        goal: data["goal"] ?? "Maintain Weight",
      );

      final result = formula.calculate();

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
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
        formulaResult = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _startJourney() async {
    setState(() => isStartingJourney = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Stack(
              children: [
                /// BACKGROUND GLOW
                Positioned(
                  top: -120,
                  left: -100,
                  child: AnimatedBuilder(
                    animation:
                        _animationController ?? kAlwaysDismissedAnimation,
                    builder: (_, __) {
                      return Container(
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF22C55E).withOpacity(
                            0.08 +
                                ((_animationController?.value ?? 0.0) * 0.05),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: -140,
                  right: -100,
                  child: Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF06B6D4).withOpacity(0.08),
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        /// TOP TEXT
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "FITMIND AI PLAN",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Your Body Is Ready 🔥",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "AI generated nutrition & calorie targets based on your body profile and goals.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// MAIN CALORIES CARD
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF22C55E),
                                Color(0xFF06B6D4),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF22C55E,
                                ).withOpacity(0.25),
                                blurRadius: 35,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 12,
                                sigmaY: 12,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 34,
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orange,
                                        size: 34,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Text(
                                      "Daily Calories",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "${formulaResult?["dailyCalories"] ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 52,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "kcal / day",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.45),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// MACROS
                        Row(
                          children: [
                            _macroCard(
                              title: "Protein",
                              value:
                                  "${formulaResult?["protein"] ?? 0}g",
                              icon: Icons.fitness_center,
                              color: const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 14),
                            _macroCard(
                              title: "Carbs",
                              value: "${formulaResult?["carbs"] ?? 0}g",
                              icon: Icons.bakery_dining,
                              color: const Color(0xFF3B82F6),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            _macroCard(
                              title: "Fat",
                              value: "${formulaResult?["fat"] ?? 0}g",
                              icon: Icons.opacity,
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 14),
                            _macroCard(
                              title: "Timeline",
                              value:
                                  "${formulaResult?["estimatedWeeks"] ?? 0} Weeks",
                              icon: Icons.timelapse,
                              color: const Color(0xFFEC4899),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// TARGET CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: const Color(
                                    0xFF22C55E,
                                  ).withOpacity(0.15),
                                ),
                                child: const Icon(
                                  Icons.track_changes,
                                  color: Color(0xFF22C55E),
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Target Weight",
                                      style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${formulaResult?["targetWeight"] ?? 0} kg",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// BUTTON
                        isStartingJourney
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : CustomGradientButton(
                                text: "Start My Journey",
                                onPressed: _startJourney,
                              ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: color.withOpacity(0.12),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}