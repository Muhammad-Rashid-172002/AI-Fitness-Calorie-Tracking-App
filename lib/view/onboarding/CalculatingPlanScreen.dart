import 'dart:async';
import 'dart:ui';

import 'package:fitmind_ai/view/onboarding/WeightProjectionScreen.dart';
import 'package:flutter/material.dart';

class CalculatingPlanScreen extends StatefulWidget {
  final double weight;
  final double targetWeight;

  const CalculatingPlanScreen({
    super.key,
    required this.weight,
    required this.targetWeight,
  });

  @override
  State<CalculatingPlanScreen> createState() => _CalculatingPlanScreenState();
}

class _CalculatingPlanScreenState extends State<CalculatingPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  Timer? _stepTimer;
  Timer? _navigationTimer;

  int activeStep = 0;

  final List<String> steps = const [
    "Analyzing your body data",
    "Estimating daily calories",
    "Calculating macro targets",
    "Creating your fitness roadmap",
  ];

  bool get isGain => widget.targetWeight > widget.weight;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    _animateSteps();

    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WeightProjectionScreen(
            currentWeight: widget.weight,
            targetWeight: widget.targetWeight,
          ),
        ),
      );
    });
  }

  void _animateSteps() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 850), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (activeStep < steps.length - 1) {
        setState(() => activeStep++);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _navigationTimer?.cancel();
    _spinController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final change = (widget.targetWeight - widget.weight).abs();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -90,
            child: _glowCircle(
              color: const Color(0xFF22C55E).withOpacity(0.15),
              size: 290,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.12),
              size: 320,
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),

                          _aiOrb(),

                          const SizedBox(height: 26),

                          const Text(
                            "Building Your\nAI Fitness Plan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.08,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "FitMind AI is creating a personalized plan based on your body data, activity level, and target weight.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.58),
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 20),

                          _goalPreviewCard(change),

                          const SizedBox(height: 18),

                          _progressCard(),

                          const SizedBox(height: 16),

                          _stepsCard(),

                          const SizedBox(height: 20),

                          Text(
                            "Please wait while we prepare your smart health journey...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.40),
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiOrb() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final scale = 0.94 + (_pulseController.value * 0.10);

        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF22C55E).withOpacity(0.22),
                      const Color(0xFF06B6D4).withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              RotationTransition(
                turns: _spinController,
                child: Container(
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFF22C55E),
                        Color(0xFF06B6D4),
                        Color(0xFF3B82F6),
                        Color(0xFF22C55E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.35),
                        blurRadius: 35,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF020617),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06B6D4),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.28),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _goalPreviewCard(double change) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              _miniItem(
                title: "Current",
                value: "${widget.weight.toStringAsFixed(1)} kg",
                icon: Icons.monitor_weight_rounded,
                color: const Color(0xFF06B6D4),
              ),
              _divider(),
              _miniItem(
                title: isGain ? "To Gain" : "To Lose",
                value: "${change.toStringAsFixed(1)} kg",
                icon: isGain
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isGain
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF22C55E),
              ),
              _divider(),
              _miniItem(
                title: "Target",
                value: "${widget.targetWeight.toStringAsFixed(1)} kg",
                icon: Icons.flag_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 42,
      width: 1,
      color: Colors.white.withOpacity(0.10),
    );
  }

  Widget _miniItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (_, __) {
          final percent = (_progressController.value * 100).toInt();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF22C55E),
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$percent% completed",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "AI Plan",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 10,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(steps.length, (index) {
          final active = activeStep == index;
          final done = index < activeStep;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == steps.length - 1 ? 0 : 12,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active || done
                        ? const Color(0xFF22C55E)
                        : Colors.white.withOpacity(0.08),
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : Icons.circle,
                    color: Colors.white,
                    size: done ? 17 : 7,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (active)
                  const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF22C55E),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}