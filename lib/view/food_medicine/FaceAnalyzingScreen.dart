import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fitmind_ai/view/food_medicine/FaceResultScreen.dart';
import 'package:flutter/material.dart';

class FaceAnalyzingScreen extends StatefulWidget {
  final File image;
  final Future<String> analyzeFuture;

  const FaceAnalyzingScreen({
    super.key,
    required this.image,
    required this.analyzeFuture,
  });

  @override
  State<FaceAnalyzingScreen> createState() => _FaceAnalyzingScreenState();
}

class _FaceAnalyzingScreenState extends State<FaceAnalyzingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  int currentStep = 0;

  final List<String> steps = const [
    "Preparing face image",
    "Scanning skin details",
    "Detecting facial patterns",
    "Generating AI face report",
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runStepAnimation();
    _startAnalysis();
  }

  void _runStepAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 850));

      if (!mounted) return false;

      setState(() {
        currentStep = (currentStep + 1) % steps.length;
      });

      return true;
    });
  }

  Future<void> _startAnalysis() async {
    try {
      final result = await widget.analyzeFuture.timeout(
        const Duration(seconds: 35),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FaceResultScreen(image: widget.image, result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Face analysis failed")));

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isSmall = height < 720;

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _glowCircle(
              color: const Color(0xFF8B5CF6).withOpacity(0.20),
              size: 270,
            ),
          ),

          Positioned(
            bottom: -140,
            left: -100,
            child: _glowCircle(
              color: const Color(0xFFEC4899).withOpacity(0.16),
              size: 290,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 18 : 24,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _badge(),
                        const Spacer(),
                        const Text(
                          "Face AI",
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 24 : 42),

                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: _imagePreview(isSmall),
                    ),

                    SizedBox(height: isSmall ? 24 : 34),

                    Text(
                      "Analyzing Your\nFace & Skin",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 25 : 30,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "FitMind AI is scanning your face image and generating smart AI skin insights.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: isSmall ? 13 : 14,
                        height: 1.45,
                      ),
                    ),

                    SizedBox(height: isSmall ? 22 : 30),

                    _progressCard(),

                    SizedBox(height: isSmall ? 18 : 24),

                    _stepsCard(),

                    const SizedBox(height: 22),

                    Text(
                      "Please wait while AI completes the scan",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePreview(bool isSmall) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.file(
          widget.image,
          height: isSmall ? 170 : 210,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _progressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${(_progressController.value * 100).toStringAsFixed(0)}% completed",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 11,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFEC4899)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final active = index == currentStep;
          final done = index < currentStep;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == steps.length - 1 ? 0 : 14,
            ),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.circle,
                  color: active || done
                      ? const Color(0xFFEC4899)
                      : Colors.white24,
                  size: 22,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.face_retouching_natural_rounded,
            color: Color(0xFFEC4899),
            size: 17,
          ),
          SizedBox(width: 8),
          Text(
            "Face Scanner",
            style: TextStyle(
              color: Color(0xFFEC4899),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle({required Color color, required double size}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
