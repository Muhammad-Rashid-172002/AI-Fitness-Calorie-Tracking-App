import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/ai_coach_controller.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
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

  int todayMeals = 0;
  int todayCalories = 0;

  int todayProtein = 0;
  int todayCarbs = 0;
  int todayFat = 0;

  int dailyGoalCalories = 0;
  int proteinGoal = 0;
  int carbsGoal = 0;
  int fatGoal = 0;

  final ScanController controller = ScanController();
  final AICoachController aiController = AICoachController();

  @override
  void initState() {
    super.initState();
    loadUserGoals();
  }

  /// =========================
  /// LOAD USER GOALS
  /// =========================
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

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Greeting
              Text(
                _getGreeting(),
                style: TextStyle(color: textGrey, fontSize: 18),
              ),

              const SizedBox(height: 5),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {

                  final name = snapshot.data?.get("name") ?? "User";

                  return Text(
                    name,
                    style: TextStyle(
                      color: textMain,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _todayProgressCard(),
                      const SizedBox(height: 20),
                      _scanButton(),
                      const SizedBox(height: 20),
                      _macroProgressCard(),
                      const SizedBox(height: 20),
                      _aiCoachPanel(),   // ✅ AI PANEL ADDED
                      const SizedBox(height: 20),
                      _dailyTipCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// TODAY PROGRESS
  /// =========================
  Widget _todayProgressCard() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection('dailyLogs')
          .doc(today)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _caloriesUI(0, 0);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        int totalCalories = (data['totalCalories'] ?? 0).toInt();
        int mealCount = (data['mealCount'] ?? 0).toInt();
        todayProtein = (data['totalProtein'] ?? 0).toInt();
        todayCarbs = (data['totalCarbs'] ?? 0).toInt();
        todayFat = (data['totalFat'] ?? 0).toInt();

        return _caloriesUI(totalCalories, mealCount);
      },
    );
  }

  Widget _caloriesUI(int consumed, int meals) {

    int remaining = dailyGoalCalories - consumed;

    double progress = dailyGoalCalories == 0
        ? 0
        : (consumed / dailyGoalCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: consumed > dailyGoalCalories
              ? [Colors.red, Colors.redAccent]
              : [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Today's Calories",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 10),

          Text(
            "$consumed / $dailyGoalCalories kcal",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            remaining >= 0
                ? "$remaining kcal remaining"
                : "Exceeded by ${remaining.abs()} kcal",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),

          const SizedBox(height: 10),

          Text(
            "$meals meals logged today",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// MACROS
  /// =========================
  Widget _macroProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Macros Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          _macroBar("Protein", todayProtein, proteinGoal),
          _macroBar("Carbs", todayCarbs, carbsGoal),
          _macroBar("Fat", todayFat, fatGoal),
        ],
      ),
    );
  }

  Widget _macroBar(String title, int current, int goal) {
    double progress = goal == 0 ? 0 : (current / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title  $current / $goal g",
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, minHeight: 6),
        ],
      ),
    );
  }

  /// =========================
  /// AI COACH PANEL
  /// =========================
 Widget _aiCoachPanel() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("dailyLogs")
        .doc(today)
        .snapshots(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "AI Coach is analyzing your progress...",
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      Map<String, dynamic>? data =
          snapshot.data!.data() as Map<String, dynamic>?;

      int protein = (data?['totalProtein'] ?? 0).toInt();

      return FutureBuilder<String>(
        future: aiController.generateDailyCoaching(protein),
        builder: (context, aiSnapshot) {

          if (!aiSnapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "AI Coach is thinking...",
                style: TextStyle(color: Colors.white),
              ),
            );
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
                  "Daily AI Coach",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  aiSnapshot.data!,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}  /// =========================
  /// SCAN BUTTON
  /// =========================
  Widget _scanButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: CustomGradientButton(
        text: 'Scan a Meal',
        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _dailyTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Add more greens to your meals",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Greeting
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return "Good Morning";
  if (hour < 17) return "Good Afternoon";
  return "Good Evening";
}
