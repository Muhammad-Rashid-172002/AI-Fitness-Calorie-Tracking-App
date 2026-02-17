import 'package:fitmind_ai/components/custom_text_field.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/controller/signup_controller.dart';
import 'package:fitmind_ai/view/auth_view/login_Screen.dart';
import 'package:fitmind_ai/view/onboarding/step_one_screen.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController controller = SignUpController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey, //  Important
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Title
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF8FAFC),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Sign up to start your fitness journey",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 17),
                ),

                const SizedBox(height: 40),

                /// Name
                CustomTextField(
                  hint: "Full Name",
                  icon: Icons.person_outline,
                  controller: controller.nameController,
                  validator: controller.nameValidator,
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 20),

                /// Confirm Password
                CustomTextField(
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: controller.confirmPasswordController,
                  validator: controller.confirmPasswordValidator,
                ),

                const SizedBox(height: 30),

                /// Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: GestureDetector(
                    onTap: () {

                      // ✅ Validation Check
                      if (controller.validateForm()) {

                        showCustomSnackBar(
                            context, "Account Created", true);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StepOneScreen(),
                          ),
                        );

                      } else {
                        showCustomSnackBar(
                            context, "Fix errors first", false);
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
                          "Sign Up",
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
                SizedBox(
                  height: 45,
                ),

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

                    onPressed: () {},

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

                /// Already Account
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoginScreen())),
                    child: const Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Login",
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