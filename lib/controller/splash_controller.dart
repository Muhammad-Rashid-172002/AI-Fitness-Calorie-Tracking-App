import 'dart:async';

import 'package:fitmind_ai/view/onboarding_screen.dart';
import 'package:flutter/material.dart';

// Splash Screen Controller
class SplashController {
  static void startTimer(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }
}