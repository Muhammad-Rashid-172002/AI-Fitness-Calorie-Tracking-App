import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController kcalController = TextEditingController();

  String weightGoal = "Maintain Weight"; // Default value

  final List<String> weightOptions = [
    "Maintain Weight",
    "Lose Weight",
    "Gain Weight",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final controller = Provider.of<ProfileController>(context, listen: false);
    await controller.fetchUserData();

    // Set controllers
    nameController.text = controller.name;
    weightController.text = controller.weight;
    heightController.text = controller.height;
    ageController.text = controller.age;
    kcalController.text = controller.kcal;

    // Safe weight goal assignment
    if (weightOptions.contains(controller.weightGoal)) {
      weightGoal = controller.weightGoal;
    } else {
      weightGoal = "Maintain Weight";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context, listen: false);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text("Edit Profile", style: TextStyle(color: textMain)),
        iconTheme: IconThemeData(color: textMain),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),

              // Weight Goal Dropdown
              DropdownButtonFormField<String>(
                value: weightOptions.contains(weightGoal) ? weightGoal : null,
                decoration: InputDecoration(
                  labelText: "Weight Goal",
                  labelStyle: TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: weightOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    weightGoal = val!;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? "Select Weight Goal" : null,
                dropdownColor: cardColor,
                style: TextStyle(color: textMain),
              ),
              const SizedBox(height: 15),

              // Weight
              TextFormField(
                controller: weightController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  labelStyle: TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Height
              TextFormField(
                controller: heightController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Age
              TextFormField(
                controller: ageController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: "Age (years)",
                  labelStyle: TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Calories
              TextFormField(
                controller: kcalController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: "Calories/day",
                  labelStyle: TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 25),

              // Save Button
              // Save Button (Gradient Style like your Login Button)
              SizedBox(
                width: double.infinity,
                height: 62,
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      // Show Loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      );

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .update({
                                'name': nameController.text,
                                'weightGoal': weightGoal,
                                'weight': weightController.text,
                                'height': heightController.text,
                                'age': ageController.text,
                                'kcal': kcalController.text,
                              });
                        }

                        // Refresh controller
                        final controller = Provider.of<ProfileController>(
                          context,
                          listen: false,
                        );
                        await controller.fetchUserData();

                        Navigator.pop(context); // Close loading
                        Navigator.pop(context); // Close EditProfile
                      } catch (e) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Update failed: $e")),
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF22C55E),
                          Color(0xFF06B6D4),
                          Color(0xFF38BDF8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
