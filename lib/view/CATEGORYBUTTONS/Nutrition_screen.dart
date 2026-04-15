
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Lifestyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int calories = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fetchNutritionData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔥 FIREBASE FETCH
  Future<void> _fetchNutritionData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          calories = doc['dailyCalories'] ?? 0;
          protein = doc['proteinTarget'] ?? 0;
          carbs = doc['carbsTarget'] ?? 0;
          fat = doc['fatTarget'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching nutrition: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Nutrition Guide",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 TOP CARD
            _fade(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.white, size: 34),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Good nutrition helps you stay strong, active and healthy every day.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📊 REAL FIREBASE DATA
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          title: "Calories",
                          value: "$calories",
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          title: "Protein",
                          value: "${protein}g",
                          icon: Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          title: "Carbs",
                          value: "${carbs}g",
                          icon: Icons.grain,
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daily Nutrition Tips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🧾 LIST
            Expanded(
              child: ListView(
                children: [
                  _fade(
                    child: const TipCard(
                      title: "Eat Fresh Fruits",
                      subtitle: "Apples, bananas, oranges boost immunity",
                      icon: Icons.apple,
                    ),
                  ),
                  _fade(
                    child: const TipCard(
                      title: "High Protein Food",
                      subtitle: "Eggs, chicken, fish, lentils for muscle",
                      icon: Icons.set_meal,
                    ),
                  ),
                  _fade(
                    child: const TipCard(
                      title: "Stay Hydrated",
                      subtitle: "Drink water regularly for energy",
                      icon: Icons.water_drop,
                    ),
                  ),
                  _fade(
                    child: const TipCard(
                      title: "Avoid Junk Food",
                      subtitle: "Reduce fast food for better health",
                      icon: Icons.no_food,
                    ),
                  ),
                  _fade(
                    child: const TipCard(
                      title: "Balanced Diet",
                      subtitle: "Include carbs, protein, and fats",
                      icon: Icons.health_and_safety,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fade({required Widget child}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _controller.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _controller.value)),
            child: child,
          ),
        );
      },
    );
  }
  
}class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF22C55E)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}