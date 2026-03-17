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

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

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
    int remainingCalories = dailyGoalCalories;
    int remainingProtein = proteinGoal - todayProtein;

    // If calories almost finished
    if (remainingCalories <= 150) {
      return "You are close to your calorie limit.\nChoose light foods like salad, cucumber, or soup.";
    }

    // If protein is low
    if (remainingProtein >= 20) {
      return "Your protein intake is low.\nTry foods like eggs, grilled chicken, greek yogurt, or lentils.";
    }

    // If fat is high
    if (todayFat > fatGoal) {
      return "Fat intake is high today.\nChoose grilled or steamed food like vegetables, boiled rice, or chicken breast.";
    }

    // If calories still high but protein good
    if (remainingCalories > 400) {
      return "You still have enough calories left.\nA balanced meal like rice, chicken, and vegetables would be good.";
    }

    // Normal balanced message
    return "Great balance today.\nKeep eating clean meals and stay hydrated.";
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
                      fontWeight: FontWeight.bold,
                    ),
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
                        DateTime startOfWeek = DateTime.now().subtract(
                          Duration(days: DateTime.now().weekday - 1),
                        );

                        DateTime weekDay = startOfWeek.add(
                          Duration(days: index),
                        );

                        bool isToday =
                            DateFormat('yyyy-MM-dd').format(weekDay) ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());

                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isToday ? primary : cardColor,
                            borderRadius: BorderRadius.circular(14),

                            /// Optional glow for today
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: primary.withOpacity(0.5),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// Day Name
                              Text(
                                DateFormat("E").format(weekDay),
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// Date Number
                              Text(
                                DateFormat("d").format(weekDay),
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// ENERGY STATUS
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/energy.png", height: 120),

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
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                    width: double.infinity,
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
                            fontWeight: FontWeight.bold,
                          ),
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
                        return const Center(child: CircularProgressIndicator());
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
                            Text(
                              "MYDiet Feedback",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              snapshot.data!,
                              style: const TextStyle(color: Colors.white),
                            ),
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
                          MaterialPageRoute(builder: (_) => const ScanScreen()),
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
    int percent = (progress * 100).toInt();

    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// TITLE
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          /// PROGRESS RING
          SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(primary),
                ),

                /// PERCENT
                Text(
                  "$percent%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// VALUE
          Text(
            "$value g",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          /// GOAL
          Text(
            "Goal $goal g",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
