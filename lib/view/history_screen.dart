import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Filter options
  final List<String> filters = ["Day", "Week", "Month"];
  int selectedIndex = 0;

  // Sample data
  final Map<String, List<Map<String, String>>> historyData = {
    "Day": [
      {"time": "07:00 AM", "activity": "Morning Jog", "cal": "120 kcal"},
      {"time": "09:00 AM", "activity": "Yoga", "cal": "80 kcal"},
    ],
    "Week": [
      {"time": "Mon", "activity": "Gym", "cal": "500 kcal"},
      {"time": "Wed", "activity": "Cycling", "cal": "350 kcal"},
      {"time": "Fri", "activity": "Swimming", "cal": "400 kcal"},
    ],
    "Month": [
      {"time": "1 Feb", "activity": "Gym", "cal": "500 kcal"},
      {"time": "3 Feb", "activity": "Yoga", "cal": "200 kcal"},
      {"time": "10 Feb", "activity": "Running", "cal": "600 kcal"},
      {"time": "15 Feb", "activity": "Cycling", "cal": "450 kcal"},
    ],
  };

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Screen Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    "Meal History",
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(filters.length, (index) {
                  bool isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color: isSelected ? bgColor : inactiveColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: historyData[filters[selectedIndex]]!.length,
                itemBuilder: (context, index) {
                  var item = historyData[filters[selectedIndex]]![index];

                  return GestureDetector(
                    onTap: () {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: activeColor.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["activity"]!,
                                style: TextStyle(
                                    color: activeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["time"]!,
                                style: TextStyle(color: inactiveColor, fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            item["cal"]!,
                            style: TextStyle(color: activeColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}