import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import '../../controller/step_one_controller.dart';
import 'height_screen.dart';

class BodyInfoScreen extends StatefulWidget {
  const BodyInfoScreen({super.key});

  @override
  State<BodyInfoScreen> createState() => _BodyInfoScreenState();
}

class _BodyInfoScreenState extends State<BodyInfoScreen> {
  final StepOneController controller = StepOneController();

  final ageController = TextEditingController(text: "30");
  final heightController = TextEditingController(text: "170");
  final weightController = TextEditingController(text: "75");

  String gender = "Male";
  bool isLoading = false;

  Future<void> saveData() async {
    setState(() => isLoading = true);

    String? result = await controller.saveStepOneData(
      gender: gender,
      age: int.parse(ageController.text),
    );

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HeightScreen()),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7EF), Color(0xFFD8F5E6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              children: [
                const SizedBox(height: 20),

                /// Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _progress(true),
                    const SizedBox(width: 8),
                    _progress(true),
                    const SizedBox(width: 8),
                    _progress(false),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Step 1 of 3",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 30),

                /// Title
                const Text(
                  "Tell us about your body",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "This helps calculate your metabolism.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 35),

                /// Age Card
                _inputCard(title: "Age", controller: ageController, suffix: ""),

                const SizedBox(height: 16),

                /// Gender Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardDecoration(),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Gender", style: TextStyle(fontSize: 16)),

                      Row(
                        children: [
                          _genderButton("Male"),
                          const SizedBox(width: 8),
                          _genderButton("Female"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Height Card
                _inputCard(
                  title: "Height",
                  controller: heightController,
                  suffix: "cm",
                ),

                const SizedBox(height: 16),

                /// Weight Card
                _inputCard(
                  title: "Weight",
                  controller: weightController,
                  suffix: "kg",
                ),

                const Spacer(),

                /// Next Button
              CustomGradientButton(text: "Next", onPressed: saveData),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card Input
  Widget _inputCard({
    required String title,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),

      decoration: _cardDecoration(),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),

          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: suffix,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gender Button
  Widget _genderButton(String value) {
    bool selected = gender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        decoration: BoxDecoration(
          color: selected ? const Color(0xFF18C37E) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),

        child: Text(
          value,
          style: TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  /// Progress bar
  Widget _progress(bool active) {
    return Container(
      width: 30,
      height: 6,

      decoration: BoxDecoration(
        color: active ? const Color(0xFF18C37E) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// Card Decoration
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    );
  }
}
