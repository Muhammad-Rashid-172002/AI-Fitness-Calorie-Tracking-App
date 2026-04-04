import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/view/FoodDetectedScreen.dart';

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
  late AnimationController _scanController;
  late AnimationController _rotateController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    /// 🔥 Scan Line Animation
    _scanController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _scanAnimation =
        Tween<double>(begin: -100, end: 100).animate(_scanController);

    _scanController.repeat(reverse: true);

    /// 🔄 Rotation Animation
    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    _startAnalysis();
  }

  void _startAnalysis() async {
    String result = await widget.analyzeFuture;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetectedScreen(
          foods: [],
          image: widget.image,
          result: result,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🔥 Scanner UI
            Stack(
              alignment: Alignment.center,
              children: [

                /// Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    widget.image,
                    height: 220,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),

                /// Glow Border
                Container(
                  height: 230,
                  width: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),

                /// Moving Scan Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 110 + _scanAnimation.value,
                      child: Container(
                        width: 200,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),

                /// Corner Borders
                _buildCorners(),
              ],
            ),

            const SizedBox(height: 40),

            /// 🔄 Loader
            RotationTransition(
              turns: _rotateController,
              child: const Icon(
                Icons.sync,
                color: Colors.greenAccent,
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            /// Title
            const Text(
              "Analyzing Your Meal",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// Subtitle
            const Text(
              "Please wait while AI analyzes your food",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 25),

            /// Steps Text
            const Text(
              "Analyzing image...\nDetecting food items...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔲 Corner Design (Scanner Look)
  Widget _buildCorners() {
    return SizedBox(
      height: 230,
      width: 230,
      child: Stack(
        children: [
          _corner(top: 0, left: 0),
          _corner(top: 0, right: 0),
          _corner(bottom: 0, left: 0),
          _corner(bottom: 0, right: 0),
        ],
      ),
    );
  }

  Widget _corner({double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.greenAccent, width: 3),
            left: BorderSide(color: Colors.greenAccent, width: 3),
            right: BorderSide(color: Colors.greenAccent, width: 3),
            bottom: BorderSide(color: Colors.greenAccent, width: 3),
          ),
        ),
      ),
    );
  }
}