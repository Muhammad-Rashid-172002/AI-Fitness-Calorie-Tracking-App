import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool mealReminder = true;

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Title
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rashid",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Maintain Weight",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: activeColor)
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
                  children: const [
                    StatItem(value: "59", label: "kg"),
                    StatItem(value: "172", label: "cm"),
                    StatItem(value: "21", label: "years"),
                    StatItem(value: "2426", label: "kcal/day"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Preferences
              Text(
                "PREFERENCES",
                style: TextStyle(color: inactiveColor),
              ),

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
              Text(
                "ABOUT",
                style: TextStyle(color: inactiveColor),
              ),

              const SizedBox(height: 15),

              AboutTile(
                icon: Icons.help_outline,
                title: "Help & Support",
                iconColor: activeColor,
                textColor: Colors.white,
              ),
              AboutTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                iconColor: activeColor,
                textColor: Colors.white,
              ),
              AboutTile(
                icon: Icons.description_outlined,
                title: "Terms of Service",
                iconColor: activeColor,
                textColor: Colors.white,
              ),

              /// 🔥 Reset All Data
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
            ],
          ),
        ),
      ),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white54),
        ),
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
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }
}