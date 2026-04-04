
class Food {
  final String name;
  final String shortMsg;
  final double? calories; // per 100g
  final double? fats;
  final double? carbs;
  final double? protein;
  final double? grams; // ✅ ADD THIS
  final String? imagePath;

  Food({
    required this.name,
    required this.shortMsg,
    this.calories,
    this.fats,
    this.carbs,
    this.protein,
    this.grams,
    this.imagePath,
  });

  /// ✅ COPY WITH (VERY IMPORTANT)
  Food copyWith({
    String? name,
    String? shortMsg,
    double? calories,
    double? fats,
    double? carbs,
    double? protein,
    double? grams,
    String? imagePath,
  }) {
    return Food(
      name: name ?? this.name,
      shortMsg: shortMsg ?? this.shortMsg,
      calories: calories ?? this.calories,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      grams: grams ?? this.grams,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}