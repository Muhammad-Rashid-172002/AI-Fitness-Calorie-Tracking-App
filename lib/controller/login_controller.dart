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