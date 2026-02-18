import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize properly
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // Google Login
  Future<String?> signInWithGoogle() async {
    try {

      // Select account
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        return "Login cancelled";
      }

      // Get auth data
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return "Token is null";
      }

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User user = userCredential.user!;

      // Save to Firestore
      await _firestore
          .collection("users")
          .doc(user.uid)
          .set({

        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photo": user.photoURL ?? "",
        "isPremium": false,
        "createdAt": FieldValue.serverTimestamp(),

      }, SetOptions(merge: true));

      return null; // success

    } catch (e) {
      print("Google Login Error: $e");
      return "Google login failed";
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}