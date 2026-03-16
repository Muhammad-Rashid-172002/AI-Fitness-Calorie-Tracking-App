import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/onboarding/result_screen.dart';

class WeightProjectionScreen extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;

  const WeightProjectionScreen({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
  });

  /// Generate weight timeline
  List<Map<String, String>> generateTimeline() {
    int weeks = 5;
    double diff = currentWeight - targetWeight;
    double step = diff / weeks;

    List<Map<String, String>> timeline = [];

    for (int i = 0; i <= weeks; i++) {
      double weight = currentWeight - (step * i);

      String label;

      if (i == 0) {
        label = "Today";
      } else if (i == weeks) {
        label = "Goal";
        weight = targetWeight;
      } else {
        label = "Week ${i * 2}";
      }

      timeline.add({
        "week": label,
        "weight": "${weight.toStringAsFixed(1)} kg"
      });
    }

    return timeline;
  }

  Widget timelineItem(String week, String weight, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// DOT + LINE
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [primary, accent]),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: primary.withOpacity(0.3),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          /// CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    week,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      weight,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final timeline = generateTimeline();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 30),

              const Text(
                "Your Weight Journey",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Your estimated progress based on your goal.",
                style: TextStyle(
                  color: textGrey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 40),

              /// Dynamic timeline
              ...List.generate(
                timeline.length,
                (index) => timelineItem(
                  timeline[index]["week"]!,
                  timeline[index]["weight"]!,
                  index == timeline.length - 1,
                ),
              ),

              const Spacer(),

              CustomGradientButton(
                text: "Continue",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResultScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}