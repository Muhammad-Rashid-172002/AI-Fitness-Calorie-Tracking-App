import 'dart:ui';

import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/controller/step_one_controller.dart';
import 'package:fitmind_ai/view/onboarding/target_screen.dart';
import 'package:flutter/material.dart';

class BodyInfoScreen extends StatefulWidget {
  const BodyInfoScreen({super.key});

  @override
  State<BodyInfoScreen> createState() => _BodyInfoScreenState();
}

class _BodyInfoScreenState extends State<BodyInfoScreen>
    with SingleTickerProviderStateMixin {
  final StepOneController controller = StepOneController();

  final ageController = TextEditingController(text: "18");
  final heightController = TextEditingController(text: "170");
  final weightController = TextEditingController(text: "75");

  String gender = "Male";
  bool isLoading = false;

  late AnimationController _animationController;

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
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    final age = int.tryParse(ageController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;
    final weight = double.tryParse(weightController.text) ?? 0;

    if (age <= 0 || height <= 0 || weight <= 0) {
      showCustomSnackBar(context, "Please enter valid values", false);
      return;
    }

    setState(() => isLoading = true);

    final result = await controller.saveStepOneData(
      gender: gender,
      age: age,
      height: height,
      weight: weight,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TargetWeightScreen(
            height: height,
            weight: weight,
          ),
        ),
      );
    } else {
      showCustomSnackBar(context, result, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (_, __) {
              return Positioned(
                top: -120 + (_animationController.value * 35),
                right: -95,
                child: _glowCircle(
                  color: const Color(0xFF22C55E).withOpacity(0.14),
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
                left: -110 + (_animationController.value * 45),
                child: _glowCircle(
                  color: const Color(0xFF06B6D4).withOpacity(0.12),
                  size: 320,
                ),
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _iconBox(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      _stepBadge(),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _progressLine(),

                  const SizedBox(height: 32),

                  const Text(
                    "Tell Us About\nYour Body",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "FitMind AI uses this information to calculate your calories, macros, and personalized plan.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.58),
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _profilePreviewCard(),

                  const SizedBox(height: 22),

                  _formCard(),

                  const SizedBox(height: 28),

                  GestureDetector(
                    onTap: isLoading ? null : saveData,
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
                                    "Continue",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF22C55E),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.26),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 74,
            width: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(color: Colors.white.withOpacity(0.24)),
            ),
            child: Icon(
              gender == "Male" ? Icons.male_rounded : Icons.female_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$gender • ${ageController.text} yrs\n${heightController.text} cm • ${weightController.text} kg",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              _inputTile(
                title: "Age",
                subtitle: "Your current age",
                suffix: "Years",
                icon: Icons.cake_rounded,
                controller: ageController,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 14),
              _inputTile(
                title: "Height",
                subtitle: "Body height",
                suffix: "CM",
                icon: Icons.height_rounded,
                controller: heightController,
                color: const Color(0xFF06B6D4),
              ),
              const SizedBox(height: 14),
              _inputTile(
                title: "Weight",
                subtitle: "Current body weight",
                suffix: "KG",
                icon: Icons.monitor_weight_rounded,
                controller: weightController,
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _genderCard("Male", Icons.male_rounded),
                  const SizedBox(width: 12),
                  _genderCard("Female", Icons.female_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputTile({
    required String title,
    required String subtitle,
    required String suffix,
    required IconData icon,
    required TextEditingController controller,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.42),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 78,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "0",
                suffixText: " $suffix",
                suffixStyle: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.28)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderCard(String title, IconData icon) {
    final selected = gender == title;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06B6D4),
                    ],
                  )
                : null,
            color: selected ? null : Colors.white.withOpacity(0.045),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressLine() {
    return Row(
      children: [
        _dot(true),
        _bar(false),
        _dot(false),
        _bar(false),
        _dot(false),
        _bar(false),
        _dot(false),
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
        "STEP 1 OF 4",
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
      child: Icon(icon, color: Colors.white, size: 19),
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