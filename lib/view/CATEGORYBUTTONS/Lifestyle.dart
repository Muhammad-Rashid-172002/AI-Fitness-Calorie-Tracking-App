import 'package:flutter/material.dart';

class Lifestylescreen extends StatefulWidget {
  const Lifestylescreen({super.key});

  @override
  State<Lifestylescreen> createState() => _LifestylescreenState();
}

class _LifestylescreenState extends State<Lifestylescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Lifestyle",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🌿 TOP CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.self_improvement,
                      color: Colors.white, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Healthy habits build a strong and balanced lifestyle.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📊 MINI STATS
            Row(
              children: const [
                Expanded(
                  child: _MiniCard(
                    title: "Sleep",
                    value: "7-8h",
                    icon: Icons.bed,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MiniCard(
                    title: "Water",
                    value: "2L",
                    icon: Icons.water_drop,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MiniCard(
                    title: "Steps",
                    value: "8k",
                    icon: Icons.directions_walk,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🎯 GOAL CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.flag, color: Colors.purpleAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Goal: Maintain a healthy routine with proper sleep, hydration and activity.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📋 TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lifestyle Tips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🧾 TIPS
            Expanded(
              child: ListView(
                children: const [
                  TipCard(
                    title: "Sleep Well",
                    subtitle: "Get 7-8 hours of sleep daily",
                    icon: Icons.bed,
                  ),
                  TipCard(
                    title: "Stay Hydrated",
                    subtitle: "Drink enough water throughout the day",
                    icon: Icons.water_drop,
                  ),
                  TipCard(
                    title: "Reduce Stress",
                    subtitle: "Practice meditation & relaxation",
                    icon: Icons.spa,
                  ),
                  TipCard(
                    title: "Stay Active",
                    subtitle: "Move your body every day",
                    icon: Icons.directions_run,
                  ),
                  TipCard(
                    title: "Limit Screen Time",
                    subtitle: "Reduce mobile usage for mental health",
                    icon: Icons.phone_android,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 MINI CARD
class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purpleAccent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🧾 TIP CARD
class TipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TipCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purpleAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white60)),
              ],
            ),
          )
        ],
      ),
    );
  }
}