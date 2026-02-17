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

  //  Register User
  Future<String?> signUp() async {
    if (!validateForm()) return "Invalid Form";

    try {
      // 1️ Create User in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2️ Save User Data in Firestore
      await _firestore.collection("users").doc(uid).set({
        "uid": uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null; //  Success

    } on FirebaseAuthException catch (e) {
      return e.message; //  Firebase Error
    } catch (e) {
      return "Something went wrong";
    }
  }

  // Validate All Fields
  bool validateForm() {
    return formKey.currentState!.validate();
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Validators
  String? nameValidator(String? value) {
    return Validator.validateName(value ?? "");
  }

  String? emailValidator(String? value) {
    return Validator.validateEmail(value ?? "");
  }

  String? passwordValidator(String? value) {
    return Validator.validatePassword(value ?? "");
  }

  String? confirmPasswordValidator(String? value) {
    return Validator.validateConfirmPassword(
      passwordController.text,
      value ?? "",
    );
  }
}