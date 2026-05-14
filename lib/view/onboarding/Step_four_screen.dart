import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/controller/step_four_controller.dart';
import 'package:fitmind_ai/view/onboarding/CalculatingPlanScreen.dart';

class StepFourScreen extends StatefulWidget {
  final double weight;
  final double targetWeight;

  const StepFourScreen({
    super.key,
    required this.weight,
    required this.targetWeight,
  });

  @override
  State<StepFourScreen> createState() => _StepFourScreenState();
}

class _StepFourScreenState extends State<StepFourScreen> {
  final StepFourController _controller = StepFourController();

  int selectedIndex = 0;
  bool isLoading = false;

  final List<Map<String, dynamic>> activities = [
    {
      "title": "Sedentary",
      "subtitle": "Little or no exercise",
      "icon": Icons.weekend_rounded,
      "emoji": "🛋️",
    },
    {
      "title": "Lightly Active",
      "subtitle": "Light exercise 1-3 days/week",
      "icon": Icons.directions_walk_rounded,
      "emoji": "🚶",
    },
    {
      "title": "Moderately Active",
      "subtitle": "Moderate exercise 3-5 days/week",
      "icon": Icons.fitness_center_rounded,
      "emoji": "💪",
    },
    {
      "title": "Very Active",
      "subtitle": "Hard exercise 6-7 days/week",
      "icon": Icons.local_fire_department_rounded,
      "emoji": "🔥",
    },
  ];

  Future<void> _saveAndContinue() async {
    setState(() {
      isLoading = true;
    });

    try {
      String selectedActivity =
          activities[selectedIndex]["title"].toString();

      String? result = await _controller.saveStepFourData(
        activityLevel: selectedActivity,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF111827),
              Color(0xFF020617),
            ],
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              /// Top Glow
              Positioned(
                top: -120,
                right: -80,
                child: _glowCircle(
                  color: primary.withOpacity(0.18),
                  size: 260,
                ),
              ),

              /// Bottom Glow
              Positioned(
                bottom: -100,
                left: -60,
                child: _glowCircle(
                  color: accent.withOpacity(0.15),
                  size: 220,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    /// Progress
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

                    const SizedBox(height: 18),

                    /// Step Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: const Text(
                          "STEP 4 OF 4",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Heading
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
                        "How Active\nAre You?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Choose your activity level to generate your personalized fitness and calorie plan.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Cards
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final item = activities[index];

                          return _activityCard(
                            index: index,
                            title: item["title"]?.toString() ?? "",
                            subtitle: item["subtitle"]?.toString() ?? "",
                            icon: item["icon"] ?? Icons.fitness_center,
                            emoji: item["emoji"]?.toString() ?? "🔥",
                          );
                        },
                      ),
                    ),

                    /// Continue Button
                    GestureDetector(
                      onTap: isLoading ? null : _saveAndContinue,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: double.infinity,
                        height: 64,

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
                              color: primary.withOpacity(0.45),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(width: 10),

                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
    required IconData icon,
    required String emoji,
  }) {
    bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,

        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),

          gradient: selected
              ? LinearGradient(
                  colors: [
                    primary.withOpacity(0.28),
                    accent.withOpacity(0.22),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.03),
                  ],
                ),

          border: Border.all(
            color: selected
                ? primary.withOpacity(0.9)
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),

          boxShadow: [
            BoxShadow(
              color: selected
                  ? primary.withOpacity(0.30)
                  : Colors.black.withOpacity(0.22),
              blurRadius: selected ? 24 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            /// Icon Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),

              height: 62,
              width: 62,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: selected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF22C55E),
                          Color(0xFF06B6D4),
                        ],
                      )
                    : null,

                color: selected
                    ? null
                    : Colors.white.withOpacity(0.06),

                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),

              child: Center(
                child: selected
                    ? Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      )
                    : Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
              ),
            ),

            const SizedBox(width: 18),

            /// Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            /// Check
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 250),

              child: Container(
                padding: const EdgeInsets.all(8),

                decoration: const BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06B6D4),
                    ],
                  ),
                ),

                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress Bar
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

  /// Glow Effect
  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}