import 'package:fitmind_ai/view/history_screen.dart';
import 'package:fitmind_ai/view/home_screen.dart';
import 'package:fitmind_ai/view/insight_screen.dart';
import 'package:fitmind_ai/view/profile_screen.dart';
import 'package:fitmind_ai/view/scan_page.dart';
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
    ScanPage(),
    InsightScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: pages[currentIndex],

      // 🔥 Center Scan Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          setState(() {
            currentIndex = 2;
          });
        },
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.black,
          size: 28,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // 🌟 Bottom Bar
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.3),
              blurRadius: 20,
            )
          ],
        ),

        child: BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [

              buildItem(Icons.home, "Home", 0),
              buildItem(Icons.history, "History", 1),

              const SizedBox(width: 40), // Space for FAB

              buildItem(Icons.insights, "Insight", 3),
              buildItem(Icons.person, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(IconData icon, String title, int index) {
    bool isActive = currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 24,
            color: isActive
                ? Colors.greenAccent
                : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Colors.greenAccent
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}