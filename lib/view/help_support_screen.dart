import 'dart:ui';

import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  final String supportEmail =
      'mailto:muhammadrashid172002@gmail.com?subject=FitMind%20AI%20App%20Support';

  final String bugEmail =
      'mailto:muhammadrashid172002@gmail.com?subject=FitMind%20AI%20Bug%20Report';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glowCircle(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              size: 260,
            ),
          ),

          Positioned(
            bottom: -140,
            left: -90,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.10),
              size: 280,
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                const SizedBox(height: 18),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF22C55E).withOpacity(0.24),
                        ),
                      ),
                      child: const Text(
                        "Support",
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _heroCard(context),

                const SizedBox(height: 28),

                _sectionTitle(
                  "Frequently Asked Questions",
                  "Common questions about FitMind AI",
                ),

                const SizedBox(height: 14),

                _buildFAQCard(
                  title: "How do I track my meals?",
                  content:
                      "Open the Scan screen, take a clear food photo or upload from gallery, then FitMind AI will estimate calories and nutrition details.",
                ),
                _buildFAQCard(
                  title: "How does AI food scanning work?",
                  content:
                      "FitMind AI analyzes your food image and provides estimated calories, protein, carbs, and fat. For best results, use clear and well-lit images.",
                ),
                _buildFAQCard(
                  title: "How can I update my profile?",
                  content:
                      "Go to Profile, open settings or edit profile option, then update your body information and goals.",
                ),

                const SizedBox(height: 24),

                _sectionTitle(
                  "Tips & Tutorials",
                  "Improve your tracking accuracy",
                ),

                const SizedBox(height: 14),
                _sectionTitle(
                  "AI Features",
                  "Smart tools powered by FitMind AI",
                ),

                const SizedBox(height: 14),

                _buildTipCard(
                  "AI Food Scanner analyzes calories, protein, carbs, and fats instantly.",
                  Icons.restaurant_menu_rounded,
                  const Color(0xFF22C55E),
                ),
                const SizedBox(height: 14),
                _buildTipCard(
                  "AI Skin Analysis helps detect hydration, oiliness, and skin concerns.",
                  Icons.face_retouching_natural_rounded,
                  const Color(0xFFEC4899),
                ),
                const SizedBox(height: 14),
                _buildTipCard(
                  "Medicine Scanner provides usage, purpose, and safety information.",
                  Icons.medication_rounded,
                  const Color(0xFF06B6D4),
                ),
                SizedBox(height: 14),

                _buildTipCard(
                  "Upload clear meal images with good lighting for better nutrition analysis.",
                  Icons.camera_alt_rounded,
                  const Color(0xFFF59E0B),
                ),
                _buildTipCard(
                  "Use daily logs to track calories, protein, carbs, and fat consistently.",
                  Icons.bar_chart_rounded,
                  const Color(0xFF22C55E),
                ),
                _buildTipCard(
                  "Ask AI Coach for meal ideas, protein targets, and healthy food suggestions.",
                  Icons.psychology_alt_rounded,
                  const Color(0xFF06B6D4),
                ),
                SizedBox(height: 14),
                _sectionTitle(
                  "Privacy & Security",
                  "Your health data stays protected",
                ),

                const SizedBox(height: 14),

                _buildTipCard(
                  "FitMind AI securely stores your health scans and personal information.",
                  Icons.security_rounded,
                  const Color(0xFF22C55E),
                ),
                SizedBox(height: 14),
                _buildTipCard(
                  "We never share your personal health data with third parties.",
                  Icons.lock_rounded,
                  const Color(0xFF3B82F6),
                ),

                const SizedBox(height: 24),

                _sectionTitle(
                  "Contact Us",
                  "Need more help? Reach out anytime",
                ),

                const SizedBox(height: 14),

                _buildContactCard(
                  context,
                  title: "Contact Support",
                  subtitle: "Email us for help, feedback, or account support.",
                  icon: Icons.email_rounded,
                  color: const Color(0xFF3B82F6),
                  mailto: supportEmail,
                ),

                _buildContactCard(
                  context,
                  title: "Report a Bug",
                  subtitle: "Tell us if something is not working properly.",
                  icon: Icons.bug_report_rounded,
                  color: const Color(0xFFEF4444),
                  mailto: bugEmail,
                ),

                _buildContactCard(
                  context,
                  title: "Rate FitMind AI",
                  subtitle: "Enjoying the app? Leave a review on Play Store.",
                  icon: Icons.star_rate_rounded,
                  color: const Color(0xFFF59E0B),
                  mailto:
                      "https://play.google.com/store/apps/details?id=com.rashidapps.fitmindai",
                ),
                const SizedBox(height: 26),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(.18)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "FitMind AI provides general wellness guidance only and is not a substitute for professional medical advice.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.32),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.20),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "How can we help you?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Find answers, learn app tips, or contact support for your FitMind AI app.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.045),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Theme(
              data: ThemeData().copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: const Color(0xFF22C55E),
                collapsedIconColor: Colors.white54,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.64),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String mailto,
  }) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrlString(mailto)) {
          await launchUrlString(mailto);
        } else {
          showCustomSnackBar(context, "Could not open email app.", false);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.52),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.35),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
