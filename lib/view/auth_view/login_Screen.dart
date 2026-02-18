import 'package:fitmind_ai/components/custom_text_field.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/controller/google_auth_controller.dart';
import 'package:fitmind_ai/controller/login_controller.dart';
import 'package:fitmind_ai/view/auth_view/signup_screen.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:fitmind_ai/view/onboarding/step_one_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = LoginController();
  //final GoogleAuthController _googleAuthController = GoogleAuthController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final GoogleAuthController googleController = GoogleAuthController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF8FAFC),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Login to continue your fitness journey",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 17),
                ),

                const SizedBox(height: 40),

                /// Email
                CustomTextField(
                  hint: "Email",
                  icon: Icons.email_outlined,
                  controller: controller.emailController,
                  validator: controller.emailValidator,
                ),

                const SizedBox(height: 20),

                /// Password
                CustomTextField(
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: controller.passwordController,
                  validator: controller.passwordValidator,
                ),

                const SizedBox(height: 10),

                /// Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Forgot Password
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF22C55E)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Login Button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: GestureDetector(
                    onTap: () async {
                      // Show Loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: SpinKitFadingCircle(
                            color: Colors.green,
                            size: 60.0,
                          ),
                        ),
                      );

                      // Firebase Login
                      String? result = await controller.login();

                      // Close Loading
                      Navigator.pop(context);

                      // Success
                      if (result == null) {
                        showCustomSnackBar(context, "Login Successful", true);

                        //  Go to HOME PAGE (Not StepOne)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainView()),
                        );
                      } else {
                        // Error
                        showCustomSnackBar(context, result, false);
                      }
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF06B6D4),
                            Color(0xFF38BDF8),
                          ],
                        ),
                      ),

                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              
              
                const SizedBox(height: 45),

                /// Divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 45),

                /// Google Login
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      backgroundColor: const Color(0xFF020617),
                    ),

                    onPressed: () async {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        ),
                      );

                      // Call Google Login
                      String? result = await googleController
                          .signInWithGoogle();

                      Navigator.pop(context); // Remove loading

                      // Success
                      if (result == null) {
                        showCustomSnackBar(context, "Login Successful", true);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StepOneScreen(),
                          ),
                        );
                      }
                      // Error
                      else {
                        showCustomSnackBar(context, result, false);
                      }
                    },

                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 30,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// Sign Up
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
