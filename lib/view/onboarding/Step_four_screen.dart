import 'package:fitmind_ai/view/onboarding/CalculatingPlanScreen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/controller/step_four_controller.dart';

class StepFourScreen extends StatefulWidget {
  final double weight;
  final double targetWeight;

  const StepFourScreen({super.key, required this.weight, required this.targetWeight});

  @override
  State<StepFourScreen> createState() => _StepFourScreenState();
}

class _StepFourScreenState extends State<StepFourScreen> {
  final StepFourController _controller = StepFourController();

  int selectedIndex = 0;
  bool isLoading = false;

  final List<Map<String, String>> activities = [
    {"title": "Sedentary", "subtitle": "Little or no exercise"},
    {"title": "Lightly Active", "subtitle": "Light exercise 1-3 days/week"},
    {
      "title": "Moderately Active",
      "subtitle": "Moderate exercise 3-5 days/week",
    },
    {"title": "Very Active", "subtitle": "Hard exercise 6-7 days/week"},
  ];

  Future<void> _saveAndContinue() async {
    setState(() => isLoading = true);

    String selectedActivity = activities[selectedIndex]["title"]!;
    String? result = await _controller.saveStepFourData(
      activityLevel: selectedActivity,
    );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _progress(false),
                  const SizedBox(width: 8),
                  _progress(false),
                  const SizedBox(width: 8),
                  _progress(false),
                  const SizedBox(width: 8),
                  _progress(true),
                ],
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Step 4 of 4",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              /// Title
              Text(
                "How active are you?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Your activity level helps us calculate your daily calorie needs.",
                style: TextStyle(color: textGrey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              /// Selectable Activity Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      activities.length,
                      (index) => _activityCard(
                        index: index,
                        title: activities[index]["title"]!,
                        subtitle: activities[index]["subtitle"]!,
                      ),
                    ),
                  ),
                ),
              ),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: isLoading ? null : _saveAndContinue,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [primary, accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.45),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
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
    );
  }

  /// Activity Card
  Widget _activityCard({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? null : const Color(0xFF1E293B),
          gradient: selected
              ? LinearGradient(
                  colors: [primary.withOpacity(0.2), accent.withOpacity(0.2)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary : const Color(0xFF334155),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? primary.withOpacity(0.35)
                  : Colors.black.withOpacity(0.3),
              blurRadius: selected ? 18 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Icon Bubble
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: selected ? null : const Color(0xFF334155),
                gradient: selected
                    ? LinearGradient(colors: [primary, accent])
                    : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run,
                color: selected ? Colors.white : textGrey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            /// Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? accent : textGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            /// Check Icon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: primary,
                child: const Icon(Icons.check, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress Indicator
  Widget _progress(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 35 : 20,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: active
            ? const LinearGradient(
                colors: [
                  Color(0xFF22C55E), // Green
                  Color(0xFF06B6D4), // Cyan
                  Color(0xFF38BDF8), // Light Blue
                ],
              )
            : null,
        color: active ? null : Colors.white24,
      ),
    );
  }
}
