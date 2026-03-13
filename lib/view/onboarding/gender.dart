import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'age_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen>
    with SingleTickerProviderStateMixin {
  String selectedGender = "Male";
  late AnimationController _bgController;
  late Animation<Color?> _bgAnimation;

  @override
  void initState() {
    super.initState();

    // Animated gradient background
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);

    _bgAnimation = ColorTween(begin: primary.withOpacity(0.8), end: accent.withOpacity(0.8))
        .animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgeScreen(gender: selectedGender),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgAnimation.value!, Colors.black87],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// Step Text
                  Text(
                    "Step 1 of 7",
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.14,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF1E293B),
                      valueColor: AlwaysStoppedAnimation(primary),
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Title
                  Text(
                    "Select your gender",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(child: genderCard("Male", Icons.male)),
                      const SizedBox(width: 18),
                      Expanded(child: genderCard("Female", Icons.female)),
                    ],
                  ),

                  const Spacer(),

                  /// Continue Button with glow
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: GestureDetector(
                      onTap: goNext,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(colors: [primary, accent]),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
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
                              )
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
        ),
      ),
    );
  }

  Widget genderCard(String gender, IconData icon) {
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF1E293B),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 48, color: isSelected ? const Color(0xFF22C55E) : Colors.white70),
            const SizedBox(height: 10),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? const Color(0xFF22C55E) : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}