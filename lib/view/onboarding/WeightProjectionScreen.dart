import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/view/onboarding/result_screen.dart';

class WeightProjectionScreen extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;

   WeightProjectionScreen({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
  });

  /// Generate realistic curve
  List<FlSpot> generateSpots() {
    int weeks = 5;
    double diff = currentWeight - targetWeight;
    double step = diff / weeks;

    List<FlSpot> spots = [];

    for (int i = 0; i <= weeks; i++) {
      double base = currentWeight - (step * i);
      double fluctuation = (i % 2 == 0) ? 0.4 : -0.5;

      double value = (i == weeks) ? targetWeight : base + fluctuation;

      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  final List<String> labels = ["Today", "W2", "W4", "W6", "W8", "Goal"];

  Widget bottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index < 0 || index >= labels.length) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        labels[index],
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = generateSpots();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.04),

              /// TITLE
              const Text(
                "Your Weight Journey",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Your estimated progress based on your goal.",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: size.height * 0.04),

              /// GRAPH CONTAINER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 1.4, // 🔥 responsive height
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;
                      double height = constraints.maxHeight;

                      double minY = targetWeight - 2;
                      double maxY = currentWeight + 2;

                      double stepX = width / (spots.length - 1);

                      return Stack(
                        children: [
                          /// 📈 CHART
                          LineChart(
                            LineChartData(
                              minY: minY,
                              maxY: maxY,

                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.white.withOpacity(0.05),
                                  );
                                },
                              ),

                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: bottomTitles,
                                  ),
                                ),
                              ),

                              borderData: FlBorderData(show: false),

                              lineBarsData: [
                                /// GLOW
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: Colors.greenAccent.withOpacity(0.25),
                                  barWidth: 10,
                                  dotData: FlDotData(show: false),
                                ),

                                /// MAIN LINE
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF22C55E),
                                      Color(0xFF4ADE80),
                                    ],
                                  ),
                                  barWidth: 3,

                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, bar, index) {
                                      bool isGoal = index == spots.length - 1;

                                      return FlDotCirclePainter(
                                        radius: isGoal ? 7 : 4,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: const Color(0xFF22C55E),
                                      );
                                    },
                                  ),

                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(
                                          0xFF22C55E,
                                        ).withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 🔥 RESPONSIVE LABELS
                          ...spots.asMap().entries.map((entry) {
                            int i = entry.key;
                            FlSpot spot = entry.value;

                            double x = stepX * i;

                            double yRatio = (spot.y - minY) / (maxY - minY);
                            double y = height - (yRatio * height);

                            /// Prevent overflow
                            double adjustedX = x - 20;

                            if (i == 0) {
                              adjustedX = 4;
                            } else if (i == spots.length - 1) {
                              adjustedX = width - 55;
                            }

                            return Positioned(
                              left: adjustedX,
                              top: y - 35,
                              child: Column(
                                children: [
                                  Text(
                                    "${spot.y.toStringAsFixed(1)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 14,
                                    color: Colors.greenAccent,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// VALUES ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${currentWeight.toStringAsFixed(1)} kg",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "${targetWeight.toStringAsFixed(1)} kg",
                    style: const TextStyle(color: Color(0xFF22C55E)),
                  ),
                ],
              ),

              const Spacer(),

              /// BUTTON
              CustomGradientButton(
                text: "Continue",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResultScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}