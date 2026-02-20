import 'dart:io';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:fitmind_ai/view/scan_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';

class AnalyzingScreen extends StatefulWidget {
  final File image;
  final Future<String> analyzeFuture; // <-- Future<String>

  const AnalyzingScreen({
    super.key,
    required this.image,
    required this.analyzeFuture,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() async {
    // Wait for AI analysis
    String result = await widget.analyzeFuture;

    if (!mounted) return;

    // Navigate to ScanResultScreen with result string
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          food: Food(name: result, shortMsg: result),
          image: widget.image,
          result: result, // <-- Use the string returned by ScanController
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// Image Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  widget.image,
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 40),

              /// Loader
              const SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 30),

              /// Main Text
              const Text(
                "Analyzing your food...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// Sub Text
              const Text(
                "Our AI is identifying food and calculating nutrition",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}