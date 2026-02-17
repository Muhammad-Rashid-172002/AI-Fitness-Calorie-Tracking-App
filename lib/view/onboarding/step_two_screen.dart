import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/onboarding/step_three_Screen.dart';
import 'package:flutter/material.dart';

class StepTwoScreen extends StatefulWidget {
  const StepTwoScreen({super.key});

  @override
  State<StepTwoScreen> createState() => _StepTwoScreenState();
}

class _StepTwoScreenState extends State<StepTwoScreen> {
  double height = 170;
  double weight = 70;


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

              /// Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  Text(
                    "Step 2 of 4",
                    style: TextStyle(
                      color: textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    "SKIP",
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.50,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),

              const SizedBox(height: 35),

              /// Title
              Center(
                child: Column(
                  children: [

                    Text(
                      "Body Measurements",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "This helps us calculate your BMI and nutrition needs",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              /// Height Section
              buildSliderCard(
                title: "Height",
                unit: "cm",
                value: height,
                min: 140,
                max: 220,
                divisions: 80,
                onChanged: (val) {
                  setState(() => height = val);
                },
              ),

              const SizedBox(height: 30),

              /// Weight Section
              buildSliderCard(
                title: "Weight",
                unit: "kg",
                value: weight,
                min: 30,
                max: 150,
                divisions: 120,
                onChanged: (val) {
                  setState(() => weight = val);
                },
              ),

              const Spacer(),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 62,

                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StepThreeScreen(),
                      ),
                    );
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),

                      gradient: LinearGradient(
                        colors: [primary, accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.45),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
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
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
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

  /// Reusable Slider Card (Premium)
  Widget buildSliderCard({
    required String title,
    required String unit,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF020617),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.12),
            blurRadius: 12,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),

                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06B6D4),
                    ],
                  ),
                ),

                child: Text(
                  "${value.toInt()} $unit",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primary,
              inactiveTrackColor: const Color(0xFF1E293B),
              thumbColor: accent,
              overlayColor: primary.withOpacity(0.2),
              trackHeight: 4,
            ),

            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}