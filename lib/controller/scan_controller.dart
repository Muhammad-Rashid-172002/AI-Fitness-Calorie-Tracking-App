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

      if (response.text == null || response.text!.isEmpty) {
        return "Food detected but nutrition data unavailable.";
      }

      return response.text!;
    } catch (e) {
      /// Retry once if server busy
      if (e.toString().contains("503")) {
        await Future.delayed(const Duration(seconds: 2));

        try {
          final model = GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: _apiKey,
          );

          final imageBytes = await image.readAsBytes();

          final retryResponse = await model.generateContent([
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
          ]);

          return retryResponse.text ?? "AI analysis completed.";
        } catch (retryError) {
          return "AI server busy. Please try again.";
        }
      }

      return "Food analysis failed. Try another image.";
    }
  }

  /// =========================
  /// SAVE SCAN + UPDATE DAILY TOTALS
  /// =========================
  Future<void> saveScan({required String result, required Food food}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    /// 1️⃣ SAVE SCAN HISTORY
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("scans")
        .add({
          "result": result,
          "calories": food.calories ?? 0,
          "protein": food.protein ?? 0,
          "carbs": food.carbs ?? 0,
          "fat": food.fats ?? 0,
          "type": "scan",
          "timestamp": FieldValue.serverTimestamp(),
        });

    /// 2️⃣ UPDATE DAILY LOGS
    final dailyRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("dailyLogs")
        .doc(today);

    print("📌 Attempting to save daily log at: users/$uid/dailyLogs/$today");

    final doc = await dailyRef.get();

    int calories = food.calories?.toInt() ?? 0;
    int protein = food.protein?.toInt() ?? 0;
    int carbs = food.carbs?.toInt() ?? 0;
    int fat = food.fats?.toInt() ?? 0;

    print(
      "📊 Nutrition data to save => Calories: $calories, Protein: $protein, Carbs: $carbs, Fat: $fat",
    );

    try {
      if (doc.exists) {
        /// update totals
        await dailyRef.update({
          "totalCalories": FieldValue.increment(calories),
          "totalProtein": FieldValue.increment(protein),
          "totalCarbs": FieldValue.increment(carbs),
          "totalFat": FieldValue.increment(fat),
          "mealCount": FieldValue.increment(1),
        });
        print("✅ Daily log updated successfully");
      } else {
        /// create new daily log
        await dailyRef.set({
          "totalCalories": calories,
          "totalProtein": protein,
          "totalCarbs": carbs,
          "totalFat": fat,
          "mealCount": 1,
          "date": today,
        });
        print("✅ Daily log created successfully");
      }
    } catch (e) {
      print("❌ Failed to save daily log: $e");
    }

    print("✅ Scan saved + DailyLog updated");
  }

  Stream<QuerySnapshot> getScanHistory() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("scans")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  /// =========================
  /// DAILY LOG STREAM (FOR HOME SCREEN)
  /// =========================

  Stream<DocumentSnapshot> getTodayLogStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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

  Future<int> getTodayTotalCarbs() async => await _getTodayField('totalCarbs');

  Future<int> getTodayTotalFat() async => await _getTodayField('totalFat');

  Future<int> _getTodayField(String field) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
    final File? image = fromCamera
        ? await pickFromCamera()
        : await pickFromGallery();

    if (image == null) return null;

    return await analyzeFoodImage(image);
  }

  /// =========================
  /// PARSE FOOD FROM AI RESULT STRING
  /// =========================
  Food parseFoodFromResult(String result) {
    final caloriesRegex = RegExp(
      r'Calories:\s*(\d+)\s*kcal',
      caseSensitive: false,
    );
    final fatsRegex = RegExp(r'Fats:\s*(\d+)\s*g', caseSensitive: false);
    final carbsRegex = RegExp(r'Carbs:\s*(\d+)\s*g', caseSensitive: false);
    final proteinRegex = RegExp(r'Protein:\s*(\d+)\s*g', caseSensitive: false);

    return Food(
      name: result.split("Calories").first.replaceAll("Food:", "").trim(),
      shortMsg: '',
      calories: double.tryParse(
        caloriesRegex.firstMatch(result)?.group(1) ?? '0',
      ),
      fats: double.tryParse(fatsRegex.firstMatch(result)?.group(1) ?? '0'),
      carbs: double.tryParse(carbsRegex.firstMatch(result)?.group(1) ?? '0'),
      protein: double.tryParse(
        proteinRegex.firstMatch(result)?.group(1) ?? '0',
      ),
    );
  }
}
