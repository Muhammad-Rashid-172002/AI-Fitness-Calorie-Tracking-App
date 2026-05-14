import 'package:fitmind_ai/controller/step_two_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
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
    targetWeight = widget.weight - 5;
  }

  Future<void> saveData() async {
    setState(() => isLoading = true);

    try {
      String? result = await controller.saveStepTwoData(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      body: Stack(
        children: [
          /// Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF111827),
                  Color(0xFF020617),
                ],
              ),
            ),
          ),

          /// Glow Effects
          Positioned(
            top: -120,
            right: -70,
            child: _glowCircle(
              color: primary.withOpacity(0.18),
              size: 240,
            ),
          ),

          Positioned(
            bottom: -100,
            left: -60,
            child: _glowCircle(
              color: accent.withOpacity(0.14),
              size: 220,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _progress(false),
                      const SizedBox(width: 8),
                      _progress(true),
                      const SizedBox(width: 8),
                      _progress(false),
                      const SizedBox(width: 8),
                      _progress(false),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// Step Text
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: const Text(
                        "STEP 2 OF 4",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Heading
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFF67E8F9),
                          Color(0xFF22C55E),
                        ],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      "Set Your\nTarget Weight",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Adjust your target weight to personalize your fitness transformation journey.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Premium Weight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 34),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),

                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primary.withOpacity(0.95),
                          accent.withOpacity(0.95),
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.45),
                          blurRadius: 35,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "TARGET WEIGHT",
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          "${targetWeight.toInt()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 58,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "KG",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  /// Weight Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "30 kg",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${widget.weight.toInt()} kg",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accent,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: primary,
                      overlayColor: primary.withOpacity(0.2),
                      trackHeight: 7,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 16,
                      ),
                    ),
                    child: Slider(
                      value: targetWeight,
                      min: 30,
                      max: widget.weight,
                      divisions: (widget.weight - 30).toInt(),

                      onChanged: (value) {
                        setState(() {
                          targetWeight = value;
                        });
                      },
                    ),
                  ),

                  const Spacer(),

                  /// Continue Button
                  GestureDetector(
                    onTap: isLoading ? null : saveData,

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      width: double.infinity,
                      height: 64,

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
                            color: primary.withOpacity(0.45),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
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
                                    size: 24,
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

          /// Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),

              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF22C55E),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Progress
  Widget _progress(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      width: active ? 40 : 18,
      height: 7,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),

        gradient: active
            ? const LinearGradient(
                colors: [
                  Color(0xFF22C55E),
                  Color(0xFF06B6D4),
                  Color(0xFF3B82F6),
                ],
              )
            : null,

        color: active
            ? null
            : Colors.white.withOpacity(0.12),
      ),
    );
  }

  /// Glow Circle
  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}