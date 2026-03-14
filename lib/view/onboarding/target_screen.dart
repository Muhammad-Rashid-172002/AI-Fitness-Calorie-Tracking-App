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
        MaterialPageRoute(builder: (_) => GoalScreen()),
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

              /// Step Text
              Text(
                "Step 5 of 7",
                style: TextStyle(
                  color: textGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              /// Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.71,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              const SizedBox(height: 40),

              /// Title
              Text(
                "What is your target weight?",
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
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [primary.withOpacity(0.9), accent.withOpacity(0.9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    "${targetWeight.toInt()} kg",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              /// Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: primary,
                  overlayColor: primary.withOpacity(0.2),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 16),
                  trackHeight: 6,
                  valueIndicatorColor: primary,
                ),
                child: Slider(
                  value: targetWeight,
                  min: 30,
                  max: widget.weight,
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
                      gradient: LinearGradient(colors: [primary, accent]),
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
}