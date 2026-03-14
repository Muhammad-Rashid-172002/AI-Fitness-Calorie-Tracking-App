import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/controller/step_three_controller.dart';
import 'package:fitmind_ai/view/onboarding/Step_four_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final StepThreeController _controller = StepThreeController();

  int selectedIndex = 0;
  bool isLoading = false;

  final List<Map<String, String>> goals = [
    {"title": "Lose Weight", "subtitle": "Deficit recommended"},
    {"title": "Maintain Weight", "subtitle": "Balance intake"},
    {"title": "Gain Muscle", "subtitle": "Surplus recommended"},
  ];

  /// Save Goal & Continue
  Future<void> _saveAndContinue() async {
    setState(() => isLoading = true);

    String selectedGoal = goals[selectedIndex]["title"]!;
    String? result = await _controller.saveStepThreeData(goal: selectedGoal);

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StepFourScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                
                  Text(
                    "Step 5 of 7",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain),
                  ),
                  
                ],
              ),
              const SizedBox(height: 12),

              /// Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              const SizedBox(height: 35),

              /// Title
              Text(
                "Your Goal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                  shadows: const [
                    Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "What do you want to achieve?",
                style: TextStyle(color: textGrey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              /// Goal Cards
              ...List.generate(
                goals.length,
                (index) => _goalCard(
                  index: index,
                  title: goals[index]["title"]!,
                  subtitle: goals[index]["subtitle"]!,
                ),
              ),

              const Spacer(),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: isLoading ? null : _saveAndContinue,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(colors: [primary, accent]),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.45),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        )
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
                                Icon(Icons.arrow_forward_rounded, color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalCard({required int index, required String title, required String subtitle}) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [primary.withOpacity(0.2), accent.withOpacity(0.2)])
              : null,
          color: selected ? null : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : const Color(0xFF334155), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: selected ? primary.withOpacity(0.35) : Colors.black.withOpacity(0.3),
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
                gradient: selected ? LinearGradient(colors: [primary, accent]) : null,
                color: selected ? null : const Color(0xFF334155),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fitness_center, color: selected ? Colors.white : textGrey, size: 24),
            ),
            const SizedBox(width: 16),

            /// Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: selected ? accent : textGrey, fontSize: 13)),
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
}