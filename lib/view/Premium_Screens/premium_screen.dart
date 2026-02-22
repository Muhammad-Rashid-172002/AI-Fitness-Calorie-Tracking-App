import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/view/Premium_Screens/trial_screen.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final Color bgColor = const Color(0xFF0F172A);
  String selectedPlan = ""; // default selected plan
  bool? isPremium; // null = loading, true/false = fetched

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  /// Fetch premium status from Firebase
  Future<void> _checkPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    if (!mounted) return;

    setState(() {
      isPremium = doc.exists && (doc.data()?['premium'] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isPremium == null
            ? const Center(child: CircularProgressIndicator())
            : isPremium!
                ? _premiumCongratsUI()
                : _goPremiumUI(),
      ),
    );
  }

  /// UI for premium users
  Widget _premiumCongratsUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.greenAccent, Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(40),
            child: const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
          ),
          const SizedBox(height: 20),
          const Text(
            "Congratulations!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "You are already a Premium user",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          CustomGradientButton(
            text: "Explore Premium Features",
            onPressed: () {
              // Navigate to premium feature screen or do any action
            },
          ),
        ],
      ),
    );
  }

  /// UI for non-premium users
  Widget _goPremiumUI() {
    return Stack(
      children: [
        /// Background Glow
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            height: 350,
            width: 350,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.green, Colors.transparent],
              ),
            ),
          ),
        ),

        /// Scrollable Content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              /// Title
              const Text(
                "Go Premium",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Eat Smarter with AI",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              /// Features Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  children: [
                    FeatureTile(
                      icon: Icons.camera_alt_outlined,
                      text: "Unlimited AI Scans",
                    ),
                    FeatureTile(
                      icon: Icons.auto_awesome,
                      text: "Smart Nutrition Insights",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              /// Monthly Plan
              planCard(
                id: "monthly",
                title: "Monthly Plan",
                subtitle: "RM 29.90 / month",
                price: "RM 29.90",
                isSelected: selectedPlan == "monthly",
                onTap: () {
                  setState(() {
                    selectedPlan = "monthly";
                  });
                },
              ),
              const SizedBox(height: 15),

              /// Re-Activation Plan (50% Off)
              planCard(
                id: "renew",
                title: "Re-Activation Offer",
                subtitle: "3 Months at 50% Discount",
                price: "RM 44.85",
                badge: "SPECIAL OFFER",
                isSelected: selectedPlan == "renew",
                onTap: () {
                  setState(() {
                    selectedPlan = "renew";
                  });
                },
              ),
              const SizedBox(height: 30),

              const Text(
                "14-Day Free Trial Available",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 15),

              /// Start Button
              SizedBox(
                width: double.infinity,
                child: Opacity(
                  opacity: selectedPlan.isEmpty ? 0.5 : 1,
                  child: IgnorePointer(
                    ignoring: selectedPlan.isEmpty,
                    child: CustomGradientButton(
                      text: 'Start Free Trial',
                      onPressed: () {
                        if (selectedPlan.isEmpty) return;

                        bool isReActivation = selectedPlan == "renew";

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrialScreen(
                              plan: selectedPlan,
                              isReActivation: isReActivation,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  /// Plan Card Widget
  static Widget planCard({
    required String id,
    required String title,
    required String subtitle,
    required String price,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white24,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
                if (badge != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}