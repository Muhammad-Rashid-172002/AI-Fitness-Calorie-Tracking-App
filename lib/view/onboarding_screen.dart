import 'package:fitmind_ai/controller/onboarding_controller.dart';
import 'package:fitmind_ai/view/profile_view.dart';
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
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [

            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView()));
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.grey),
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

                      // Icon
                      Text(
                        pages[index]["icon"]!,
                        style: const TextStyle(fontSize: 80),
                      ),

                      const SizedBox(height: 30),

                      // Title
                      Text(
                        pages[index]["title"]!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Description
                      Text(
                        pages[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  height: 8,
                  width: _currentPage == index ? 25 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 65,

                child: ElevatedButton(
                  onPressed: nextPage,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 2 ? "Start" : "Next ",
                        style: const TextStyle(fontSize: 18,color: Colors.white),
                      ),
                      const Icon(Icons.arrow_forward, size: 18,color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}