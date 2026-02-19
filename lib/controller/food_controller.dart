import 'dart:convert';
import 'dart:io';
import 'package:fitmind_ai/models/food_model.dart';
import 'package:http/http.dart' as http;


class FoodController {
  final String geminiApiKey = "Your Gemini API Key";
  final String nutritionAppId = "YOUR_EDAMAM_APP_ID"; // optional
  final String nutritionApiKey = "YOUR_EDAMAM_API_KEY"; // optional

  // Step 1: Send image to Gemini API and detect food
  Future<String> detectFood(File image) async {
    // Convert image to base64
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse("https://api.gemini.google.com/v1/images/analyze"); // Example
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $geminiApiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "image": base64Image,
        "question": "What food is in this image?"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'] ?? "Unknown Food";
    } else {
      throw Exception("Failed to detect food");
    }
  }

  // Step 2: Optional - Fetch nutrition info from Edamam
  Future<Map<String, dynamic>?> getNutrition(String foodName) async {
    final url = Uri.parse(
        "https://api.edamam.com/api/nutrition-data?app_id=$nutritionAppId&app_key=$nutritionApiKey&ingr=$foodName");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "calories": data['calories'],
        "fats": data['totalNutrients']['FAT']?['quantity']
      };
    }
    return null;
  }

  // Step 3: Generate short message
  String generateShortMsg(String foodName, double? calories, double? fats) {
    if (calories != null && fats != null) {
      if (calories < 400 && fats < 15) {
        return "$foodName 🍴: Low calorie, healthy ✅";
      } else {
        return "$foodName 🍴: High in calories/fats, eat occasionally ❌";
      }
    } else {
      return "$foodName 🍴: Looks delicious! 😋"; // fallback
    }
  }

  // Full workflow
  Future<Food> analyzeFood(File image) async {
    final foodName = await detectFood(image);
    final nutrition = await getNutrition(foodName);
    final msg = generateShortMsg(
        foodName, nutrition?['calories'], nutrition?['fats']);
    return Food(
        name: foodName, shortMsg: msg, calories: nutrition?['calories'], fats: nutrition?['fats']);
  }
}