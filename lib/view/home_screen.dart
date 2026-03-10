import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/ai_coach_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/view/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int todayProtein = 0;
  int todayCarbs = 0;
  int todayFat = 0;

  int dailyGoalCalories = 0;
  int proteinGoal = 0;
  int carbsGoal = 0;
  int fatGoal = 0;

  DateTime selectedDate = DateTime.now();

  final AICoachController aiController = AICoachController();

  @override
  void initState() {
    super.initState();
    loadUserGoals();
  }

  void loadUserGoals() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        dailyGoalCalories = (data["dailyCalories"] ?? 0).toInt();
        proteinGoal = (data["proteinTarget"] ?? 0).toInt();
        carbsGoal = (data["carbsTarget"] ?? 0).toInt();
        fatGoal = (data["fatTarget"] ?? 0).toInt();
      });
    }
  }

  String getEnergyStatus(int remaining) {

    if (remaining > 200) {
      return "Under Calories";
    } else if (remaining >= -200 && remaining <= 200) {
      return "Balanced";
    } else {
      return "Excess Calories";
    }
  }

  Color getEnergyColor(int remaining) {

    if (remaining > 200) {
      return Colors.orange;
    } else if (remaining >= -200 && remaining <= 200) {
      return Colors.greenAccent;
    } else {
      return Colors.redAccent;
    }
  }

  String nextMealSuggestion() {

    if (todayProtein < proteinGoal) {
      return "Protein intake is low.\nTry eggs, chicken breast, or greek yogurt.";
    }

    if (todayFat > fatGoal) {
      return "Fat intake is high.\nChoose grilled or steamed food.";
    }

    if (dailyGoalCalories < 0) {
      return "Calories are high.\nChoose vegetables or soup.";
    }

    return "Great balance today. Keep eating clean meals.";
  }

  @override
  Widget build(BuildContext context) {

    final today = DateFormat('yyyy-MM-dd').format(selectedDate);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection('dailyLogs')
              .doc(today)
              .snapshots(),
          builder: (context, snapshot) {

            int calories = 0;

            if (snapshot.hasData && snapshot.data!.exists) {

              final data = snapshot.data!.data() as Map<String, dynamic>;

              calories = (data['totalCalories'] ?? 0).toInt();

              todayProtein = (data['totalProtein'] ?? 0).toInt();
              todayCarbs = (data['totalCarbs'] ?? 0).toInt();
              todayFat = (data['totalFat'] ?? 0).toInt();
            }

            int remaining = dailyGoalCalories - calories;

            String energyStatus = getEnergyStatus(remaining);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// DATE SECTION
                  Text(
                    DateFormat("MMMM d").format(selectedDate),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),

                  Text(
                    DateFormat("EEEE").format(selectedDate),
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  /// WEEK CALENDAR
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {

                        DateTime weekDay =
                        DateTime.now()
                            .subtract(Duration(days: DateTime.now().weekday - 1))
                            .add(Duration(days: index));

                        bool isSelected =
                            DateFormat('yyyy-MM-dd').format(weekDay) ==
                                DateFormat('yyyy-MM-dd').format(selectedDate);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = weekDay;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? primary : cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text(
                                  DateFormat("E").format(weekDay),
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  DateFormat("d").format(weekDay),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ENERGY STATUS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [

                        Image.asset(
                          "assets/energy.png",
                          height: 120,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Energy Status",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          energyStatus,
                          style: TextStyle(
                            color: getEnergyColor(remaining),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// CALORIES REMAINING CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Calories Remaining",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "$remaining kcal",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Consumed: $calories kcal",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        Text(
                          "Goal: $dailyGoalCalories kcal",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// MACRO CIRCLES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      _macroCircle("Protein", todayProtein, proteinGoal),

                      _macroCircle("Carbs", todayCarbs, carbsGoal),

                      _macroCircle("Fat", todayFat, fatGoal),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// NEXT MEAL SUGGESTION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Next Meal Suggestion",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          nextMealSuggestion(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// AI FEEDBACK
                  FutureBuilder<String>(
                    future: aiController.generateDailyCoaching(todayProtein),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("MYDiet Feedback",
                                style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold)),

                            const SizedBox(height: 10),

                            Text(snapshot.data!,
                                style:
                                const TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// SCAN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: CustomGradientButton(
                      text: "Scan a Meal",
                      onPressed: () async {

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ScanScreen()),
                        );

                        if (result != null) {
                          setState(() {});
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// MACRO CIRCLE
  Widget _macroCircle(String title, int value, int goal) {

    double progress = goal == 0 ? 0 : (value / goal).clamp(0.0, 1.0);

    return Column(
      children: [

        SizedBox(
          height: 90,
          width: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [

              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(primary),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    "$value",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "/$goal g",
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(title, style: const TextStyle(color: Colors.white70))
      ],
    );
  }
}