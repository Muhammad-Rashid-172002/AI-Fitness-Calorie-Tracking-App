import 'dart:ui';

import 'package:fitmind_ai/controller/step_two_controller.dart';
import 'package:fitmind_ai/view/onboarding/goal_screen.dart';
import 'package:flutter/material.dart';

class TargetWeightScreen extends StatefulWidget {
  final double height;
  final double weight;

  const TargetWeightScreen({
    super.key,
    required this.height,
    required this.weight,
  });

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  final StepTwoController controller = StepTwoController();

  late double targetWeight;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    targetWeight = widget.weight;
  }

  Future<void> saveData() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final result = await controller.saveStepTwoData(
        height: widget.height.toInt(),
        weight: widget.weight.toInt(),
        targetWeight: targetWeight.toInt(),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (result == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GoalScreen(
              currentWeight: widget.weight,
              targetWeight: targetWeight,
              height: widget.height,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  double get difference => widget.weight - targetWeight;

  @override
  Widget build(BuildContext context) {
    final progress = widget.weight <= 30
        ? 0.0
        : ((targetWeight - 30) / (widget.weight - 30)).clamp(0.0, 1.0);

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
              
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: _iconBox(Icons.arrow_back_ios_new_rounded),
                        ),
                       const SizedBox(height: 30),
                        _stepBadge(),
                      ],
                    ),
              
                    const SizedBox(height: 26),
              
                    _progressLine(),
              
                    const SizedBox(height: 34),
              
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Choose Your\nTarget Weight",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 12),
              
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Set a realistic target so FitMind AI can create your personalized fitness journey.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          fontSize: 14.5,
                          height: 1.5,
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 30),
              
                    _weightHeroCard(progress),
              
                    const SizedBox(height: 24),
              
                    Row(
                      children: [
                        _miniInfoCard(
                          title: "Current",
                          value: "${widget.weight.toInt()} kg",
                          icon: Icons.monitor_weight_rounded,
                          color: const Color(0xFF06B6D4),
                        ),
                        const SizedBox(width: 12),
                        _miniInfoCard(
                          title: difference >= 0 ? "To Lose" : "To Gain",
                          value: "${difference.abs().toStringAsFixed(1)} kg",
                          icon: difference >= 0
                              ? Icons.trending_down_rounded
                              : Icons.trending_up_rounded,
                          color: difference >= 0
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
              
                   const SizedBox(height: 30),
              
                    GestureDetector(
                      onTap: isLoading ? null : saveData,
                      child: Container(
                        height: 64,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF22C55E),
                              Color(0xFF06B6D4),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.32),
                              blurRadius: 26,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Continue",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightHeroCard(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            color: Colors.white.withOpacity(0.055),
            border: Border.all(color: Colors.white.withOpacity(0.09)),
          ),
          child: Column(
            children: [
              Container(
                height: 112,
                width: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                "${targetWeight.toInt()} kg",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Target weight",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 26),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10,
                  activeTrackColor: const Color(0xFF22C55E),
                  inactiveTrackColor: Colors.white.withOpacity(0.12),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF22C55E).withOpacity(0.18),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 15,
                  ),
                ),
                child: Slider(
                  value: targetWeight,
                  min: 30,
                  max: widget.weight + 30,
                  divisions: ((widget.weight + 30) - 30).toInt(),
                  onChanged: (value) {
                    setState(() => targetWeight = value);
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "30 kg",
                    style: TextStyle(color: Colors.white.withOpacity(0.42)),
                  ),
                  Text("${(widget.weight + 30).toInt()} kg"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.48),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressLine() {
    return Row(
      children: [
        _dot(true),
        _bar(true),
        _dot(true),
        _bar(false),
        _dot(false),
        _bar(false),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      height: 13,
      width: 13,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF22C55E) : Colors.white24,
      ),
    );
  }

  Widget _bar(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? const Color(0xFF22C55E) : Colors.white12,
        ),
      ),
    );
  }

  Widget _stepBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.25)),
      ),
      child: const Text(
        "STEP 2 OF 4",
        style: TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
