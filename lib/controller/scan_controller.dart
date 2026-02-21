import 'dart:io';
import 'package:fitmind_ai/config/key.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanController {
  final ImagePicker _picker = ImagePicker();
  final String _apiKey = AppKeys.geminiApiKey;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    return image != null ? File(image.path) : null;
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    return image != null ? File(image.path) : null;
  }

  /// Analyze food using Gemini
  Future<String> analyzeFoodImage(File image) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: _apiKey,
      );
      final imageBytes = await image.readAsBytes();
      final content = [
        Content.multi([
          TextPart(
            "Identify the food in this image. Response format: "
            "Food: [Name]\nCalories: [Value] kcal\nFats: [Value]g\nCarbs: [Value]g\nProtein: [Value]g",
          ),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];
      final response = await model.generateContent(content);
      return response.text ?? "AI could not recognize the food";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  /// Save scan to Firestore
Future<void> saveScan({File? image, required String result}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ User not logged in. Scan not saved.");
      return;
    }

    Map<String, dynamic> data = {
      'result': result,
      'createdAt': DateTime.now(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (image != null) {
      data['imagePath'] = image.path;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .add(data);

    print("✅ Scan saved for user ${user.uid}");
  } catch (e) {
    print("❌ Firestore save error: $e");
  }
}

  /// Get real-time scan history
  Stream<List<Scan>> getScanHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Scan.fromMap(doc.id, doc.data())).toList());
  }

  /// Full flow: pick → analyze → save
  Future<String?> pickAnalyzeAndSave({bool fromCamera = true}) async {
    final File? image =
        fromCamera ? await pickFromCamera() : await pickFromGallery();
    if (image == null) return null;

    final String result = await analyzeFoodImage(image);
    await saveScan(image: image, result: result);

    return result;
  }
}