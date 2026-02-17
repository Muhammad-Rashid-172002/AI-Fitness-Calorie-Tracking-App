import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// Crown Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7F5AF0), Color(0xFF2CB67D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 25),

              /// Title
              const Text(
                "Upgrade to Premium",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Unlock the full power of AI coaching.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              /// Feature Cards
              FeatureCard(
                icon: Icons.flash_on,
                title: "Unlimited AI Scans",
                subtitle: "Instantly log meals with your camera",
                cardColor: cardColor,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              FeatureCard(
                icon: Icons.star_border,
                title: "Personalized Meal Plans",
                subtitle: "Custom recipes based on your goals",
                cardColor: cardColor,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              FeatureCard(
                icon: Icons.shield_outlined,
                title: "Advanced Macro Insights",
                subtitle: "Deep dive into micronutrients",
                cardColor: cardColor,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),

              const SizedBox(height: 30),

              /// Pricing Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: activeColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// BEST VALUE Tag
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "BEST VALUE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "YEARLY PLAN",
                      style: TextStyle(
                        color: inactiveColor,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$49.99",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "/ year",
                          style: TextStyle(color: inactiveColor),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Save 50% vs monthly",
                      style: TextStyle(
                        color: activeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Divider(height: 30, color: Colors.white24),

                    PricingFeature(text: "All Premium Features", activeColor: activeColor, inactiveColor: inactiveColor),
                    PricingFeature(text: "Priority Support", activeColor: activeColor, inactiveColor: inactiveColor),
                    PricingFeature(text: "Offline Mode", activeColor: activeColor, inactiveColor: inactiveColor),

                    const SizedBox(height: 25),

                    /// CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Start 7-Day Free Trial",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Restore Purchases",
                style: TextStyle(
                  color: inactiveColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature Card Widget
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color activeColor;
  final Color inactiveColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: activeColor.withOpacity(0.2),
            child: Icon(icon, color: activeColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: inactiveColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Pricing Feature Row
class PricingFeature extends StatelessWidget {
  final String text;
  final Color activeColor;
  final Color inactiveColor;

  const PricingFeature({
    super.key,
    required this.text,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check, color: activeColor, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: inactiveColor),
          )
        ],
      ),
    );
  }
}