import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepOneController {
  Future<String?> saveStepOneData({
    required String gender,
    required int age,
    required double height,
    required double weight,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return "User not logged in";

      final docRef =
          FirebaseFirestore.instance.collection("users").doc(user.uid);

      final doc = await docRef.get();

      Map<String, dynamic> data = {
        "gender": gender,
        "age": age,
        "height": height,
        "weight": weight, // ✅ current weight
      };

      /// 🔥 ONLY SET startWeight FIRST TIME
      if (!doc.exists || !(doc.data()?.containsKey("startWeight") ?? false)) {
        data["startWeight"] = weight;
      }

      await docRef.set(data, SetOptions(merge: true));

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}