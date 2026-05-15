import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      showCustomDialog(
        context: context,
        title: "Check your email",
        message:
            "We sent a secure password reset link to your email address or spam folder.",
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      String errorMessage = "Something went wrong. Try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email address.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many attempts. Please try again later.";
      }

      showCustomDialog(
        context: context,
        title: "Reset failed",
        message: errorMessage,
        isSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      showCustomDialog(
        context: context,
        title: "Reset failed",
        message: "Something went wrong. Please try again later.",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _glowCircle(
              color: const Color(0xFF22C55E).withOpacity(0.15),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.12),
              size: 320,
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: AnimatedBuilder(
                animation: _slideAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  );
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _iconBox(Icons.arrow_back_ios_new_rounded),
                          ),
                          const Spacer(),
                          _smallBadge(Icons.lock_reset_rounded, "Secure Reset"),
                        ],
                      ),

                      const SizedBox(height: 55),

                      _heroIcon(),

                      const SizedBox(height: 30),

                      Text(
                        "Reset Your\nPassword",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 38,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Enter your registered email and we’ll send you a secure reset link.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.60),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),

                      const SizedBox(height: 34),

                      _formCard(),

                      const SizedBox(height: 26),

                      Text(
                        "Remember your password?",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Back to Login",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                customTextField(
                  label: "Email Address",
                  controller: emailController,
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter your email";
                    }

                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value.trim())) {
                      return "Enter a valid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: _isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF22C55E),
                                Color(0xFF06B6D4),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : CustomGradientButton(
                          text: 'Send Reset Link',
                          onPressed: passwordReset,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroIcon() {
    return Container(
      height: 118,
      width: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF22C55E),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.30),
            blurRadius: 34,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        color: Colors.white,
        size: 58,
      ),
    );
  }

  Widget customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: const Color(0xFF22C55E),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.055),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.60),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF22C55E),
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF22C55E),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _smallBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF22C55E).withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF22C55E), size: 16),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF22C55E),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}