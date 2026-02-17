import 'package:fitmind_ai/controller/splash_controller.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SplashController.startTimer(context);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF0F172A), // Deep Dark Background
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // App Logo
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF22C55E), // Green
                  Color(0xFF06B6D4), // Cyan
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF22C55E).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "N",
                style: TextStyle(
                  fontSize: 52,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // App Name
          const Text(
            "NutriMind AI",
            style: TextStyle(
              fontSize: 30,
              color: Color(0xFFF8FAFC),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // Tagline
          const Text(
            "Your personal AI nutrition coach\nTrack smarter, eat better",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 35),

          // Loading Indicator
          const CircularProgressIndicator(
            color: Color(0xFF22C55E),
            strokeWidth: 3,
          ),
        ],
      ),
    ),
  );
}}