import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/config/key.dart';

class MonthlyHabitReportScreen extends StatefulWidget {
  const MonthlyHabitReportScreen({super.key});

  @override
  State<MonthlyHabitReportScreen> createState() =>
      _MonthlyHabitReportScreenState();
}

class _MonthlyHabitReportScreenState extends State<MonthlyHabitReportScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  String aiReport = "Generating your AI habit report...";

  @override
  void initState() {
    super.initState();
    generateMonthlyReport();
  }

  Future<void> generateMonthlyReport() async {
    final user = _auth.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    // Fetch all daily logs for this month
    final logsSnap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyLogs')
        .where(
          'date',
          isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(firstDay),
        )
        .where(
          'date',
          isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(lastDay),
        )
        .get();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int daysLogged = 0;
    int overCaloriesDays = 0;
    int skippedDays = 0;

    for (int i = 0; i < lastDay.day; i++) {
      final dateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(firstDay.add(Duration(days: i)));
      QueryDocumentSnapshot<Map<String, dynamic>>? doc;
      try {
        doc = logsSnap.docs.firstWhere((d) => d.data()['date'] == dateStr);
      } catch (e) {
        // firstWhere throws if no element matches; treat as no document for that day
        doc = null;
      }

      if (doc != null) {
        daysLogged++;
        final data = doc.data();
        int dailyCalories = (data['totalCalories'] ?? 0).toInt();
        int dailyProtein = (data['totalProtein'] ?? 0).toInt();
        int dailyCarbs = (data['totalCarbs'] ?? 0).toInt();
        int dailyFat = (data['totalFat'] ?? 0).toInt();
        int dailyGoal = (data['dailyGoal'] ?? 0).toInt();

        totalCalories += dailyCalories;
        totalProtein += dailyProtein;
        totalCarbs += dailyCarbs;
        totalFat += dailyFat;

        if (dailyCalories > dailyGoal) overCaloriesDays++;
      } else {
        skippedDays++;
      }
    }

    // Build AI prompt
    double avgCalories = daysLogged == 0 ? 0 : totalCalories / daysLogged;
    double avgProtein = daysLogged == 0 ? 0 : totalProtein / daysLogged;
    double avgCarbs = daysLogged == 0 ? 0 : totalCarbs / daysLogged;
    double avgFat = daysLogged == 0 ? 0 : totalFat / daysLogged;

    String behaviourNote = "";
    if (overCaloriesDays >= 3)
      behaviourNote += "User exceeded calories multiple times. ";
    if (skippedDays >= 3)
      behaviourNote += "User skipped logging several days. ";
    if (avgProtein < 0.6 * 150)
      behaviourNote +=
          "Protein intake below recommended target. "; // example target

    final prompt =
        """
Generate a 10-point monthly AI habit report.

Monthly Summary:
- Average Calories: ${avgCalories.toStringAsFixed(0)}
- Average Protein: ${avgProtein.toStringAsFixed(0)}
- Average Carbs: ${avgCarbs.toStringAsFixed(0)}
- Average Fat: ${avgFat.toStringAsFixed(0)}
- Days Logged: $daysLogged
- Over Calorie Days: $overCaloriesDays
- Skipped Days: $skippedDays

Behaviour Insight:
$behaviourNote

Follow structure:
1. Monthly overview
2. Calorie analysis
3. Protein intake analysis
4. Carbs & fat insights
5. Streak evaluation
6. Weak habits
7. Risk factors
8. Recommendations
9. Motivation
10. Next month focus
""";

    // Generate AI response
    final model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: AppKeys.geminiApiKey,
    );

    final response = await model.generateContent([Content.text(prompt)]);

    setState(() {
      aiReport = response.text ?? "AI report unavailable";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Monthly AI Habit Report"),
        backgroundColor: cardColor,
        foregroundColor: textMain,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: inactiveColor),
                ),
                child: Text(
                  aiReport,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
    );
  }
}
