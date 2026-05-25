import 'dart:convert';
import 'dart:io';

import 'package:fitmind_ai/config/key.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:http/http.dart' as http;
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

      final response = await model.generateContent([
        Content.multi([
          TextPart("""
You are a professional AI nutrition assistant.

Analyze the food image carefully and return realistic estimated nutrition values.
If the image is not food, clearly say it is not food.

Use this exact format only:

Food: [food name]
Serving Size: [estimated serving size in grams]
Calories: [realistic kcal] kcal
Protein: [grams] g
Carbs: [grams] g
Fats: [grams] g
Sugar: [grams] g
Fiber: [grams] g
Health Score: [score]/10
AI Insight: [professional short nutrition feedback]
Goal Advice: [advice for weight loss/gain/healthy eating]
Better Option: [healthier alternative]
Warning: [short warning if high sugar, high fat, oily, processed, etc]

Important:
- Give realistic estimated values.
- Do not say "unknown" unless image is unclear.
- Keep response professional and user-friendly.
"""),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      return response.text ?? "Food detected but nutrition data unavailable.";
    } catch (e) {
      return "AI food analysis failed. Please try again.";
    }
  }

  Future<String> analyzeFaceImage(File image) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: _apiKey,
      );

      final imageBytes = await image.readAsBytes();

      final response = await model.generateContent([
        Content.multi([
          TextPart("""
You are a safe AI skin wellness assistant.

Analyze the face/skin image only for general wellness insights.
Do not diagnose disease. Do not claim medical certainty.

Use this exact format only:

Skin Scan: Completed
Skin Health Score: [score]/100
Skin Overview: [short professional overview]
Hydration Level: [Low/Normal/Good]
Oiliness Level: [Low/Normal/High]
Possible Concerns: [acne/redness/dryness/dark circles/texture etc]
AI Insight: [professional skin wellness feedback]
Care Tips: [3 simple care tips]
Lifestyle Advice: [hydration, sleep, diet, sun protection etc]
Doctor Note: This is not a medical diagnosis. Consult a dermatologist for serious or painful skin concerns.

Important:
- Be professional and safe.
- Avoid disease diagnosis.
- Avoid scary medical claims.
"""),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      return response.text ?? "Skin scan completed.";
    } catch (e) {
      return "Skin scan failed. Please try again.";
    }
  }

  Future<String> analyzeMedicineImage(File image) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: _apiKey,
      );

      final imageBytes = await image.readAsBytes();

      final response = await model.generateContent([
        Content.multi([
          TextPart("""
You are a safe AI medicine label assistant.

Read the medicine name or label from the image.
Give general medicine information only.
Do not prescribe medicine.
Do not give personal dosage unless it is clearly printed on the package.

Use this exact format only:

Medicine Scan: Completed
Medicine Name: [name if visible]
Category: [pain relief/antibiotic/vitamin/allergy/etc if identifiable]
Common Purpose: [general use]
Important Info: [short simple explanation]
Common Side Effects: [general possible side effects]
Safety Warnings: [important warnings]
Who Should Be Careful: [pregnant people, children, allergies, liver/kidney issues etc if relevant]
AI Insight: [professional safety-focused feedback]
Pharmacist Note: Always confirm with a doctor or pharmacist before using medicine.

Important:
- If medicine name is unclear, say "Medicine name not clearly visible".
- Do not create fake dosage.
- Do not replace professional medical advice.
"""),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      return response.text ?? "Medicine scan completed.";
    } catch (e) {
      return "Medicine scan failed. Please try again.";
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
    double extract(List<String> keys) {
      for (var key in keys) {
        final regex = RegExp(
          "$key[: ]*([0-9]+\\.?[0-9]*)",
          caseSensitive: false,
        );
        final match = regex.firstMatch(result);
        if (match != null) {
          return double.tryParse(match.group(1)!) ?? 0;
        }
      }
      return 0;
    }

    String extractName() {
      final regex = RegExp(r"Food:\s*(.*)", caseSensitive: false);
      final match = regex.firstMatch(result);
      if (match != null) return match.group(1)!.trim();
      return "Food Item";
    }

    return Food(
      name: extractName(),
      calories: extract(["calories", "kcal"]),
      protein: extract(["protein"]),
      carbs: extract(["carbs", "carbohydrates"]),
      fats: extract(["fats", "fat"]),
      grams: extract(["serving size", "grams"]) == 0
          ? 100
          : extract(["serving size", "grams"]),
      shortMsg: '',
    );
  }

  /// CALCULATE TODAY'S WEIGHT CHANGE
  Future<Map<String, dynamic>> calculateTodayWeightChange() async {
    final user = _auth.currentUser;
    if (user == null) return {"change": 0.0, "deficit": 0};

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    /// 1️⃣ Get today's calories
    final dailyDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .doc(todayDate)
        .get();

    int consumedCalories = dailyDoc.data()?['totalCalories'] ?? 0;

    /// 2️⃣ Get user target calories
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    int targetCalories = userDoc.data()?['dailyCalories'] ?? 2000;

    /// 3️⃣ Calculate deficit
    int deficit = targetCalories - consumedCalories;

    /// 4️⃣ Convert to weight
    double weightChange = deficit / 7700;

    /// 5️⃣ Save (optional but PRO feature)
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .doc(todayDate)
        .set({
          "deficit": deficit,
          "weightChange": weightChange,
        }, SetOptions(merge: true));

    return {
      "change": weightChange,
      "deficit": deficit,
      "consumed": consumedCalories,
      "target": targetCalories,
    };
  }



  /// usda food 
  /// 
  Future<Food?> fetchFoodFromUSDA(String foodName) async {
  try {
    final uri = Uri.parse(
      "https://api.nal.usda.gov/fdc/v1/foods/search"
      "?query=${Uri.encodeComponent(foodName)}"
      "&pageSize=1"
      "&api_key=${AppKeys.usdaApiKey}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final foods = data["foods"];

    if (foods == null || foods.isEmpty) return null;

    final foodData = foods[0];
    final nutrients = foodData["foodNutrients"] as List;

    double getNutrient(String name) {
      final item = nutrients.firstWhere(
        (n) => n["nutrientName"]
            .toString()
            .toLowerCase()
            .contains(name.toLowerCase()),
        orElse: () => null,
      );

      if (item == null) return 0;
      return double.tryParse(item["value"].toString()) ?? 0;
    }

    return Food(
      name: foodData["description"] ?? foodName,
      calories: getNutrient("Energy"),
      protein: getNutrient("Protein"),
      carbs: getNutrient("Carbohydrate"),
      fats: getNutrient("Total lipid"),
      grams: 100,
      shortMsg: "Nutrition verified from USDA FoodData Central",
    );
  } catch (e) {
    return null;
  }
}
Future<String> detectFoodNameWithGemini(File image) async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  final imageBytes = await image.readAsBytes();

  final response = await model.generateContent([
    Content.multi([
      TextPart("""
Identify only the main food name in this image.
Return only food name, no extra text.
Example: Chicken Biryani
"""),
      DataPart('image/jpeg', imageBytes),
    ]),
  ]);

  return response.text?.trim() ?? "";
}
}


//'gemini-3-flash-preview',