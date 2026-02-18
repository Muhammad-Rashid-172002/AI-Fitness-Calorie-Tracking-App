class UserProfileModel {
  final String uid;
  final String gender;
  final int age;
  final int height;
  final int weight;
  final String loseWeightGoal;
  final String maintainWeightGoal;
  final String gainmuscleGoal;

  UserProfileModel({
    required this.uid,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.loseWeightGoal,
    required this.maintainWeightGoal,
    required this.gainmuscleGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,

      // Step 1
      "gender": gender,
      "age": age,

      // Step 2
      "height": height,
      "weight": weight,

      // Step 3 / 4
      "loseWeightGoal": loseWeightGoal,
      "maintainWeightGoal": maintainWeightGoal,
      "gainmuscleGoal": gainmuscleGoal,

      "updatedAt": DateTime.now(),
    };
  }
}