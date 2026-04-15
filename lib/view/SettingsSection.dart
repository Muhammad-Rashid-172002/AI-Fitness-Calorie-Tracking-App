import 'package:fitmind_ai/view/auth_view/login_Screen.dart';
import 'package:fitmind_ai/view/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  bool notificationsEnabled = true;

  bool useMetric = true; // kg/cm or lb/ft

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2623),
        title: const Text(
          "About MYDiet",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "MYDiet is a smart fitness & nutrition tracker app.\n\nVersion: 1.1.0",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2623),
        title: const Text(
          "Select Units",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              value: true,
              groupValue: useMetric,
              title: const Text(
                "kg / cm",
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (val) {
                setState(() => useMetric = true);
                Navigator.pop(context);
              },
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: useMetric,
              title: const Text(
                "lb / ft",
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (val) {
                setState(() => useMetric = false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4ADE80)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(color: Colors.white10, height: 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2623),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _tile(
                icon: Icons.notifications_none,
                title: "Notifications",
                trailing: Switch(
                  value: notificationsEnabled,
                  activeColor: const Color(0xFF4ADE80),
                  onChanged: (val) {
                    setState(() => notificationsEnabled = val);
                  },
                ),
              ),
              _divider(),

              _tile(
                icon: Icons.straighten,
                title: "Units (Weight / Height)",
                onTap: _showUnitsDialog,
              ),
              _divider(),

              _tile(
                icon: Icons.privacy_tip_outlined,
                title: "Data & Privacy",
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://mydiet-privacy-policy.vercel.app',
                  );

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              _divider(),

              _tile(
                icon: Icons.help_outline,
                title: "Help & Support",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _divider(),

              _tile(
                icon: Icons.info_outline,
                title: "About MYDiet",
                onTap: _showAboutDialog,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2623),
                  title: const Text(
                    "Confirm Log Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              "Log Out",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
