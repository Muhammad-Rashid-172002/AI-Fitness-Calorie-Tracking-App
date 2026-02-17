import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/view/history_screen.dart';
import 'package:fitmind_ai/view/home_screen.dart';
import 'package:fitmind_ai/view/premium_screen.dart';
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
    PremiumScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,

      /// Body
      body: SafeArea(bottom: true, child: pages[currentIndex]),

      /// Floating Action Button
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        onPressed: () => setState(() => currentIndex = 2),
        backgroundColor: primary,
        child: const Icon(Icons.qr_code_scanner, color: Colors.black, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFF1E293B),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 65,
            child: Row(
              children: [
                _navItem(Icons.home, "Home", 0),
                _navItem(Icons.history, "History", 1),
                const Spacer(), // space for FAB
                _navItem(Icons.workspace_premium, "Premium", 3),
                _navItem(Icons.person, "Profile", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigation Item
  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double iconSize = constraints.maxHeight * 0.42; // slightly smaller
          double fontSize = constraints.maxHeight * 0.18; // slightly smaller

          return InkWell(
            onTap: () => setState(() => currentIndex = index),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(4), // smaller padding
                    decoration: BoxDecoration(
                      color: isActive
                          ? primary.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: isActive ? primary : inactive,
                    ),
                  ),
                  const SizedBox(height: 2), // smaller spacing
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isActive ? primary : inactive,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
