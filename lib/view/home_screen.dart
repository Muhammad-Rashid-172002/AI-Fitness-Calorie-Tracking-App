// Replace your HomeScreen with this updated premium UI.
// Water container is tappable and adds 0.25L on every tap.

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/ai_coach_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int dailyGoalCalories = 2200;
  int proteinGoal = 150;
  int carbsGoal = 300;
  int fatGoal = 75;

  DateTime selectedDate = DateTime.now();

  final AICoachController aiController = AICoachController();

  static const Color bgColor = Color(0xFF07101D);
  static const Color cardColor = Color(0xFF101D31);
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color orange = Color(0xFFF97316);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSub = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    loadUserGoals();
  }

  Stream<Map<String, dynamic>> weeklyStatsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("dailyLogs")
        .snapshots()
        .map((snapshot) {
          int completedDays = 0;
          int streak = 0;

          for (int i = 0; i < 7; i++) {
            final date = startOfWeek.add(Duration(days: i));
            final id = DateFormat('yyyy-MM-dd').format(date);

            final doc = snapshot.docs.where((e) => e.id == id).toList();

            if (doc.isNotEmpty) {
              final data = doc.first.data();

              final calories = ((data["totalCalories"] ?? 0) as num).toInt();
              final water = ((data["waterDrank"] ?? 0) as num).toDouble();

              if (calories >= dailyGoalCalories || water >= 8) {
                completedDays++;
              }
            }
          }

          for (int i = 0; i < 30; i++) {
            final date = now.subtract(Duration(days: i));
            final id = DateFormat('yyyy-MM-dd').format(date);

            final doc = snapshot.docs.where((e) => e.id == id).toList();

            if (doc.isEmpty) break;

            final data = doc.first.data();
            final calories = ((data["totalCalories"] ?? 0) as num).toInt();
            final water = ((data["waterDrank"] ?? 0) as num).toDouble();

            if (calories > 0 || water > 0) {
              streak++;
            } else {
              break;
            }
          }

          return {"completedDays": completedDays, "streak": streak};
        });
  }

  String getHealthStatus({
    required int calories,
    required int calorieGoal,
    required double water,
    required int protein,
    required int proteinGoal,
  }) {
    double calorieProgress = calories / calorieGoal;
    double proteinProgress = protein / proteinGoal;

    if (calorieProgress >= 0.9 && proteinProgress >= 0.8 && water >= 6) {
      return "Excellent!";
    }

    if (calorieProgress >= 0.7 && proteinProgress >= 0.6) {
      return "Great!";
    }

    if (calorieProgress >= 0.5) {
      return "Good!";
    }

    return "Needs Focus";
  }

  Future<void> loadUserGoals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!mounted || !doc.exists) return;

    final data = doc.data()!;

    setState(() {
      dailyGoalCalories = ((data["dailyCalories"] ?? 2200) as num).toInt();
      proteinGoal = ((data["proteinTarget"] ?? 150) as num).toInt();
      carbsGoal = ((data["carbsTarget"] ?? 300) as num).toInt();
      fatGoal = ((data["fatTarget"] ?? 75) as num).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            "User not logged in",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final todayId = DateFormat('yyyy-MM-dd').format(selectedDate);

    final dailyRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("dailyLogs")
        .doc(todayId);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;

                final userName = userData?["name"] ?? "User";

                return StreamBuilder<DocumentSnapshot>(
                  stream: dailyRef.snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() as Map<String, dynamic>?;

                    final calories = ((data?["totalCalories"] ?? 0) as num)
                        .toInt();
                    final todayProtein = ((data?["totalProtein"] ?? 0) as num)
                        .toInt();
                    final todayCarbs = ((data?["totalCarbs"] ?? 0) as num)
                        .toInt();
                    final todayFat = ((data?["totalFat"] ?? 0) as num).toInt();

                    final waterDrank = ((data?["waterDrank"] ?? 0) as num)
                        .toDouble();
                    final dailyWaterGoal =
                        ((data?["dailyWaterGoal"] ?? 8.0) as num).toDouble();

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(userName),
                          const SizedBox(height: 24),

                          _healthScoreCard(
                            calories: calories,
                            protein: todayProtein,
                            water: waterDrank,
                          ),
                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: _todayStatCard(
                                  icon: Icons.local_fire_department_rounded,
                                  color: orange,
                                  title: "Calories",
                                  value: "$calories",
                                  subtitle: "of $dailyGoalCalories kcal",
                                  progress: (calories / dailyGoalCalories)
                                      .clamp(0.0, 1.0),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _waterTodayCard(
                                  waterDrank: waterDrank,
                                  goal: dailyWaterGoal,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          _macrosTodayCard(
                            protein: todayProtein,
                            carbs: todayCarbs,
                            fat: todayFat,
                            proteinGoal: proteinGoal,
                            carbsGoal: carbsGoal,
                            fatGoal: fatGoal,
                          ),

                          const SizedBox(height: 22),

                          FutureBuilder<String>(
                            future: aiController.generateDailyTip(todayProtein),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _loadingTipCard();
                              }

                              final tip =
                                  snapshot.data ??
                                  "Add more protein and stay hydrated today for better energy and recovery.";

                              return _aiTipCard(tip);
                            },
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(child: _quickActionScan()),
                              const SizedBox(width: 14),
                              Expanded(child: _quickActionFitness()),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String userName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  color: textSub,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textMain,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Track your health goals today",
                style: TextStyle(
                  color: textSub,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [primaryLight, primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: bgColor,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _healthScoreCard({
    required int calories,
    required int protein,
    required double water,
  }) {
    final healthText = getHealthStatus(
      calories: calories,
      calorieGoal: dailyGoalCalories,
      water: water,
      protein: protein,
      proteinGoal: proteinGoal,
    );

    return StreamBuilder<Map<String, dynamic>>(
      stream: weeklyStatsStream(),
      builder: (context, snapshot) {
        final completedDays = snapshot.data?["completedDays"] ?? 0;
        final streak = snapshot.data?["streak"] ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              colors: [Color(0xFF4ADE80), Color(0xFF22C55E), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AI Health Score",
                style: TextStyle(
                  color: bgColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 26),

              Text(
                healthText,
                style: const TextStyle(
                  color: bgColor,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                healthText == "Excellent!"
                    ? "You're crushing your goals today 🔥"
                    : healthText == "Great!"
                    ? "Almost there, keep going 💪"
                    : healthText == "Good!"
                    ? "You're making progress 🚀"
                    : "Let's improve today's nutrition ✨",
                style: const TextStyle(
                  color: bgColor,
                  fontSize: 17,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _greenMiniBox("Daily Streak", "$streak days"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _greenMiniBox("This Week", "$completedDays/7 goals"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _greenMiniBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: bgColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: bgColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      height: 202,
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon, color),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: textMain,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: textSub,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _waterTodayCard({required double waterDrank, required double goal}) {
    final progress = goal == 0 ? 0.0 : (waterDrank / goal).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => addWater(0.25),
      child: Container(
        height: 202,
        padding: const EdgeInsets.all(20),
        decoration: _glassCard(glowColor: cyan),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconBox(Icons.water_drop_rounded, cyan),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "+ Tap",
                    style: TextStyle(
                      color: cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              waterDrank.toStringAsFixed(1),
              style: const TextStyle(
                color: textMain,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              "of ${goal.toStringAsFixed(0)} glasses",
              style: const TextStyle(
                color: textSub,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: const AlwaysStoppedAnimation(cyan),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macrosTodayCard({
    required int protein,
    required int carbs,
    required int fat,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _glassCard(radius: 32, glowColor: primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.pie_chart_rounded, primary, size: 54),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Macros Today",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Updated after every meal",
                      style: TextStyle(
                        color: textSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _macroCircle(
                  title: "Protein",
                  value: protein,
                  goal: proteinGoal,
                  color: primary,
                ),
              ),
              Expanded(
                child: _macroCircle(
                  title: "Carbs",
                  value: carbs,
                  goal: carbsGoal,
                  color: cyan,
                ),
              ),
              Expanded(
                child: _macroCircle(
                  title: "Fats",
                  value: fat,
                  goal: fatGoal,
                  color: orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroCircle({
    required String title,
    required int value,
    required int goal,
    required Color color,
  }) {
    final progress = goal == 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return SizedBox(
              height: 96,
              width: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 86,
                    width: 86,
                    child: CircularProgressIndicator(
                      value: animatedValue,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$percent%",
                        style: const TextStyle(
                          color: textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "$value/$goal g",
                        style: const TextStyle(
                          color: textSub,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: textMain,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "${goal - value <= 0 ? 0 : goal - value}g left",
          style: const TextStyle(
            color: textSub,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _aiTipCard(String tip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _glassCard(radius: 32, glowColor: primary),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(Icons.bolt_rounded, primary, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Tip of the Day",
                  style: TextStyle(
                    color: textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tip,
                  style: const TextStyle(
                    color: textSub,
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionScan() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [primaryLight, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.document_scanner_rounded, color: bgColor, size: 34),
          Spacer(),
          Text(
            "AI Scan",
            style: TextStyle(
              color: bgColor,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Scan food or skin",
            style: TextStyle(
              color: bgColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionFitness() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(22),
      decoration: _glassCard(radius: 28, glowColor: cyan),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fitness_center_rounded, color: cyan, size: 34),
          Spacer(),
          Text(
            "Fitness Plan",
            style: TextStyle(
              color: textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "View workout",
            style: TextStyle(
              color: textSub,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingTipCard() {
    return Container(
      height: 145,
      decoration: _glassCard(radius: 32),
      child: const Center(child: CircularProgressIndicator(color: primary)),
    );
  }

  BoxDecoration _glassCard({double radius = 30, Color glowColor = primary}) {
    return BoxDecoration(
      color: cardColor.withOpacity(0.86),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(0.10),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color, {double size = 50}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }

  Widget _backgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -100,
          child: _blurCircle(primary.withOpacity(0.18), 300),
        ),
        Positioned(
          top: 330,
          left: -150,
          child: _blurCircle(cyan.withOpacity(0.14), 310),
        ),
        Positioned(
          bottom: -120,
          right: -130,
          child: _blurCircle(primaryLight.withOpacity(0.10), 280),
        ),
      ],
    );
  }

  Widget _blurCircle(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Future<void> addWater(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dailyRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("dailyLogs")
        .doc(todayId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(dailyRef);
      final data = snapshot.data();

      final currentWater = ((data?["waterDrank"] ?? 0) as num).toDouble();
      final dailyWaterGoal = ((data?["dailyWaterGoal"] ?? 8.0) as num)
          .toDouble();

      transaction.set(dailyRef, {
        "waterDrank": currentWater + amount,
        "dailyWaterGoal": dailyWaterGoal,
        "updatedAt": Timestamp.now(),
        "createdAt": data?["createdAt"] ?? Timestamp.now(),
      }, SetOptions(merge: true));
    });
  }
}
