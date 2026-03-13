import 'package:fitmind_ai/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashService().isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Dark Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // App Logo with Gradient + Shadow
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF22C55E), // Green
                    Color(0xFF06B6D4), // Cyan
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF22C55E).withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Color(0xFF06B6D4).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Image(
                  image: AssetImage("assets/splash_icon.png"),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // App Name
            const Text(
              "MyDiet",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 10),

            // Tagline / Subtitle
            const Text(
              "Your personal AI nutrition coach\nTrack smarter, eat better",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF94A3B8),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 50),

            // Loading Indicator
            SizedBox(
              height: 80,
              width: 80,
              child: Center(
                child: SpinKitFadingCircle(
                  color: Color(0xFF22C55E),
                  size: 60.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}