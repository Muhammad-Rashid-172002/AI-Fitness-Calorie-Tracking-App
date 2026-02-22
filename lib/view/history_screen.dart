import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';

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
            // Title
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
            // History List
            Expanded(
              child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: controller.getScanHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No meals logged yet",
                        style: TextStyle(color: inactiveColor),
                      ),
                    );
                  }

                  // Convert documents to a list of maps (and normalize timestamp) then filter by selected tab
                  DateTime now = DateTime.now();
                  List<Map<String, dynamic>> items = snapshot.data!.docs.map((doc) {
                    final raw = doc.data();
                    final data = (raw is Map<String, dynamic>) ? raw : Map<String, dynamic>.from(raw as Map);
                    return data;
                  }).toList();

                  List<Map<String, dynamic>> filtered = items.where((data) {
                    final ts = data['timestamp'];
                    DateTime timestamp;
                    if (ts is Timestamp) {
                      timestamp = ts.toDate();
                    } else if (ts is DateTime) {
                      timestamp = ts;
                    } else {
                      timestamp = DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
                    }

                    if (selectedIndex == 0) {
                      // Today
                      return timestamp.day == now.day &&
                          timestamp.month == now.month &&
                          timestamp.year == now.year;
                    } else if (selectedIndex == 1) {
                      // Week
                      DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
                      return timestamp.isAfter(weekStart);
                    } else {
                      // Month
                      DateTime monthStart = DateTime(now.year, now.month, 1);
                      return timestamp.isAfter(monthStart);
                    }
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No meals logged in this period",
                        style: TextStyle(color: inactiveColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final data = filtered[index];
                      final ts = data['timestamp'];
                      DateTime timestamp;
                      if (ts is Timestamp) {
                        timestamp = ts.toDate();
                      } else if (ts is DateTime) {
                        timestamp = ts;
                      } else {
                        timestamp = DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
                      }
                      final String result = data['result']?.toString() ?? '';
                      final String? imagePath = data['imagePath'] as String?;

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
                            // Image or placeholder
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imagePath != null
                                  ? Image.file(
                                      File(imagePath),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[400],
                                      child: const Icon(
                                        Icons.fastfood,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result,
                                    style: TextStyle(
                                      color: activeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('hh:mm a, dd MMM').format(timestamp),
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
            ]),
          
        ),
      );
    
  }
}