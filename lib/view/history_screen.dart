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

  final List<String> filters = ["Today", "Week", "Month"];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activeColor,
                  activeColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Meal History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Track your daily nutrition",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// ================= FILTER =================
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: filters.length,
              itemBuilder: (context, index) {

                bool selected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? activeColor
                          : cardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: activeColor.withOpacity(0.4),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color:
                              selected ? Colors.white : inactiveColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// ================= HISTORY =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.getScanHistory(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _emptyView();
                }

                DateTime now = DateTime.now();

                List<Map<String, dynamic>> items =
                    snapshot.data!.docs.map((doc) {
                  return Map<String, dynamic>.from(
                      doc.data() as Map<String, dynamic>);
                }).toList();

                /// Filter Data
                List<Map<String, dynamic>> filtered =
                    items.where((data) {

                  final ts = data['timestamp'];
                  DateTime time;

                  if (ts is Timestamp) {
                    time = ts.toDate();
                  } else {
                    time = DateTime.tryParse(ts.toString()) ??
                        DateTime.now();
                  }

                  if (selectedIndex == 0) {
                    return time.day == now.day &&
                        time.month == now.month &&
                        time.year == now.year;
                  } 
                  else if (selectedIndex == 1) {
                    final weekStart =
                        now.subtract(Duration(days: now.weekday));
                    return time.isAfter(weekStart);
                  } 
                  else {
                    final monthStart =
                        DateTime(now.year, now.month, 1);
                    return time.isAfter(monthStart);
                  }

                }).toList();

                if (filtered.isEmpty) {
                  return _emptyView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {

                    final data = filtered[index];

                    final ts = data['timestamp'];

                    DateTime time;

                    if (ts is Timestamp) {
                      time = ts.toDate();
                    } else {
                      time = DateTime.tryParse(ts.toString()) ??
                          DateTime.now();
                    }

                    return _historyCard(
                      imagePath: data['imagePath'],
                      result: data['result'] ?? "Food",
                      time: time,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= HISTORY CARD =================
  Widget _historyCard({
    required String? imagePath,
    required String result,
    required DateTime time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imagePath != null
                ? Image.file(
                    File(imagePath),
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  result,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [

                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: inactiveColor,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      DateFormat('hh:mm a • dd MMM')
                          .format(time),
                      style: TextStyle(
                        color: inactiveColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// ARROW
          Icon(
            Icons.chevron_right,
            size: 26,
            color: inactiveColor,
          ),
        ],
      ),
    );
  }

  /// ================= EMPTY VIEW =================
  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            Icons.no_food_outlined,
            size: 80,
            color: inactiveColor,
          ),

          const SizedBox(height: 18),

          Text(
            "No History Found",
            style: TextStyle(
              color: inactiveColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Start scanning your meals",
            style: TextStyle(
              color: inactiveColor.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}