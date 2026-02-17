import 'dart:io';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';



class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScanController controller = ScanController();
  File? selectedImage;

  void _takePhoto() async {
    File? image = await controller.pickFromCamera();
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  void _pickGallery() async {
    File? image = await controller.pickFromGallery();
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Title
              const Text(
                "Scan Meal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Take a photo or pick from gallery",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              /// Display Selected Image
              if (selectedImage != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                   decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.green.shade700, Colors.teal.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.camera_alt, size: 60, color: Colors.white),
                        ),
                        SizedBox(height: 35),
                        Text(
                          "Take Photo",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Use your camera to scan a meal",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              /// Row Buttons
              Row(
                children: [
                  /// Gallery Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickGallery,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.photo, size: 35, color: Colors.blue),
                            SizedBox(height: 10),
                            Text(
                              "Gallery",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Pick from photos",
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  /// Quick Add (Dummy)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.flash_on, size: 35, color: Colors.orange),
                          SizedBox(height: 10),
                          Text(
                            "Quick Add",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Log a meal fast",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              /// Features List
              const FeatureItem(text: "AI identifies food from photos"),
              const FeatureItem(text: "Instant calorie & nutrition data"),
              const FeatureItem(text: "Personalized feedback on meals"),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;
  const FeatureItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}