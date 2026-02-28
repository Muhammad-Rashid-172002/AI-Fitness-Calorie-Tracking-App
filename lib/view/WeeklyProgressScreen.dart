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
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    // Clear previous data
    weeklyCalories.clear();
    weeklyProtein.clear();
    weeklyCarbs.clear();
    weeklyFat.clear();

    final dailyLogsSnap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .where(
          'date',
          isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(startOfWeek),
        )
        .get();

    for (var doc in dailyLogsSnap.docs) {
      final data = doc.data();
      if (data['date'] == null) continue;

      DateTime date;
      try {
        date = DateFormat('yyyy-MM-dd').parse(data['date']);
      } catch (_) {
        continue;
      }

      int dayIndex = date.weekday % 7;

      weeklyCalories[dayIndex] =
          (weeklyCalories[dayIndex] ?? 0) +
          ((data['totalCalories'] ?? 0) as num).toInt();
      weeklyProtein[dayIndex] =
          (weeklyProtein[dayIndex] ?? 0) +
          ((data['totalProtein'] ?? 0) as num).toInt();
      weeklyCarbs[dayIndex] =
          (weeklyCarbs[dayIndex] ?? 0) +
          ((data['totalCarbs'] ?? 0) as num).toInt();
      weeklyFat[dayIndex] =
          (weeklyFat[dayIndex] ?? 0) + ((data['totalFat'] ?? 0) as num).toInt();
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
                    barColor: activeColor,
                  ),
                  const SizedBox(height: 25),
                  _buildWeeklyChartCard(
                    title: "Weekly Protein",
                    dataMap: weeklyProtein,
                    barColor: accent,
                  ),
                  const SizedBox(height: 25),
                  _buildWeeklyChartCard(
                    title: "Weekly Carbs",
                    dataMap: weeklyCarbs,
                    barColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 25),
                  _buildWeeklyChartCard(
                    title: "Weekly Fats",
                    dataMap: weeklyFat,
                    barColor: Colors.redAccent,
                  ),
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
    // Keep only days with actual data
    final filteredData = dataMap.entries.where((e) => e.value > 0).toList();

    int maxY = 10;
    if (filteredData.isNotEmpty) {
      maxY =
          filteredData.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 10;
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
                barGroups: filteredData.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        color: barColor,
                      ),
                    ],
                  );
                }).toList(),
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
                          value.toInt().toString(), // left axis value
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
                          "Sun",
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                        ];
                        return Text(
                          days[value.toInt()],
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
