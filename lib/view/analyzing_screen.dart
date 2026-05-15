import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:fitmind_ai/view/scan_result_screen.dart';
import 'package:flutter/material.dart';

class AnalyzingScreen extends StatefulWidget {
  final File image;
  final Future<String> analyzeFuture;

  const AnalyzingScreen({
    super.key,
    required this.image,
    required this.analyzeFuture,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  int currentStep = 0;
  bool hasError = false;
  String errorTitle = "";
  String errorMessage = "";

  final List<String> steps = const [
    "Preparing image",
    "Detecting food items",
    "Estimating calories",
    "Building nutrition report",
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
      if (!mounted || hasError) return false;

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

      final ScanController controller = ScanController();
      final Food parsedFood = controller.parseFoodFromResult(result);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            image: widget.image,
            result: result,
            food: parsedFood,
          ),
        ),
      );
    } on SocketException {
      _showError(
        title: "No Internet Connection",
        message:
            "Your internet is not working. Please check Wi-Fi or mobile data and try again.",
      );
    } on TimeoutException {
      _showError(
        title: "Slow Internet Connection",
        message:
            "The analysis is taking too long. Please use a stronger connection and try again.",
      );
    } catch (e) {
      _showError(
        title: "Analysis Failed",
        message:
            "We couldn’t analyze this meal right now. Please check your internet and try again.",
      );
    }
  }

  void _showError({required String title, required String message}) {
    if (!mounted) return;

    _pulseController.stop();
    _progressController.stop();

    setState(() {
      hasError = true;
      errorTitle = title;
      errorMessage = message;
    });
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
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _glowCircle(
              color: const Color(0xFF22C55E).withOpacity(0.13),
              size: 270,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.11),
              size: 290,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 18 : 24,
                vertical: 18,
              ),
              child: hasError ? _errorView(isSmall) : _loadingView(isSmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingView(bool isSmall) {
    return Column(
      children: [
        Row(
          children: [
            _smallBadge(Icons.auto_awesome_rounded, "AI Scanner"),
            const Spacer(),
            const Text(
              "Analyzing",
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
          child: _imagePreviewCard(isSmall),
        ),

        SizedBox(height: isSmall ? 24 : 34),

        Text(
          "Creating Your\nNutrition Report",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 24 : 28,
            fontWeight: FontWeight.bold,
            height: 1.12,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "FitMind AI is analyzing your meal photo and estimating calories, protein, carbs, and fat.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: isSmall ? 13 : 14,
            height: 1.45,
          ),
        ),

        SizedBox(height: isSmall ? 20 : 28),

        _progressCard(),

        SizedBox(height: isSmall ? 16 : 22),

        _stepsCard(),

        SizedBox(height: isSmall ? 18 : 26),

        Text(
          "Please keep this screen open",
          style: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 12),
        ),
      ],
    );
  }

  Widget _errorView(bool isSmall) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _iconBox(Icons.arrow_back_ios_new_rounded),
            ),
            const Spacer(),
            _smallBadge(Icons.wifi_off_rounded, "Connection Issue"),
          ],
        ),

        SizedBox(height: isSmall ? 22 : 34),

        _imagePreviewCard(isSmall),

        SizedBox(height: isSmall ? 20 : 28),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmall ? 18 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Container(
                height: isSmall ? 58 : 68,
                width: isSmall ? 58 : 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.14),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.redAccent,
                  size: isSmall ? 30 : 34,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                errorTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 20 : 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: isSmall ? 13 : 14,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: _actionButton(text: "Go Back", filled: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: _actionButton(text: "Try Again", filled: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagePreviewCard(bool isSmall) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          widget.image,
          height: isSmall ? 185 : 240,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _progressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
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
                  minHeight: 10,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final active = index == currentStep;
          final done = index < currentStep;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == steps.length - 1 ? 0 : 12,
            ),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.circle,
                  color: active || done
                      ? const Color(0xFF22C55E)
                      : Colors.white24,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _actionButton({required String text, required bool filled}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
              )
            : null,
        color: filled ? null : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: filled ? Colors.transparent : Colors.white.withOpacity(0.10),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: filled ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _smallBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF22C55E), size: 16),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
