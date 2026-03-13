import 'package:flutter/material.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import '../../controller/step_one_controller.dart';
import 'height_screen.dart';

class AgeScreen extends StatefulWidget {
  final String gender;
  const AgeScreen({super.key, required this.gender});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen>
    with SingleTickerProviderStateMixin {
  final StepOneController controller = StepOneController();

  double age = 18;
  bool isLoading = false;

  late AnimationController _bgController;
  late Animation<Color?> _bgAnimation;

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);

    _bgAnimation = ColorTween(begin: primary.withOpacity(0.7), end: accent.withOpacity(0.7))
        .animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    setState(() => isLoading = true);

    String? result = await controller.saveStepOneData(
      gender: widget.gender,
      age: age.toInt(),
    );

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HeightScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, child) => Container(
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
                    "Step 2 of 7",
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
                      value: 0.28,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF1E293B),
                      valueColor: AlwaysStoppedAnimation(primary),
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Title
                  Text(
                    "How old are you?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Age Display with frosted glass effect
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [primary.withOpacity(0.9), accent.withOpacity(0.9)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        "${age.toInt()}",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Slider with active color animation
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accent,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: primary,
                      overlayColor: primary.withOpacity(0.2),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 16),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: age,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      label: "${age.toInt()}",
                      onChanged: (value) {
                        setState(() => age = value);
                      },
                    ),
                  ),
                  const Spacer(),

                  /// Continue Button with glowing effect
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: GestureDetector(
                      onTap: isLoading ? null : saveData,
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
}