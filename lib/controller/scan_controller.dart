import 'dart:io';
import 'package:fitmind_ai/config/key.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ScanController {
  final ImagePicker _picker = ImagePicker();
  
  // Your Gemini API Key
  final String _apiKey = AppKeys.geminiApiKey;

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    return image != null ? File(image.path) : null;
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    return image != null ? File(image.path) : null;
  }

  /// Analyze food using Gemini 3 Flash
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
            "Food: [Name]\nCalories: [Value] kcal\nFats: [Value]g\nCarbs: [Value]g\nProtein: [Value]g"
          ),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);

      if (response.text == null) {
        return "AI could not recognize the food. Try a better photo.";
      }

      return response.text!;
      
    } catch (e) {
      if (e.toString().contains("not found")) {
        return "Error: Model name update required. Use 'gemini-2.5-flash'.";
      }
      return "Error: ${e.toString()}";
    }
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage(File image) async {
    String uid = _auth.currentUser!.uid;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('users/$uid/scans/$fileName.jpg');
    UploadTask task = ref.putFile(image);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  /// Save scan (image + AI result) to Firestore
  Future<void> saveScan(File image, String result) async {
    String imageUrl = await uploadImage(image);
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).collection('scans').add({
      'imageUrl': imageUrl,
      'result': result,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Fetch user scan history (real-time)
  Stream<List<Scan>> getScanHistory() {
    String uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Scan.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Full flow: Pick, analyze, and save scan
  Future<String?> pickAnalyzeAndSave({bool fromCamera = true}) async {
    File? image = fromCamera ? await pickFromCamera() : await pickFromGallery();
    if (image == null) return null;

    String result = await analyzeFoodImage(image);
    await saveScan(image, result);

    return result;
  }
}