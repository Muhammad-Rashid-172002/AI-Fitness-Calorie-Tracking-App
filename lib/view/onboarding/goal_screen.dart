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

  late final AnimationController _animationController;

  int selectedIndex = 2;
  bool isLoading = false;

  final List<GoalItem> goals = const [
    GoalItem(
      title: "Lose Weight",
      subtitle: "Burn fat and reduce calories",
      icon: Icons.trending_down_rounded,
      emoji: "📉",
      color1: Color(0xFFEF4444),
      color2: Color(0xFFF97316),
    ),
    GoalItem(
      title: "Maintain Weight",
      subtitle: "Stay healthy and balanced",
      icon: Icons.balance_rounded,
      emoji: "⚖️",
      color1: Color(0xFF06B6D4),
      color2: Color(0xFF3B82F6),
    ),
    GoalItem(
      title: "Gain Weight",
      subtitle: "Build muscle and strength",
      icon: Icons.fitness_center_rounded,
      emoji: "💪",
      color1: Color(0xFF22C55E),
      color2: Color(0xFF14B8A6),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final selectedGoal = goals[selectedIndex].title;

    final result = await _controller.saveStepThreeData(goal: selectedGoal);

    if (!mounted) return;

    setState(() => isLoading = false);

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
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedGoal = goals[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (_, __) {
              return Positioned(
                top: -125 + (_animationController.value * 35),
                right: -95,
                child: _glowCircle(
                  color: selectedGoal.color1.withOpacity(0.14),
                  size: 290,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (_, __) {
              return Positioned(
                bottom: -150,
                left: -110 + (_animationController.value * 40),
                child: _glowCircle(
                  color: selectedGoal.color2.withOpacity(0.12),
                  size: 320,
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _iconBox(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      _stepBadge(),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _progressLine(),
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Choose Your\nFitness Goal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select your goal so FitMind AI can build the right calorie and nutrition plan for you.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        fontSize: 14.5,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  _selectedGoalPreview(selectedGoal),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];

                        return _goalCard(
                          index: index,
                          goal: goal,
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: isLoading ? null : _saveAndContinue,
                    child: Container(
                      height: 64,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF06B6D4),
                            Color(0xFF3B82F6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withOpacity(0.32),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedGoalPreview(GoalItem selectedGoal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [selectedGoal.color1, selectedGoal.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: selectedGoal.color1.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.20),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Center(
              child: Text(
                selectedGoal.emoji,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selected Goal",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedGoal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  selectedGoal.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard({
    required int index,
    required GoalItem goal,
  }) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? goal.color1.withOpacity(0.14)
              : Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? goal.color1.withOpacity(0.75) : Colors.white10,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(colors: [goal.color1, goal.color2])
                    : null,
                color: selected ? null : Colors.white.withOpacity(0.055),
              ),
              child: selected
                  ? Icon(goal.icon, color: Colors.white, size: 28)
                  : Center(
                      child: Text(
                        goal.emoji,
                        style: const TextStyle(fontSize: 27),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    goal.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.52),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [goal.color1, goal.color2]),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressLine() {
    return Row(
      children: [
        _dot(true),
        _bar(true),
        _dot(true),
        _bar(true),
        _dot(true),
        _bar(false),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      height: 13,
      width: 13,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF22C55E) : Colors.white24,
      ),
    );
  }

  Widget _bar(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? const Color(0xFF22C55E) : Colors.white12,
        ),
      ),
    );
  }

  Widget _stepBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF22C55E).withOpacity(0.25),
        ),
      ),
      child: const Text(
        "STEP 3 OF 4",
        style: TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class GoalItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final Color color1;
  final Color color2;

  const GoalItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.color1,
    required this.color2,
  });
}