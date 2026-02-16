import 'package:fitmind_ai/view/profile_view.dart';
import 'package:flutter/material.dart';

// 
class OnboardingController {

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileView(),
      ),
    );
  }
}