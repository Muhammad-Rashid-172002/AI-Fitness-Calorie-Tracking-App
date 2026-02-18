import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepOneController {

  /// Save Step 1 Data (Gender + Age) to Firestore
  Future<String?> saveStepOneData({
    required String gender,
    required int age,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return "User not logged in";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
            "gender": gender,
            "age": age,
          }, SetOptions(merge: true)); // merge:true → don't overwrite other fields

      return null; // Success

    } catch (e) {
      return e.toString();
    }
  }
}