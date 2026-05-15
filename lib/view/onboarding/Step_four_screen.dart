import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/step_four_controller.dart';
import 'package:fitmind_ai/view/onboarding/CalculatingPlanScreen.dart';

class StepFourScreen extends StatefulWidget {
  final double weight;
  final double targetWeight;

  const StepFourScreen({
    super.key,
    required this.weight,
    required this.targetWeight,
  });

  @override
  State<StepFourScreen> createState() => _StepFourScreenState();
}

class _StepFourScreenState extends State<StepFourScreen>
    with SingleTickerProviderStateMixin {
  final StepFourController _controller = StepFourController();

  late final AnimationController _animationController;

  int selectedIndex = 0;
  bool isLoading = false;

  final List<ActivityItem> activities = const [
    ActivityItem(
      title: "Sedentary",
      subtitle: "Little or no exercise",
      icon: Icons.weekend_rounded,
      emoji: "🛋️",
      color1: Color(0xFF64748B),
      color2: Color(0xFF334155),
    ),
    ActivityItem(
      title: "Lightly Active",
      subtitle: "Light exercise 1-3 days/week",
      icon: Icons.directions_walk_rounded,
      emoji: "🚶",
      color1: Color(0xFF06B6D4),
      color2: Color(0xFF3B82F6),
    ),
    ActivityItem(
      title: "Moderately Active",
      subtitle: "Moderate exercise 3-5 days/week",
      icon: Icons.fitness_center_rounded,
      emoji: "💪",
      color1: Color(0xFF22C55E),
      color2: Color(0xFF14B8A6),
    ),
    ActivityItem(
      title: "Very Active",
      subtitle: "Hard exercise 6-7 days/week",
      icon: Icons.local_fire_department_rounded,
      emoji: "🔥",
      color1: Color(0xFFF97316),
      color2: Color(0xFFEF4444),
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

    try {
      final selectedActivity = activities[selectedIndex].title;

      final result = await _controller.saveStepFourData(
        activityLevel: selectedActivity,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (result == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CalculatingPlanScreen(
              weight: widget.weight,
              targetWeight: widget.targetWeight,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedActivity = activities[selectedIndex];

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
                  color: selectedActivity.color1.withOpacity(0.14),
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
                  color: selectedActivity.color2.withOpacity(0.12),
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
                      _iconBox(Icons.directions_run_rounded),
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
                      "Choose Your\nActivity Level",
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
                      "This helps FitMind AI calculate your daily calories and build the right plan for your lifestyle.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        fontSize: 14.5,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  _selectedActivityPreview(selectedActivity),

                  const SizedBox(height: 22),

                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return _activityCard(
                          index: index,
                          activity: activities[index],
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
                                    "Create My Plan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.auto_awesome_rounded,
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

  Widget _selectedActivityPreview(ActivityItem activity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [activity.color1, activity.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: activity.color1.withOpacity(0.28),
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
                activity.emoji,
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
                  "Selected Activity",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  activity.subtitle,
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

  Widget _activityCard({
    required int index,
    required ActivityItem activity,
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
              ? activity.color1.withOpacity(0.14)
              : Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? activity.color1.withOpacity(0.75)
                : Colors.white10,
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
                    ? LinearGradient(
                        colors: [activity.color1, activity.color2],
                      )
                    : null,
                color: selected ? null : Colors.white.withOpacity(0.055),
              ),
              child: selected
                  ? Icon(activity.icon, color: Colors.white, size: 28)
                  : Center(
                      child: Text(
                        activity.emoji,
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
                    activity.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.subtitle,
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
                  gradient: LinearGradient(
                    colors: [activity.color1, activity.color2],
                  ),
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
        _bar(true),
        _dot(true),
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
        "STEP 4 OF 4",
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
      child: Icon(icon, color: Colors.white, size: 22),
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

class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final Color color1;
  final Color color2;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.color1,
    required this.color2,
  });
}