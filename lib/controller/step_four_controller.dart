import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepFourController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save Step 4 Data (Activity Level)
  Future<String?> saveStepFourData({required String activityLevel}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return "User not logged in";

      // Save the activity level in the user's document
      await _firestore.collection("users").doc(uid).set({
        "activityLevel": activityLevel,
      }, SetOptions(merge: true)); // merge true → updates instead of overwriting

      return null; // success
    } catch (e) {
      return e.toString(); // return error message
    }
  }
}