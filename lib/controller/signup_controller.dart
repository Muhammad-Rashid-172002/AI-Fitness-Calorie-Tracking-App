import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/utils/validator.dart';
import 'package:flutter/material.dart';

class SignUpController {

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> signUp() async {

    if (!formKey.currentState!.validate()) {
      return "Fix errors first";
    }

    try {

      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Save user in Firestore
      await _firestore.collection("users").doc(uid).set({

        "uid": uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "isPremium": false,
        "createdAt": FieldValue.serverTimestamp(),

      });

      return null; // Success

    } on FirebaseAuthException catch (e) {

      return e.message ?? "Auth Error";

    } catch (e) {

      return "Something went wrong";

    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Validators
  String? nameValidator(String? value) =>
      Validator.validateName(value ?? "");

  String? emailValidator(String? value) =>
      Validator.validateEmail(value ?? "");

  String? passwordValidator(String? value) =>
      Validator.validatePassword(value ?? "");

  String? confirmPasswordValidator(String? value) =>
      Validator.validateConfirmPassword(
        passwordController.text,
        value ?? "",
      );
}