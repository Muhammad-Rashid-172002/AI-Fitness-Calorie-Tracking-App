import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final weightController = TextEditingController();
  final bodyFatController = TextEditingController();
  final muscleController = TextEditingController();
  final whrController = TextEditingController();

  bool isLoading = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  /// 🔥 PARSE FUNCTIONS (SEPARATED)
  double? parse(TextEditingController c) {
    final value = double.tryParse(c.text);
    return (value == null || value <= 0) ? null : value;
  }

  /// 🔥 BUILD CLEAN DATA MAP
  Map<String, dynamic> buildData() {
    final weight = parse(weightController);

    if (weight == null) {
      throw "Weight required";
    }

    final bodyFat = parse(bodyFatController);
    final muscle = parse(muscleController);
    final whr = parse(whrController);

    Map<String, dynamic> data = {
      "weight": weight,
      "timestamp": Timestamp.now(),
    };

    /// ✅ ADD ONLY IF EXISTS
    if (bodyFat != null) data["bodyFat"] = bodyFat;
    if (muscle != null) data["muscle"] = muscle;
    if (whr != null) data["whr"] = whr;

    return data;
  }

  /// 🔥 SAVE FUNCTION
Future<void> saveData() async {
  setState(() => isLoading = true);

  try {
    final data = buildData();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('body_metrics_log')
        .add(data);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      "weight": data["weight"],
    });

    showCustomSnackBar(context, "Saved successfully ✅", true);

    Navigator.pop(context);
  } catch (e) {
    showCustomSnackBar(context, e.toString(), false);
  }

  setState(() => isLoading = false);
}

/// 🔥 INPUT FIELD
Widget inputField(
  String label,
  TextEditingController controller, {
  String hint = "",
    IconData icon = Icons.edit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.greenAccent),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Body Metrics",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            /// 🔥 HEADER CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.monitor_weight, color: Colors.greenAccent),
                  SizedBox(width: 10),
                  Text(
                    "Track Your Progress Daily",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INPUTS
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    inputField(
                      "Weight (kg)",
                      weightController,
                      icon: Icons.monitor_weight,
                      hint: "Enter weight e.g 70",
                    ),
                    const SizedBox(height: 14),

                    inputField(
                      "Body Fat %",
                      bodyFatController,
                      icon: Icons.percent,
                      hint: "e.g 18",
                    ),
                    const SizedBox(height: 14),

                    inputField(
                      "Muscle (kg)",
                      muscleController,
                      icon: Icons.fitness_center,
                    ),
                    const SizedBox(height: 14),

                    inputField("WHR", whrController, icon: Icons.insights),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// SAVE BUTTON
            GestureDetector(
              onTap: isLoading ? null : saveData,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.greenAccent, Colors.green],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "SAVE DATA",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
