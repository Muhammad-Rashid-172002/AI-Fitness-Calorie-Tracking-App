import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final List<String> filters = [
    "Today",
    "Week",
    "Month",
  ];

  int selectedIndex = 0;

late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getDailyLogs() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("scans")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      body: Stack(
        children: [
          /// TOP GLOW
          Positioned(
            top: -120,
            left: -80,
            child: AnimatedBuilder(
  animation: _animationController,
  builder: (_, __) {
    return Container(
      height: 260,
      width: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: activeColor.withOpacity(
          0.04 + (_animationController.value * 0.05),
        ),
      ),
    );
  },
),
          ),

          /// BOTTOM GLOW
          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _header(),

                const SizedBox(height: 18),

                _filterBar(),

                const SizedBox(height: 18),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getDailyLogs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return _emptyView();
                      }

                      List<Map<String, dynamic>> items =
                          snapshot.data!.docs.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;

                        data["docId"] = doc.id;

                        return data;
                      }).toList();

                      List<Map<String, dynamic>> filtered =
                          _filterData(items);

                      filtered.sort((a, b) {
                        Timestamp? aTime = a["timestamp"];
                        Timestamp? bTime = b["timestamp"];

                        if (aTime == null || bTime == null) {
                          return 0;
                        }

                        return bTime.compareTo(aTime);
                      });

                      if (filtered.isEmpty) {
                        return _emptyView();
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          120,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _historyCard(filtered[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// HEADER

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06B6D4),
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  "History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Your nutrition journey",
                style: TextStyle(
                  color: Colors.white.withOpacity(.55),
                  fontSize: 15,
                ),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  activeColor.withOpacity(.25),
                  Colors.cyanAccent.withOpacity(.15),
                ],
              ),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER BAR

  Widget _filterBar() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          bool selected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),

                gradient: selected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF22C55E),
                          Color(0xFF06B6D4),
                        ],
                      )
                    : null,

                color: selected
                    ? null
                    : Colors.white.withOpacity(.05),

                border: Border.all(
                  color: Colors.white.withOpacity(.06),
                ),
              ),

              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// FILTER DATA

  List<Map<String, dynamic>> _filterData(
    List<Map<String, dynamic>> items,
  ) {
    DateTime now = DateTime.now();

    return items.where((data) {
      Timestamp? ts = data["timestamp"];

      if (ts == null) return true;

      DateTime date = ts.toDate();

      if (selectedIndex == 0) {
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }

      if (selectedIndex == 1) {
        return date.isAfter(
          now.subtract(const Duration(days: 7)),
        );
      }

      return date.month == now.month &&
          date.year == now.year;
    }).toList();
  }

  /// HISTORY CARD

  Widget _historyCard(Map<String, dynamic> item) {
    int calories = (item["calories"] ?? 0).toInt();
    int protein = (item["protein"] ?? 0).toInt();
    int carbs = (item["carbs"] ?? 0).toInt();
    int fat = (item["fat"] ?? 0).toInt();

    Timestamp? ts = item["timestamp"];

    String formattedDate = "No Date";

    if (ts != null) {
      formattedDate = DateFormat(
        "dd MMM yyyy • hh:mm a",
      ).format(ts.toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),

          child: Container(
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(.05),

              border: Border.all(
                color: Colors.white.withOpacity(.08),
              ),
            ),

            child: Column(
              children: [
                /// TOP

                Row(
                  children: [
                    Container(
                      height: 62,
                      width: 62,

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),

                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF06B6D4),
                          ],
                        ),
                      ),

                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Nutrition Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            formattedDate,
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(.55),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color:
                            Colors.orange.withOpacity(.12),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),

                      child: Text(
                        "$calories kcal",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// MACROS

                Row(
                  children: [
                    _macroItem(
                      "Protein",
                      protein,
                      Colors.greenAccent,
                    ),

                    const SizedBox(width: 12),

                    _macroItem(
                      "Carbs",
                      carbs,
                      Colors.orangeAccent,
                    ),

                    const SizedBox(width: 12),

                    _macroItem(
                      "Fat",
                      fat,
                      Colors.cyanAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _macroItem(
    String title,
    int value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(.04),
        ),

        child: Column(
          children: [
            Text(
              "$value g",
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EMPTY VIEW

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 110,
            width: 110,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  activeColor.withOpacity(.18),
                  Colors.cyanAccent.withOpacity(.10),
                ],
              ),
            ),

            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: Colors.white,
              size: 55,
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            "No History Found",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Start scanning meals to see your nutrition history.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.55),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}