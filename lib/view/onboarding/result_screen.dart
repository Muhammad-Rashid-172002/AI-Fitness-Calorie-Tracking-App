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

      final formula = FormulaRecommendation(
        gender: data["gender"] ?? "Male",
        age: data["age"] ?? 25,
        height: (data["height"] ?? 170).toDouble(),
        weight: (data["weight"] ?? 70).toDouble(),
        targetWeight: data["targetWeight"] != null
            ? (data["targetWeight"] as num).toDouble()
            : (data["weight"] ?? 70).toDouble(),
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

      setState(() {
        formulaResult = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _calculateEstimatedDate(int weeks) {
    final now = DateTime.now();
    final estimatedDate = now.add(Duration(days: weeks * 7));

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${estimatedDate.day} ${months[estimatedDate.month - 1]} ${estimatedDate.year}";
  }

  Future<void> _startJourney() async {
    setState(() => isStartingJourney = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => isStartingJourney = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),

                            /// HEADER
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.flash_on, color: primary),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "DAILY TARGET",
                                  style: TextStyle(
                                    color: primary,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Your Nutrition Plan",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Optimized for your Diet goal",
                              style: TextStyle(color: textGrey),
                            ),

                            const SizedBox(height: 30),

                            /// CALORIES CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primary, accent],
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Daily Calories",
                                      style: TextStyle(color: textGrey),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${formulaResult?["dailyCalories"] ?? 0}",
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "kcal / day",
                                      style: TextStyle(color: textGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 35),

                            /// MACROS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _macroCircle(
                                  "Carbs",
                                  formulaResult?["carbs"] ?? 0,
                                ),
                                _macroCircle(
                                  "Protein",
                                  formulaResult?["protein"] ?? 0,
                                ),
                                _macroCircle("Fat", formulaResult?["fat"] ?? 0),
                              ],
                            ),

                            const SizedBox(height: 35),

                            /// GOAL TIMELINE
                            Text(
                              "Your Goal Timeline",
                              style: TextStyle(
                                color: textMain,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: _timelineBox(
                                    "Target\nWeight",
                                    "${formulaResult?["targetWeight"] ?? 0} kg",
                                    Icons.flag,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _timelineBox(
                                    "Duration\nAchieve",
                                    "${formulaResult?["estimatedWeeks"] ?? 0} Weeks",
                                    Icons.schedule,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _timelineBox(
                                    "Estimated Date",
                                    _calculateEstimatedDate(
                                      formulaResult?["estimatedWeeks"] ?? 0,
                                    ),
                                    Icons.calendar_today,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            /// BUTTON
                            isStartingJourney
                                ? Container(
                                    height: 55,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primary, accent],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : CustomGradientButton(
                                    text: "Continue",
                                    onPressed: _startJourney,
                                  ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _timelineBox(String title, String value, IconData icon) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textMain,
              fontWeight: FontWeight.bold,
              fontSize: 13, // slightly smaller to fit
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroCircle(String title, int value) {
    return Column(
      children: [
        Container(
          height: 95,
          width: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary, width: 7),
          ),
          child: Center(
            child: Text(
              "$value g",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(color: textGrey, fontSize: 13)),
      ],
    );
  }
}
