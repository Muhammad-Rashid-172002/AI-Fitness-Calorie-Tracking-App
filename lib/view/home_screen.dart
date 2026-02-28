import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
import 'package:fitmind_ai/view/history_screen.dart';
import 'package:fitmind_ai/view/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMacro = -1;

  // Daily stats
  int todayMeals = 0;
  int todayCalories = 0;
  int dailyGoal = 2426; // Default daily calories
  int streakDays = 0;

  // Macro nutrients today (start with 0)
  int todayProtein = 0;
  int todayCarbs = 0;
  int todayFat = 0;

  // Set daily goals
  int dailyGoalCalories = 0;
  int proteinGoal = 0;
  int carbsGoal = 0;
  int fatGoal = 0;

  final ScanController controller = ScanController();

  @override
  void initState() {
    super.initState();
    loadTodayMeals();
    loadUserGoals();
  }

  void loadUserGoals() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        dailyGoalCalories = (data["dailyCalories"] ?? 0).toInt();
        proteinGoal = (data["proteinTarget"] ?? 0).toInt();
        carbsGoal = (data["carbsTarget"] ?? 0).toInt();
        fatGoal = (data["fatTarget"] ?? 0).toInt();
      });
    }
  }

  // Load meals and macros from Firestore or local storage
  void loadTodayMeals() async {
    int count = await controller.getTodayMealCount();
    // int calories = await controller.getTodayTotalCalories();
    // int protein = await controller.getTodayTotalProtein();
    // int carbs = await controller.getTodayTotalCarbs();
    // int fat = await controller.getTodayTotalFat();
    //int streak = await controller.getStreakDays();

    setState(() {
      todayMeals = count;
      //   todayCalories = calories;
      // todayProtein = protein;
      // todayCarbs = carbs;
      // todayFat = fat;
      // streakDays = streak;
    });
  }

  // Update UI after a new scan
  void updateTodayStats({
    int addedCalories = 0,
    int addedProtein = 0,
    int addedCarbs = 0,
    int addedFat = 0,
  }) {
    setState(() {
      todayMeals += 1;
      todayCalories += addedCalories;
      todayProtein += addedProtein;
      todayCarbs += addedCarbs;
      todayFat += addedFat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(color: textGrey, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              "Loading...",
                              style: TextStyle(
                                color: textMain,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Text(
                              "user",
                              style: TextStyle(
                                color: textMain,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final userName = userData["name"] ?? "user";

                          return Text(
                            userName,
                            style: TextStyle(
                              color: textMain,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                     // _caloriesCard(),
                      const SizedBox(height: 20),
                      _todayProgressCard(),
                      const SizedBox(height: 20),
                      _scanButton(),
                      const SizedBox(height: 20),
                        _macroProgressCard(),
                      SizedBox(height: 20),
                      // _macrosCard(),
                      // const SizedBox(height: 20),
                    //  _lastTwoHistory(),
                      const SizedBox(height: 20),
                      _dailyTipCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//////// -========>.  

Widget _todayProgressCard() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("dailyLogs")
        .doc(today)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return _caloriesUI(0, 0);
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;

      int totalCalories = (data["totalCalories"] ?? 0).toInt();
      int mealCount = (data["mealCount"] ?? 0).toInt();

      return _caloriesUI(totalCalories, mealCount);
    },
  );
}
Widget _caloriesUI(int consumed, int meals) {
  int remaining = dailyGoalCalories - consumed;

  double progress = dailyGoalCalories == 0
      ? 0
      : (consumed / dailyGoalCalories).clamp(0.0, 1.0);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: consumed > dailyGoalCalories
            ? [Colors.red, Colors.redAccent]
            : [Colors.orange, Colors.deepOrange],
      ),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Calories",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          "$consumed / $dailyGoalCalories kcal",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          remaining >= 0
              ? "$remaining kcal remaining"
              : "Exceeded by ${remaining.abs()} kcal",
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 15),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation(Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          "$meals meals logged today",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}


  // macro progress card
  Widget _macroProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Macros Progress",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          const SizedBox(height: 15),

          _macroBar("Protein", todayProtein, proteinGoal),
          _macroBar("Carbs", todayCarbs, carbsGoal),
          _macroBar("Fat", todayFat, fatGoal),
        ],
      ),
    );
  }

  Widget _macroBar(String title, int current, int goal) {
    double progress = goal == 0 ? 0 : (current / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title  $current / $goal g",style: TextStyle(color: Colors.white),),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, minHeight: 6),
        ],
      ),
    );
  }

  // Widget _lastTwoHistory() {
  //   return StreamBuilder<QuerySnapshot<Object?>>(
  //     stream: controller.getScanHistory(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: CircularProgressIndicator(
  //             color: activeColor,
  //             strokeWidth: 3,
  //           ),
  //         );
  //       }

  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return SizedBox(
  //           width: double.infinity,
  //           child: Column(
  //             children: [
  //               Container(
  //                 margin: const EdgeInsets.symmetric(vertical: 20),
  //                 padding: const EdgeInsets.all(25),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(35),
  //                   border: Border.all(color: activeColor.withOpacity(0.2)),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 25,
  //                       offset: const Offset(0, 12),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     Icon(
  //                       Icons.fastfood_outlined,
  //                       size: 50,
  //                       color: activeColor.withOpacity(0.8),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     Text(
  //                       "No recent meals",
  //                       style: TextStyle(
  //                         color: inactiveColor.withOpacity(0.8),
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         letterSpacing: 0.3,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }

  //       // Sort latest first
  //       List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
  //       docs.sort((a, b) {
  //         final aTs = (a.data() as Map<String, dynamic>)['timestamp'];
  //         final bTs = (b.data() as Map<String, dynamic>)['timestamp'];
  //         DateTime aTime = aTs is Timestamp
  //             ? aTs.toDate()
  //             : DateTime.fromMillisecondsSinceEpoch(0);
  //         DateTime bTime = bTs is Timestamp
  //             ? bTs.toDate()
  //             : DateTime.fromMillisecondsSinceEpoch(0);
  //         return bTime.compareTo(aTime);
  //       });

  //       final lastTwo = docs.take(2).toList();

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Header
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Recent Meals",
  //                   style: TextStyle(
  //                     color: activeColor,
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     letterSpacing: 0.5,
  //                   ),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => const HistoryScreen(),
  //                       ),
  //                     );
  //                   },
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: activeColor,
  //                     textStyle: const TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                   child: const Text("See All"),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 20),

  //           // Meal Cards
  //           ...lastTwo.map((doc) {
  //             final data = doc.data() as Map<String, dynamic>;
  //             final ts = data['timestamp'];
  //             final DateTime timestamp = ts is Timestamp
  //                 ? ts.toDate()
  //                 : DateTime.now();
  //             final String result = data['result'] ?? '';
  //             final String? imagePath = data['imagePath'];

  //             return Container(
  //               margin: const EdgeInsets.only(bottom: 20),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(35),
  //                 border: Border.all(color: activeColor.withOpacity(0.2)),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black26,
  //                     blurRadius: 25,
  //                     offset: const Offset(0, 12),
  //                   ),
  //                 ],
  //               ),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(35),
  //                 child: BackdropFilter(
  //                   filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(18),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [
  //                           Colors.white.withOpacity(0.2),
  //                           Colors.white.withOpacity(0.05),
  //                         ],
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                       ),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         // Meal Image
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(20),
  //                           child: imagePath != null
  //                               ? Image.file(
  //                                   File(imagePath),
  //                                   width: 80,
  //                                   height: 80,
  //                                   fit: BoxFit.cover,
  //                                 )
  //                               : Container(
  //                                   width: 80,
  //                                   height: 80,
  //                                   decoration: BoxDecoration(
  //                                     color: activeColor.withOpacity(0.3),
  //                                     borderRadius: BorderRadius.circular(20),
  //                                   ),
  //                                   child: Icon(
  //                                     Icons.fastfood,
  //                                     color: activeColor,
  //                                     size: 36,
  //                                   ),
  //                                 ),
  //                         ),
  //                         const SizedBox(width: 18),

  //                         // Meal Info
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 result,
  //                                 style: TextStyle(
  //                                   color: activeColor,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 18,
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 6),
  //                               Text(
  //                                 DateFormat(
  //                                   'hh:mm a, dd MMM',
  //                                 ).format(timestamp),
  //                                 style: TextStyle(
  //                                   color: inactiveColor.withOpacity(0.7),
  //                                   fontSize: 13.5,
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 10),
  //                               // Mini Nutritional Bar (Premium Touch)
  //                               Container(
  //                                 height: 6,
  //                                 width: double.infinity,
  //                                 decoration: BoxDecoration(
  //                                   color: inactiveColor.withOpacity(0.2),
  //                                   borderRadius: BorderRadius.circular(3),
  //                                 ),
  //                                 child: FractionallySizedBox(
  //                                   alignment: Alignment.centerLeft,
  //                                   widthFactor: 0.7, // example progress
  //                                   child: Container(
  //                                     decoration: BoxDecoration(
  //                                       color: activeColor,
  //                                       borderRadius: BorderRadius.circular(3),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),

  //                         Icon(
  //                           Icons.chevron_right_rounded,
  //                           color: activeColor.withOpacity(0.7),
  //                           size: 28,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         ],
  //       );
  //     },
  //   );
  // } // Calories/Streak Card

  Widget _caloriesCard() {
    int remaining = dailyGoalCalories - todayCalories;
    double progress = dailyGoalCalories == 0
        ? 0
        : (todayCalories / dailyGoalCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Calories",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 10),

                Text(
                  "$todayCalories / $dailyGoalCalories kcal",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "$remaining kcal remaining",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 15),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: CustomGradientButton(
        text: 'Scan a Meal',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );

          if (result != null && result is Map<String, dynamic>) {
            updateTodayStats(
              addedCalories: (result["calories"] ?? 0).toInt(),
              addedProtein: (result["protein"] ?? 0).toInt(),
              addedCarbs: (result["carbs"] ?? 0).toInt(),
              addedFat: (result["fat"] ?? 0).toInt(),
            );
          }
        },
      ),
    );
  }

  Widget _dailyTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DAILY TIP",
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Add more greens to your meals",
                  style: TextStyle(color: textMain, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Greeting helper
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return "Good Morning ";
  if (hour < 17) return "Good Afternoon ";
  return "Good Evening ";
}
