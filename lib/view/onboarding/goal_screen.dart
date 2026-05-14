import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/step_three_controller.dart';
import 'package:fitmind_ai/view/onboarding/Step_four_screen.dart';

class GoalScreen extends StatefulWidget {
  final double currentWeight;
  final double targetWeight;
  final double height;

  const GoalScreen({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen>
    with SingleTickerProviderStateMixin {
  final StepThreeController _controller = StepThreeController();

AnimationController? _animationController;

  int selectedIndex = 2;
  bool isLoading = false;

  final List<Map<String, dynamic>> goals = [
    {
      "title": "Lose Weight",
      "subtitle": "Reduce body fat and calories",
      "icon": "📉",
      "color1": const Color(0xFFEF4444),
      "color2": const Color(0xFFF97316),
    },
    {
      "title": "Maintain Weight",
      "subtitle": "Stay healthy and balanced",
      "icon": "⚖️",
      "color1": const Color(0xFF06B6D4),
      "color2": const Color(0xFF3B82F6),
    },
    {
      "title": "Gain Weight",
      "subtitle": "Build muscle and strength",
      "icon": "💪",
      "color1": const Color(0xFF22C55E),
      "color2": const Color(0xFF14B8A6),
    },
  ];

  @override
   @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animationController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final selectedGoal =
        goals[selectedIndex]["title"]?.toString() ?? "Lose Weight";

    final result = await _controller.saveStepThreeData(
      goal: selectedGoal,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StepFourScreen(
            weight: widget.currentWeight,
            targetWeight: widget.targetWeight,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          /// TOP GLOW
          Positioned(
            top: -120,
            left: -90,
            child: AnimatedBuilder(
              animation: _animationController ?? kAlwaysDismissedAnimation,
              builder: (_, __) {
                return Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF22C55E,
                    ).withOpacity(
                      0.08 +(_animationController?.value ?? 0.0)
                    ),
                  ),
                );
              },
            ),
          ),

          /// BOTTOM GLOW
          Positioned(
            bottom: -130,
            right: -100,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  /// TOP BAR
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "STEP 3 OF 4",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "What's Your Goal?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Select your fitness goal",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.builder(
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];

                        final isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isSelected
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.04),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.white12,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  goal["icon"],
                                  style: const TextStyle(fontSize: 30),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal["title"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        goal["subtitle"],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  GestureDetector(
                    onTap: isLoading ? null : _saveAndContinue,
                    child: Container(
                      height: 65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF06B6D4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}