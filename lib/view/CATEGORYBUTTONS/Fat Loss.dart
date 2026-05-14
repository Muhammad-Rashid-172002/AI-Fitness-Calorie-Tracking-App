import 'dart:ui';
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
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glowCircle(
              color: const Color(0xFFF97316).withOpacity(0.14),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _glowCircle(
              color: const Color(0xFFEF4444).withOpacity(0.10),
              size: 280,
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                const SizedBox(height: 18),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: _iconBox(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFF97316).withOpacity(0.28),
                        ),
                      ),
                      child: const Text(
                        "Fat Loss Guide",
                        style: TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _heroCard(),

                const SizedBox(height: 24),

                Row(
                  children: const [
                    Expanded(
                      child: _MiniCard(
                        title: "Deficit",
                        value: "-500",
                        subtitle: "kcal/day",
                        icon: Icons.trending_down_rounded,
                        color: Color(0xFFF97316),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MiniCard(
                        title: "Steps",
                        value: "8k",
                        subtitle: "daily",
                        icon: Icons.directions_walk_rounded,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MiniCard(
                        title: "Workout",
                        value: "45m",
                        subtitle: "session",
                        icon: Icons.fitness_center_rounded,
                        color: Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _goalCard(),

                const SizedBox(height: 26),

                _sectionTitle(
                  title: "Fat Loss Tips",
                  subtitle: "Simple habits that help you burn fat",
                ),

                const SizedBox(height: 14),

                const TipCard(
                  title: "Calorie Deficit",
                  subtitle: "Eat slightly fewer calories than you burn daily.",
                  icon: Icons.trending_down_rounded,
                  color: Color(0xFFF97316),
                ),
                const TipCard(
                  title: "Increase Activity",
                  subtitle: "Walk more and stay active throughout the day.",
                  icon: Icons.directions_walk_rounded,
                  color: Color(0xFF22C55E),
                ),
                const TipCard(
                  title: "Limit Sugar",
                  subtitle: "Avoid sugary drinks and highly processed foods.",
                  icon: Icons.no_food_rounded,
                  color: Color(0xFFEF4444),
                ),
                const TipCard(
                  title: "Strength Training",
                  subtitle: "Build muscle to improve your metabolism.",
                  icon: Icons.fitness_center_rounded,
                  color: Color(0xFF06B6D4),
                ),
                const TipCard(
                  title: "Drink Water",
                  subtitle: "Stay hydrated to control hunger and cravings.",
                  icon: Icons.water_drop_rounded,
                  color: Color(0xFF38BDF8),
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF97316),
            Color(0xFFEF4444),
            Color(0xFF7F1D1D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.28),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            right: -45,
            child: _glowCircle(
              color: Colors.white.withOpacity(0.14),
              size: 150,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 66,
                width: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Burn Fat Smarter",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Focus on a healthy calorie deficit, daily movement, strength training, and consistency.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF97316).withOpacity(0.14),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "Goal: Lose 2kg in 4 weeks with consistent diet and exercise.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MiniCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.38),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
class TipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const TipCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
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
}