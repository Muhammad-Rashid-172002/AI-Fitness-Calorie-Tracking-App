import 'package:fitmind_ai/models/user_model.dart';
import 'package:flutter/material.dart';


class ProfileController extends ChangeNotifier {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  String selectedGoal = "Lose";

  void selectGoal(String goal) {
    selectedGoal = goal;
    notifyListeners();
  }

  UserModel getUserData() {
    return UserModel(
      name: nameController.text,
      age: int.parse(ageController.text),
      weight: double.parse(weightController.text),
      height: double.parse(heightController.text),
      goal: selectedGoal,
    );
  }

  bool validate() {
    return nameController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        heightController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }
}