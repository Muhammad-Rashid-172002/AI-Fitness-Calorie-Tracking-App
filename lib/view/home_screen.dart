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
    if (remaining > 200) return "Under Calories";
    if (remaining >= -200 && remaining <= 200) return "Balanced";
    return "Excess Calories";
  }

  Color getEnergyColor(int remaining) {
    if (remaining > 200) return Colors.orange;
    if (remaining >= -200 && remaining <= 200) return Colors.greenAccent;
    return Colors.redAccent;
  }

  String nextMealSuggestion() {
    int remainingCalories = dailyGoalCalories;
    int remainingProtein = proteinGoal - todayProtein;

    if (remainingCalories <= 150) {
      return "You are close to your calorie limit.\nChoose light foods like salad, cucumber, or soup.";
    }

    if (remainingProtein >= 20) {
      return "Your protein intake is low.\nTry foods like eggs, grilled chicken, greek yogurt, or lentils.";
    }

    if (todayFat > fatGoal) {
      return "Fat intake is high today.\nChoose grilled or steamed food like vegetables, boiled rice, or chicken breast.";
    }

    if (remainingCalories > 400) {
      return "You still have enough calories left.\nA balanced meal like rice, chicken, and vegetables would be good.";
    }

    return "Great balance today.\nKeep eating clean meals and stay hydrated.";
  }

  List<DateTime> getCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // Monday = 1

    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  Widget _calendarStrip() {
    final weekDays = getCurrentWeek();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          bool isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? primary : cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date), // Mon, Tue
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d').format(date), // 20
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

            /// ✅ NEW FLAG
            bool hasLoggedMeals = false;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              calories = (data['totalCalories'] ?? 0).toInt();
              todayProtein = (data['totalProtein'] ?? 0).toInt();
              todayCarbs = (data['totalCarbs'] ?? 0).toInt();
              todayFat = (data['totalFat'] ?? 0).toInt();

              /// ✅ CHECK
              hasLoggedMeals = calories > 0;
            }

            int remaining = dailyGoalCalories - calories;
            String energyStatus = getEnergyStatus(remaining);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// DATE
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

                  const SizedBox(height: 10),

                  /// CALENDAR STRIP
                  _calendarStrip(),

                  const SizedBox(height: 25),

                  /// ENERGY
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/energy.png", height: 120),
                        const SizedBox(height: 10),
                        const Text(
                          "Energy Status",
                          style: TextStyle(color: Colors.white70),
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

                  /// CALORIES CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
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

                  /// MACROS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _macroCircle("Protein", todayProtein, proteinGoal),
                      _macroCircle("Carbs", todayCarbs, carbsGoal),
                      _macroCircle("Fat", todayFat, fatGoal),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// ✅ CLIENT FIX
                  if (hasLoggedMeals)
                    _suggestionCard(nextMealSuggestion())
                  else
                    _emptyCard(),

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

                  /// BUTTON
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
                        if (result != null) setState(() {});
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

  /// SUGGESTION CARD
  Widget _suggestionCard(String text) {
    return Container(
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  /// EMPTY STATE
  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Log your first meal to get personalized suggestions 🍽️",
        style: TextStyle(color: Colors.white70),
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
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
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
                Text("$percent%", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$value g",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Goal $goal g",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
