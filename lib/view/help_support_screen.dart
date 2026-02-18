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
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: bgColor,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // FAQ 1
          ExpansionTile(
            title: const Text(
              "How do I track my meals?",
              style: TextStyle(color: Colors.white),
            ),
            children: const [
              ListTile(
                title: Text(
                  "Simply tap the 'Camera' button on the home screen to add your meal. You can take a photo of your meal or food using the camera, or select an image from your gallery, then enter nutrition details.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),

          // FAQ 2
          ExpansionTile(
            title: const Text(
              "How can I update my profile?",
              style: TextStyle(color: Colors.white),
            ),
            children: const [
              ListTile(
                title: Text(
                  "Go to Profile > Tap Edit > Update your information.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),

          // FAQ 3
          ExpansionTile(
            title: const Text(
              "What are premium features?",
              style: TextStyle(color: Colors.white),
            ),
            children: const [
              ListTile(
                title: Text(
                  "Premium users can upload unlimited meal photos, access advanced nutrition insights, and get personalized meal suggestions.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white38),
          const SizedBox(height: 16),

          // Tips / Tutorials
          const Text(
            "Tips & Tutorials",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.orange),
            title: Text(
              "Upload clear images of meals for accurate nutrition analysis.",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.orange),
            title: Text(
              "Use the daily log to track calories, fats, carbs, and protein intake.",
              style: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white38),
          const SizedBox(height: 16),

          // Contact Support
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text(
              "Contact Support",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Email us for help, feedback, or to report bugs.",
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              if (await canLaunchUrlString(supportEmail)) {
                await launchUrlString(supportEmail);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open email app.")),
                );
              }
            },
          ),

          const SizedBox(height: 16),

          // Report a Bug
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.redAccent),
            title: const Text(
              "Report a Bug",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Let us know if something is not working properly.",
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              final String bugEmail =
                  'mailto:bahagiajemali@gmail.com?subject=MyDiet%20App%20Bug%20Report';
              if (await canLaunchUrlString(bugEmail)) {
                await launchUrlString(bugEmail);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open email app.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
