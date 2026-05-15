import 'dart:math' as math;
import 'package:flutter/material.dart';

class FirePulseIcon extends StatefulWidget {
  const FirePulseIcon({super.key});

  @override
  State<FirePulseIcon> createState() => _FirePulseIconState();
}

class _FirePulseIconState extends State<FirePulseIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    /// PULSE
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    /// ROTATION
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 10, end: 26).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_rotateController.value * math.pi * 2) * 0.08,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF22C55E),
                    Color(0xFF06B6D4),
                    Color(0xFF3B82F6),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.55),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: 2,
                  ),
                ],

                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.4,
                ),
              ),

              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// INNER GLOW
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),

                  /// FIRE ICON
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 28,
                  ),

                  /// SHINE EFFECT
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
