import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepTwoController {

  /// Save Height & Weight to Firestore
  Future<String?> saveStepTwoData({
    required int height,
    required int weight,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "User not logged in";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
            "height": height,
            "weight": weight,
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // merge:true → keep existing data

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }
}