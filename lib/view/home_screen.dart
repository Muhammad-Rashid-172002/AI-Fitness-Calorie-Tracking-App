import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/ai_coach_controller.dart';
import 'package:fitmind_ai/resources/fire_animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int dailyGoalCalories = 0;
  int proteinGoal = 0;
  int carbsGoal = 0;
  int fatGoal = 0;

  DateTime selectedDate = DateTime.now();

  final AICoachController aiController = AICoachController();
  AnimationController? _animationController;

  static const Color bgColor = Color(0xFF0B1220);
  static const Color primary = Color(0xFF22C55E);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color orange = Color(0xFFF97316);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSub = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    loadUserGoals();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> loadUserGoals() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        dailyGoalCalories = ((data["dailyCalories"] ?? 0) as num).toInt();
        proteinGoal = ((data["proteinTarget"] ?? 0) as num).toInt();
        carbsGoal = ((data["carbsTarget"] ?? 0) as num).toInt();
        fatGoal = ((data["fatTarget"] ?? 0) as num).toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayId = DateFormat('yyyy-MM-dd').format(selectedDate);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final dailyRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("dailyLogs")
        .doc(todayId);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: dailyRef.snapshots(),
              builder: (context, snapshot) {
                final data =
                    snapshot.data?.data() as Map<String, dynamic>?;

                final calories =
                    ((data?["totalCalories"] ?? 0) as num).toInt();
                final todayProtein =
                    ((data?["totalProtein"] ?? 0) as num).toInt();
                final todayCarbs =
                    ((data?["totalCarbs"] ?? 0) as num).toInt();
                final todayFat =
                    ((data?["totalFat"] ?? 0) as num).toInt();

                final waterDrank =
                    ((data?["waterDrank"] ?? 0) as num).toDouble();
                final dailyWaterGoal =
                    ((data?["dailyWaterGoal"] ?? 4.0) as num).toDouble();

                final remaining = dailyGoalCalories - calories;

                final calorieProgress = dailyGoalCalories == 0
                    ? 0.0
                    : (calories / dailyGoalCalories).clamp(0.0, 1.0);

                final remainingWater =
                    (dailyWaterGoal - waterDrank).clamp(0.0, dailyWaterGoal);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 22),

                      _calorieHeroCard(
                        calories: calories,
                        goal: dailyGoalCalories,
                        remaining: remaining,
                        progress: calorieProgress,
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: _smallStatCard(
                              icon: Icons.local_fire_department_rounded,
                              title: "Consumed",
                              value: "$calories",
                              unit: "kcal",
                              color: orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _smallStatCard(
                              icon: Icons.flag_rounded,
                              title: "Daily Goal",
                              value: "$dailyGoalCalories",
                              unit: "kcal",
                              color: primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      _sectionTitle(
                        title: "Today's Macros",
                        subtitle: "Protein, carbs and fat progress",
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _macroCard(
                            title: "Protein",
                            value: todayProtein,
                            goal: proteinGoal,
                            icon: Icons.fitness_center_rounded,
                            color: primary,
                          ),
                          const SizedBox(width: 12),
                          _macroCard(
                            title: "Carbs",
                            value: todayCarbs,
                            goal: carbsGoal,
                            icon: Icons.rice_bowl_rounded,
                            color: cyan,
                          ),
                          const SizedBox(width: 12),
                          _macroCard(
                            title: "Fat",
                            value: todayFat,
                            goal: fatGoal,
                            icon: Icons.opacity_rounded,
                            color: orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      _waterCard(
                        waterDrank: waterDrank,
                        goal: dailyWaterGoal,
                        remaining: remainingWater,
                      ),

                      const SizedBox(height: 16),

                      _drinkWaterButton(),

                      const SizedBox(height: 26),

                      FutureBuilder<String>(
                        future: aiController.generateDailyTip(todayProtein),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingTipCard();
                          }

                          if (snapshot.hasError) {
                            final error =
                                snapshot.error.toString().toLowerCase();

                            if (error.contains("socketexception") ||
                                error.contains("failed host lookup") ||
                                error.contains("network") ||
                                error.contains("connection")) {
                              return _aiCoachCard(
                                "📡 No internet connection. Please check your Wi-Fi or mobile data to load AI nutrition coaching.",
                              );
                            }

                            return _aiCoachCard(
                              "⚠️ Unable to load AI coaching tips right now.",
                            );
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return _aiCoachCard(
                              "💪 Keep tracking your meals daily to receive smart nutrition coaching.",
                            );
                          }

                          return _aiCoachCard(snapshot.data!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  color: textMain,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                DateFormat('EEEE, dd MMM').format(DateTime.now()),
                style: const TextStyle(
                  color: textSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.95),
                cyan.withOpacity(0.95),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_graph_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _calorieHeroCard({
    required int calories,
    required int goal,
    required int remaining,
    required double progress,
  }) {
    final displayRemaining = remaining < 0 ? 0 : remaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF22C55E),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cyan.withOpacity(0.30),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -48,
            child: _softCircle(Colors.white.withOpacity(0.15), 160),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              Icons.restaurant_rounded,
              size: 96,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FirePulseIcon(),
              const SizedBox(height: 20),
              Text(
                "$displayRemaining",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                remaining < 0
                    ? "Calories limit exceeded"
                    : "Calories remaining today",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.88),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 15,
                  backgroundColor: Colors.white.withOpacity(0.20),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$calories / $goal kcal",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.86),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return _glassCard(
      child: Row(
        children: [
          _roundIcon(icon, color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          color: textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: " $unit",
                        style: const TextStyle(
                          color: textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 6,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textMain,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSub,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _macroCard({
    required String title,
    required int value,
    required int goal,
    required IconData icon,
    required Color color,
  }) {
    final progress = goal == 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.045),
          border: Border.all(color: Colors.white.withOpacity(0.075)),
        ),
        child: Column(
          children: [
            _roundIcon(icon, color, size: 42),
            const SizedBox(height: 10),
            Text(
              "$value g",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textMain,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: textSub,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "$goal g goal",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.38),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waterCard({
    required double waterDrank,
    required double goal,
    required double remaining,
  }) {
    final progress = goal == 0 ? 0.0 : (waterDrank / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.060),
            Colors.white.withOpacity(0.035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: cyan.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roundIcon(Icons.water_drop_rounded, cyan),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Water Intake",
                  style: TextStyle(
                    color: textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: cyan,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "${remaining.toStringAsFixed(1)}L",
            style: const TextStyle(
              color: textMain,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            "Remaining today",
            style: TextStyle(
              color: textSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(cyan),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${waterDrank.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} Liters",
            style: const TextStyle(
              color: textSub,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drinkWaterButton() {
    return GestureDetector(
      onTap: () => addWater(0.25),
      child: Container(
        height: 76,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF06B6D4),
              Color(0xFF0891B2),
              Color(0xFF22C55E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cyan.withOpacity(0.32),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Drink Water",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Tap to add 250ml hydration",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiCoachCard(String tip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roundIcon(Icons.auto_awesome_rounded, primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "AI Coach Tip",
                  style: TextStyle(
                    color: textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tip,
            style: TextStyle(
              color: Colors.white.withOpacity(0.74),
              fontSize: 14.5,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.050),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.075)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, Color color, {double size = 46}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.14),
      ),
      child: Icon(icon, color: color, size: size * 0.50),
    );
  }

  Widget _loadingTipCard() {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: primary),
      ),
    );
  }

  Widget _backgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -95,
          child: AnimatedBuilder(
            animation: _animationController ?? kAlwaysDismissedAnimation,
            builder: (_, __) {
              return _blurCircle(
                primary.withOpacity(
                  0.12 + ((_animationController?.value ?? 0) * 0.08),
                ),
                300,
              );
            },
          ),
        ),
        Positioned(
          top: 300,
          left: -130,
          child: _blurCircle(cyan.withOpacity(0.12), 300),
        ),
        Positioned(
          bottom: -120,
          right: -90,
          child: _blurCircle(const Color(0xFF6366F1).withOpacity(0.11), 270),
        ),
      ],
    );
  }

  Widget _blurCircle(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: _softCircle(color, size),
    );
  }

  Widget _softCircle(Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> addWater(double amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dailyRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("dailyLogs")
        .doc(todayId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(dailyRef);
      final data = snapshot.data();

      final currentWater = ((data?["waterDrank"] ?? 0) as num).toDouble();
      final dailyWaterGoal =
          ((data?["dailyWaterGoal"] ?? 4.0) as num).toDouble();

      transaction.set(dailyRef, {
        "waterDrank": currentWater + amount,
        "dailyWaterGoal": dailyWaterGoal,
        "updatedAt": Timestamp.now(),
        "createdAt": data?["createdAt"] ?? Timestamp.now(),
      }, SetOptions(merge: true));
    });
  }
}