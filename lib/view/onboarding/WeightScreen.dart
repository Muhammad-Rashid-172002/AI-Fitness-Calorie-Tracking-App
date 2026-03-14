import 'package:fitmind_ai/view/onboarding/target_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';

class WeightScreen extends StatefulWidget {
  final double height;
  const WeightScreen({super.key, required this.height});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double weight = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // simple static background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Step Text
              Text(
                "Step 4 of 7",
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
                  value: 0.57,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              const SizedBox(height: 40),

              /// Title
              Text(
                "What is your weight?",
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

              /// Weight Display Card with frosted-glass effect
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
                    "${weight.toInt()} kg",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              /// Slider with modern styling
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
                  value: weight,
                  min: 30,
                  max: 150,
                  divisions: 120,
                  label: "${weight.toInt()} kg",
                  onChanged: (value) {
                    setState(() => weight = value);
                  },
                ),
              ),
              const Spacer(),

              /// Continue Button with gradient and shadow
              SizedBox(
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TargetWeightScreen(
                          height: widget.height,
                          weight: weight,
                        ),
                      ),
                    );
                  },
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
                    child: const Center(
                      child: Row(
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
                          )
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