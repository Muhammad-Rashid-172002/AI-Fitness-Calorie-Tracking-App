import 'package:fitmind_ai/view/auth_view/signup_screen.dart';
import 'package:flutter/material.dart';

//
class OnboardingController {
  static void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }
}
