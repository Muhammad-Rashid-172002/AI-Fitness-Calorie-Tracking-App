import 'package:fitmind_ai/view/add_weight_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// MYDiet History mockup — spacing & chart height.
abstract final class HistoryScreenStyle {
  static const double cardRadius = 16;
  static const double chartHeight = 200;
  static const double sectionGap = 16;
  static const double horizontalPadding = 18;

  /// Design tokens (image spec).
  static const Color bgBlack = Color(0xFF000000);
  static const Color cardFill = Color(0xFF1A1C1E);
  static const Color lime = Color(0xFF4ADE80);
  static const Color textSecondary = Color(0xFF9CA3AF);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScanController controller = ScanController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final List<String> filters = ["Today", "Week", "Month"];
  int selectedIndex = 0;
  Stream<QuerySnapshot> getBodyMetrics() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("body_metrics_log")
        .orderBy("timestamp")
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddWeightScreen()),
            );
          },
          backgroundColor: Colors.greenAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
      appBar: AppBar(
        backgroundColor: bgColor, // dark background
        elevation: 0,
        leadingWidth: 120,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MYDiet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green, // green text
                fontSize: 22,
              ),
            ),
          ),
        ),
        title: const Text(
          "History",
          style: TextStyle(
            color: Colors.white, // white text
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _filter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getBodyMetrics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyView();
                }

                List<Map<String, dynamic>> items = snapshot.data!.docs
                    .map(
                      (doc) => Map<String, dynamic>.from(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

                List<Map<String, dynamic>> filtered = _filterData(items);
                if (filtered.isEmpty) return _emptyView();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _weeklySummaryPremium(75), // Mocked score for demo
                    _trendCard(filtered),
                    StreamBuilder<DocumentSnapshot>(
                      stream: getUserData(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox();

                        var data =
                            userSnap.data!.data() as Map<String, dynamic>;

                        double start =
                            (data['startWeight'] ?? data['weight'] ?? 70)
                                .toDouble();

                        double current = (data['weight'] ?? 70).toDouble();

                        double target = (data['targetWeight'] ?? 60).toDouble();

                        return goalCardRealtime(start: start, target: target);
                      },
                    ),
                    _bodyFatCard(filtered),
                    _muscleCard(filtered),
                    _whrCard(filtered),
                    _insightCard(generateInsightFromBody(filtered)),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // FILTER
  Widget _filter() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          bool selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: selected ? activeColor : cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: selected ? Colors.white : inactiveColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> items) {
    DateTime now = DateTime.now();
    return items.where((data) {
      final ts = data['timestamp'];
      DateTime time = ts is Timestamp ? ts.toDate() : now;
      if (selectedIndex == 0) return time.day == now.day;
      if (selectedIndex == 1)
        return time.isAfter(now.subtract(const Duration(days: 7)));
      return time.month == now.month;
    }).toList();
  }

  // TREND CHART
  List<FlSpot> _generateWeightSpots(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];

    data.sort(
      (a, b) => (a['timestamp'] as Timestamp).toDate().compareTo(
        (b['timestamp'] as Timestamp).toDate(),
      ),
    );

    for (int i = 0; i < data.length; i++) {
      double weight = (data[i]['weight'] ?? 0).toDouble();

      if (weight > 0) {
        spots.add(FlSpot(i.toDouble(), weight));
      }
    }

    return spots;
  }

  Widget _trendCard(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = _generateWeightSpots(data);

    if (spots.isEmpty) return const SizedBox();

    double change = spots.last.y - spots.first.y;

    return _simpleChartCard(
      "WEIGHT PROGRESS",
      spots,
      "kg",
      extraTop: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: change < 0
                  ? Colors.greenAccent.withOpacity(0.2)
                  : Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${change.toStringAsFixed(1)} kg",
              style: TextStyle(
                color: change < 0 ? Colors.greenAccent : Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleChartCard(
    String title,
    List<FlSpot> spots,
    String unit, {
    Widget? extraTop,
  }) {
    if (spots.isEmpty) return const SizedBox();

    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    double lastValue = spots.last.y;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 TITLE
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 6),

          /// 🔹 CURRENT VALUE
          Text(
            "${lastValue.toStringAsFixed(1)} $unit",
            style: TextStyle(
              color: activeColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 OPTIONAL EXTRA
          if (extraTop != null) ...[extraTop, const SizedBox(height: 12)],

          /// 🔹 DIVIDER
          Container(height: 1, color: Colors.white10),

          const SizedBox(height: 12),

          /// 🔹 CHART
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: minY - 1,
                maxY: maxY + 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: activeColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          activeColor.withOpacity(0.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget goalCardRealtime({required double start, required double target}) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const SizedBox();
        }

        final userData = userSnap.data!.data() as Map<String, dynamic>;

        double current = (userData['weight'] ?? start).toDouble();
        double startWeight = (userData['startWeight'] ?? start).toDouble();

        double remaining = (target - current);

        double progress = 0;

        if (startWeight != target) {
          if (target < startWeight) {
            progress = ((startWeight - current) / (startWeight - target)) * 100;
          } else {
            progress = ((current - startWeight) / (target - startWeight)) * 100;
          }
        }

        progress = progress.clamp(0, 100);

        return Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GOAL PROGRESS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _weightItem("Start", startWeight),
                  _weightItem("Current", current),
                  _weightItem("Target", target),
                ],
              ),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 14,
                backgroundColor: Colors.white12,
                color: activeColor,
              ),

              const SizedBox(height: 14),

              Center(
                child: Column(
                  children: [
                    Text(
                      "${progress.toStringAsFixed(0)}% completed",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${remaining.abs().toStringAsFixed(1)} kg remaining",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _weightItem(String title, double value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          "${value.toStringAsFixed(1)} kg",
          style: TextStyle(
            color: activeColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _bodyFatCard(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      double value = (data[i]['bodyFat'] ?? 0).toDouble();
      if (value > 0) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) return const SizedBox();
    return _simpleChartCard("BODY FAT PROGRESS", spots, "%");
  }

  Widget _muscleCard(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      double value = (data[i]['muscle'] ?? 0).toDouble();
      if (value > 0) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) return const SizedBox();
    return _simpleChartCard("MUSCLE MASS", spots, "kg");
  }

  Widget _whrCard(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      double value = (data[i]['whr'] ?? 0).toDouble();
      if (value > 0) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) return const SizedBox();
    return _simpleChartCard("WHR PROGRESS", spots, "");
  }

  Widget _insightCard(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (insight["color"] as Color).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(insight["icon"], color: insight["color"]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight["text"],
              style: TextStyle(color: insight["color"]),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> generateInsightFromBody(
    List<Map<String, dynamic>> data,
  ) {
    if (data.length < 2) {
      return {
        "text": "Not enough data yet",
        "color": Colors.white70,
        "icon": Icons.info,
      };
    }

    double fatStart = (data.first['bodyFat'] ?? 0).toDouble();
    double fatEnd = (data.last['bodyFat'] ?? 0).toDouble();

    double muscleStart = (data.first['muscle'] ?? 0).toDouble();
    double muscleEnd = (data.last['muscle'] ?? 0).toDouble();

    if (fatEnd < fatStart && muscleEnd > muscleStart) {
      return {
        "text": "Excellent recomposition: losing fat & gaining muscle",
        "color": Colors.greenAccent,
        "icon": Icons.local_fire_department,
      };
    }

    if (fatEnd > fatStart) {
      return {
        "text": "Fat gain detected. Review diet",
        "color": Colors.redAccent,
        "icon": Icons.trending_up,
      };
    }

    return {
      "text": "Keep tracking progress",
      "color": Colors.white70,
      "icon": Icons.insights,
    };
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF0F2027), Color(0xFF203A43)],
    ),
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: activeColor.withOpacity(0.25),
        blurRadius: 25,
        offset: const Offset(0, 10),
      ),
    ],
  );

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_food_outlined,
            size: 80,
            color: HistoryScreenStyle.textSecondary,
          ),
          const SizedBox(height: 18),
          Text(
            'No history for this range',
            style: TextStyle(
              color: HistoryScreenStyle.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start scanning or adding meals manually',
            style: TextStyle(
              color: HistoryScreenStyle.textSecondary.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklySummaryPremium(double score) {
    String status = score >= 80
        ? "Excellent"
        : score >= 60
        ? "Good"
        : "Needs Improvement";
    String insight = score >= 80
        ? "Your consistency improved this week"
        : score >= 60
        ? "You're doing good, keep tracking"
        : "Try to improve your consistency";
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WEEKLY SUMMARY",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "/ 100",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            insight,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
