import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/view/onboarding/target_screen.dart';
import 'package:flutter/material.dart';
import '../../controller/step_one_controller.dart';

class BodyInfoScreen extends StatefulWidget {
  const BodyInfoScreen({super.key});

  @override
  State<BodyInfoScreen> createState() => _BodyInfoScreenState();
}

class _BodyInfoScreenState extends State<BodyInfoScreen> {
  final StepOneController controller = StepOneController();

  final ageController = TextEditingController(text: "18");
  final heightController = TextEditingController(text: "170");
  final weightController = TextEditingController(text: "75");

  String gender = "Male";
  bool isLoading = false;

  Future<void> saveData() async {
    int age = int.tryParse(ageController.text) ?? 0;
    double height = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;

    if (age == 0 || height == 0 || weight == 0) {
      showCustomSnackBar(context, "Please enter valid values", false);
      return;
    }

    setState(() => isLoading = true);

    String? result = await controller.saveStepOneData(
      gender: gender,
      age: age,
      height: height,
      weight: weight,
    );

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TargetWeightScreen(height: height, weight: weight),
        ),
      );
    } else {
      showCustomSnackBar(context, result, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SizedBox.expand(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
        
                  /// Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _progress(true),
                      const SizedBox(width: 8),
                      _progress(false),
                      const SizedBox(width: 8),
                      _progress(false),
                      const SizedBox(width: 8),
                      _progress(false),
                      
                    ],
                  ),
        
                  const SizedBox(height: 10),
        
                  const Center(
                    child: Text(
                      "Step 1 of 4",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 30),
        
                  const Text(
                    "Tell us about your body",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        
                  const SizedBox(height: 8),
        
                  const Text(
                    "This helps us calculate your metabolism and calories.",
                    style: TextStyle(color: Colors.white70),
                  ),
        
                  const SizedBox(height: 30),
        
                  /// AGE
                  _inputCard("Age", ageController, "", Icons.cake_outlined),
        
                  const SizedBox(height: 18),
        
                  /// Gender
                  const Text(
                    "Gender",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  Row(
                    children: [
                      Expanded(child: _genderCard("Male", Icons.male)),
                      const SizedBox(width: 12),
                      Expanded(child: _genderCard("Female", Icons.female)),
                    ],
                  ),
        
                  const SizedBox(height: 18),
        
                  /// Height
                  _inputCard("Height", heightController, "cm", Icons.height),
        
                  const SizedBox(height: 18),
        
                  /// Weight
                  _inputCard(
                    "Weight",
                    weightController,
                    "kg",
                    Icons.monitor_weight_outlined,
                  ),
        
                  const SizedBox(height: 180),
        
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomGradientButton(
                          text: "Continue",
                          onPressed: saveData,
                        ),
        
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Input Card
  Widget _inputCard(
    String title,
    TextEditingController controller,
    String suffix,
    IconData icon,
  ) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white70),

          const SizedBox(width: 10),

          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const Spacer(),

          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: suffix,
                suffixStyle: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gender Card
  Widget _genderCard(String value, IconData icon) {
    bool selected = gender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        padding: const EdgeInsets.symmetric(vertical: 20),

        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                   Color(0xFF22C55E), // Green
                  Color(0xFF06B6D4), // Cyan
                  Color(0xFF38BDF8), // Light Blue
                  ],
                )
              : null,

          color: selected ? null : Colors.white.withOpacity(0.08),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: selected ? Colors.transparent : Colors.white24,
          ),
        ),

        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.white),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
