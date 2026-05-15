import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/view/onboarding/result_screen.dart';

class WeightProjectionScreen extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;

  const WeightProjectionScreen({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
  });

  bool get isGain => targetWeight > currentWeight;
  bool get isLose => targetWeight < currentWeight;

  double get totalChange => (targetWeight - currentWeight).abs();

  /// Realistic weekly rate:
  /// Weight loss: 0.5 kg/week
  /// Weight gain: 0.25 kg/week
  double get weeklyRate {
    if (isGain) return 0.25;
    if (isLose) return 0.50;
    return 0.0;
  }

  int get estimatedWeeks {
    if (totalChange == 0 || weeklyRate == 0) return 1;
    return max(1, (totalChange / weeklyRate).ceil());
  }

  List<FlSpot> generateSpots() {
    final int weeks = estimatedWeeks.clamp(1, 24);
    final double step = (targetWeight - currentWeight) / weeks;

    return List.generate(weeks + 1, (i) {
      if (i == 0) return FlSpot(i.toDouble(), currentWeight);
      if (i == weeks) return FlSpot(i.toDouble(), targetWeight);

      double value = currentWeight + (step * i);

      /// small realistic fluctuation
      if (isLose) {
        value += i.isEven ? 0.15 : -0.10;
      } else if (isGain) {
        value += i.isEven ? -0.10 : 0.15;
      }

      return FlSpot(i.toDouble(), value);
    });
  }

  double get minY {
    final low = min(currentWeight, targetWeight);
    return (low - 2).floorToDouble();
  }

  double get maxY {
    final high = max(currentWeight, targetWeight);
    return (high + 2).ceilToDouble();
  }

  String bottomLabel(double value) {
    final index = value.toInt();

    if (index == 0) return "Start";
    if (index == estimatedWeeks.clamp(1, 24)) return "Goal";

    if (index % 2 == 0) {
      return "W$index";
    }

    return "";
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final label = bottomLabel(value);

    if (label.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get goalText {
    if (isGain) {
      return "Healthy weight gain plan";
    }

    if (isLose) {
      return "Healthy weight loss plan";
    }

    return "Maintain your current weight";
  }

  Color get mainColor {
    if (isGain) return const Color(0xFFF59E0B);
    if (isLose) return const Color(0xFF22C55E);
    return const Color(0xFF06B6D4);
  }

  IconData get goalIcon {
    if (isGain) return Icons.trending_up_rounded;
    if (isLose) return Icons.trending_down_rounded;
    return Icons.balance_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final spots = generateSpots();
    final chartWeeks = estimatedWeeks.clamp(1, 24);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _glowCircle(mainColor.withOpacity(0.12), 270),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: _glowCircle(const Color(0xFF06B6D4).withOpacity(0.09), 310),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _iconBox(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      _badge(goalText, goalIcon, mainColor),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    "Your Weight\nProjection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    isGain
                        ? "Based on a realistic gain rate of 0.25 kg per week."
                        : isLose
                            ? "Based on a realistic loss rate of 0.5 kg per week."
                            : "Your target is same as your current weight.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.58),
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _summaryCard(),

                  const SizedBox(height: 22),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.045),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: chartWeeks.toDouble(),
                          minY: minY,
                          maxY: maxY,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (v) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.055),
                                strokeWidth: 1,
                              );
                            },
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
                                reservedSize: 30,
                                interval: max(1, chartWeeks / 6),
                                getTitlesWidget: bottomTitles,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 8,
                              color: mainColor.withOpacity(0.14),
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [
                                  mainColor,
                                  const Color(0xFF06B6D4),
                                ],
                              ),
                              barWidth: 3.5,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  final isLast = index == spots.length - 1;

                                  return FlDotCirclePainter(
                                    radius: isLast ? 7 : 4,
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                    strokeColor: mainColor,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    mainColor.withOpacity(0.22),
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
                  ),

                  const SizedBox(height: 22),

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

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor.withOpacity(0.18),
            const Color(0xFF06B6D4).withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: mainColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          _summaryItem(
            "Current",
            "${currentWeight.toStringAsFixed(1)}kg",
            Icons.monitor_weight_rounded,
            const Color(0xFF06B6D4),
          ),
          _divider(),
          _summaryItem(
            isGain ? "Gain" : isLose ? "Lose" : "Change",
            "${totalChange.toStringAsFixed(1)}kg",
            goalIcon,
            mainColor,
          ),
          _divider(),
          _summaryItem(
            "Time",
            "$estimatedWeeks wk",
            Icons.calendar_month_rounded,
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 46,
      width: 1,
      color: Colors.white.withOpacity(0.10),
    );
  }

  Widget _badge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}