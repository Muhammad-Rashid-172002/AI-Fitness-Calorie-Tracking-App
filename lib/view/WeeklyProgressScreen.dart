import 'package:fitmind_ai/models/GuidanceModel.dart';
import 'package:fitmind_ai/models/MilestoneModel.dart';
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

    var userData =
        userSnap.data!.data() as Map<String, dynamic>;

    double start =
        (userData['startWeight'] ?? userData['weight'] ?? 70)
            .toDouble();

    double current =
        (userData['weight'] ?? 70).toDouble();

    double target =
        (userData['targetWeight'] ?? 60).toDouble();

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
            future: goalCardPremium(
              start: start,
              current: current,
              target: target,
            ),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox();
              return snap.data!;
            },
          ),

          const SizedBox(height: 20),

          /// ETA
          buildEtaCardPremium(
            current: current,
            target: target,
            todayChange: (target - current) / 7700,
          ),

          const SizedBox(height: 20),

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

          _buildMilestones(),
        ],
      ),
    );
  },
),  ),
        ],
      ),
    );
  }

  /// ---------------- GOAL CARD ----------------
  Future<Widget> goalCardPremium({
    required double start,
    required double current,
    required double target,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final uid = user.uid;

    /// ================= FETCH DATA =================
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

    double consumedCalories = (dailyDoc.data()?["totalCalories"] ?? 0)
        .toDouble();

    double targetCalories = (userDoc.data()?["dailyCalories"] ?? 2000)
        .toDouble();

    /// ================= CALC =================
    double deficit = targetCalories - consumedCalories;
    double todayChange = deficit / 7700;

    bool isLosing = target < start;

    double progress;

    if (isLosing) {
      progress = ((start - current) / (start - target)) * 100;
    } else {
      progress = ((current - start) / (target - start)) * 100;
    }

    progress = progress.isNaN ? 0 : progress.clamp(0, 100);

    double remaining = (target - current).abs();

    /// ETA
    double weeklyChange = todayChange * 7;
    double etaWeeks = weeklyChange != 0 ? (remaining / weeklyChange).abs() : 0;

    String etaText = etaWeeks.isFinite
        ? "${etaWeeks.toStringAsFixed(1)} weeks"
        : "--";

    /// MOTIVATION TEXT
    String motivation;
    if (progress < 25) {
      motivation = "Great start 💪 Keep going!";
    } else if (progress < 60) {
      motivation = "You're doing amazing 🚀";
    } else if (progress < 90) {
      motivation = "Almost there 🔥";
    } else {
      motivation = "You're crushing it 🎯";
    }

    /// ================= UI =================
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.withOpacity(0.15), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "GOAL PROGRESS",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$current kg",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// CIRCULAR PROGRESS
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),

              Column(
                children: [
                  Text(
                    "${progress.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "COMPLETED",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// TARGET
          Text(
            "Target: $target kg",
            style: const TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 8),

          /// REMAINING
          Text(
            "${remaining.toStringAsFixed(1)} kg remaining",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          /// MOTIVATION
          Text(
            motivation,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 18),

          /// ETA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.greenAccent),
                const SizedBox(width: 6),
                Text(
                  "ETA: $etaText",
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- ETA ----------------
  Widget buildEtaCardPremium({
    required double current,
    required double target,
    required double todayChange, // from your calc (deficit / 7700)
  }) {
    /// ================= CALC =================
    double remaining = (target - current).abs();

    double weeklyChange = todayChange * 7;

    double etaWeeks = weeklyChange != 0 ? (remaining / weeklyChange).abs() : 0;

    /// Estimated DATE
    DateTime now = DateTime.now();
    DateTime estimatedDate = now.add(Duration(days: (etaWeeks * 7).toInt()));

    String dateText = "${estimatedDate.day} ${_monthName(estimatedDate.month)}";

    String weeksText = etaWeeks.isFinite
        ? "~${etaWeeks.toStringAsFixed(1)} weeks remaining"
        : "--";

    /// STATUS (On Track / Slow / Off Track)
    String status;
    Color statusColor;

    if (etaWeeks == 0 || !etaWeeks.isFinite) {
      status = "No progress data";
      statusColor = Colors.white54;
    } else if (etaWeeks < 6) {
      status = "On Track 🔥";
      statusColor = Colors.greenAccent;
    } else if (etaWeeks < 12) {
      status = "Keep Going 💪";
      statusColor = Colors.orange;
    } else {
      status = "Needs Focus ⚡";
      statusColor = Colors.redAccent;
    }

    /// ================= UI =================
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.withOpacity(0.15), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON CIRCLE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.greenAccent.withOpacity(0.2),
            ),
            child: const Icon(Icons.timer, color: Colors.greenAccent),
          ),

          const SizedBox(width: 14),

          /// TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ESTIMATED TIME",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 6),

                /// DATE
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                /// WEEKS
                Text(
                  weeksText,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          /// STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
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
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), Colors.black.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
    final guidance = _calculateGuidance();

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
                child: _guidanceCard(
                  icon: Icons.fitness_center,
                  title: "TARGET",
                  value: "${guidance.weeklyGoal} kg/week",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _guidanceCard(
                  icon: Icons.local_fire_department,
                  title: "TODAY",
                  value: "${guidance.calories} kcal",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔥 SMART MESSAGE
          Text(
            guidance.message,
            style: TextStyle(
              color: guidance.isOnTrack
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guidanceCard({
    required IconData icon,
    required String title,
    required String value,
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
          /// 🔥 ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor.withOpacity(0.15),
            ),
            child: Icon(icon, color: activeColor, size: 18),
          ),

          const SizedBox(width: 10),

          /// 🔥 TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  GuidanceModel _calculateGuidance() {
    double weeklyGoal = -0.5; // kg/week target

    double expectedWeightToday =
        startWeight + (weeklyGoal / 7) * DateTime.now().weekday;

    double difference = currentWeight - expectedWeightToday;

    int baseCalories = 1800;
    int adjustedCalories = baseCalories;

    String message;
    bool isOnTrack = true;

    if (difference > 0.3) {
      /// ❌ behind
      adjustedCalories = baseCalories - 200;
      message = "You're slightly behind. Reduce ~200 kcal today.";
      isOnTrack = false;
    } else if (difference < -0.3) {
      /// 🚀 ahead
      adjustedCalories = baseCalories + 150;
      message = "Great! You're ahead. You can eat a bit more today.";
    } else {
      /// ✅ on track
      message = "Perfect! You're on track. Keep going!";
    }

    return GuidanceModel(
      weeklyGoal: weeklyGoal,
      calories: adjustedCalories,
      message: message,
      isOnTrack: isOnTrack,
    );
  }

  /// ---------------- MILESTONES ----------------
  Widget _buildMilestones() {
    final milestone = _calculateMilestone();

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
              /// ✅ COMPLETED
              Expanded(
                child: _milestoneCard(
                  title: milestone.completedTitle,
                  subtitle: milestone.completedDate,
                  icon: Icons.emoji_events,
                  isCompleted: true,
                ),
              ),

              const SizedBox(width: 12),

              /// ⏳ UPCOMING
              Expanded(
                child: _milestoneCard(
                  title: milestone.nextTitle,
                  subtitle: "Coming soon",
                  icon: Icons.directions_run,
                  isCompleted: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MilestoneModel _calculateMilestone() {
    double weightLost = startWeight - currentWeight;

    String completedTitle = "Start Journey";
    String completedDate = "";
    String nextTitle = "Lose 2kg";

    if (weightLost >= 2) {
      completedTitle = "First 2kg Lost";
      completedDate = _formatDate(DateTime.now());
      nextTitle = "Halfway There";
    }

    if (weightLost >= ((startWeight - targetWeight) / 2)) {
      completedTitle = "Halfway There";
      completedDate = _formatDate(DateTime.now());
      nextTitle = "Target قريب 🔥";
    }

    if (currentWeight <= targetWeight) {
      completedTitle = "Goal Achieved 🎉";
      completedDate = _formatDate(DateTime.now());
      nextTitle = "Maintain وزن";
    }

    return MilestoneModel(
      completedTitle: completedTitle,
      completedDate: completedDate,
      nextTitle: nextTitle,
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

  String _formatDate(DateTime date) {
    return "${date.day} ${_monthName(date.month)}";
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
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('dailyLogs')
      .snapshots()
      .map((snapshot) {
    Map<int, int> data = {for (int i = 1; i <= 7; i++) i: 0};

    for (var doc in snapshot.docs) {
      final docId = doc.id; // yyyy-MM-dd
      final date = DateTime.parse(docId);

      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        data[date.weekday] =
            (doc.data()['totalCalories'] ?? 0).toInt();
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
                        "Sun"
                      ];
                      return Text(
                        days[value.toInt()],
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
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
                    colors: [
                      activeColor.withOpacity(0.5),
                      activeColor,
                    ],
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
