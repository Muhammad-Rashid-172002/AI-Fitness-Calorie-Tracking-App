import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/ai_coach_controller.dart';
import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/resources/fire_animation.dart';
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Fat%20Loss.dart';
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Lifestyle.dart';
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Nutrition_screen.dart';
import 'package:fitmind_ai/view/SettingsSection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileController>(context, listen: false).fetchUserData();
  }

  Stream<QuerySnapshot> getDailyLogs() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailyLogs')
        .snapshots();
  }

  Stream<QuerySnapshot> getScanLogs() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scans')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF020617),
          body: Stack(
            children: [
              Positioned(
                top: -120,
                right: -90,
                child: _glowCircle(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  size: 260,
                ),
              ),

              Positioned(
                bottom: -140,
                left: -100,
                child: _glowCircle(
                  color: const Color(0xFF06B6D4).withOpacity(0.10),
                  size: 280,
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),

                      _topTitle(),

                      const SizedBox(height: 24),

                      _buildHeader(context, controller),

                      const SizedBox(height: 24),

                      _sectionTitle(
                        title: "Quick Stats",
                        subtitle: "Your daily fitness consistency",
                      ),

                      const SizedBox(height: 14),

                      StreamBuilder<QuerySnapshot>(
                        stream: getDailyLogs(),
                        builder: (context, dailySnap) {
                          if (dailySnap.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingCard();
                          }

                          return StreamBuilder<QuerySnapshot>(
                            stream: getScanLogs(),
                            builder: (context, scanSnap) {
                              if (scanSnap.connectionState ==
                                  ConnectionState.waiting) {
                                return _loadingCard();
                              }

                              final dailyDocs = dailySnap.data?.docs ?? [];
                              final scanDocs = scanSnap.data?.docs ?? [];

                              final allDocs = [
                                ...dailyDocs,
                                ...scanDocs,
                              ];

                              final streak = calculateStreak(allDocs);

                              return _buildStreakCard(streak);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 26),

                      _sectionTitle(
                        title: "Knowledge Hub",
                        subtitle: "Smart tips and learning",
                      ),

                      const SizedBox(height: 14),

                      _tipCard(),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          _buildCategoryItem(
                            context,
                            Icons.restaurant_menu_rounded,
                            "Nutrition",
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryItem(
                            context,
                            Icons.local_fire_department_rounded,
                            "Fat Loss",
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryItem(
                            context,
                            Icons.directions_run_rounded,
                            "Lifestyle",
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      const SettingsSection(),

                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topTitle() {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF22C55E),
                Color(0xFF06B6D4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Manage your health journey",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
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
            color: Color(0xFF22C55E),
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
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProfileController controller,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.075),
                Colors.white.withOpacity(0.035),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06B6D4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 37,
                  backgroundColor: const Color(0xFF0F172A),
                  child: Text(
                    controller.name.isNotEmpty
                        ? controller.name[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.name.isNotEmpty ? controller.name : "User",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "FitMind AI Member",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF22C55E).withOpacity(0.25),
                        ),
                      ),
                      child: const Text(
                        "Active Journey",
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF22C55E),
                  size: 23,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF172554),
            Color(0xFF0F172A),
            Color(0xFF052E2B),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 86,
            width: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.orangeAccent.withOpacity(0.25),
              ),
            ),
            child: const Center(
              child: FirePulseIcon(),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Streak",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "$streak Days",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  streak > 0
                      ? "Great work! Keep your streak alive."
                      : "Start logging today to build your streak.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
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

  Widget _tipCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF22C55E).withOpacity(0.20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E).withOpacity(0.13),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFF22C55E),
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "FitMind Tip of the Day",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              FutureBuilder<String>(
                future: AICoachController().generateDailyTip(100),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      "Preparing a smart health tip for you...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      "Unable to load tip right now.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    );
                  }

                  return Text(
                    snapshot.data ?? "No tip available",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 13,
                      height: 1.5,
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

  Widget _loadingCard() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF22C55E),
        ),
      ),
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

int calculateStreak(List<QueryDocumentSnapshot> docs) {
  if (docs.isEmpty) return 0;

  List<DateTime> dates = [];

  for (var doc in docs) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      final ts = data['createdAt'] ?? data['timestamp'];
      if (ts == null) continue;

      DateTime d;

      if (ts is Timestamp) {
        d = ts.toDate();
      } else if (ts is String) {
        d = DateTime.parse(ts);
      } else {
        continue;
      }

      dates.add(DateTime(d.year, d.month, d.day));
    } catch (e) {
      debugPrint("Error parsing doc: $e");
    }
  }

  if (dates.isEmpty) return 0;

  dates = dates.toSet().toList();
  dates.sort((a, b) => b.compareTo(a));

  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);

  int streak = 0;

  for (int i = 0; i < dates.length; i++) {
    if (i == 0) {
      int diff = normalizedToday.difference(dates[i]).inDays;

      if (diff <= 1) {
        streak = 1;
      } else {
        return 0;
      }
    } else {
      int diff = dates[i - 1].difference(dates[i]).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
  }

  return streak;
}

Widget _buildCategoryItem(
  BuildContext context,
  IconData icon,
  String label,
) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        if (label == "Nutrition") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NutritionScreen()),
          );
        } else if (label == "Fat Loss") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Fatlossscreen()),
          );
        } else if (label == "Lifestyle") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Lifestylescreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.035),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: _getColor(label).withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColor(label).withOpacity(0.13),
              ),
              child: Icon(
                icon,
                color: _getColor(label),
                size: 25,
              ),
            ),

            const SizedBox(height: 11),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Color _getColor(String label) {
  switch (label) {
    case "Nutrition":
      return const Color(0xFF22C55E);
    case "Fat Loss":
      return Colors.orangeAccent;
    case "Lifestyle":
      return Colors.purpleAccent;
    default:
      return Colors.white;
  }
}