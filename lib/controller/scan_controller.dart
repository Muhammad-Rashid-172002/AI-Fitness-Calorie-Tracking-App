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
            "Identify the food in this image. Response format:\n"
            "Food: [Name]\n"
            "Calories: [Value] kcal\n"
            "Fats: [Value] g\n"
            "Carbs: [Value] g\n"
            "Protein: [Value] g",
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

  /// Save scan data
 Future<void> saveScan({
  required String result,
  required Food food,
}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    String dayName = _getDayName(now.weekday);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .add({
      "result": result,
      "calories": (food.calories ?? 0).toInt(),
      "protein": (food.protein ?? 0).toInt(),
      "fat": (food.fats ?? 0).toInt(),
      "carbs": (food.carbs ?? 0).toInt(),
      "day": dayName,
      "date": now,
      "createdAt": FieldValue.serverTimestamp(),
    });

    print("✅ Scan saved successfully");
  } catch (e) {
    print("❌ Firestore save error: $e");
  }
}/// Get scan history (real-time)
  Stream<QuerySnapshot> getScanHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Pick → Analyze → Return Result (NO auto save)
  Future<String?> pickAndAnalyze({bool fromCamera = true}) async {
    final File? image = fromCamera
        ? await pickFromCamera()
        : await pickFromGallery();
    if (image == null) return null;

    final String result = await analyzeFoodImage(image);
    return result;
  }

  /// Helper: Day name
  String _getDayName(int day) {
    switch (day) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  /// Meals count today
  Future<int> getTodayMealCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    DateTime startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .get();

    return snapshot.docs.length;
  }

Future<int> getTodayTotalProtein() async => await _getTodayTotalField('protein');
Future<int> getTodayTotalCarbs() async => await _getTodayTotalField('carbs');
Future<int> getTodayTotalFat() async => await _getTodayTotalField('fat');

Future<int> _getTodayTotalField(String fieldName) async {
  final user = _auth.currentUser;
  if (user == null) return 0;

  DateTime startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final snapshot = await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('scans')
      .where('date', isGreaterThanOrEqualTo: startOfDay)
      .get();

  int total = 0;
  for (var doc in snapshot.docs) {
    final val = doc.data()[fieldName];
    total += (val is num) ? val.toInt() : 0;
  }
  return total;
}
}
