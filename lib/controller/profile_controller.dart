import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String weightGoal = "";
  String weight = "0";
  String height = "0";
  String age = "0";
  String kcal = "0";

  // Fetch user data
  Future<void> fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection("users").doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          name = data['name'] ?? "";
          weightGoal = data['weightGoal'] ?? "Maintain Weight";
          weight = data['weight']?.toString() ?? "0";
          height = data['height']?.toString() ?? "0";
          age = data['age']?.toString() ?? "0";
          kcal = data['kcal']?.toString() ?? "0";
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  // Update weight goal
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

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}