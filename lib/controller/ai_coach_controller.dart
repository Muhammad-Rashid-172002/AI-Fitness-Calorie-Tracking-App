import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AICoachController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==============================
  /// MAIN DAILY COACHING METHOD
  /// ==============================
  Future<String> generateDailyCoaching(int proteinGoal) async {

    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();

    int totalCalories = 0;
    int totalProtein = 0;
    int daysLogged = 0;
    int overCaloriesDays = 0;

    /// Last 7 Days Analysis
    for (int i = 0; i < 7; i++) {
      final date =
          DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyLogs')
          .doc(date)
          .get();

      if (doc.exists) {
        daysLogged++;

        final data = doc.data()!;
        int cals = (data['totalCalories'] ?? 0).toInt();
        int protein = (data['totalProtein'] ?? 0).toInt();
        int goal = (data['dailyGoal'] ?? 0).toInt();

        totalCalories += cals;
        totalProtein += protein;

        if (goal > 0 && cals > goal) {
          overCaloriesDays++;
        }
      }
    }

    if (daysLogged == 0) {
      return "You haven't logged enough data yet. Start tracking meals consistently for better AI coaching.";
    }

    int avgCalories = totalCalories ~/ daysLogged;
    int avgProtein = totalProtein ~/ daysLogged;

    /// ==============================
    /// SIMPLE COACHING LOGIC
    /// ==============================

    String message = "";

    // Protein Issue
    if (avgProtein < proteinGoal) {
      message +=
          "⚠ Your protein intake is below target.\nIncrease lean protein like eggs, chicken, yogurt or lentils.\n\n";
    } else {
      message += "✅ Great job hitting your protein target!\n\n";
    }

    // Calorie Issue
    if (overCaloriesDays >= 4) {
      message +=
          "⚠ You exceeded calories on $overCaloriesDays days this week.\nBe mindful of portion sizes.\n\n";
    } else {
      message += "✅ Calorie control looks stable.\n\n";
    }

    // Consistency
    if (daysLogged < 5) {
      message +=
          "⚠ Logging consistency is low ($daysLogged/7 days).\nTry to log daily for best results.\n\n";
    } else {
      message += "🔥 Excellent logging consistency!\n\n";
    }

    message += "Keep pushing. Small daily wins create big results.";

    return message;
  }
}
