import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// BASIC INFO
  String name = "";
  String weightGoal = "";
  String weight = "0";
  String height = "0";
  String age = "0";
  String kcal = "0";

  /// 🔥 NEW (FOR YOUR UI)
  int days = 0;
  String status = "On Track";
  Color statusColor = Colors.green;

  /// ---------------------------
  /// FETCH USER DATA
  /// ---------------------------
  Future<void> fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc =
            await _firestore.collection("users").doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data()!;

          name = data['name'] ?? "";
          weightGoal = data['weightGoal'] ?? "Maintain Weight";
          weight = data['weight']?.toString() ?? "0";
          height = data['height']?.toString() ?? "0";
          age = data['age']?.toString() ?? "0";
          kcal = data['kcal']?.toString() ?? "0";

          /// 🔥 DAY CALCULATION
          Timestamp? createdAt = data['createdAt'];
          if (createdAt != null) {
            days = DateTime.now()
                .difference(createdAt.toDate())
                .inDays;
          }

          /// 🔥 STATUS CALCULATION
          _calculateStatus();

          notifyListeners();
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  /// ---------------------------
  /// STATUS LOGIC (PDF BASED)
  /// ---------------------------
  void _calculateStatus() {
    int kcalValue = int.tryParse(kcal) ?? 0;

    if (kcalValue >= 1800 && kcalValue <= 2200) {
      status = "On Track";
      statusColor = Colors.green;
    } else if (kcalValue < 1800) {
      status = "Under Eating";
      statusColor = Colors.orange;
    } else {
      status = "Over Limit";
      statusColor = Colors.red;
    }
  }

  /// ---------------------------
  /// UPDATE WEIGHT GOAL
  /// ---------------------------
  Future<void> updateWeightGoal(String goal) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).update({
          'weightGoal': goal,
        });

        weightGoal = goal;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating weight goal: $e");
    }
  }

  /// ---------------------------
  /// LOGOUT
  /// ---------------------------
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}