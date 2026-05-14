/// ===============================
/// UPDATED PREMIUM BODY INFO UI
/// ===============================

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
      duration: const Duration(seconds: 4),
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
          /// TOP GLOW
          Positioned(
            top: -120,
            left: -90,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF22C55E,
                    ).withOpacity(0.10 + (_animationController.value * 0.06)),
                  ),
                );
              },
            ),
          ),

          /// BOTTOM GLOW
          Positioned(
            bottom: -130,
            right: -100,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// TOP BAR
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: const Text(
                          "STEP 1 OF 4",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  /// PROGRESS BAR
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

                  const SizedBox(height: 40),

                  /// TITLE
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFF67E8F9),
                          Color(0xFF22C55E),
                        ],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      "Body\nInformation",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "This information helps AI generate your personalized nutrition and fitness plan.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 38),

                  /// GLASS CARD
                  ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 14,
                        sigmaY: 14,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            _modernField(
                              title: "Age",
                              hint: "18",
                              suffix: "Years",
                              controller: ageController,
                              icon: Icons.cake_rounded,
                            ),

                            const SizedBox(height: 22),

                            _modernField(
                              title: "Height",
                              hint: "170",
                              suffix: "CM",
                              controller: heightController,
                              icon: Icons.height_rounded,
                            ),

                            const SizedBox(height: 22),

                            _modernField(
                              title: "Weight",
                              hint: "75",
                              suffix: "KG",
                              controller: weightController,
                              icon: Icons.monitor_weight_rounded,
                            ),

                            const SizedBox(height: 32),

                            /// GENDER TITLE
                            Row(
                              children: [
                                Text(
                                  "Gender",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.92),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Expanded(
                                  child: _genderCard(
                                    title: "Male",
                                    icon: Icons.male_rounded,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: _genderCard(
                                    title: "Female",
                                    icon: Icons.female_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// CONTINUE BUTTON
                  GestureDetector(
                    onTap: isLoading ? null : saveData,

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      height: 72,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),

                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF06B6D4),
                            Color(0xFF3B82F6),
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF06B6D4,
                            ).withOpacity(0.4),
                            blurRadius: 24,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// MODERN FIELD
  Widget _modernField({
    required String title,
    required String hint,
    required String suffix,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.04),

            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),

          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF22C55E).withOpacity(0.2),
                      const Color(0xFF06B6D4).withOpacity(0.2),
                    ],
                  ),
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFF22C55E),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),

                  decoration: InputDecoration(
                    border: InputBorder.none,

                    hintText: hint,

                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
              ),

              Text(
                suffix,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// GENDER CARD
  Widget _genderCard({
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = gender == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = title;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        padding: const EdgeInsets.symmetric(vertical: 24),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF22C55E),
                    Color(0xFF06B6D4),
                  ],
                )
              : null,

          color: isSelected
              ? null
              : Colors.white.withOpacity(0.04),

          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.06),
          ),

          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(
                      0xFF06B6D4,
                    ).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),

        child: Column(
          children: [
            Icon(
              icon,
              size: 42,
              color: Colors.white,
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PROGRESS
  Widget _progress(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      width: active ? 40 : 18,
      height: 7,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),

        gradient: active
            ? const LinearGradient(
                colors: [
                  Color(0xFF22C55E),
                  Color(0xFF06B6D4),
                  Color(0xFF3B82F6),
                ],
              )
            : null,

        color: active
            ? null
            : Colors.white.withOpacity(0.12),
      ),
    );
  }
}