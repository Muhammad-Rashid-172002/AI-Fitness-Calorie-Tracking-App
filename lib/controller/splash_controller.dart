import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/view/onboarding_screen.dart';

class SplashService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void isLogin(BuildContext context) {

    try {

      final User? user = _auth.currentUser;

      Timer(const Duration(seconds: 2), () {

        // User Already Logged In → Home
        if (user != null) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainView(),
            ),
          );

        }

        // Not Logged In → Login
        else {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            ),
          );

        }

      });

    } catch (e) {

      debugPrint("Auth Error: $e");

      // Error → Send to Login
      Timer(const Duration(seconds: 2), () {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );

      });

    }
  }
}