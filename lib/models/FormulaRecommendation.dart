class FormulaRecommendation {
  final String gender;
  final int age;
  final double height;
  final double weight;
  final double targetWeight;
  final String activityLevel;
  final String goal;

  FormulaRecommendation({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.activityLevel,
    required this.goal,
  });

  Map<String, dynamic> calculate() {

    /// 1️⃣ BMR Calculation
    double bmr;

    if (gender == "Male") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    /// 2️⃣ Activity Multiplier
    double activityMultiplier;

    switch (activityLevel) {
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

    /// 3️⃣ Goal Adjustment
    double dailyCalories = maintenanceCalories;

    if (goal == "Lose Weight") {
      dailyCalories = maintenanceCalories * 0.85;
    } else if (goal == "Gain Muscle") {
      dailyCalories = maintenanceCalories * 1.15;
    }

    /// 4️⃣ Macro Distribution
    double protein = weight * 1.6;
    double fat = (dailyCalories * 0.25) / 9;
    double carbs = (dailyCalories - ((protein * 4) + (fat * 9))) / 4;

    /// 5️⃣ Weight Timeline Calculation
    double weightDifference = (weight - targetWeight).abs();

    /// Safe fat loss rate ≈ 0.5kg per week
    double estimatedWeeks = weightDifference / 0.5;

    return {
      "dailyCalories": dailyCalories.round(),
      "protein": protein.round(),
      "carbs": carbs.round(),
      "fat": fat.round(),
      "targetWeight": targetWeight,
      "estimatedWeeks": estimatedWeeks.round(),
    };
  }
}