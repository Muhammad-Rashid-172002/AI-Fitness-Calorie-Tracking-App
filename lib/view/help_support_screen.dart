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

  final String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rashidapps.fitmindai';

  static const Color bgColor = Color(0xFF020617);
  static const Color surface = Color(0xFF0B1220);
  static const Color primary = Color(0xFF22C55E);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _glowCircle(primary.withOpacity(.14), 280),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _glowCircle(cyan.withOpacity(.12), 300),
          ),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
              children: [
                _topBar(context),
                const SizedBox(height: 26),

                _heroCard(),
                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _quickCard(
                        icon: Icons.email_rounded,
                        title: "Support",
                        subtitle: "Get help",
                        color: blue,
                        onTap: () => _openLink(context, supportEmail),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickCard(
                        icon: Icons.bug_report_rounded,
                        title: "Bug Report",
                        subtitle: "Tell issue",
                        color: red,
                        onTap: () => _openLink(context, bugEmail),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _sectionTitle(
                  "Frequently Asked Questions",
                  "Quick answers about FitMind AI",
                ),
                const SizedBox(height: 14),

                _faqCard(
                  title: "How do I track my meals?",
                  content:
                      "Open the Scan screen, capture a clear food image or upload one from your gallery. FitMind AI will estimate calories, protein, carbs, fats, and nutrition details.",
                ),
                _faqCard(
                  title: "How can I get better food scan results?",
                  content:
                      "Use bright lighting, keep the meal clearly visible, avoid blurry images, and try to capture the full plate from the top angle.",
                ),

                _faqCard(
                  title: "Is FitMind AI medical advice?",
                  content:
                      "No. FitMind AI provides general health and wellness guidance only. For medical conditions, always consult a qualified doctor.",
                ),

                const SizedBox(height: 28),

                _sectionTitle("AI Features", "Smart tools inside your app"),
                const SizedBox(height: 14),

                _featureCard(
                  "AI Food Scanner",
                  "Analyze calories, protein, carbs, fats, and meal nutrition instantly.",
                  Icons.restaurant_menu_rounded,
                  primary,
                ),
                _featureCard(
                  "AI Skin Analysis",
                  "Get smart skin insights for hydration, oiliness, and visible concerns.",
                  Icons.face_retouching_natural_rounded,
                  pink,
                ),
                _featureCard(
                  "Medicine Scanner",
                  "Scan medicine and get helpful usage, purpose, and safety information.",
                  Icons.medication_rounded,
                  cyan,
                ),
                _featureCard(
                  "Smart AI Coach",
                  "Ask about diet, workouts, protein targets, and healthy lifestyle tips.",
                  Icons.psychology_alt_rounded,
                  blue,
                ),

                const SizedBox(height: 28),

                _sectionTitle(
                  "Tips & Tutorials",
                  "Improve your tracking accuracy",
                ),
                const SizedBox(height: 14),

                _tipCard(
                  "Track meals daily to improve your calorie and macro consistency.",
                  Icons.insights_rounded,
                  primary,
                ),
                _tipCard(
                  "Drink water regularly and update your hydration progress.",
                  Icons.water_drop_rounded,
                  cyan,
                ),
                _tipCard(
                  "Use clear images for food, skin, and medicine scanning.",
                  Icons.camera_alt_rounded,
                  orange,
                ),

                const SizedBox(height: 28),

                _sectionTitle(
                  "Privacy & Security",
                  "Your health data stays protected",
                ),
                const SizedBox(height: 14),

                _privacyCard(
                  icon: Icons.security_rounded,
                  title: "Secure Health Data",
                  subtitle:
                      "Your scans and profile details are handled securely inside the app.",
                  color: primary,
                ),
                _privacyCard(
                  icon: Icons.lock_rounded,
                  title: "Private by Design",
                  subtitle:
                      "Your personal health data is not shared publicly with other users.",
                  color: blue,
                ),

                const SizedBox(height: 28),

                _sectionTitle(
                  "Contact Us",
                  "Need more help? Reach out anytime",
                ),
                const SizedBox(height: 14),

                _contactCard(
                  context,
                  title: "Contact Support",
                  subtitle: "Email us for help, feedback, or account support.",
                  icon: Icons.email_rounded,
                  color: blue,
                  link: supportEmail,
                ),
                _contactCard(
                  context,
                  title: "Report a Bug",
                  subtitle: "Tell us if something is not working properly.",
                  icon: Icons.bug_report_rounded,
                  color: red,
                  link: bugEmail,
                ),
                _contactCard(
                  context,
                  title: "Rate FitMind AI",
                  subtitle: "Enjoying the app? Leave a review on Play Store.",
                  icon: Icons.star_rate_rounded,
                  color: orange,
                  link: playStoreUrl,
                ),

                const SizedBox(height: 22),

                _warningBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _iconButton(Icons.arrow_back_ios_new_rounded),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withOpacity(.13),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: primary.withOpacity(.25)),
          ),
          child: const Text(
            "HELP CENTER",
            style: TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [primary, cyan, blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cyan.withOpacity(.30),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 140,
              color: Colors.white.withOpacity(.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.20),
                  border: Border.all(color: Colors.white.withOpacity(.25)),
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
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                "Find answers, learn smart tracking tips, report issues, or contact FitMind AI support anytime.",
                style: TextStyle(
                  color: Colors.white.withOpacity(.88),
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.055),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _circleIcon(icon, color),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(.55),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [primary, cyan],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(.48),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _faqCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            child: Theme(
              data: ThemeData().copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: primary,
                collapsedIconColor: Colors.white54,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                        fontSize: 13,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
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

  Widget _featureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          _circleIcon(icon, color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.56),
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.075)),
      ),
      child: Row(
        children: [
          _circleIcon(icon, color),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(.68),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(.12), Colors.white.withOpacity(.035)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Row(
        children: [
          _circleIcon(icon, color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.58),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String link,
  }) {
    return GestureDetector(
      onTap: () => _openLink(context, link),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Row(
          children: [
            _circleIcon(icon, color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.55),
                      fontSize: 12.3,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(.35),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _warningBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: orange.withOpacity(.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: orange.withOpacity(.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "FitMind AI provides general wellness guidance only and is not a substitute for professional medical advice.",
              style: TextStyle(
                color: Colors.white.withOpacity(.75),
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(.14),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Future<void> _openLink(BuildContext context, String link) async {
    if (await canLaunchUrlString(link)) {
      await launchUrlString(link, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar(context, "Could not open this link.", false);
    }
  }
}
