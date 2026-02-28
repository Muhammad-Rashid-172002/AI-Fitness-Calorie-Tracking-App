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

  /// Map: Day index (0=Sun..6=Sat) -> Total Calories for that day
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
    if (user == null) return;

    DateTime now = DateTime.now();
    final startOfWeek = now.subtract(
      Duration(days: now.weekday % 7),
    ); // Sunday as 0

    // Initialize map for all days
    for (int i = 0; i < 7; i++) {
      weeklyCalories[i] = 0;
      weeklyProtein[i] = 0;
      weeklyCarbs[i] = 0;
      weeklyFat[i] = 0;
    }

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

      int dayIndex = date.weekday % 7; // 0=Sun, 1=Mon,..6=Sat
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
    const List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Progress"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// WEEKLY CHART CARD FOR CALORIES
                  _buildWeeklyChartCard(
                    title: "Weekly Calories",
                    dataMap: weeklyCalories,
                    barColor: Colors.orange,
                  ),

                  const SizedBox(height: 25),

                  /// WEEKLY CHART CARD FOR PROTEIN
                  _buildWeeklyChartCard(
                    title: "Weekly Protein",
                    dataMap: weeklyProtein,
                    barColor: Colors.green,
                  ),

                  const SizedBox(height: 25),

                  /// WEEKLY CHART CARD FOR CARBS
                  _buildWeeklyChartCard(
                    title: "Weekly Carbs",
                    dataMap: weeklyCarbs,
                    barColor: Colors.blue,
                  ),

                  const SizedBox(height: 25),

                  /// WEEKLY CHART CARD FOR FATS
                  _buildWeeklyChartCard(
                    title: "Weekly Fats",
                    dataMap: weeklyFat,
                    barColor: Colors.red,
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
    int maxY = 5;
    if (dataMap.values.isNotEmpty) {
      maxY = dataMap.values.reduce((a, b) => a > b ? a : b) + 10;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble(),
                barGroups: dataMap.entries.map((e) {
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
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
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
