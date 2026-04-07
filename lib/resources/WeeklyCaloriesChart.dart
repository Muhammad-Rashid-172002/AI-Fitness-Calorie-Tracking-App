import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyCaloriesChart extends StatelessWidget {
  final Stream<Map<int, int>> stream;

  const WeeklyCaloriesChart({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: stream,
      builder: (context, snapshot) {

        /// Loading
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;

        /// Convert to FlSpots
        List<FlSpot> spots = [];
        data.forEach((day, calories) {
          spots.add(FlSpot(day.toDouble(), calories.toDouble()));
        });

        return SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: 7,
              minY: 0,

              /// 🔥 Dynamic max Y
              maxY: (data.values.reduce((a, b) => a > b ? a : b) + 500)
                  .toDouble(),

              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 1:
                          return const Text("Mon");
                        case 2:
                          return const Text("Tue");
                        case 3:
                          return const Text("Wed");
                        case 4:
                          return const Text("Thu");
                        case 5:
                          return const Text("Fri");
                        case 6:
                          return const Text("Sat");
                        case 7:
                          return const Text("Sun");
                      }
                      return const Text("");
                    },
                  ),
                ),

                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: spots,

                  dotData: FlDotData(show: true),

                  belowBarData: BarAreaData(show: true),

                  isStrokeCapRound: true,
                  barWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}