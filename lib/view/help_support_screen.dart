import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Support email
  final String supportEmail =
      'mailto:bahagiajemali@gmail.com?subject=MyDiet%20App%20Support';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// FAQ Header
          Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMain,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 5, offset: Offset(0, 2))],
            ),
          ),
          const SizedBox(height: 12),

          /// FAQ Cards
          _buildFAQCard(
            title: "How do I track my meals?",
            content:
                "Simply tap the 'Camera' button on the home screen to add your meal. You can take a photo of your meal or food using the camera, or select an image from your gallery, then enter nutrition details.",
          ),
          _buildFAQCard(
            title: "How can I update my profile?",
            content: "Go to Profile > Tap Edit > Update your information.",
          ),
          _buildFAQCard(
            title: "What are premium features?",
            content:
                "Premium users can upload unlimited meal photos, access advanced nutrition insights, and get personalized meal suggestions.",
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white38),
          const SizedBox(height: 20),

          /// Tips & Tutorials
          Text(
            "Tips & Tutorials",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMain,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 5, offset: Offset(0, 2))],
            ),
          ),
          const SizedBox(height: 12),
          _buildTipCard("Upload clear images of meals for accurate nutrition analysis.", Icons.camera_alt, Colors.orange),
          _buildTipCard("Use the daily log to track calories, fats, carbs, and protein intake.", Icons.bar_chart, Colors.greenAccent),

          const SizedBox(height: 20),
          const Divider(color: Colors.white38),
          const SizedBox(height: 20),

          /// Contact Support Card
          _buildContactCard(
            context,
            title: "Contact Support",
            subtitle: "Email us for help, feedback, or to report bugs.",
            icon: Icons.email,
            iconColor: Colors.blue,
            mailto: supportEmail,
          ),

          const SizedBox(height: 16),

          /// Report Bug Card
          _buildContactCard(
            context,
            title: "Report a Bug",
            subtitle: "Let us know if something is not working properly.",
            icon: Icons.bug_report,
            iconColor: Colors.redAccent,
            mailto: 'mailto:bahagiajemali@gmail.com?subject=MyDiet%20App%20Bug%20Report',
          ),
        ],
      ),
    );
  }

  /// FAQ Card
  Widget _buildFAQCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary.withOpacity(0.15), accent.withOpacity(0.15)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primary,
          collapsedIconColor: textGrey,
          title: Text(
            title,
            style: TextStyle(color: textMain, fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                content,
                style: TextStyle(color: textGrey, fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tip / Tutorial Card
  Widget _buildTipCard(String content, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary.withOpacity(0.1), accent.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(color: textGrey, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Contact / Bug Card
  Widget _buildContactCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color iconColor,
      required String mailto}) {
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
          gradient: LinearGradient(colors: [primary.withOpacity(0.15), accent.withOpacity(0.15)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textGrey, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}




//  double avgCalories = daysLogged == 0 ? 0 : totalCalories / daysLogged;
//     double avgProtein = daysLogged == 0 ? 0 : totalProtein / daysLogged;
//     double avgCarbs = daysLogged == 0 ? 0 : totalCarbs / daysLogged;
//     double avgFat = daysLogged == 0 ? 0 : totalFat / daysLogged;