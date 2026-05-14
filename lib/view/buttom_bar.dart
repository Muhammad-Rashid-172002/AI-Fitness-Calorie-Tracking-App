import 'dart:ui';

import 'package:fitmind_ai/ai_coach.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/history_screen.dart';
import 'package:fitmind_ai/view/home_screen.dart';
import 'package:fitmind_ai/view/profile_screen.dart';
import 'package:fitmind_ai/view/scan_screen.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  AnimationController? _animationController;

  final pages = const [
    HomeScreen(),
    HistoryScreen(),
    ScanScreen(),
    AiCoach(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController?.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          /// BACKGROUND GLOW
          Positioned(
            bottom: -100,
            left: -80,
            child: AnimatedBuilder(
              animation:
                  _animationController ?? kAlwaysDismissedAnimation,
              builder: (_, __) {
                return Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(
                      0.05 +
                          ((_animationController?.value ?? 0.0) * 0.04),
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: pages[currentIndex],
          ),
        ],
      ),

      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// ================= FAB =================

  Widget _buildFAB() {
    final isActive = currentIndex == 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = 2;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: isActive ? 82 : 74,
        width: isActive ? 82 : 74,
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
              color: primary.withOpacity(0.45),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF08101E),
          ),
          child: Center(
            child: Image.asset(
              "assets/scan_icon.png",
              height: 32,
              width: 32,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= BOTTOM BAR =================

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _navItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                ),

                _navItem(
                  icon: Icons.history_rounded,
                  label: "History",
                  index: 1,
                ),

                const SizedBox(width: 75),

                _navItem(
                  icon: Icons.smart_toy_rounded,
                  label: "AI Coach",
                  index: 3,
                ),

                _navItem(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= NAV ITEM =================

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? primary.withOpacity(0.14)
                      : Colors.transparent,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive
                      ? primary
                      : Colors.white.withOpacity(0.45),
                ),
              ),

              const SizedBox(height: 4),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}