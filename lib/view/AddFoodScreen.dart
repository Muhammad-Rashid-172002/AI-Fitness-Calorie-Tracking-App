// add_food_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_model.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final nameController = TextEditingController();
  final caloriesController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? image;

  double grams = 100;

  /// ---------------- CALC ----------------
  double get totalCalories {
    final cal = double.tryParse(caloriesController.text) ?? 0;
    return (cal / 100) * grams;
  }

  /// ---------------- IMAGE PICK ----------------
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                "Camera",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.white),
              title: const Text(
                "Gallery",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              const Text(
                "Add Food",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// IMAGE PICKER 🔥
              GestureDetector(
                onTap: showImageOptions,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFF1A1A1A),
                    child: image == null
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white54,
                                  size: 30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Add Food Image",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          )
                        : Image.file(image!, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NAME FIELD
              _inputField(nameController, "Food Name"),

              const SizedBox(height: 15),

              /// CALORIES FIELD
              _inputField(
                caloriesController,
                "Calories per 100g",
                isNumber: true,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 20),

              /// PORTION CARD 🔥
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Portion",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    /// BIG NUMBER
                    Text(
                      "${grams.toStringAsFixed(0)} g",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Slider(
                      value: grams,
                      min: 10,
                      max: 500,
                      activeColor: Colors.greenAccent,
                      onChanged: (v) => setState(() => grams = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// CALORIES PREVIEW
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estimated Calories",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${totalCalories.toStringAsFixed(0)} kcal",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final food = Food(
                      name: nameController.text,
                      shortMsg: nameController.text,
                      calories: double.tryParse(caloriesController.text) ?? 0,
                      grams: grams,
                      imagePath: image?.path, // 🔥 SAVE IMAGE
                    );

                    Navigator.pop(context, food);
                  },
                  child: const Text(
                    "Add Food",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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

  /// ---------------- INPUT FIELD ----------------
  Widget _inputField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}
