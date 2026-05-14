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
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));

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
      return "You haven't logged enough data yet. Start tracking your meals consistently, even small snacks count!";
    }

    int avgCalories = totalCalories ~/ daysLogged;
    int avgProtein = totalProtein ~/ daysLogged;

    /// ==============================
    /// REALISTIC COACHING MESSAGES
    /// ==============================
    String message = "Your weekly summary:\n\n";

    // Protein feedback
    if (avgProtein < proteinGoal) {
     // double deficit = proteinGoal - avgProtein.toDouble();
      message +=
          "⚠ Protein intake is slightly low (avg ${avgProtein}g/day, target ${proteinGoal}g/day).\n"
          "Try adding more lean protein like eggs, chicken, lentils, yogurt, or tofu.\n\n";
    } else if (avgProtein > proteinGoal * 1.3) {
      message +=
          "⚠ Your protein intake is quite high (avg ${avgProtein}g/day).\n"
          "Balance it with enough carbs and healthy fats.\n\n";
    } else {
      message +=
          "Protein intake is on point (avg ${avgProtein}g/day). Keep it consistent!\n\n";
    }

    // Calories feedback
    if (overCaloriesDays >= 4) {
      message +=
          "⚠ Calorie intake was above your goal on $overCaloriesDays days this week.\n"
          "Consider portion control or swapping high-calorie snacks for fruits or vegetables.\n\n";
    } else if (avgCalories < 1200) {
      message +=
          "⚠ Average calories seem low (${avgCalories} kcal/day).\n"
          "Make sure you’re eating enough to meet your energy needs.\n\n";
    } else {
      message +=
          " Your calorie intake is balanced (avg ${avgCalories} kcal/day). Nice work managing portions!\n\n";
    }

    // Logging consistency
    if (daysLogged < 5) {
      message +=
          "⚠ You logged meals for only $daysLogged out of 7 days.\n"
          "Try to log every meal/snack — this helps the AI give better coaching.\n\n";
    } else {
      message +=
          "🔥 Excellent logging consistency! Logging almost every day helps track progress accurately.\n\n";
    }

    message +=
        "Remember: Small, consistent improvements beat perfection. Keep going! 💪";

    return message;
  }

  // ai feedback
Future<String> generateDailyTip(int proteinGoal) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final now = DateTime.now();

  int totalProtein = 0;
  int daysLogged = 0;

  for (int i = 0; i < 3; i++) {
    final date = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(Duration(days: i)));

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailyLogs')
        .doc(date)
        .get();

    if (doc.exists) {
      daysLogged++;

      final data = doc.data()!;

      totalProtein += ((data['totalProtein'] ?? 0) as num).toInt();
    }
  }

  /// NO DATA
  if (daysLogged == 0) {
    final List<String> startTips = [
      "👋 Start logging your meals daily to unlock personalized nutrition coaching.",
      "🥗 Track your meals consistently so FitMind AI can guide your nutrition better.",
      "💪 Your fitness journey starts with meal tracking. Add your meals to get smart AI insights.",
      "🔥 Begin logging your food today and receive personalized health recommendations.",
    ];

    return startTips[
        DateTime.now().millisecond % startTips.length];
  }

  int avgProtein = totalProtein ~/ daysLogged;

  /// LOW PROTEIN
  if (avgProtein < proteinGoal) {
    final List<String> lowProteinTips = [
      "🍗 Your protein intake is slightly low. Add chicken, eggs, fish, or Greek yogurt today.",
      "💪 You need more protein to support recovery and muscle health. Try high-protein snacks.",
      "🥚 Increase your protein intake today for better strength and fitness performance.",
      "🔥 You're doing well! Adding more lean protein can improve your daily nutrition balance.",
    ];

    return lowProteinTips[
        DateTime.now().second % lowProteinTips.length];
  }

  /// HIGH PROTEIN
  if (avgProtein > proteinGoal + 20) {
    final List<String> highProteinTips = [
      "💧 Your protein intake is high today. Drink more water and balance it with healthy carbs.",
      "🥤 Great protein intake! Make sure to stay hydrated throughout the day.",
      "⚖️ Your protein levels are above target. Add fruits and healthy carbs for better balance.",
      "🚰 High protein intake detected. Increase water intake to support digestion and recovery.",
    ];

    return highProteinTips[
        DateTime.now().minute % highProteinTips.length];
  }

  /// BALANCED NUTRITION
  final List<String> balancedTips = [
    "✨ Excellent progress today! Your nutrition balance looks strong and consistent.",
    "💪 Great job! Your protein and nutrition intake are looking balanced today.",
    "🔥 Awesome work! Your food choices are supporting your fitness journey perfectly.",
    "🥗 Nice balance today! Keep making healthy choices and stay hydrated.",
    "⭐ Your nutrition is on track today. Consistency like this builds real results.",
    "🚀 Amazing progress! Your daily nutrition balance is helping you move closer to your goal.",
  ];

  return balancedTips[
      DateTime.now().day % balancedTips.length];
}
}