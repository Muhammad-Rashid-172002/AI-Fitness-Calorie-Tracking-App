import 'package:flutter/material.dart';

class Fatlossscreen extends StatefulWidget {
  const Fatlossscreen({super.key});

  @override
  State<Fatlossscreen> createState() => _FatlossscreenState();
}

class _FatlossscreenState extends State<Fatlossscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Fat Loss",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 TOP CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.white, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Stay in a calorie deficit to burn fat effectively.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📊 STATS ROW
            Row(
              children: const [
                Expanded(
                  child: _MiniCard(
                    title: "Calories",
                    value: "-500",
                    icon: Icons.trending_down,
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
                SizedBox(width: 10),
                Expanded(
                  child: _MiniCard(
                    title: "Workout",
                    value: "45m",
                    icon: Icons.fitness_center,
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
                  Icon(Icons.flag, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Goal: Lose 2kg in 4 weeks with consistent diet & exercise.",
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
                "Fat Loss Tips",
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
                    title: "Calorie Deficit",
                    subtitle: "Consume fewer calories than you burn daily",
                    icon: Icons.trending_down,
                  ),
                  TipCard(
                    title: "Increase Activity",
                    subtitle: "Walk more & stay active throughout the day",
                    icon: Icons.directions_walk,
                  ),
                  TipCard(
                    title: "Avoid Sugar",
                    subtitle: "Cut sugary drinks & processed foods",
                    icon: Icons.no_food,
                  ),
                  TipCard(
                    title: "Strength Training",
                    subtitle: "Build muscle to boost metabolism",
                    icon: Icons.fitness_center,
                  ),
                  TipCard(
                    title: "Drink Water",
                    subtitle: "Stay hydrated to control hunger",
                    icon: Icons.water_drop,
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
/// 🔥 MINI CARD (TOP STATS)
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
          Icon(icon, color: Colors.orange),
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
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.orange),
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