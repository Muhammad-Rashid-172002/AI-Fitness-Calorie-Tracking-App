import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/utils/validator.dart';
import 'package:flutter/material.dart';

class LoginController {

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Login Function
  Future<String?> login() async {

    if (!formKey.currentState!.validate()) {
      return "Fix errors first";
    }

    try {

      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      return null; // Success

    } on FirebaseAuthException catch (e) {

      // 🔹 Email not registered
      if (e.code == "user-not-found") {
        return "Email not found";
      }

      // 🔹 Wrong password
      if (e.code == "wrong-password") {
        return "Incorrect password";
      }

      // 🔹 Invalid email format
      if (e.code == "invalid-email") {
        return "Invalid email address";
      }

      // 🔹 Too many attempts
      if (e.code == "too-many-requests") {
        return "Too many login attempts. Try again later.";
      }

      // 🔹 Default error
      return e.message ?? "Login failed";

    } catch (e) {

      return "Something went wrong";

    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // Validators
  String? emailValidator(String? value) =>
      Validator.validateEmail(value ?? "");

  String? passwordValidator(String? value) =>
      Validator.validatePassword(value ?? "");
}