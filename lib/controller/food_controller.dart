import 'dart:convert';
import 'dart:io';
import 'package:fitmind_ai/config/key.dart';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:http/http.dart' as http;

class FoodController {

  final String geminiApiKey = AppKeys.geminiApiKey;

  /// Analyze Food Image
  Future<Food> analyzeFood(File image) async {
    try {

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
        "https://api.gemini.google.com/v1/images/analyze",
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $geminiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "image": base64Image,
          "question":
              "Identify the food and give calories, fats, carbs, protein",
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("API Error: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      final foodName = data['answer'] ?? "Unknown Food";
      final nutrition = data['nutrition'] ?? {};

      final calories = nutrition['calories']?.toDouble();
      final fats = nutrition['fats']?.toDouble();
      final carbs = nutrition['carbs']?.toDouble();
      final protein = nutrition['protein']?.toDouble();

      /// Generate Smart Recommendation
      final shortMsg = _generateSmartMsg(
        foodName,
        calories,
        fats,
        carbs,
        protein,
      );

      return Food(
        name: foodName,
        shortMsg: shortMsg,
        calories: calories,
        fats: fats,
        carbs: carbs,
        protein: protein,
      );
    } catch (e) {
      throw Exception("Analyze Error: $e");
    }
  }

  /// AI Recommendation System
  String _generateSmartMsg(
    String food,
    double? calories,
    double? fats,
    double? carbs,
    double? protein,
  ) {

    String msg = "🍽 $food Detected\n\n";

    if (calories != null) msg += "🔥 Calories: $calories kcal\n";
    if (protein != null) msg += "💪 Protein: $protein g\n";
    if (carbs != null) msg += "🍞 Carbs: $carbs g\n";
    if (fats != null) msg += "🧈 Fats: $fats g\n";

    msg += "\n📊 Recommendation:\n";

    /// Health Logic
    if (calories != null && fats != null && protein != null) {

      // Weight Loss
      if (calories < 350 && fats < 12) {
        msg += "✅ Good for weight loss & daily diet.";
      }

      // Gym / Muscle
      else if (protein > 20 && calories < 500) {
        msg += "💪 Great for muscle building & gym users.";
      }

      // Balanced
      else if (calories < 450 && protein > 15) {
        msg += "🥗 Balanced meal. Safe to eat regularly.";
      }

      // Junk
      else {
        msg += "⚠ High calories/fat. Eat in moderation.";
      }

    } else {
      msg += "ℹ Nutrition data incomplete.";
    }

    return msg;
  }
}