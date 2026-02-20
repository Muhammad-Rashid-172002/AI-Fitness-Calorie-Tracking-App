import 'package:fitmind_ai/models/food_model.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';

import 'package:fitmind_ai/resources/app_them.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScanController controller = ScanController();
  final List<String> filters = ["Day", "Week", "Month"];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Real History List
            Expanded(
              child: StreamBuilder<List<Scan>>(
                stream: controller.getScanHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                      "No meals logged yet",
                      style: TextStyle(color: inactiveColor),
                    ));
                  }

                  // Filter based on selectedIndex
                  DateTime now = DateTime.now();
                  List<Scan> filtered = snapshot.data!.where((scan) {
                    if (selectedIndex == 0) {
                      return scan.timestamp.day == now.day &&
                          scan.timestamp.month == now.month &&
                          scan.timestamp.year == now.year;
                    } else if (selectedIndex == 1) {
                      DateTime weekStart =
                          now.subtract(Duration(days: now.weekday - 1));
                      return scan.timestamp.isAfter(weekStart);
                    } else {
                      DateTime monthStart = DateTime(now.year, now.month, 1);
                      return scan.timestamp.isAfter(monthStart);
                    }
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      var scan = filtered[index];
                      return AnimatedContainer(
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
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                scan.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scan.result,
                                    style: TextStyle(
                                        color: activeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('hh:mm a, dd MMM')
                                        .format(scan.timestamp),
                                    style: TextStyle(
                                        color: inactiveColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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