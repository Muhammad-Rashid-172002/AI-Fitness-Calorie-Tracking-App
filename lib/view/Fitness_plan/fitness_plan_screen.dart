import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FitnessPlanScreen extends StatefulWidget {
  const FitnessPlanScreen({super.key});

  @override
  State<FitnessPlanScreen> createState() => _FitnessPlanScreenState();
}

class _FitnessPlanScreenState extends State<FitnessPlanScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? fitnessPlan;

  static const bg = Color(0xFF0B1220);
  static const green = Color(0xFF22C55E);
  static const cyan = Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection("users").doc(user.uid).get();

    final planDoc = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("fitness_plan")
        .doc("current")
        .get();

    setState(() {
      userData = userDoc.data();
      fitnessPlan = planDoc.data();
    });
  }

  Future<void> generateFitnessPlan() async {
    final user = _auth.currentUser;
    if (user == null || userData == null) return;

    setState(() => isLoading = true);

    try {
      final name = userData?["name"] ?? "User";
      final age = userData?["age"] ?? "";
      final gender = userData?["gender"] ?? "";
      final weight = userData?["weight"] ?? "";
      final targetWeight = userData?["targetWeight"] ?? "";
      final goal = userData?["goal"] ?? "General Fitness";
      final activity = userData?["activityLevel"] ?? "Beginner";
      final calories = userData?["dailyCalories"] ?? "";
      final protein = userData?["proteinTarget"] ?? "";

      final prompt =
          """
Create a personalized 7-day fitness plan for this user.

User Profile:
Name: $name
Age: $age
Gender: $gender
Current Weight: $weight kg
Target Weight: $targetWeight kg
Goal: $goal
Activity Level: $activity
Daily Calories: $calories kcal
Protein Target: $protein g

Rules:
- Make plan realistic and safe.
- Use home workouts only.
- Include warm-up and cool-down.
- Different plan according to user goal.
- Keep beginner-friendly.
- Return ONLY valid JSON.
- No markdown.
- No extra text.

JSON format:
{
  "title": "Personalized Fat Loss Plan",
  "weeklyGoal": "Short weekly goal",
  "fitnessScore": 82,
  "aiInsight": "Short professional insight",
  "days": [
    {
      "day": "Monday",
      "focus": "Full Body Fat Burn",
      "duration": "35 min",
      "intensity": "Medium",
      "caloriesBurn": "250 kcal",
      "exercises": ["Jumping Jacks - 3 sets", "Squats - 3 sets"],
      "coachTip": "Short useful tip"
    }
  ]
}
""";

      final url =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${AppKeys.geminiApiKey}";

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
                "maxOutputTokens": 1800,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final data = jsonDecode(response.body);
      String text =
          data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";

      text = text.replaceAll("```json", "").replaceAll("```", "").trim();

      Map<String, dynamic> plan;

      try {
        text = text.replaceAll("```json", "").replaceAll("```", "").trim();
        plan = Map<String, dynamic>.from(jsonDecode(text));
      } catch (e) {
        plan = {
          "title": "Personalized AI Fitness Plan",
          "weeklyGoal":
              "Follow this safe weekly workout plan based on your profile.",
          "fitnessScore": 80,
          "aiInsight": text,
          "days": [
            {
              "day": "Monday",
              "focus": "Full Body Workout",
              "duration": "30 min",
              "intensity": "Medium",
              "caloriesBurn": "180-250 kcal",
              "exercises": [
                "Jumping Jacks - 3 sets",
                "Bodyweight Squats - 3 sets",
                "Push-ups - 3 sets",
                "Plank - 3 rounds",
              ],
              "coachTip": "Start slow and focus on correct form.",
            },
            {
              "day": "Tuesday",
              "focus": "Core & Mobility",
              "duration": "25 min",
              "intensity": "Light",
              "caloriesBurn": "120-180 kcal",
              "exercises": [
                "Crunches - 3 sets",
                "Leg Raises - 3 sets",
                "Cat-Cow Stretch - 2 min",
                "Child Pose - 2 min",
              ],
              "coachTip": "Keep breathing controlled during core exercises.",
            },
            {
              "day": "Wednesday",
              "focus": "Lower Body Strength",
              "duration": "35 min",
              "intensity": "Medium",
              "caloriesBurn": "200-280 kcal",
              "exercises": [
                "Squats - 4 sets",
                "Lunges - 3 sets",
                "Glute Bridges - 3 sets",
                "Wall Sit - 3 rounds",
              ],
              "coachTip": "Rest 45-60 seconds between sets.",
            },
            {
              "day": "Thursday",
              "focus": "Active Recovery",
              "duration": "20 min",
              "intensity": "Easy",
              "caloriesBurn": "80-120 kcal",
              "exercises": ["Light Walk - 15 min", "Full Body Stretch - 5 min"],
              "coachTip": "Recovery helps your body improve faster.",
            },
            {
              "day": "Friday",
              "focus": "Upper Body Strength",
              "duration": "30 min",
              "intensity": "Medium",
              "caloriesBurn": "160-230 kcal",
              "exercises": [
                "Push-ups - 3 sets",
                "Tricep Dips - 3 sets",
                "Shoulder Taps - 3 sets",
                "Superman Hold - 3 rounds",
              ],
              "coachTip": "Keep your core tight during upper body workouts.",
            },
            {
              "day": "Saturday",
              "focus": "Fat Burn Circuit",
              "duration": "35 min",
              "intensity": "High",
              "caloriesBurn": "250-350 kcal",
              "exercises": [
                "High Knees - 3 sets",
                "Mountain Climbers - 3 sets",
                "Burpees - 3 sets",
                "Plank - 3 rounds",
              ],
              "coachTip": "Take breaks if your breathing feels too heavy.",
            },
            {
              "day": "Sunday",
              "focus": "Rest Day",
              "duration": "10 min",
              "intensity": "Rest",
              "caloriesBurn": "0-50 kcal",
              "exercises": [
                "Gentle Stretching",
                "Hydration Focus",
                "Sleep Recovery",
              ],
              "coachTip": "Rest day is part of progress.",
            },
          ],
        };
      }

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("fitness_plan")
          .doc("current")
          .set({...plan, "createdAt": FieldValue.serverTimestamp()});

      setState(() {
        fitnessPlan = Map<String, dynamic>.from(plan);
      });
    } catch (e) {
      debugPrint("Fitness Plan Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("AI plan generate nahi ho saka.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = (fitnessPlan?["days"] as List?) ?? [];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _glow(top: -90, right: -80, color: green.withOpacity(0.18)),
          _glow(bottom: -100, left: -80, color: cyan.withOpacity(0.14)),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  if (fitnessPlan == null) _emptyState(),
                  if (fitnessPlan != null) ...[
                    _heroCard(),
                    const SizedBox(height: 18),
                    _todayCard(days),
                    const SizedBox(height: 18),
                    const Text(
                      "7-Day AI Workout Plan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...days.map((day) => _dayCard(day)).toList(),
                  ],
                  const SizedBox(height: 20),
                  _generateButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _iconBox(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AI Fitness Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Personalized workout plan for your goal",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        _iconBox(Icons.auto_awesome_rounded),
      ],
    );
  }

  Widget _emptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [green, cyan]),
                  boxShadow: [
                    BoxShadow(color: green.withOpacity(0.35), blurRadius: 28),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Generate Your AI Fitness Plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "FitMind AI will create a custom weekly workout plan based on your weight, goal, activity level, and fitness profile.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: green.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 34),
          const SizedBox(height: 12),
          Text(
            fitnessPlan?["title"] ?? "Personalized Fitness Plan",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            fitnessPlan?["weeklyGoal"] ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _miniStat("Score", "${fitnessPlan?["fitnessScore"] ?? 80}/100"),
              const SizedBox(width: 12),
              _miniStat("Plan", "7 Days"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _todayCard(List days) {
    if (days.isEmpty) return const SizedBox();

    final today = days.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today’s Workout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "AI personalized training session",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            today["focus"] ?? "Workout",
            style: const TextStyle(
              color: Color(0xFF4ADE80),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _proTag(Icons.timer_rounded, today["duration"] ?? "30 min"),

              const SizedBox(width: 10),

              _proTag(
                Icons.local_fire_department_rounded,
                today["caloriesBurn"] ?? "200 kcal",
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF22C55E),
                  size: 22,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    fitnessPlan?["weeklyGoal"] ??
                        "Stay consistent with your workouts and nutrition plan for best results.",
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.6,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF22C55E), size: 18),

          const SizedBox(width: 7),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(dynamic day) {
    final exercises = (day["exercises"] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleIcon(Icons.directions_run_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${day["day"] ?? ""} • ${day["focus"] ?? ""}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _tag(Icons.timer_rounded, day["duration"] ?? ""),
              const SizedBox(width: 8),
              _tag(Icons.speed_rounded, day["intensity"] ?? ""),
            ],
          ),
          const SizedBox(height: 12),
          ...exercises.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(color: green, fontSize: 17),
                  ),
                  Expanded(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ((day["coachTip"] ?? "").toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: green.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "Coach Tip: ${day["coachTip"]}",
                style: const TextStyle(
                  color: Color(0xFFBBF7D0),
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _generateButton() {
    return GestureDetector(
      onTap: isLoading ? null : generateFitnessPlan,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isLoading
              ? null
              : const LinearGradient(colors: [green, cyan]),
          color: isLoading ? Colors.white12 : null,
          boxShadow: [
            if (!isLoading)
              BoxShadow(
                color: cyan.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  fitnessPlan == null
                      ? "Generate AI Fitness Plan"
                      : "Regenerate New Plan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: green, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: green.withOpacity(0.14),
      ),
      child: Icon(icon, color: green, size: 22),
    );
  }

  Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
