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

  // Weekly nutrient data maps
  Map<int, int> weeklyCalories = {};
  Map<int, int> weeklyProtein = {};
  Map<int, int> weeklyCarbs = {};
  Map<int, int> weeklyFat = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    setState(() => isLoading = true);

    final user = _auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    DateTime now = DateTime.now();

    // Week starts from Monday (1) to Sunday (7)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Initialize maps with all 7 days (Mon-Sun)
    weeklyCalories = {for (int i = 1; i <= 7; i++) i: 0};
    weeklyProtein = {for (int i = 1; i <= 7; i++) i: 0};
    weeklyCarbs = {for (int i = 1; i <= 7; i++) i: 0};
    weeklyFat = {for (int i = 1; i <= 7; i++) i: 0};

    // Fetch all logs for the week
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
        int dayIndex = date.weekday; // 1 = Monday, 7 = Sunday

        weeklyCalories[dayIndex] =
            (data['totalCalories'] ?? 0).toInt();
        weeklyProtein[dayIndex] =
            (data['totalProtein'] ?? 0).toInt();
        weeklyCarbs[dayIndex] =
            (data['totalCarbs'] ?? 0).toInt();
        weeklyFat[dayIndex] =
            (data['totalFat'] ?? 0).toInt();
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Weekly Progress"),
        backgroundColor: cardColor,
        foregroundColor: textMain,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildWeeklyChartCard(
                      title: "Weekly Calories",
                      dataMap: weeklyCalories,
                      barColor: activeColor),
                  const SizedBox(height: 25),
                  _buildWeeklyChartCard(
                      title: "Weekly Protein",
                      dataMap: weeklyProtein,
                      barColor: accent),
                  const SizedBox(height: 25),
                  _buildWeeklyChartCard(
                      title: "Weekly Carbs",
                      dataMap: weeklyCarbs,
                      barColor: Colors.blueAccent),
                  const SizedBox(height: 25),
                  _buildWeeklyChartCard(
                      title: "Weekly Fats",
                      dataMap: weeklyFat,
                      barColor: Colors.redAccent),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyChartCard({
    required String title,
    required Map<int, int> dataMap,
    required Color barColor,
  }) {
    // Prepare chart data for 7 days (Mon-Sun)
    List<BarChartGroupData> barGroups = [];
    int maxY = 10;

    for (int day = 1; day <= 7; day++) {
      int value = dataMap[day] ?? 0;
      if (value > maxY) maxY = value + 10;

      barGroups.add(BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(6),
            color: barColor,
          )
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: inactiveColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble(),
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: inactiveColor.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: textGrey, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                        ];
                        return Text(
                          days[value.toInt() - 1],
                          style: TextStyle(fontSize: 12, color: textGrey),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
