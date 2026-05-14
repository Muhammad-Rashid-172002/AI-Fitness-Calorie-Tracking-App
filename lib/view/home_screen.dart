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
  int todayProtein = 0;
  int todayCarbs = 0;
  int todayFat = 0;

  int dailyGoalCalories = 0;
  int proteinGoal = 0;
  int carbsGoal = 0;
  int fatGoal = 0;

  DateTime selectedDate = DateTime.now();

  final AICoachController aiController = AICoachController();
  AnimationController? _animationController;

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

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(selectedDate);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -100,
            child: AnimatedBuilder(
              animation: _animationController ?? kAlwaysDismissedAnimation,
              builder: (_, __) {
                return _glowCircle(
                  color: const Color(0xFF22C55E).withOpacity(
                    0.07 + ((_animationController?.value ?? 0) * 0.05),
                  ),
                  size: 290,
                );
              },
            ),
          ),

          Positioned(
            bottom: -130,
            left: -100,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.09),
              size: 280,
            ),
          ),

          SafeArea(
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

                final remaining = dailyGoalCalories - calories;

                final progress = dailyGoalCalories == 0
                    ? 0.0
                    : (calories / dailyGoalCalories).clamp(0.0, 1.0);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),

                      const SizedBox(height: 24),

                      _calorieHeroCard(
                        calories: calories,
                        goal: dailyGoalCalories,
                        remaining: remaining,
                        progress: progress,
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle(
                        title: "Today's Macros",
                        subtitle: "Your daily nutrition breakdown",
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _macroCard(
                            title: "Protein",
                            value: todayProtein,
                            goal: proteinGoal,
                            icon: Icons.fitness_center_rounded,
                            color: const Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 12),
                          _macroCard(
                            title: "Carbs",
                            value: todayCarbs,
                            goal: carbsGoal,
                            icon: Icons.grain_rounded,
                            color: const Color(0xFF06B6D4),
                          ),
                          const SizedBox(width: 12),
                          _macroCard(
                            title: "Fat",
                            value: todayFat,
                            goal: fatGoal,
                            icon: Icons.opacity_rounded,
                            color: const Color(0xFFF97316),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return _loadingCard();
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;

                          final waterDrank = (data?["waterDrank"] ?? 0)
                              .toDouble();
                          final dailyWaterGoal = (data?["dailyWaterGoal"] ?? 4)
                              .toDouble();

                          final remainingWater = (dailyWaterGoal - waterDrank)
                              .clamp(0.0, dailyWaterGoal);

                          return Column(
                            children: [
                              _waterCard(
                                waterDrank,
                                dailyWaterGoal,
                                remainingWater,
                              ),

                              const SizedBox(height: 18),

                              GestureDetector(
                                onTap: () => addWater(0.25),

                                child: Container(
                                  height: 78,
                                  width: double.infinity,

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),

                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF06B6D4),
                                        Color(0xFF0891B2),
                                        Color(0xFF22C55E),
                                      ],
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF06B6D4,
                                        ).withOpacity(0.35),
                                        blurRadius: 28,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),

                                  child: Row(
                                    children: [
                                      /// LEFT ICON
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

                                      const SizedBox(width: 16),

                                      /// TEXT
                                      const Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Drink Water",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
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

                                      /// RIGHT ARROW
                                      Container(
                                        height: 42,
                                        width: 42,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.18),
                                        ),

                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      FutureBuilder<String>(
                        future: aiController.generateDailyTip(todayProtein),
                        builder: (context, snapshot) {
                          /// LOADING
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingTipCard();
                          }

                          /// INTERNET / FIREBASE ERROR
                          if (snapshot.hasError) {
                            final error = snapshot.error
                                .toString()
                                .toLowerCase();

                            /// NO INTERNET
                            if (error.contains("socketexception") ||
                                error.contains("failed host lookup") ||
                                error.contains("network") ||
                                error.contains("connection")) {
                              return _aiCoachCard(
                                "📡 No internet connection. Please check your Wi-Fi or mobile data to load AI nutrition coaching.",
                              );
                            }

                            /// OTHER ERROR
                            return _aiCoachCard(
                              "⚠️ Unable to load AI coaching tips right now.",
                            );
                          }

                          /// EMPTY
                          if (!snapshot.hasData || snapshot.data == null) {
                            return _aiCoachCard(
                              "💪 Keep tracking your meals daily to receive smart nutrition coaching.",
                            );
                          }

                          /// SUCCESS
                          return _aiCoachCard(snapshot.data!);
                        },
                      ),

                      const SizedBox(height: 35),
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
                "Welcome Back 👋",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, dd MMM').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withOpacity(0.28),
                blurRadius: 35,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -45,
                top: -45,
                child: _glowCircle(
                  color: Colors.white.withOpacity(0.16),
                  size: 160,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 42,
                  ),

                  const SizedBox(height: 22),

                  Text(
                    "$remaining",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 66,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Calories remaining today",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.86),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 22),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 15,
                      backgroundColor: Colors.white.withOpacity(0.18),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle({required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.48),
                  fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.045),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              "$value g",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                fontSize: 11,
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
            const SizedBox(height: 6),
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

  Widget _waterCard(double waterDrank, double goal, double remaining) {
    final progress = goal == 0 ? 0.0 : (waterDrank / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roundIcon(Icons.water_drop_rounded, const Color(0xFF06B6D4)),
              const SizedBox(width: 12),
              const Text(
                "Water Intake",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            "${remaining.toStringAsFixed(1)}L",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Remaining today",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF06B6D4)),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "${waterDrank.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} Liters",
            style: TextStyle(
              color: Colors.white.withOpacity(0.52),
              fontSize: 12,
            ),
          ),
        ],
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
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roundIcon(Icons.auto_awesome_rounded, const Color(0xFF22C55E)),
              const SizedBox(width: 12),
              const Text(
                "AI Coach Tip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tip,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14.5,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.14),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF22C55E)),
      ),
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
        child: CircularProgressIndicator(color: Color(0xFF22C55E)),
      ),
    );
  }

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Future<void> addWater(double amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final docRef = FirebaseFirestore.instance.collection("users").doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();

      double currentWater = 0.0;

      if (data != null && data.containsKey("waterDrank")) {
        currentWater = (data["waterDrank"] ?? 0).toDouble();
      }

      transaction.set(docRef, {
        "waterDrank": currentWater + amount,
        "dailyWaterGoal": 4.0,
      }, SetOptions(merge: true));
    });
  }
}
