import 'package:fitmind_ai/view/onboarding/goal_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/step_two_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';

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
    targetWeight = widget.weight - 5; // default target
  }

  Future<void> saveData() async {
    setState(() => isLoading = true);

    String? result = await controller.saveStepTwoData(
      height: widget.height.toInt(),
      weight: widget.weight.toInt(),
      targetWeight: targetWeight.toInt(),
    );

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
      
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
                  const SizedBox(width: 8),
                  _progress(false),
                  const SizedBox(width: 8),
                  _progress(false),
                ],
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Step 2 of 6",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
      
              /// Title
              Text(
                "Set Your Target Weight",
                style: TextStyle(
                  color: textMain,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
      
              /// Target Weight Card
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.85),
                        accent.withOpacity(0.85),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${targetWeight.toInt()} kg",
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Slide to adjust your goal",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
      
              /// Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: primary,
                  overlayColor: primary.withOpacity(0.2),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 18),
                  trackHeight: 6,
                  valueIndicatorColor: primary,
                  valueIndicatorTextStyle:
                      const TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: targetWeight,
                  min: 30,
                  max: widget.weight,
                  divisions: (widget.weight - 30).toInt(),
                  label: "${targetWeight.toInt()} kg",
                  onChanged: (value) {
                    setState(() => targetWeight = value);
                  },
                ),
              ),
              const Spacer(),
      
              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: isLoading ? null : saveData,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [primary, accent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
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
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  /// Progress Indicator
  Widget _progress(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 35 : 20,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: active
            ? const LinearGradient(
                colors: [
                  Color(0xFF22C55E), // Green
                  Color(0xFF06B6D4), // Cyan
                  Color(0xFF38BDF8), // Light Blue
                ],
              )
            : null,
        color: active ? null : Colors.white24,
      ),
    );
  }
}