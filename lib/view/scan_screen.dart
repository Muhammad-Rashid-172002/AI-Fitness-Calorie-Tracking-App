import 'dart:io';

import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/analyzing_screen.dart';
import 'package:fitmind_ai/view/quick_add_meal_screen.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScanController controller = ScanController();
  File? selectedImage;

  /// Camera
  Future<void> _takePhoto() async {
    File? image = await controller.pickFromCamera();
    if (image != null) {
      _handleImage(image);
    }
  }

  /// Gallery
  Future<void> _pickGallery() async {
    File? image = await controller.pickFromGallery();
    if (image != null) {
      _handleImage(image);
    }
  }

  /// Handle Image
  void _handleImage(File image) {
    setState(() {
      selectedImage = image;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          image: image,
          analyzeFuture: controller.analyzeFoodImage(image),
        ),
      ),
    );
  }

  /// Premium Card
  Widget actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.4),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

 /// Scan Card
Widget scanCard() {
  return GestureDetector(
    onTap: _takePhoto,
    child: Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFA726), // orange
            Color(0xFFFF6F00), // deep orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.45),
            blurRadius: 30,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.camera_alt,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Scan Your Meal",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Take a photo to analyze calories",
            style: TextStyle(
              color: Colors.white70,
            ),
          )
        ],
      ),
    ),
  );
}  Widget featureItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF1E1E1E),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              const Text(
                "AI Food Scanner",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      
              const SizedBox(height: 6),
      
              const Text(
                "Scan meals to track calories instantly",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
      
              const SizedBox(height: 30),
      
              /// Image Preview
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    selectedImage!,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                scanCard(),
      
              const SizedBox(height: 25),
      
              /// Buttons
              Row(
                children: [
                  actionCard(
                    icon: Icons.photo,
                    title: "Gallery",
                    subtitle: "Pick from photos",
                    color: Colors.blue,
                    onTap: _pickGallery,
                  ),
                  const SizedBox(width: 15),
                  actionCard(
                    icon: Icons.flash_on,
                    title: "Quick Add",
                    subtitle: "Log meal fast",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuickAddMealScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
      
              const SizedBox(height: 35),
      
              const Text(
                "Features",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      
              const SizedBox(height: 15),
      
              featureItem("AI identifies food from photos"),
              featureItem("Instant calorie & nutrition data"),
              featureItem("Smart meal insights & feedback"),
            ],
          ),
        ),
      ),
    );
  }
}