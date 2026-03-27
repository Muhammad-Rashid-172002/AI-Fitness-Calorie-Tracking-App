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

class _CalculatingPlanScreenState extends State<CalculatingPlanScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    /// animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    /// navigate after 3 sec
    Future.delayed(const Duration(seconds: 3), () {

      if(!mounted) return;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget stepItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget loadingDots(){
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        int dotCount = (_controller.value * 3).floor();

        return Text(
          "." * dotCount,
          style: TextStyle(
            fontSize: 28,
            color: primary,
            fontWeight: FontWeight.bold
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// animated progress
              RotationTransition(
                turns: _controller,
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primary, accent],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Calculating your personalized plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              loadingDots(),

              const SizedBox(height: 35),

              stepItem("Analyzing your body data"),

              stepItem("Estimating daily calories"),

              stepItem("Creating your nutrition targets"),

            ],
          ),
        ),
      ),
    );
  }
}