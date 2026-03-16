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

  String _calculateEstimatedDate(int weeks) {
    final now = DateTime.now();

    final estimatedDate = now.add(Duration(days: weeks * 7));

    return "${estimatedDate.day} "
        "${_monthName(estimatedDate.month)} "
        "${estimatedDate.year}";
  }

  String _monthName(int month) {
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
    return months[month - 1];
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

                    const SizedBox(height: 18),

                    /// Title
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
                      style: TextStyle(color: textGrey, fontSize: 15),
                    ),

                    const SizedBox(height: 30),

                    /// CALORIES CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(colors: [primary, accent]),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Daily Calories",
                              style: TextStyle(color: textGrey, fontSize: 16),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "${formulaResult?["dailyCalories"] ?? 0} KCAL / DAY",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
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
                        _macroCircle("Protein", formulaResult?["protein"] ?? 0),
                        _macroCircle("Carbs", formulaResult?["carbs"] ?? 0),
                        _macroCircle("Fats", formulaResult?["fat"] ?? 0),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// TIMELINE CARD
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _timelineBox(
                              "Target Weight",
                              "${formulaResult?["targetWeight"] ?? 0} kg",
                              Icons.gps_fixed,
                            ),

                            _timelineBox(
                              "Duration",
                              "${formulaResult?["estimatedWeeks"] ?? 0} Weeks",
                              Icons.access_time,
                            ),

                            _timelineBox(
                              "Estimated Date",
                              _calculateEstimatedDate(
                                formulaResult?["estimatedWeeks"] ?? 0,
                              ),
                              Icons.calendar_month,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

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
  }

  Widget _timelineBox(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(14),
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

          const SizedBox(height: 5),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _macroCircle(String title, int value) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary, width: 6),
          ),
          child: Center(
            child: Text(
              "$value g",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(title, style: TextStyle(color: textGrey, fontSize: 13)),
      ],
    );
  }
}
