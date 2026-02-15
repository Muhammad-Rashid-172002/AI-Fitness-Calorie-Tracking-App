import 'package:fitmind_ai/view/login_screen.dart';
import 'package:flutter/material.dart';

// 
class OnboardingController {

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}