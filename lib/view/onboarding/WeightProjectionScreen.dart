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

  List<FlSpot> generateSpots() {
    int weeks = 5;
    double diff = currentWeight - targetWeight;
    double step = diff / weeks;

    return List.generate(weeks + 1, (i) {
      double base = currentWeight - (step * i);
      double noise = (i % 2 == 0) ? 0.3 : -0.4;
      double value = (i == weeks) ? targetWeight : base + noise;
      return FlSpot(i.toDouble(), value);
    });
  }

  final List<String> labels = ["Start", "W2", "W4", "W6", "Goal"];

  Widget bottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index < 0 || index >= labels.length) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        labels[index],
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = generateSpots();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          /// 🌈 BACKGROUND GLOW
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E).withOpacity(0.08),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// 🔙 TOP BAR
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          "Progress AI",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// TITLE
                  const Text(
                    "Your Transformation",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "AI predicted weight journey based on your goal",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CARD WRAPPER (GLASS)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: LineChart(
                        LineChartData(
                          minY: targetWeight - 2,
                          maxY: currentWeight + 2,

                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: Colors.white.withOpacity(0.05),
                              strokeWidth: 1,
                            ),
                          ),

                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
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
                                getTitlesWidget: bottomTitles,
                              ),
                            ),
                          ),

                          borderData: FlBorderData(show: false),

                          lineBarsData: [
                            /// GLOW LINE
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 8,
                              color: const Color(0xFF22C55E).withOpacity(0.15),
                              dotData: const FlDotData(show: false),
                            ),

                            /// MAIN LINE
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF22C55E),
                                  Color(0xFF06B6D4),
                                ],
                              ),
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  final isLast = index == spots.length - 1;

                                  return FlDotCirclePainter(
                                    radius: isLast ? 6 : 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFF22C55E),
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF22C55E).withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// WEIGHT INFO CARDS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniCard("Start", currentWeight, Colors.white),
                      _miniCard("Goal", targetWeight, const Color(0xFF22C55E)),
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "${value.toStringAsFixed(1)} kg",
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}