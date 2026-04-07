import 'package:fitmind_ai/models/MilestoneModel.dart';
import 'package:fitmind_ai/resources/MotivationHelper.dart';
import 'package:fitmind_ai/resources/WeightProgressCard.dart';
import 'package:fitmind_ai/resources/app_them.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  int dailyCalories = 0;
  bool isLoadingCalories = true;

  Future<void> fetchCalories() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      print("🔥 Firestore Data: $data"); //  DEBUG

      setState(() {
        dailyCalories = (data["dailyCalories"] ?? 0).toInt();
        isLoadingCalories = false;
      });
    } else {
      print("❌ Document not found");
    }
  }

  Map<int, int> weeklyCalories = {};

  double startWeight = 85;
  double currentWeight = 82;
  double targetWeight = 75;

  Stream<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCalories();
  }

  Future<void> fetchWeeklyData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    weeklyCalories = {for (int i = 1; i <= 7; i++) i: 0};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailyLogs')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        weeklyCalories[date.weekday] = (data['totalCalories'] ?? 0).toInt();
      }
    }

    setState(() => isLoading = false);
  }

  double get progressPercent {
    return ((startWeight - currentWeight) / (startWeight - targetWeight)) * 100;
  }

  double get remainingWeight => currentWeight - targetWeight;

  String get eta {
    double weeklyLoss = 0.5;
    int weeks = (remainingWeight / weeklyLoss).ceil();
    return "$weeks weeks remaining";
  }

  String get onTrackStatus {
    if (progressPercent >= 40) return "On Track";
    if (progressPercent >= 25) return "Slightly Behind";
    return "Behind";
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          /// 🔥 COLLAPSING APPBAR
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,

            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                double height = constraints.biggest.height;

                /// 👇 detect collapse
                bool isCollapsed = height <= kToolbarHeight + 20;

                return FlexibleSpaceBar(
                  centerTitle: false,
                  title: isCollapsed
                      ? Text(
                          "Progress",
                          style: TextStyle(
                            color: textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            /// MYDiet (colored)
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "MY",
                                    style: TextStyle(
                                      color: activeColor, // GREEN
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Diet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),

                            /// Progress (gray)
                            Text(
                              "Progress",
                              style: TextStyle(color: textGrey, fontSize: 14),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                );
              },
            ),
          ),

          /// 📦 BODY CONTENT
          SliverToBoxAdapter(
            child: StreamBuilder<DocumentSnapshot>(
              stream: getUserData(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: CircularProgressIndicator(color: primary),
                    ),
                  );
                }

                var userData = userSnap.data!.data() as Map<String, dynamic>;

                double start =
                    (userData['startWeight'] ?? userData['weight'] ?? 70)
                        .toDouble();

                double current = (userData['weight'] ?? 70).toDouble();

                double target = (userData['targetWeight'] ?? 60).toDouble();

                /// 🔥 UPDATE STATE VARIABLES
                startWeight = start;
                currentWeight = current;
                targetWeight = target;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// GOAL CARD
                      FutureBuilder<Widget>(
                        future: goalCardDynamicReal(
                          start: start,
                          current: current,
                          target: target,
                        ),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox();
                          return snap.data!;
                        },
                      ),

                      const SizedBox(height: 10),

                      /// ETA
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          final current = (data["weight"] ?? 0).toDouble();
                          final target = (data["targetWeight"] ?? 0).toDouble();
                          final weeks = (data["estimatedWeeks"] ?? 0)
                              .toDouble();

                          return buildEtaCardFromFirebase(
                            current: current,
                            target: target,
                            etaWeeks: weeks,
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      /// STATUS
                      _buildStatusCard(
                        actualProgress: current,
                        expectedProgress: target,
                      ),

                      const SizedBox(height: 20),

                      /// 🔥 REALTIME CHART
                      StreamBuilder<Map<int, int>>(
                        stream: weeklyCaloriesStream(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox();

                          final weeklyData = snap.data!;

                          return _buildLineChartReal(weeklyData);
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildGuidance(),

                      const SizedBox(height: 20),

                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          double startWeight = (data["weight"] ?? 0).toDouble();
                          double currentWeight =
                              (data["currentWeight"] ?? startWeight).toDouble();
                          double targetWeight = (data["targetWeight"] ?? 0)
                              .toDouble();

                          return _buildMilestonesRealtime(
                            startWeight,
                            currentWeight,
                            targetWeight,
                          );
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

  /// ---------------- GOAL CARD ----------------
 
Future<Widget> goalCardDynamicReal({
  required double start,
  required double current,
  required double target,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const SizedBox();

  final uid = user.uid;

  /// ================= FETCH TODAY =================
  final today = DateTime.now();
  final todayId =
      "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

  final dailyDoc = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("dailyLogs")
      .doc(todayId)
      .get();

  final userDoc = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .get();

  /// 🔥 IMPORTANT: GET LATEST WEIGHT
  final latestLog = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("dailyLogs")
      .orderBy("timestamp", descending: true)
      .limit(1)
      .get();

  if (latestLog.docs.isNotEmpty) {
    final data = latestLog.docs.first.data();
    current = (data['weight'] ?? current).toDouble();
  }

  double consumedCalories =
      (dailyDoc.data()?["totalCalories"] ?? 0).toDouble();

  double targetCalories =
      (userDoc.data()?["dailyCalories"] ?? 2000).toDouble();

  /// ================= CALC =================
  double deficit = targetCalories - consumedCalories;
  double todayChange = deficit / 7700;




  /// 🔥 FIXED PROGRESS
  double progress;

  if (target < start) {
    progress = ((start - current) / (start - target)) * 100;
  } else {
    progress = ((current - start) / (target - start)) * 100;
  }

  progress = progress.isNaN ? 0 : progress.clamp(0, 100);

  /// 🔥 UX BOOST (if still 0 but effort exists)
  if (progress == 0 && todayChange != 0) {
    progress = 2;
  }

  double remaining = (target - current);


  print("START: $start | CURRENT: $current | TARGET: $target");

  /// ================= UI =================
 return Container(
  margin: const EdgeInsets.all(18),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: const LinearGradient(
      colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: Column(
    children: [
      /// TITLE
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "CURRENT WEIGHT",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),

      const SizedBox(height: 6),

      /// CURRENT WEIGHT (HERO)
      Text(
        "${current.toStringAsFixed(1)} KG",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 4),

      /// TARGET
      Text(
        "Target weight: ${target.toStringAsFixed(1)} KG",
        style: TextStyle(
          color: Colors.greenAccent.shade200,
          fontSize: 13,
        ),
      ),

      const SizedBox(height: 30),

      /// HALF CIRCLE PROGRESS
      SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(220, 140),
              painter: HalfCirclePainter(
                progress: progress / 100,
              //  isLosing: isLosing,
              ),
            ),

            /// CENTER TEXT
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${progress.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "COMPLETED",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      /// REMAINING
      Text(
        "${remaining.abs().toStringAsFixed(1)} kg remaining",
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 6),

      /// MOTIVATION
     Text(
  MotivationHelper.getMotivation(progress),
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 13,
  ),
),

      const SizedBox(height: 20),
      

    ],
  ),
  
);


}
/// ================= MOTIVATION =================
  Widget buildEtaCardFromFirebase({
    required double current,
    required double target,
    required double etaWeeks,
  }) {
    /// Remaining weight
    // double remaining = (target - current).abs();

    /// Estimated DATE
    DateTime now = DateTime.now();
    DateTime estimatedDate = now.add(Duration(days: (etaWeeks * 7).toInt()));

    String dateText = "${estimatedDate.day} ${_monthName(estimatedDate.month)}";

    String weeksText = etaWeeks > 0
        ? "~${etaWeeks.toStringAsFixed(1)} weeks remaining"
        : "--";

    /// UI (same as yours)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.greenAccent.withOpacity(0.2),
            ),
            child: const Icon(Icons.timer, color: Colors.greenAccent),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "ESTIMATED:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  weeksText, // e.g., "10 weeks"
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } //

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

  /// ---------------- STATUS ----------------
  Widget _buildStatusCard({
    required double actualProgress,
    required double expectedProgress,
  }) {
    String status;
    Color color;
    IconData icon;
    String message;

    // 🔥 LOGIC IMPLEMENTATION
    if (actualProgress >= expectedProgress) {
      status = "On Track";
      color = Colors.greenAccent;
      icon = Icons.check_circle;
      message = "Great job! You're hitting your goals 🚀";
    } else if (actualProgress >= expectedProgress * 0.85) {
      status = "Slightly Behind";
      color = Colors.orangeAccent;
      icon = Icons.warning_amber_rounded;
      message = "A little push needed. You got this 💪";
    } else {
      status = "Behind Schedule";
      color = Colors.redAccent;
      icon = Icons.error_outline;
      message = "Let’s refocus and get back on track ⚡";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔥 ICON CIRCLE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(width: 15),

          // 🔥 TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ON TRACK STATUS",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- GUIDANCE ----------------
  Widget _buildGuidance() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WEEKLY TARGET / DAILY GUIDANCE",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    /// 🔄 Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _guidanceCard(
                        icon: Icons.fitness_center,
                        title: "TARGET\nLose",
                        value: "Loading...",
                      );
                    }

                    /// ❌ No data
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return _guidanceCard(
                        icon: Icons.fitness_center,
                        title: "TARGET\nLose",
                        value: "No Data",
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    /// ✅ Safe parsing (VERY IMPORTANT)
                    final weight = (data["weight"] ?? 0).toDouble();
                    final targetWeight = (data["targetWeight"] ?? 0).toDouble();
                    final weeks = (data["estimatedWeeks"] ?? 0).toDouble();

                    /// 🧠 Calculation
                    double weeklyGoal = 0;

                    if (weeks > 0 && weight > targetWeight) {
                      weeklyGoal = (weight - targetWeight) / weeks;
                    }

                    /// 🛡️ Prevent weird values
                    if (weeklyGoal.isNaN || weeklyGoal.isInfinite) {
                      weeklyGoal = 0;
                    }

                    return _guidanceCard(
                      icon: Icons.fitness_center,
                      title: "TARGET\nLose",
                      value: "${weeklyGoal.toStringAsFixed(2)} kg/week",
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _guidanceCard(
                        icon: Icons.local_fire_department,
                        title: "Daily Calories",
                        value: "...",
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    final calories = (data["dailyCalories"] ?? 0).toString();

                    return _guidanceCard(
                      icon: Icons.local_fire_department,
                      title: "Daily Calories target",
                      value: "$calories kcal",
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _guidanceCard({
    required IconData icon,
    required String title,
    required String value,
    String? subValue, // 👈 NEW
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor.withOpacity(0.15),
            ),
            child: Icon(icon, color: activeColor, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                const SizedBox(height: 4),

                /// Main Value
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// 👇 Sub Value (Goal)
                if (subValue != null)
                  Text(
                    subValue,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- MILESTONES ----------------
  Widget _buildMilestonesRealtime(
    double startWeight,
    double currentWeight,
    double targetWeight,
  ) {
    final milestone = _calculateMilestone(
      startWeight,
      currentWeight,
      targetWeight,
    );

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MILESTONES",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _milestoneCard(
                  title: milestone.completedTitle,
                  subtitle: milestone.completedDate,
                  icon: Icons.emoji_events,
                  isCompleted: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _milestoneCard(
                  title: milestone.nextTitle,
                  subtitle: milestone.nextSubtitle,
                  icon: Icons.flag,
                  isCompleted: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MilestoneModel _calculateMilestone(
    double startWeight,
    double currentWeight,
    double targetWeight,
  ) {
    double totalLoss = startWeight - targetWeight;
    double lost = startWeight - currentWeight;

    /// Default
    String completedTitle = "Start Journey 🚀";
    String completedDate = "";
    String nextTitle = "Lose 2kg";
    String nextSubtitle = "Keep going";

    /// ✅ First milestone
    if (lost >= 2) {
      completedTitle = "First 2kg Lost 💪";
      completedDate = "Great start!";
      nextTitle = "Lose 5kg";
      nextSubtitle = "Next milestone";
    }

    /// ✅ Halfway
    if (lost >= totalLoss / 2) {
      completedTitle = "Halfway There 🔥";
      completedDate = "You're doing amazing!";
      nextTitle = "Reach Target";
      nextSubtitle =
          "${(currentWeight - targetWeight).toStringAsFixed(1)} kg left";
    }

    /// ✅ Goal Achieved
    if (currentWeight <= targetWeight) {
      completedTitle = "Goal Achieved 🎉";
      completedDate = "You did it!";
      nextTitle = "Maintain Weight";
      nextSubtitle = "Stay consistent";
    }

    return MilestoneModel(
      completedTitle: completedTitle,
      completedDate: completedDate,
      nextTitle: nextTitle,
      nextSubtitle: nextSubtitle,
    );
  }

  Widget _milestoneCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        /// 🔥 Glow for completed
        gradient: LinearGradient(
          colors: isCompleted
              ? [activeColor.withOpacity(0.25), Colors.transparent]
              : [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: Border.all(
          color: isCompleted
              ? activeColor.withOpacity(0.6)
              : Colors.white.withOpacity(0.08),
        ),

        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 TOP ROW (ICON + CHECK)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: isCompleted ? activeColor : Colors.white38,
                size: 20,
              ),

              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔹 TITLE
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          /// 🔹 SUBTITLE
          Text(
            subtitle,
            style: TextStyle(
              color: isCompleted ? activeColor : Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- CARD WRAPPER ----------------
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Stream<Map<int, int>> weeklyCaloriesStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    DateTime now = DateTime.now();

    /// Week start (Monday)
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    /// Week end (Sunday)
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .snapshots()
        .map((snapshot) {
          Map<int, int> data = {for (int i = 1; i <= 7; i++) i: 0};

          for (var doc in snapshot.docs) {
            final date = DateTime.parse(doc.id); // yyyy-MM-dd

            /// ✅ Only current week data
            if (!date.isBefore(startOfWeek) && !date.isAfter(endOfWeek)) {
              data[date.weekday] = (doc.data()['totalCalories'] ?? 0).toInt();
            }
          }

          return data;
        });
  }

  Widget _buildLineChartReal(Map<int, int> weeklyData) {
    final spots = weeklyData.entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WEEKLY CALORIES",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 7,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          "",
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun",
                        ];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    gradient: LinearGradient(
                      colors: [activeColor.withOpacity(0.5), activeColor],
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  
  
  
  }
}
