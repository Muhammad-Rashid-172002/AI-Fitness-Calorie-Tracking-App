import 'dart:io';

import 'package:fitmind_ai/config/key.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScanController {
  final ImagePicker _picker = ImagePicker();
  final String _apiKey = AppKeys.geminiApiKey;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// =========================
  /// IMAGE PICKING
  /// =========================

  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    return image != null ? File(image.path) : null;
  }

  /// =========================
  /// GEMINI AI ANALYSIS
  /// =========================

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


  /// =========================
  /// SAVE SCAN + UPDATE DAILY TOTALS
  /// =========================

  Future<void> saveScan({
    required String result,
    required Food food,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(now);

      final userRef = _firestore.collection('users').doc(user.uid);

      /// 1️⃣ Save scan history
      await userRef.collection('scans').add({
        "result": result,
        "calories": (food.calories ?? 0).toInt(),
        "protein": (food.protein ?? 0).toInt(),
        "fat": (food.fats ?? 0).toInt(),
        "carbs": (food.carbs ?? 0).toInt(),
        "date": now,
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// 2️⃣ Update daily totals
      final dailyRef =
          userRef.collection('dailyLogs').doc(todayDate);

      await dailyRef.set({
        "totalCalories":
            FieldValue.increment((food.calories ?? 0).toInt()),
        "totalProtein":
            FieldValue.increment((food.protein ?? 0).toInt()),
        "totalCarbs":
            FieldValue.increment((food.carbs ?? 0).toInt()),
        "totalFat":
            FieldValue.increment((food.fats ?? 0).toInt()),
        "mealCount": FieldValue.increment(1),
        "date": todayDate,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Scan + Daily totals updated successfully");
    } catch (e) {
      print("❌ Firestore save error: $e");
    }
  }

  /// =========================
  /// REAL-TIME SCAN HISTORY
  /// =========================

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

  /// =========================
  /// DAILY LOG STREAM (FOR HOME SCREEN)
  /// =========================

  Stream<DocumentSnapshot> getTodayLogStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    String todayDate =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .doc(todayDate)
        .snapshots();
  }

  /// =========================
  /// TODAY STATS (ONE-TIME FETCH)
  /// =========================

  Future<int> getTodayMealCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    String todayDate =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .doc(todayDate)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?['mealCount'] ?? 0).toInt();
  }

  Future<int> getTodayTotalCalories() async =>
      await _getTodayField('totalCalories');

  Future<int> getTodayTotalProtein() async =>
      await _getTodayField('totalProtein');

  Future<int> getTodayTotalCarbs() async =>
      await _getTodayField('totalCarbs');

  Future<int> getTodayTotalFat() async =>
      await _getTodayField('totalFat');

  Future<int> _getTodayField(String field) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    String todayDate =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .doc(todayDate)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?[field] ?? 0).toInt();
  }

  /// =========================
  /// PICK + ANALYZE (NO SAVE)
  /// =========================

  Future<String?> pickAndAnalyze({bool fromCamera = true}) async {
    final File? image =
        fromCamera ? await pickFromCamera() : await pickFromGallery();

    if (image == null) return null;

    return await analyzeFoodImage(image);
  }

  /// =========================
/// PARSE FOOD FROM AI RESULT STRING
/// =========================
Food parseFoodFromResult(String result) {
  final caloriesRegex = RegExp(r'Calories:\s*(\d+)\s*kcal', caseSensitive: false);
  final fatsRegex = RegExp(r'Fats:\s*(\d+)\s*g', caseSensitive: false);
  final carbsRegex = RegExp(r'Carbs:\s*(\d+)\s*g', caseSensitive: false);
  final proteinRegex = RegExp(r'Protein:\s*(\d+)\s*g', caseSensitive: false);

  return Food(
    name: result.split("Calories").first.replaceAll("Food:", "").trim(),
    shortMsg: '',
    calories: double.tryParse(caloriesRegex.firstMatch(result)?.group(1) ?? '0'),
    fats: double.tryParse(fatsRegex.firstMatch(result)?.group(1) ?? '0'),
    carbs: double.tryParse(carbsRegex.firstMatch(result)?.group(1) ?? '0'),
    protein: double.tryParse(proteinRegex.firstMatch(result)?.group(1) ?? '0'),
  );
}



}
