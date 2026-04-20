import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/services/StripePaymentProvider.dart';
//import 'package:fitmind_ai/view/Premium_Screens/premium_screen.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrialScreen extends StatelessWidget {
  final bool isReActivation;
  final String plan;
  const TrialScreen({
    super.key,
    required this.plan,
    required this.isReActivation,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> startTrial() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 14));

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "isPremium": false,
        "trialStart": now.toIso8601String(),
        "trialEnd": trialEnd.toIso8601String(),
      }, SetOptions(merge: true));
    }

    return Scaffold(
      body: Consumer<StripePaymentProvider>(
        builder: (context, stripeProvider, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF0B1120),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: Stack(
              children: [
                /// Green Glow Top
                Positioned(
                  top: -100,
                  left: -80,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.green, Colors.transparent],
                      ),
                    ),
                  ),
                ),

                /// Green Glow Bottom
                Positioned(
                  bottom: -120,
                  right: -80,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.green, Colors.transparent],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        /// Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Title
                        const Text(
                          "Start Your 7-Day Trial",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Try unlimited scans for free. Cancel anytime.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),

                        const SizedBox(height: 40),

                        /// Timeline Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Column(
                            children: [
                              TimelineTile(
                                number: "1",
                                title: "Today: Free Trial Starts",
                                subtitle:
                                    "Instant access to all premium features. No charge today.",
                              ),

                              TimelineDivider(),

                              TimelineTile(
                                number: "2",
                                title: "Day 7: Trial Ends",
                                subtitle:
                                    "We'll remind you 2 days before. Cancel anytime in settings.",
                              ),

                              TimelineDivider(),

                              TimelineTile(
                                number: "3",
                                title: "Day 14: Subscription Starts",
                                subtitle:
                                    "Automatically renews at \$59.99/year.",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// Secure Payment Text
                        // Center(
                        //   child: Text(
                        //     "Secure payment via App Store",
                        //     style: TextStyle(
                        //       color: Colors.white.withOpacity(0.6),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 20),

                        /// Continue Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomGradientButton(
                            text: 'Continue to payment',
                            onPressed: () async {
                              try {
                                // 1️⃣ START 14-DAY TRIAL (SAVE IN FIRESTORE)
                                await startTrial();

                                // 2️⃣ PROCESS PAYMENT
                                final bool paymentSuccess = await context
                                    .read<StripePaymentProvider>()
                                    .makePayment(
                                      isReActivation: isReActivation,
                                    );

                                if (paymentSuccess) {
                                  showCustomSnackBar(
                                    context,
                                    "Payment Successful 🎉",
                                    true,
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainView(),
                                    ),
                                  );
                                } else {
                                  showCustomSnackBar(
                                    context,
                                    "Payment Failed ❌",
                                    false,
                                  );
                                }
                              } catch (e) {
                                showCustomSnackBar(
                                  context,
                                  "Payment Error ❌",
                                  false,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const TimelineTile({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70),
            ),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> startTrial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 14));

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "isPremium": false,
      "trialStart": now.toIso8601String(),
      "trialEnd": trialEnd.toIso8601String(),
    }, SetOptions(merge: true));
  }
}

class TimelineDivider extends StatelessWidget {
  const TimelineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        margin: const EdgeInsets.only(left: 18),
        height: 30,
        width: 1,
        color: Colors.white24,
      ),
    );
  }

  Future<bool> isTrialActive() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data();

    if (data == null) return false;

    final isPremium = data["isPremium"] ?? false;
    if (isPremium) return true;

    final trialEnd = data["trialEnd"];

    if (trialEnd == null) return false;

    DateTime end = DateTime.parse(trialEnd);
    return DateTime.now().isBefore(end);
  }
}
