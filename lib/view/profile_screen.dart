import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/auth_view/login_Screen.dart';
import 'package:fitmind_ai/view/edit_profile_screen.dart';
import 'package:fitmind_ai/view/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool mealReminder = true;

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileController>(context, listen: false).fetchUserData();
  }

  final String privacyPolicyUrl =
      'https://docs.google.com/document/d/1gtsZyGX6-02QdC5Lgc5-UXhDLxDUyCtNJcehLmsiUpc/view?usp=sharing';

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// User Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: activeColor,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.name.isNotEmpty
                                    ? controller.name
                                    : "User",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.weightGoal,
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        // Edit icon navigates to StepOneScreen
                        IconButton(
                          icon: Icon(Icons.edit, color: activeColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ).then((_) {
                              // Refresh profile data after returning from StepOneScreen
                              controller.fetchUserData();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatItem(value: controller.weight, label: "kg"),
                        StatItem(value: controller.height, label: "cm"),
                        StatItem(value: controller.age, label: "years"),
                        StatItem(value: controller.kcal, label: "kcal/day"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Preferences
                  Text("PREFERENCES", style: TextStyle(color: inactiveColor)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SwitchListTile(
                      value: mealReminder,
                      activeColor: activeColor,
                      onChanged: (val) {
                        setState(() {
                          mealReminder = val;
                        });
                      },
                      title: const Text(
                        "Meal Reminders",
                        style: TextStyle(color: Colors.white),
                      ),
                      secondary: Icon(Icons.notifications, color: activeColor),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// About Section
                  Text("ABOUT", style: TextStyle(color: inactiveColor)),
                  const SizedBox(height: 15),
                  AboutTile(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    iconColor: activeColor,
                    textColor: Colors.white,
                    onTap: () {
                      // Navigate to Help & Support Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  // Privacy Policy Tile
                  AboutTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    iconColor: Colors.green, // activeColor
                    textColor: Colors.white,
                    onTap: () async {
                      // Open Google Docs link
                      if (await canLaunchUrlString(privacyPolicyUrl)) {
                        await launchUrlString(
                          privacyPolicyUrl,
                          mode:
                              LaunchMode.externalApplication, // Open in browser
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Could not open Privacy Policy link.",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  AboutTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    iconColor: activeColor,
                    textColor: Colors.white,
                    onTap: () async {
                      const String termsUrl =
                          'https://docs.google.com/document/d/1zSgDgi65WUposhjL6I32IN4wo_hsxkpXIOCwTfYn6ko/view?usp=sharing';

                      // Open Terms of Service link in external browser
                      if (await canLaunchUrlString(termsUrl)) {
                        await launchUrlString(
                          termsUrl,
                          mode: LaunchMode
                              .externalApplication, // Opens in browser
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Could not open Terms of Service link.",
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  /// Reset All Data
                  AboutTile(
                    icon: Icons.delete_forever,
                    title: "Reset All Data",
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: cardColor,
                          title: const Text(
                            "Reset All Data?",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            "This will permanently delete all your data.",
                            style: TextStyle(color: inactiveColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Add reset logic
                              },
                              child: const Text(
                                "Reset",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  /// Logout
                  AboutTile(
                    icon: Icons.logout,
                    title: "Logout",
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.black87,
                            title: const Text(
                              "Confirm Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "Are you sure you want to logout?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(
                                    context,
                                  ); // Close confirmation dialog

                                  // Show loader
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  try {
                                    await Provider.of<ProfileController>(
                                      context,
                                      listen: false,
                                    ).logout();

                                    Navigator.pop(context); // Remove loader

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    Navigator.pop(context); // Remove loader
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Logout failed: $e"),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stat Item
class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}

/// About Tile
class AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;

  const AboutTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = Colors.blue,
    this.textColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // cardColor
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }
}
