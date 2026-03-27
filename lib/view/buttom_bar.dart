import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/WeeklyProgressScreen.dart';
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

class _MainViewState extends State<MainView> {
  int currentIndex = 0;

  final pages = const [
    HomeScreen(),
    HistoryScreen(),
    ScanScreen(),
    WeeklyProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,

      body: SafeArea(child: pages[currentIndex]),

      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// ================= FAB =================
 Widget _buildFAB() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 95,
        width: 95,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// OUTER SOFT GLOW
            Container(
              height: 95,
              width: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.08),
              ),
            ),

            /// NEON RING
            Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withOpacity(0.9),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            /// INNER BUTTON
            GestureDetector(
              onTap: () => setState(() => currentIndex = 2),
              child: Container(
                height: 62,
                width: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0B1220),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(
                    "assets/scan_icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 4),

      /// TEXT BELOW FAB
      Text(
        "Scan",
        style: TextStyle(
          fontSize: 12,
          color: primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}  /// ================= BOTTOM BAR =================
Widget _buildBottomBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Container(
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B1220),
            Color(0xFF0F1A2E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          height: 80, // 🔥 force proper height
          child: BottomAppBar(
            color: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _navItem(Icons.home_rounded, "Home", 0),
                _navItem(Icons.history, "History", 1),

                const SizedBox(width: 65),

                _navItem(Icons.bar_chart_rounded, "Progress", 3),
                _navItem(Icons.person_outline, "Profile", 4),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}  /// ================= NAV ITEM =================
Widget _navItem(IconData icon, String label, int index) {
  bool isActive = currentIndex == index;

  return Expanded(
    child: InkWell(
      onTap: () => setState(() => currentIndex = index),
      child: SizedBox(
        height: double.infinity, // 🔥 important fix
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24, // 🔽 reduced a bit
              color: isActive ? primary : Colors.grey.shade500,
            ),
            const SizedBox(height: 2), // 🔽 reduce spacing
            Flexible( // 🔥 prevents overflow
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11, // 🔽 slightly smaller
                  color: isActive ? primary : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}