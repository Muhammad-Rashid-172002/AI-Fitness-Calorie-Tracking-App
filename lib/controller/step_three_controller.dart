import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepThreeController {

  /// Save User Goal to Firestore
  Future<String?> saveStepThreeData({
    required String goal,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "User not logged in";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
            "goal": goal,
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }
}