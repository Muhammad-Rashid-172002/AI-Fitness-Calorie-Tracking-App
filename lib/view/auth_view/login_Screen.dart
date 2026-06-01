import 'dart:ui';

import 'package:fitmind_ai/components/custom_text_field.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/controller/google_auth_controller.dart';
import 'package:fitmind_ai/controller/login_controller.dart';
import 'package:fitmind_ai/view/auth_view/forgot_password.dart';
import 'package:fitmind_ai/view/auth_view/signup_screen.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final LoginController controller = LoginController();
  final GoogleAuthController googleController = GoogleAuthController();

  bool isLoading = false;

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

    _slideAnim = Tween<double>(begin: 25, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFF020617).withOpacity(0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const SpinKitFadingCircle(
                color: Color(0xFF22C55E),
                size: 58,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hideLoading() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleLogin() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    _showLoading();

    final result = await controller.login();

    _hideLoading();

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result == null) {
      showCustomSnackBar(context, "Login Successful", true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainView()),
      );
    } else {
      showCustomSnackBar(context, result, false);
    }
  }

  // Future<void> _handleGoogleLogin() async {
  //   if (isLoading) return;

  //   setState(() => isLoading = true);
  //   _showLoading();

  //   final result = await googleController.signInWithGoogle();

  //   _hideLoading();

  //   if (!mounted) return;

  //   setState(() => isLoading = false);

  //   if (result == null) {
  //     showCustomSnackBar(context, "Login Successful", true);

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const BodyInfoScreen()),
  //     );
  //   } else {
  //     showCustomSnackBar(context, result, false);
  //   }
  // }

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
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        _topBrand(),

                        const SizedBox(height: 38),

                        const Text(
                          "Welcome\nBack",
                          style: TextStyle(
                            fontSize: 42,
                            height: 1.03,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Login to continue tracking your fitness and nutrition progress.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.58),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _formGlassCard(),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPassword(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        GestureDetector(
                          onTap: _handleLogin,
                          child: Container(
                            height: 62,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(23),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF22C55E),
                                  Color(0xFF06B6D4),
                                  Color(0xFF3B82F6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF06B6D4)
                                      .withOpacity(0.30),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Login",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                       // _divider(),

                        const SizedBox(height: 26),

                        // GestureDetector(
                        //   onTap: _handleGoogleLogin,
                        //   child: Container(
                        //     height: 58,
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       color: Colors.white.withOpacity(0.055),
                        //       borderRadius: BorderRadius.circular(22),
                        //       border: Border.all(
                        //         color: Colors.white.withOpacity(0.10),
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Image.asset("assets/google.png", height: 25),
                        //         const SizedBox(width: 12),
                        //         const Text(
                        //           "Continue with Google",
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontWeight: FontWeight.w700,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 40),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.50),
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: Color(0xFF22C55E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 78),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBrand() {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF22C55E),
                Color(0xFF06B6D4),
              ],
            ),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "FitMind AI",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _formGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              CustomTextField(
                hint: "Email Address",
                icon: Icons.email_outlined,
                controller: controller.emailController,
                validator: controller.emailValidator,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: controller.passwordController,
                validator: controller.passwordValidator,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _divider() {
  //   return Row(
  //     children: [
  //       Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 12),
  //         child: Text(
  //           "OR",
  //           style: TextStyle(
  //             color: Colors.white.withOpacity(0.42),
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
  //     ],
  //   );
  // }

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