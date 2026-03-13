import 'package:fitmind_ai/view/onboarding/Step_four_screen.dart';
import 'package:fitmind_ai/view/onboarding/goal_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/step_two_controller.dart';

import 'package:fitmind_ai/resources/app_them.dart';

class TargetWeightScreen extends StatefulWidget {

  final double height;
  final double weight;

  const TargetWeightScreen({
    super.key,
    required this.height,
    required this.weight,
  });

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {

  final StepTwoController controller = StepTwoController();

  late double targetWeight;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    targetWeight = widget.weight - 5;
  }

  Future<void> saveData() async {

    setState(() {
      isLoading = true;
    });

    String? result = await controller.saveStepTwoData(
      height: widget.height.toInt(),
      weight: widget.weight.toInt(),
      targetWeight: targetWeight.toInt(),
    );

    setState(() {
      isLoading = false;
    });

    if(result == null){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>  GoalScreen(),
        ),
      );

    }else{

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

              /// Step Text
              Text(
                "Step 5 of 7",
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
                  value: 0.71,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),

              const SizedBox(height: 40),

              /// Title
              Text(
                "What is your target weight?",
                style: TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// Target Weight Card
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [primary, accent],
                    ),
                  ),
                  child: Text(
                    "${targetWeight.toInt()} kg",
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Slider
              Slider(
                value: targetWeight,
                min: 30,
                max: widget.weight,
                onChanged: (value){
                  setState(() {
                    targetWeight = value;
                  });
                },
              ),

              const Spacer(),

              /// Finish Button
              SizedBox(
                width: double.infinity,
                height: 60,

                child: GestureDetector(
                  onTap: isLoading ? null : saveData,

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [primary, accent],
                      ),
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                SizedBox(width: 8),

                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),

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
}