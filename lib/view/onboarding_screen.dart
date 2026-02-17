import 'package:fitmind_ai/controller/onboarding_controller.dart';
import 'package:fitmind_ai/view/auth_view/signup_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Snap your meal",
      "desc": "Take a photo and let AI analyze your food",
      "icon": "📸",
    },
    {
      "title": "Track Calories",
      "desc": "Monitor daily calories and nutrition easily",
      "icon": "🔥",
    },
    {
      "title": "Stay Fit",
      "desc": "Get personalized workouts and AI guidance",
      "icon": "💪",
    },
  ];

  void nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      OnboardingController.goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Dark
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with Glow
                      Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF22C55E), // Green
                              Color(0xFF06B6D4), // Cyan
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF22C55E).withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pages[index]["icon"]!,
                            style: const TextStyle(fontSize: 55),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        pages[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          pages[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF94A3B8),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(5),
                  height: 8,
                  width: _currentPage == index ? 26 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 62,
                child: GestureDetector(
                  onTap: nextPage,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),

                      // Gradient Background
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF22C55E), // Green
                          Color(0xFF06B6D4), // Cyan
                          Color(0xFF38BDF8), // Light Blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      // Glow Shadow
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.45),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text
                          Text(
                            _currentPage == 2 ? "Get Started" : "Next",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Icon
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
