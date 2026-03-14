import 'package:fitmind_ai/models/FormulaRecommendation.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isLoading = true;
  bool isStartingJourney = false;
  Map<String, dynamic>? formulaResult;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveFormula();
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
      final gender = data["gender"] ?? "Male";
      final age = data["age"] ?? 25;
      final height = (data["height"] ?? 170).toDouble();
      final weight = (data["weight"] ?? 70).toDouble();
      final targetWeight = data["targetWeight"] != null
          ? (data["targetWeight"] as num).toDouble()
          : weight;
      final activityLevel = data["activityLevel"] ?? "Moderately Active";
      final goal = data["goal"] ?? "Maintain Weight";

      final formula = FormulaRecommendation(
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        targetWeight: targetWeight,
        activityLevel: activityLevel,
        goal: goal,
      );

      final result = formula.calculate();

      // Save results to Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "dailyCalories": result["dailyCalories"],
        "proteinTarget": result["protein"],
        "carbsTarget": result["carbs"],
        "fatTarget": result["fat"],
        "targetWeight": result["targetWeight"],
        "estimatedWeeks": result["estimatedWeeks"],
        "formulaCalculated": true,
      });

      setState(() {
        formulaResult = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error calculating formula: $e");
      setState(() => isLoading = false);
    }
  }

  /// Start Journey Button Handler with loading
  Future<void> _startJourney() async {
    setState(() => isStartingJourney = true);

    // Simulate small delay for loading effect
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => isStartingJourney = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainView()),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    /// DAILY TARGET
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: primary),
                        const SizedBox(width: 8),
                        Text(
                          "DAILY TARGET",
                          style: TextStyle(
                            color: primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// Title
                    Text(
                      "Nutrition Plan",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Optimized for your weight path.",
                      style: TextStyle(color: textGrey, fontSize: 15),
                    ),

                    const SizedBox(height: 30),

                    /// Calories Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.25),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "DAILY CALORIES",
                            style: TextStyle(color: textGrey, letterSpacing: 2),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "${formulaResult?["dailyCalories"] ?? 0}",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: textMain,
                            ),
                          ),

                          Text(
                            "KCAL / DAY",
                            style: TextStyle(
                              color: primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Macros Circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _macroCircle("Protein", formulaResult?["protein"] ?? 0),

                        _macroCircle("Carbs", formulaResult?["carbs"] ?? 0),

                        _macroCircle("Fats", formulaResult?["fat"] ?? 0),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// Timeline Card (ADDED BACK)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Estimated Time To Reach Your Goal",
                            style: TextStyle(color: textGrey, fontSize: 14),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "${formulaResult?["estimatedWeeks"] ?? 0} Weeks to reach ${formulaResult?["targetWeight"] ?? 0} kg",
                            style: TextStyle(
                              color: primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// Start Journey Button
                   CustomGradientButton(text: "Start Journey", onPressed: _startJourney),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
  // Widget _buildMacroCard(String title, String value, IconData icon) {
  //   return Container(
  //     padding: const EdgeInsets.all(18),
  //     margin: const EdgeInsets.only(bottom: 12),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1E293B),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.2),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: primary.withOpacity(0.15),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(icon, color: primary, size: 22),
  //         ),
  //         const SizedBox(width: 15),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(title, style: TextStyle(color: textGrey, fontSize: 14)),
  //               const SizedBox(height: 4),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   color: textMain,
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _macroCircle(String title, int value) {
    return Column(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary, width: 6),
          ),
          child: Center(
            child: Text(
              "$value\nG",
              textAlign: TextAlign.center,
              style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(title, style: TextStyle(color: textGrey)),
      ],
    );
  }
}
