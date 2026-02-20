import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/scan_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMacro = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Name
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: TextStyle(color: textGrey, fontSize: 18),
        ),
        const SizedBox(height: 4),

        // Dynamic user name
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                "Loading...",
                style: TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(
                "user",
                style: TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userName = userData["name"] ?? "user";

            return Text(
              userName,
              style: TextStyle(
                color: textMain,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    ),
    // IconButton(
    //   onPressed: () {},
    //   icon: Icon(Icons.notifications, color: textGrey),
    // ),
  ],
),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calories Card
                      _caloriesCard(),
                      const SizedBox(height: 20),

                      // Scan Button
                      _scanButton(),
                      const SizedBox(height: 20),

                      // Macros Card
                      _macrosCard(),
                      const SizedBox(height: 20),

                      // Daily Tip
                      _dailyTipCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _caloriesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Left Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's \nCalories",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "2426",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "remaining",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.white70, size: 22),
                    const SizedBox(width: 5),
                    Text(
                      "0 meals \nlogged",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 0.0,
                  strokeWidth: 12,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "0",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "of 2426 kcal",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _scanButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
        },
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          "Scan a Meal",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _macrosCard() {
    final macros = [
      {"title": "Protein", "value": 45, "max": 120},
      {"title": "Carbs", "value": 80, "max": 200},
      {"title": "Fat", "value": 30, "max": 70},
    ];

    return Column(
      children: macros.asMap().entries.map((entry) {
        int idx = entry.key;
        var macro = entry.value;
        bool selected = selectedMacro == idx;

        double progress = (macro["value"] as int) / (macro["max"] as int);

        return GestureDetector(
          onTap: () => setState(() => selectedMacro = idx),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? primary.withOpacity(0.1) : cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      macro["title"] as String,
                      style: TextStyle(color: textGrey, fontSize: 16),
                    ),
                    Text(
                      "${macro['value']}g / ${macro['max']}g",
                      style: TextStyle(
                        color: textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation(
                      _getMacroColor(macro["title"] as String),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getMacroColor(String title) {
    switch (title) {
      case "Protein":
        return primary;
      case "Carbs":
        return Colors.orange;
      case "Fat":
        return Colors.redAccent;
      default:
        return accent;
    }
  }

  Widget _dailyTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DAILY TIP",
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Add more greens to your meals",
                  style: TextStyle(color: textMain, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return "Good Morning ☀️";
  if (hour < 17) return "Good Afternoon 🌤️";
  return "Good Evening 🌙";
}
