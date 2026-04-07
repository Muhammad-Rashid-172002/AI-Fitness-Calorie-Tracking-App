import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class WeightProgressCard extends StatelessWidget {
  final double current;
  final double target;
  final double progress; // 0 to 100
  final double remaining;
  final String motivation;
  final double? percentChange; // New
  final bool? isLosing;        // New

  const WeightProgressCard({
    super.key,
    required this.current,
    required this.target,
    required this.progress,
    required this.remaining,
    required this.motivation,
    this.percentChange,
    this.isLosing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    return Center(
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER: Current and Target Weight
            Column(
              children: [
                const Text(
                  "CURRENT WEIGHT",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$current kg",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),

                /// PERCENT CHANGE INDICATOR
                if (percentChange != null && isLosing != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${isLosing! ? '⬇' : '⬆'} ${percentChange!.toStringAsFixed(1)}% ${isLosing! ? 'lost' : 'gained'}",
                      style: TextStyle(
                        color: isLosing! ? Colors.redAccent : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "TARGET WEIGHT: ",
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      TextSpan(
                        text: "${target.toStringAsFixed(1)} kg",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// CIRCULAR PROGRESS: Half Circle
            SizedBox(
              height: 160,
              width: cardWidth * 0.8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(cardWidth * 0.8, 160),
                    painter: HalfCirclePainter(progress: progress / 100),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "${progress.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "COMPLETED",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// REMAINING
            Text(
              "${remaining.toStringAsFixed(1)} kg remaining",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            /// MOTIVATION TEXT
            Text(
              motivation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for half-circle progress
class HalfCirclePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  HalfCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw background semi-circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}