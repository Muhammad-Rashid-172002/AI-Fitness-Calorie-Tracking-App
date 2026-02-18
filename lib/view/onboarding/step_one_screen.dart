import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:fitmind_ai/view/onboarding/step_two_screen.dart';

import '../../controller/step_one_controller.dart';

class StepOneScreen extends StatefulWidget {
  const StepOneScreen({super.key});

  @override
  State<StepOneScreen> createState() => _StepOneScreenState();
}

class _StepOneScreenState extends State<StepOneScreen> {
  final StepOneController _controller = StepOneController();

  String selectedGender = "Male";
  double age = 18;

  bool isLoading = false;

  /// Save Step 1 Data & Continue
  Future<void> _saveAndContinue() async {
    setState(() {
      isLoading = true;
    });

    String? result = await _controller.saveStepOneData(
      gender: selectedGender,
      age: age.toInt(),
    );

    setState(() {
      isLoading = false;
    });

    if (result == null) {
      // Success → Go to Step Two
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StepTwoScreen()),
      );
    } else {
      // Show Error
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

              /// Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  Text(
                    "Step 1 of 4",
                    style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainView()),
                      );
                    },
                    child: Text(
                      "SKIP",
                      style: TextStyle(color: textGrey, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),

              const SizedBox(height: 35),

              /// Title
              Text(
                "Tell us about yourself",
                style: TextStyle(color: textMain, fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 35),

              /// Gender
              Text(
                "Gender",
                style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: genderButton("Male")),
                  const SizedBox(width: 15),
                  Expanded(child: genderButton("Female")),
                ],
              ),

              const SizedBox(height: 35),

              /// Age
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Age",
                    style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [primary, accent]),
                    ),
                    child: Text(
                      age.toInt().toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Slider
              Slider(
                value: age,
                min: 18,
                max: 60,
                divisions: 42,
                onChanged: (value) => setState(() => age = value),
              ),

              const Spacer(),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 62,
                child: GestureDetector(
                  onTap: isLoading ? null : _saveAndContinue,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(colors: [primary, accent]),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue",
                                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
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

  /// Gender Button
  Widget genderButton(String gender) {
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? const Color(0xFF020617) : const Color(0xFF020617).withOpacity(0.6),
          border: Border.all(color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF1E293B), width: 1.8),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}