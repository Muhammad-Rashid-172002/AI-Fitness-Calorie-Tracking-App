import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/view/auth_view/login_Screen.dart';
import 'package:fitmind_ai/view/onboarding/gender.dart';
import 'package:flutter/material.dart';

void checkVerification(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await user.reload(); // Refresh data
    user = FirebaseAuth.instance.currentUser;

    if (user!.emailVerified) {
      // ✅ Go to StepOneScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GenderScreen()),
      );
    } else {
      // ❌ Not verified yet
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }
}
