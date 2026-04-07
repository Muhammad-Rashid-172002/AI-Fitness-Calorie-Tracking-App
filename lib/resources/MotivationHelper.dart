class MotivationHelper {
  /// Returns motivation text based on progress percentage (0 to 100)
  static String getMotivation(double progress) {
    if (progress < 25) {
      return "Great start 💪 Keep going!";
    } else if (progress < 60) {
      return "You're doing amazing 🚀";
    } else if (progress < 90) {
      return "Almost there 🔥";
    } else {
      return "You're crushing it 🎯";
    }
  }
}