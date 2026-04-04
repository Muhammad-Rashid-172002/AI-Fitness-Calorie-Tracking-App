import 'dart:io';

import 'package:fitmind_ai/view/FoodDetectedScreen.dart';

import 'package:flutter/material.dart';


class AnalyzingScreen extends StatefulWidget {
  final File image;
  final Future<String> analyzeFuture;

  const AnalyzingScreen({
    super.key,
    required this.image,
    required this.analyzeFuture,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    _startAnalysis();
  }

  void _startAnalysis() async {
    String result = await widget.analyzeFuture;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetectedScreen(
          foods: [],
         // food: Food(name: result, shortMsg: result),
          image: widget.image,
          result: result,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// 🔥 Image Card (Premium Style)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    widget.image,
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              /// 🔄 Animated Loader (Better than default)
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.greenAccent,
                      width: 4,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.greenAccent,
                      size: 32,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// ✨ Title (Glowing Style)
              const Text(
                "Analyzing Your Meal",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              /// 💬 Subtitle
              const Text(
                "Please wait while AI analyzes your food",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              /// ⚡ Fake Progress Text (Client Style Feel)
              const Text(
                "Identifying ingredients...\nCalculating calories...\nAlmost done...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}