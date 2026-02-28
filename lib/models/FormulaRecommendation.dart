class FormulaRecommendation {
  final String gender;       // "Male" or "Female"
  final int age;             // in years
  final double height;       // in cm
  final double weight;       // in kg
  final String activityLevel; // "Sedentary", "Lightly Active", "Moderately Active", "Very Active"
  final String goal;         // "Lose Weight", "Maintain Weight", "Gain Muscle"

  FormulaRecommendation({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
  });

  /// Returns daily calories and macro targets
  Map<String, dynamic> calculate() {
    // 1️⃣ Calculate BMR (Mifflin-St Jeor Equation)
    double bmr;
    if (gender == "Male") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // 2️⃣ Activity multiplier
    double activityMultiplier;
    switch (activityLevel) {
      case "Sedentary":
        activityMultiplier = 1.2;
        break;
      case "Lightly Active":
        activityMultiplier = 1.375;
        break;
      case "Moderately Active":
        activityMultiplier = 1.55;
        break;
      case "Very Active":
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double maintenanceCalories = bmr * activityMultiplier;

    // 3️⃣ Goal adjustment (safe deficit/surplus)
    double dailyCalories = maintenanceCalories;
    if (goal == "Lose Weight") {
      dailyCalories = maintenanceCalories * 0.85; // 15% deficit
    } else if (goal == "Gain Muscle") {
      dailyCalories = maintenanceCalories * 1.15; // 15% surplus
    }

    // 4️⃣ Macro distribution (common ratio: P/C/F)
    // Protein: 1.6g per kg body weight
    double protein = weight * 1.6;
    // Fat: 25% of total calories, 1g fat = 9 kcal
    double fat = (dailyCalories * 0.25) / 9;
    // Carbs: remaining calories, 1g carb = 4 kcal
    double carbs = (dailyCalories - (protein * 4 + fat * 9)) / 4;

    return {
      "dailyCalories": dailyCalories.round(),
      "protein": protein.round(),
      "carbs": carbs.round(),
      "fat": fat.round(),
    };
  }
}
