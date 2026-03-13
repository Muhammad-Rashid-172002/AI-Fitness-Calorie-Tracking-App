import 'package:fitmind_ai/view/onboarding/WeightScreen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {

  double height = 170;

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
                "Step 3 of 7",
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
                  value: 0.42,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),

              const SizedBox(height: 40),

              /// Title
              Text(
                "What is your height?",
                style: TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// Height Value Card
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [primary, accent],
                    ),
                  ),
                  child: Text(
                    "${height.toInt()} cm",
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
                value: height,
                min: 140,
                max: 220,
                divisions: 80,
                onChanged: (value) {
                  setState(() {
                    height = value;
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
                        builder: (_) => WeightScreen(height: height),
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
                        )

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