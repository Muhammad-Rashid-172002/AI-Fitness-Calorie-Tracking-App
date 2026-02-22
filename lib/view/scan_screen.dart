import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/analyzing_screen.dart';
import 'package:fitmind_ai/view/Premium_Screens/premium_screen.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScanController controller = ScanController();
  File? selectedImage;

  bool isSubscribed = false; // default false
  bool isLoading = true; // 🔹 show loading while fetching premium status

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus(); // Check Firebase on load
  }

  /// 🔹 Check user's premium status from Firebase
  Future<void> _checkPremiumStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (doc.exists && doc.data()?['premium'] == true) {
        setState(() {
          isSubscribed = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching premium status: $e");
    } finally {
      setState(() {
        isLoading = false; // 🔹 done fetching
      });
    }
  }

  /// 🔹 Camera button action
  void _takePhoto() async {
    if (!isSubscribed) {
      _showPremiumRedirect();
      return;
    }
    File? image = await controller.pickFromCamera();
    if (image != null) {
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
  }

  /// 🔹 Gallery button action
  void _pickGallery() async {
    if (!isSubscribed) {
      _showPremiumRedirect();
      return;
    }
    File? image = await controller.pickFromGallery();
    if (image != null) {
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
  }

  /// 🔹 Show SnackBar and redirect to PremiumScreen
  void _showPremiumRedirect() {
    showCustomSnackBar(context, "Please subscribe to Premium first!", true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 🔹 Show loading until Firebase check is done
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Take a photo or pick from gallery",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              /// Selected Image or Camera Widget
              if (selectedImage != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(selectedImage!, width: double.infinity, height: 260, fit: BoxFit.cover),
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
                        Text("Take Photo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 10),
                        Text("Use your camera to scan a meal", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              /// Buttons Row
              Row(
                children: [
                  /// Gallery
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickGallery,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: const [
                            Icon(Icons.photo, size: 35, color: Colors.blue),
                            SizedBox(height: 10),
                            Text("Gallery", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("Pick from photos", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  /// Quick Add (dummy)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: const [
                          Icon(Icons.flash_on, size: 35, color: Colors.orange),
                          SizedBox(height: 10),
                          Text("Quick Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Log a meal fast", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              /// Features
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
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 18))),
        ],
      ),
    );
  }
}