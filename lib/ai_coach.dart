import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

Future<String> askGemini(String question) async {
  try {
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    final name = userData?["name"] ?? "User";
    final goal = userData?["goal"] ?? "";
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

    final prompt = """
You are a professional AI Diet Coach inside a fitness app.

Rules:
- Only answer diet, nutrition, fitness, calories, weight loss, weight gain, meal plans, protein, carbs, fats, water intake, and healthy lifestyle questions.
- If the user asks unrelated questions, politely say you can only help with diet and fitness.
- Give short, practical, friendly answers.
- Use simple language.
- Do not give dangerous medical advice.

User Profile:
Name: $name
Age: $age
Gender: $gender
Weight: $weight kg
Target Weight: $targetWeight kg
Goal: $goal
Daily Calories: $calories
Protein: $protein g
Carbs: $carbs g
Fat: $fats g
Water: $water L
Activity Level: $activity

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
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      debugPrint("Gemini Error: ${response.body}");

      return "⚠️ AI Coach is currently unavailable.\nPlease try again in a moment.";
    }

    final data = jsonDecode(response.body);

    final text =
        data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

    if (text == null) {
      debugPrint("Invalid Gemini response: ${response.body}");

      return "I couldn't generate a response. Try again.";
    }

    return text.toString().trim();

  } on SocketException {
    return "📡 No internet connection.\nPlease check your network and try again.";

  } on TimeoutException {
    return "⏳ Connection timeout.\nYour internet seems slow. Please try again.";

  } catch (e) {
    debugPrint("Gemini Exception: $e");

    return "⚠️ AI service is temporarily unavailable.\nPlease try again later.";
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
                      colors: [
                        Color(0xFF22C55E),
                        Color(0xFF06B6D4),
                      ],
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
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
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

  Widget _chatBubble({
    required String text,
    required bool isUser,
  }) {
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
                  colors: [
                    Color(0xFF22C55E),
                    Color(0xFF06B6D4),
                  ],
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
            color: isUser
                ? Colors.transparent
                : Colors.white.withOpacity(0.08),
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
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.white.withOpacity(0.88),
            fontSize: 14.5,
            height: 1.55,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
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
                            colors: [
                              Color(0xFF22C55E),
                              Color(0xFF06B6D4),
                            ],
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
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}