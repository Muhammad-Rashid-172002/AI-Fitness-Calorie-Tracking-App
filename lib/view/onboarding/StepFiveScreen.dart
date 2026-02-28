import 'package:fitmind_ai/models/FormulaRecommendation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';

class StepFiveScreen extends StatefulWidget {
  const StepFiveScreen({super.key});

  @override
  State<StepFiveScreen> createState() => _StepFiveScreenState();
}

class _StepFiveScreenState extends State<StepFiveScreen> {
  bool isLoading = true;
  Map<String, dynamic>? formulaResult;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveFormula();
  }

  Future<void> _calculateAndSaveFormula() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1️⃣ Load user profile info from Firestore
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
    final activityLevel = data["activityLevel"] ?? "Moderately Active";
    final goal = data["goal"] ?? "Maintain Weight";

    // 2️⃣ Calculate formula
    final formula = FormulaRecommendation(
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      activityLevel: activityLevel,
      goal: goal,
    );

    final result = formula.calculate();

    // 3️⃣ Save formula to Firestore
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "dailyCalories": result["dailyCalories"],
      "proteinTarget": result["protein"],
      "carbsTarget": result["carbs"],
      "fatTarget": result["fat"],
      "formulaCalculated": true,
    });

    setState(() {
      formulaResult = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    /// 🔥 Title
                    Text(
                      "You're All Set! 🎉",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Here are your personalized daily targets",
                      style: TextStyle(color: textGrey, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 35),

                    /// 🎯 Big Calories Circle
                    Container(
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [primary, accent]),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formulaResult!["dailyCalories"].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "kcal / day",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// 📊 Macros Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroCard(
                            "Protein",
                            formulaResult!["protein"].toString() + " g",
                            Icons.fitness_center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            "Carbs",
                            formulaResult!["carbs"].toString() + " g",
                            Icons.rice_bowl,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildMacroCard(
                      "Fat",
                      formulaResult!["fat"].toString() + " g",
                      Icons.opacity,
                    ),

                    const SizedBox(height: 45),

                    /// 🚀 Finish Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainView()),
                          );
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [primary, accent]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Start My Journey 🚀",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMacroCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textGrey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
