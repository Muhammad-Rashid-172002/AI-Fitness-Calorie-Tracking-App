import 'package:flutter/material.dart';

class HalfCirclePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  HalfCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;

    /// Background half-circle
    final backgroundPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    /// Progress arc with gradient
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    /// Rectangle covering half circle
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height * 2,
    );

    /// DRAW BACKGROUND ARC (half circle)
    canvas.drawArc(
      rect,
      3.14, // start from left
      3.14, // half circle (180 degrees)
      false,
      backgroundPaint,
    );

    /// DRAW PROGRESS ARC based on weight progress
    canvas.drawArc(
      rect,
      3.14, // start from left
      3.14 * progress, // progress fraction
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}