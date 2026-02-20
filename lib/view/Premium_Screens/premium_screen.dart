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

  String selectedPlan = "yearly"; // default selected plan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
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
                    colors: [
                      Colors.green,
                      Colors.transparent,
                    ],
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

                  const SizedBox(height: 10),

                  // /// Close Button
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.close, color: Colors.white),
                  //     onPressed: () => Navigator.pop(context),
                  //   ),
                  // ),

                  const SizedBox(height: 10),

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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
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
                        // FeatureTile(
                        //   icon: Icons.check_circle_outline,
                        //   text: "Personalized Diet Tracking",
                        // ),
                        // FeatureTile(
                        //   icon: Icons.shield_outlined,
                        //   text: "Ad-Free Experience",
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Yearly Plan
                  planCard(
                    id: "yearly",
                    title: "Yearly Plan",
                    subtitle: "\$4.99 / month",
                    price: "\$59.99",
                    badge: "BEST VALUE",
                    isSelected: selectedPlan == "yearly",
                    onTap: () {
                      setState(() {
                        selectedPlan = "yearly";
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  /// Monthly Plan
                  planCard(
                    id: "monthly",
                    title: "Monthly Plan",
                    subtitle: "Cancel anytime",
                    price: "\$9.99 / month",
                    isSelected: selectedPlan == "monthly",
                    onTap: () {
                      setState(() {
                        selectedPlan = "monthly";
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "7-Day Free Trial Available",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 15),

                  /// Start Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomGradientButton(
                      text: 'Start Free Trial',
                  
                      onPressed: () {
                        print("Selected Plan: $selectedPlan");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrialScreen(),
                          ),
                        );
                      },
                    
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Restore Purchase",
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
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
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white70)),
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
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatefulWidget {
  final IconData icon;
  final String text;

  const FeatureTile({super.key, required this.icon, required this.text});

  @override
  State<FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(widget.icon, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              widget.text,
              style:
                  const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
