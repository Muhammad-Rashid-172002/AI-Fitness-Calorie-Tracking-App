import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

class FaceResultScreen extends StatelessWidget {
  final File image;
  final String result;

  const FaceResultScreen({
    super.key,
    required this.image,
    required this.result,
  });

  static const bg = Color(0xFF050816);
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const textMain = Color(0xFFF8FAFC);
  static const textSub = Color(0xFF94A3B8);

  String _getValue(String key) {
    final regex = RegExp('$key:\\s*(.*)', caseSensitive: false);
    final match = regex.firstMatch(result);
    return match?.group(1)?.trim() ?? "Not available";
  }

  @override
  Widget build(BuildContext context) {
    final score = _getValue("Skin Health Score");
    final overview = _getValue("Skin Overview");
    final hydration = _getValue("Hydration Level");
    final oiliness = _getValue("Oiliness Level");
    final concerns = _getValue("Possible Concerns");
    final insight = _getValue("AI Insight");
    final careTips = _getValue("Care Tips");
    final lifestyle = _getValue("Lifestyle Advice");
    final doctorNote = _getValue("Doctor Note");
    final doctorAdvice = _getValue("Doctor Recommendation");
    final products = _getValue("Recommended Products");

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _glow(top: -90, right: -80, color: purple.withOpacity(.22)),
          _glow(bottom: -100, left: -90, color: pink.withOpacity(.16)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 18),

                  _imageCard(),
                  const SizedBox(height: 20),

                  _scoreCard(score),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _miniCard(
                          icon: Icons.water_drop_rounded,
                          title: "Hydration",
                          value: hydration,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniCard(
                          icon: Icons.opacity_rounded,
                          title: "Oiliness",
                          value: oiliness,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _infoCard(
                    icon: Icons.face_retouching_natural_rounded,
                    title: "Skin Overview",
                    value: overview,
                  ),

                  _infoCard(
                    icon: Icons.warning_amber_rounded,
                    title: "Possible Concerns",
                    value: concerns,
                  ),

                  _infoCard(
                    icon: Icons.auto_awesome_rounded,
                    title: "AI Insight",
                    value: insight,
                  ),

                  _infoCard(
                    icon: Icons.spa_rounded,
                    title: "Care Tips",
                    value: careTips,
                  ),

                  _infoCard(
                    icon: Icons.favorite_rounded,
                    title: "Lifestyle Advice",
                    value: lifestyle,
                  ),

                  _infoCard(
                    icon: Icons.medical_services_rounded,
                    title: "Doctor Recommendation",
                    value: doctorAdvice,
                  ),

                  _infoCard(
                    icon: Icons.shopping_bag_rounded,
                    title: "Recommended Products",
                    value: products,
                  ),

                  _doctorNote(doctorNote),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _iconBox(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Face Scan Result",
            style: TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _iconBox(Icons.ios_share_rounded),
      ],
    );
  }

  Widget _imageCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.09),
            Colors.white.withOpacity(.025),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.file(
          image,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _scoreCard(String score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [purple, pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: pink.withOpacity(.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.18),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Skin Health Score",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: pink, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: textSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: pink, size: 25),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.68),
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorNote(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.redAccent.withOpacity(.09),
        border: Border.all(color: Colors.redAccent.withOpacity(.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.medical_information_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                color: Colors.white.withOpacity(.78),
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          height: 260,
          width: 260,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
