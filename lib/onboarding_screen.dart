import 'dart:ui';

import 'package:fitmind_ai/view/auth_view/signup_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();

  late AnimationController _bgController;

  int currentIndex = 0;

  final List<_OnboardingData> pages = const [
    _OnboardingData(
      title: "Track Calories\nWith AI",
      desc:
          "Scan meals, calculate calories, and understand your nutrition in seconds.",
      icon: Icons.local_fire_department_rounded,
      color1: Color(0xFF22C55E),
      color2: Color(0xFF06B6D4),
      badge: "Smart Tracking",
    ),
    _OnboardingData(
      title: "Build Healthy\nEating Habits",
      desc:
          "Get personalized nutrition insights to improve your daily food choices.",
      icon: Icons.restaurant_menu_rounded,
      color1: Color(0xFF06B6D4),
      color2: Color(0xFF3B82F6),
      badge: "Nutrition Coach",
    ),
    _OnboardingData(
      title: "Reach Your\nFitness Goals",
      desc:
          "Follow your progress, stay consistent, and move closer to your ideal body.",
      icon: Icons.fitness_center_rounded,
      color1: Color(0xFF8B5CF6),
      color2: Color(0xFF22C55E),
      badge: "Goal Focused",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _next() {
    if (currentIndex == pages.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return Positioned(
                top: -120 + (_bgController.value * 35),
                right: -90,
                child: _glowCircle(
                  color: page.color1.withOpacity(0.16),
                  size: 280,
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return Positioned(
                bottom: -150,
                left: -100 + (_bgController.value * 40),
                child: _glowCircle(
                  color: page.color2.withOpacity(0.13),
                  size: 320,
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: Row(
                    children: [
                      _brandBadge(),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.62),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final item = pages[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const Spacer(),

                            _heroVisual(item),

                            const SizedBox(height: 44),

                            _pageBadge(item.badge, item.color1),

                            const SizedBox(height: 16),

                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 37,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              item.desc,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.62),
                                fontSize: 15,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Spacer(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 8,
                        width: currentIndex == index ? 30 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: currentIndex == index
                              ? LinearGradient(
                                  colors: [
                                    pages[currentIndex].color1,
                                    pages[currentIndex].color2,
                                  ],
                                )
                              : null,
                          color: currentIndex == index
                              ? null
                              : Colors.white.withOpacity(0.18),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GestureDetector(
                    onTap: _next,
                    child: Container(
                      height: 64,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            page.color1,
                            page.color2,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: page.color1.withOpacity(0.34),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentIndex == pages.length - 1
                                ? "Start Your Journey"
                                : "Continue",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroVisual(_OnboardingData item) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 260,
          width: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                item.color1.withOpacity(0.20),
                item.color2.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(46),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 210,
              width: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.10),
                    Colors.white.withOpacity(0.035),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Center(
                child: Container(
                  height: 122,
                  width: 122,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [item.color1, item.color2],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.color1.withOpacity(0.35),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 62,
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 15,
          right: 25,
          child: _floatingChip(
            icon: Icons.auto_awesome_rounded,
            text: "AI",
            color: item.color1,
          ),
        ),

        Positioned(
          bottom: 20,
          left: 20,
          child: _floatingChip(
            icon: Icons.insights_rounded,
            text: "Smart",
            color: item.color2,
          ),
        ),
      ],
    );
  }

  Widget _brandBadge() {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF22C55E),
                Color(0xFF06B6D4),
              ],
            ),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "FitMind AI",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _pageBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _floatingChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String desc;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String badge;

  const _OnboardingData({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.badge,
  });
}