import 'package:fitmind_ai/utils/validator.dart';
import 'package:flutter/material.dart';


class LoginController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Validate Form
  bool validateForm() {
    return formKey.currentState!.validate();
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // Validators
  String? emailValidator(String? value) {
    return Validator.validateEmail(value ?? "");
  }

  String? passwordValidator(String? value) {
    return Validator.validatePassword(value ?? "");
  }
}