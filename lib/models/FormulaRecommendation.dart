class FormulaRecommendation {
  final String gender;
  final int age;
  final double height; // in cm
  final double weight; // current weight in kg
  final double targetWeight; // target weight in kg
  final String activityLevel;
  final String goal; // "Lose Weight", "Gain Muscle", "Maintain Weight"

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
    /// 1️ BMR Calculation (Mifflin-St Jeor)
    double bmr;
    if (gender == "Male") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    /// 2️ Activity Multiplier
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
        activityMultiplier = 1.2; // Sedentary
    }

    double maintenanceCalories = bmr * activityMultiplier;

    /// 3️ Goal Adjustment
    double dailyCalories = maintenanceCalories;

    if (goal == "Lose Weight") {
      dailyCalories = maintenanceCalories - 500; // ~0.5 kg/week
    } else if (goal == "Gain Muscle") {
      dailyCalories = maintenanceCalories + 300; // moderate surplus
    }

    /// 4️ Macro Distribution
    double protein; // g/day
    double fat; // g/day
    double carbs; // g/day

    protein = weight * 1.6; // safe protein intake per kg
    fat = (dailyCalories * 0.25) / 9; // 25% calories from fat
    carbs = (dailyCalories - ((protein * 4) + (fat * 9))) / 4; // remaining calories to carbs

    /// 5️ Weight Timeline Calculation
    double weightDifference = (weight - targetWeight);
    double weeklyChange;

    if (goal == "Lose Weight") {
      weeklyChange = 0.5; // safe loss
    } else if (goal == "Gain Muscle") {
      weeklyChange = 0.25; // safe gain
    } else {
      weeklyChange = 0.5; // maintain weight → just for timeline, can be 0
    }

    double estimatedWeeks =
        weeklyChange > 0 ? (weightDifference.abs() / weeklyChange) : 0;

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