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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// Weight Value Card
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [primary, accent],
                    ),
                  ),
                  child: Text(
                    "${weight.toInt()} kg",
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Slider
              Slider(
                value: weight,
                min: 30,
                max: 150,
                divisions: 120,
                onChanged: (value){
                  setState(() {
                    weight = value;
                  });
                },
              ),

              const Spacer(),

              /// Continue Button
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
                      gradient: LinearGradient(
                        colors: [primary, accent],
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
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

              const SizedBox(height: 25),

            ],
          ),
        ),
      ),
    );
  }
}