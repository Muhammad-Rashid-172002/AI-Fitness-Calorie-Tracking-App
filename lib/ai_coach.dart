import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class AiCoach extends StatefulWidget {
  const AiCoach({super.key});

  @override
  State<AiCoach> createState() => _AiCoachState();
}

class _AiCoachState extends State<AiCoach> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  bool isLoading = false;

  final String apiKey = AppKeys.geminiApiKey;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();

    messages.add({
      "isUser": false,
      "text":
          "Hi 👋 I’m your FitMind Coach. I can help you with calories, meal plans, weight loss, muscle gain, protein targets, and healthy food choices. Ask me anything about your fitness journey.",
    });

    loadUserData();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> sendMessage() async {
    final question = messageController.text.trim();

    if (question.isEmpty || isLoading) return;

    setState(() {
      messages.add({"isUser": true, "text": question});
      isLoading = true;
    });

    messageController.clear();
    scrollToBottom();

    final response = await askGemini(question);

    if (!mounted) return;

    setState(() {
      messages.add({"isUser": false, "text": response});
      isLoading = false;
    });

    scrollToBottom();
  }

  String cleanAiText(String text) {
    return text
        .replaceAll("**", "")
        .replaceAll("* ", "• ")
        .replaceAll("###", "")
        .replaceAll("##", "")
        .replaceAll("#", "")
        .trim();
  }

  Future<String> askGemini(String question) async {
    try {
      final url =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

      final name = userData?["name"] ?? "User";
      final goal = userData?["goal"] ?? "General fitness";
      final weight = "${userData?["weight"] ?? ""}";
      final targetWeight = "${userData?["targetWeight"] ?? ""}";
      final calories = "${userData?["dailyCalories"] ?? ""}";
      final protein = "${userData?["proteinTarget"] ?? ""}";
      final carbs = "${userData?["carbsTarget"] ?? ""}";
      final fats = "${userData?["fatTarget"] ?? ""}";
      final water = "${userData?["dailyWaterGoal"] ?? ""}";
      final age = "${userData?["age"] ?? ""}";
      final gender = "${userData?["gender"] ?? ""}";
      final activity = "${userData?["activityLevel"] ?? ""}";

      final recentChat = messages
          .take(messages.length)
          .toList()
          .reversed
          .take(8)
          .toList()
          .reversed
          .map((m) {
            final role = m["isUser"] == true ? "User" : "Coach";
            return "$role: ${m["text"]}";
          })
          .join("\n");

      final prompt =
          """
You are **FitMind AI Coach**, a premium personal nutrition and fitness assistant inside a mobile app.

Your job:
- Remember the current conversation context.
- Answer based on the user's latest question and previous chat.
- Give professional, practical, and personalized advice.
- Use markdown formatting with **bold headings**, bullets, and short sections.
- Keep answers app-friendly, clean, and not too long.

Allowed topics:
- Diet
- Nutrition
- Calories
- Macros
- Protein, carbs, fats
- Water intake
- Weight loss
- Weight gain
- Muscle gain
- Meal plans
- Workout plans
- Healthy lifestyle

Food & Nutrition Analysis Rules:

* If the user asks about any food, fruit, vegetable, drink, snack, meal, medicine-related nutrition, or ingredient, provide estimated nutrition information.

* Include:

  * Calories (kcal)
  * Protein (g)
  * Carbohydrates (g)
  * Fat (g)
  * Fiber (g) when relevant
  * Sugar (g) when relevant
  * Key vitamins or minerals when relevant

* If serving size is not provided:

  * Assume a standard serving size.
  * Clearly mention the assumed serving size.

* If quantity is provided:

  * Calculate nutrition based on the specified quantity.
  * Example: 2 bananas, 250g chicken breast, 1 cup rice.

* If multiple foods are provided:

  * Calculate estimated nutrition for each item.
  * Also provide total calories, protein, carbs, and fats.

* For fruits and vegetables:

  * Mention key health benefits.
  * Mention whether the food is high in fiber, vitamins, antioxidants, or hydration.

* For packaged foods:

  * Explain that actual nutrition may vary by brand.
  * Provide a general estimate if exact nutrition facts are unavailable.

* For restaurant meals:

  * Provide estimated nutrition values.
  * Mention that preparation methods can significantly affect calories and macros.

* Always clarify:
  "Nutrition values are estimates and may vary depending on serving size, ingredients, and preparation method."

Examples:

* Apple
* Banana
* Mango
* Orange
* Dates
* Watermelon
* Cucumber
* Tomato
* Potato
* Rice
* Bread
* Chicken
* Fish
* Beef
* Eggs
* Milk
* Yogurt
* Biryani
* Burger
* Pizza
* Juice
* Soft Drinks

When nutrition information is requested, use this response format:

**Nutrition Summary**

* Serving Size:
* Calories:
* Protein:
* Carbs:
* Fat:
* Fiber:
* Sugar:

**Health Benefits**
Short explanation.

**Personalized Advice**
Advice based on the user's goal (weight loss, weight gain, muscle gain, maintenance).

**Important Note**
Nutrition values are estimated and may vary.


If user asks unrelated questions:
Say: **I can only help with diet, fitness, nutrition, and healthy lifestyle guidance.**

Safety rules:
- Do not give dangerous medical advice.
- Do not diagnose disease.
- If user mentions serious illness, medicine, pregnancy, diabetes, heart disease, chest pain, fainting, or severe symptoms, recommend a doctor.
- Use phrases like "general guidance" and "consult a professional" when needed.

User Profile:
Name: $name
Age: $age
Gender: $gender
Current Weight: $weight kg
Target Weight: $targetWeight kg
Goal: $goal
Daily Calories Target: $calories kcal
Protein Target: $protein g
Carbs Target: $carbs g
Fat Target: $fats g
Water Goal: $water L
Activity Level: $activity

Recent Conversation:
$recentChat

Response format:
**Quick Answer**
Short friendly answer.

**Personalized Advice**
Give advice based on user profile.

**What To Do Today**
Give 2-4 practical steps.

**Smart Tip**
One useful fitness/nutrition tip.

**Safety Note**
Only include if needed.

User Question:
$question
""";

      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
              "generationConfig": {
                "temperature": 0.65,
                "topP": 0.9,
                "maxOutputTokens": 900,
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        debugPrint("Gemini Error: ${response.body}");
        return "⚠️ **AI Coach is currently busy.**\n\nPlease try again in a moment.";
      }

      final data = jsonDecode(response.body);
      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text == null || text.toString().trim().isEmpty) {
        return "I couldn't generate a response. Please try again.";
      }

      return text.toString().trim();
    } on SocketException {
      return "📡 **No internet connection.**\n\nPlease check your network and try again.";
    } on TimeoutException {
      return "⏳ **Connection timeout.**\n\nYour internet seems slow. Please try again.";
    } catch (e) {
      debugPrint("Gemini Exception: $e");
      return "⚠️ **AI service is temporarily unavailable.**\n\nPlease try again later.";
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glowCircle(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              size: 260,
            ),
          ),

          Positioned(
            bottom: -140,
            left: -90,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.10),
              size: 280,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg["isUser"] == true;

                      return _chatBubble(
                        text: msg["text"].toString(),
                        isUser: isUser,
                      );
                    },
                  ),
                ),

                if (isLoading) _typingIndicator(),

                _inputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.055),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Diet Coach",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Personal nutrition assistant",
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withOpacity(0.25),
                    ),
                  ),
                  child: const Text(
                    "Online",
                    style: TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
                )
              : null,
          color: isUser ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 22),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? const Color(0xFF06B6D4).withOpacity(0.20)
                  : Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isUser
            ? Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              )
            : MarkdownBody(
                data: text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 14.5,
                    height: 1.55,
                  ),
                  strong: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  h1: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  h2: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  h3: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  listBullet: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 15,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF22C55E),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "FitMind AI is preparing your fitness advice...",
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.92),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ask about meal plan, calories, protein...",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.055),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: isLoading ? null : sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isLoading
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
                          ),
                    color: isLoading ? Colors.white12 : null,
                    boxShadow: isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.30),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
