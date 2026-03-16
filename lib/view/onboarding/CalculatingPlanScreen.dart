import 'package:fitmind_ai/view/onboarding/WeightProjectionScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fitmind_ai/resources/app_them.dart';

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

class _CalculatingPlanScreenState extends State<CalculatingPlanScreen> {

  @override
  void initState() {
    super.initState();

    /// Wait 3 seconds then move to next screen
    Future.delayed(const Duration(seconds: 3), () {

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

  Widget stepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget stepText(String text){
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.green,
              ),

              const SizedBox(height: 35),

              const Text(
                "Calculating your personalized plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  stepText("Analyzing your body data"),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  stepText("Estimating daily calories"),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  stepText("Creating your nutrition targets"),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}