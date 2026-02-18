import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:flutter/material.dart';
import '../../controller/step_four_controller.dart';

class StepFourScreen extends StatefulWidget {
  const StepFourScreen({super.key});

  @override
  State<StepFourScreen> createState() => _StepFourScreenState();
}

class _StepFourScreenState extends State<StepFourScreen> {
  final StepFourController _controller = StepFourController();

  int selectedIndex = 0;
  bool isLoading = false;

  final List<Map<String, String>> goals = [
    {"title": "Sedentary", "subtitle": "Little or no exercise"},
    {"title": "Lightly Active", "subtitle": "Light exercise/sports 1-3 days/week"},
    {"title": "Moderately Active", "subtitle": "Moderate exercise/sports 3-5 days/week"},
    {"title": "Very Active", "subtitle": "Hard exercise/sports 6-7 days a week"},
  ];

  Future<void> _saveAndContinue() async {
    setState(() {
      isLoading = true;
    });

    String selectedActivity = goals[selectedIndex]["title"]!;
    String? result = await _controller.saveStepFourData(activityLevel: selectedActivity);

    setState(() {
      isLoading = false;
    });

    if (result == null) {
      // Success → Go to Main View
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainView()),
      );
    } else {
      // Error
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              /// Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  Text("Step 4 of 4",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain)),
                  Text("SKIP", style: TextStyle(color: textGrey, fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 12),

              /// Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              const SizedBox(height: 35),

              Text("Activity Level", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textMain)),
              const SizedBox(height: 8),
              Text("How active are you daily?", style: TextStyle(color: textGrey)),
              const SizedBox(height: 30),

              /// Selectable Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      goals.length,
                      (index) => _goalCard(
                        index: index,
                        title: goals[index]["title"]!,
                        subtitle: goals[index]["subtitle"]!,
                      ),
                    ),
                  ),
                ),
              ),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 62,
                child: GestureDetector(
                  onTap: isLoading ? null : _saveAndContinue,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(colors: [primary, accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: primary.withOpacity(0.45), blurRadius: 25, offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Continue", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white),
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

  /// Goal Card
  Widget _goalCard({required int index, required String title, required String subtitle}) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: [primary.withOpacity(0.2), accent.withOpacity(0.2)]) : null,
          color: selected ? null : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : const Color(0xFF334155), width: 1.5),
          boxShadow: [
            BoxShadow(color: selected ? primary.withOpacity(0.35) : Colors.black.withOpacity(0.4), blurRadius: selected ? 18 : 8, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                gradient: selected ? LinearGradient(colors: [primary, accent]) : null,
                color: selected ? null : const Color(0xFF334155),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_run, color: selected ? Colors.white : textGrey, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textMain)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: selected ? accent : textGrey, fontSize: 13)),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: CircleAvatar(radius: 14, backgroundColor: primary, child: const Icon(Icons.check, size: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}