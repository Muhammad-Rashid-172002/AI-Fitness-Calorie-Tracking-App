class Validator {
  // Name Validation
  static String? validateName(String value) {
    if (value.isEmpty) {
      return "Name is required";
    }
    if (value.length < 3) {
      return "Name must be at least 3 characters";
    }
    return null;
  }

  // Email Validation
  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return "Email is required";
    }

    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return "Enter valid email";
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be 6+ characters";
    }

    return null;
  }

  // Confirm Password
  static String? validateConfirmPassword(
      String pass, String confirmPass) {
    if (confirmPass.isEmpty) {
      return "Confirm password required";
    }

    if (pass != confirmPass) {
      return "Passwords do not match";
    }

    return null;
  }
}