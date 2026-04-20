import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/controller/ai_coach_controller.dart';
import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/resources/app_them.dart';
import 'package:fitmind_ai/resources/fire_animation.dart';
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Fat%20Loss.dart';
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Lifestyle.dart';
import 'package:fitmind_ai/view/CATEGORYBUTTONS/Nutrition_screen.dart';
import 'package:fitmind_ai/view/Premium_Screens/premium_screen.dart';
import 'package:fitmind_ai/view/SettingsSection.dart';
import 'package:fitmind_ai/view/add_weight_screen.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileController>(context, listen: false).fetchUserData();
  }

  Stream<DocumentSnapshot> getUserData() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getWeightLogs() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailyLogs') // ✅ correct path
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getScanLogs() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getStreakSource() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scans')
        .snapshots();
  }

  Future<List<DateTime>> getAllActivityDates() async {
    final scans = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scans')
        .get();

    final dailyLogs = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailyLogs')
        .get();

    List<DateTime> dates = [];

    for (var doc in scans.docs) {
      final t = doc['timestamp'];
      if (t != null) dates.add((t as Timestamp).toDate());
    }

    for (var doc in dailyLogs.docs) {
      final t = doc['timestamp'];
      if (t != null) dates.add((t as Timestamp).toDate());
    }

    return dates;
  }

  Stream<QuerySnapshot> getMetricsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('body_metrics_log')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(1) // 🔥 latest record
        .snapshots();
  }

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// User Card
                  _buildHeader(context, controller),

                  const SizedBox(height: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Stats",
                        style: TextStyle(
                          color: inactiveColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      StreamBuilder<DocumentSnapshot>(
                        stream: getUserData(),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          var data =
                              userSnap.data!.data() as Map<String, dynamic>;

                          double currentWeight = (data['weight'] ?? 0)
                              .toDouble();
                          double startWeight = (data['startWeight'] ?? 0)
                              .toDouble();
                          double targetWeight = (data['targetWeight'] ?? 0)
                              .toDouble();

                          // ✅ Weight trend
                          double diff = currentWeight - startWeight;

                          String subtext;
                          if (diff < 0) {
                            subtext = "↓ ${diff.toStringAsFixed(1)} kg";
                          } else if (diff > 0) {
                            subtext = "↑ +${diff.toStringAsFixed(1)} kg";
                          } else {
                            subtext = "No change";
                          }

                          // ✅ Weekly Score
                          double progress = 0;
                          if (startWeight != targetWeight) {
                            progress =
                                (startWeight - currentWeight) /
                                (startWeight - targetWeight);
                          }

                          progress = progress.clamp(0.0, 1.0);
                          int weeklyScore = (progress * 100).toInt();

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('dailyLogs')
                                .snapshots(),

                            builder: (context, weightSnap) {
                              if (!weightSnap.hasData) {
                                return const CircularProgressIndicator();
                              }

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .collection('dailyLogs')
                                    .snapshots(),
                                builder: (context, weightSnap) {
                                  if (weightSnap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .collection('scans')
                                        .snapshots(),
                                    builder: (context, scanSnap) {
                                      if (scanSnap.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      final weightDocs =
                                          weightSnap.data?.docs ?? [];
                                      final scanDocs =
                                          scanSnap.data?.docs ?? [];

                                      print(
                                        "📊 Weight Docs: ${weightDocs.length}",
                                      );
                                      print("📊 Scan Docs: ${scanDocs.length}");

                                      final allDocs = [
                                        ...weightDocs,
                                        ...scanDocs,
                                      ];

                                      final streak = calculateStreak(allDocs);

                                      print("🔥 FINAL STREAK: $streak");
                                      print("🔥 SAVED SCAN TIME: ${Timestamp.now()}");

                                      return Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              label: "Current Weight",
                                              value:
                                                  "${currentWeight.toStringAsFixed(0)} kg",
                                              subtext: subtext,
                                              iconWidget: const Icon(
                                                Icons.monitor_weight_outlined,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Expanded(
                                            child: _buildStatCard(
                                              label: "Weekly Score",
                                              value: "$weeklyScore",
                                              hasProgress: true,
                                              progressValue: progress,
                                              iconWidget: const Icon(
                                                Icons.bar_chart,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Expanded(
                                            child: _buildStatCard(
                                              label: "Streak",
                                              value: "$streak Days",
                                              iconWidget: const FirePulseIcon(),
                                              iconColor: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Aapka existing sizedBox
                  // --- GOALS SECTION START ---
                  StreamBuilder<DocumentSnapshot>(
                    stream: getUserData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text(
                          "No Data",
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      var data = snapshot.data!.data() as Map<String, dynamic>;

                      // ✅ Firebase data
                      double currentWeight = (data['weight'] ?? 0).toDouble();
                      double targetWeight = (data['targetWeight'] ?? 0)
                          .toDouble();
                      double startWeight = (data['startWeight'] ?? 0)
                          .toDouble();
                      int weeks = data['estimatedWeeks'] ?? 0;

                      // ✅ Progress
                      double progress = 0;
                      if (startWeight != targetWeight) {
                        progress =
                            (startWeight - currentWeight) /
                            (startWeight - targetWeight);
                      }
                      progress = progress.clamp(0.0, 1.0);
                      String progressText = "${(progress * 100).toInt()}%";

                      // ✅ Estimated Date (IMPORTANT 🔥)
                      Timestamp createdAt = data['createdAt'];
                      DateTime startDate = createdAt.toDate();
                      DateTime estimatedDate = startDate.add(
                        Duration(days: weeks * 7),
                      );

                      String formattedDate =
                          "${estimatedDate.day}/${estimatedDate.month}/${estimatedDate.year}";

                      // 👉 ab yahan use karo
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Goals Section",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              _buildGoalCard(
                                label: "Target Weight",
                                value: "${targetWeight.toStringAsFixed(0)} kg",
                                progress: progress,
                                progressText: progressText,
                              ),

                              const SizedBox(width: 10),

                              _buildGoalCard(
                                label: "Duration",
                                value: "$weeks Weeks",
                                progress: progress,
                                progressText: progressText,
                              ),

                              const SizedBox(width: 10),

                              // ✅ FIXED
                              _buildGoalCard(
                                label: "Estimated Date",
                                value: formattedDate, // 👈 ab error nahi aayega
                                progress: progress,
                                progressText: progressText,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: const Text(
                      "Body Metrics",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),

                  // ================= METRICS STREAM =================
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('body_metrics_log')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          "Something went wrong",
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text(
                          "No Metrics Found",
                          style: TextStyle(color: Colors.white38),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      /// 📦 Latest weight
                      final latestData = docs[0].data() as Map<String, dynamic>;
                      final currentWeight = (latestData['weight'] ?? 0)
                          .toDouble();

                      /// 📦 Previous weight (if exists)
                      double previousWeight = currentWeight;

                      if (docs.length > 1) {
                        final prevData = docs[1].data() as Map<String, dynamic>;
                        previousWeight = (prevData['weight'] ?? currentWeight)
                            .toDouble();
                      }

                      /// 🔥 Difference
                      final diff = currentWeight - previousWeight;

                      /// 🔥 Icon logic
                      IconData icon;
                      Color iconColor;
                      String changeText;

                      if (diff < 0) {
                        /// Weight loss
                        icon = Icons.arrow_downward;
                        iconColor = Colors.green;
                        changeText = " ${diff.abs().toStringAsFixed(1)} kg";
                      } else if (diff > 0) {
                        /// Weight gain
                        icon = Icons.arrow_upward;
                        iconColor = Colors.red;
                        changeText = "↑ ${diff.toStringAsFixed(1)} kg";
                      } else {
                        icon = Icons.remove;
                        iconColor = Colors.grey;
                        changeText = "No change";
                      }

                      return _buildWeightCard(
                        weight: "$currentWeight kg",
                        icon: icon,
                        iconColor: iconColor,
                        changeText: changeText,
                        context: context,
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ADE80),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddWeightScreen(isEdit: true),
                          ),
                        );
                      },
                      child: const Text(
                        "Update Body Metrics",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Knowledge Hub",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- FEATURED GLOW CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2623),
                          borderRadius: BorderRadius.circular(16),
                          // Glow Border Effect
                          border: Border.all(
                            color: const Color(0xFF4ADE80).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFF4ADE80),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "MYDiet Tip of the Day",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            /// 🔥 YAHAN CHANGE KIYA HAI
                            FutureBuilder<String>(
                              future: AICoachController().generateDailyTip(
                                100,
                              ), // apna protein goal
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading tip...",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return const Text(
                                    "Unable to load tip",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                    ),
                                  );
                                }

                                return Text(
                                  snapshot.data ?? "No tip available",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- CATEGORY BUTTONS ROW ---
                      Row(
                        children: [
                          _buildCategoryItem(
                            context,
                            Icons.apple_outlined,
                            "Nutrition",
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryItem(
                            context,
                            Icons.local_fire_department_outlined,
                            "Fat Loss",
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryItem(
                            context,
                            Icons.directions_run_outlined,
                            "Lifestyle",
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Subscription Section",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- CURRENT PLAN CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2623),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Plan",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text("Loading...");
                                }

                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;

                                bool isPremium = data["isPremium"] ?? false;

                                String trialEndStr = data["trialEnd"] ?? "";
                                DateTime? trialEnd = trialEndStr.isNotEmpty
                                    ? DateTime.parse(trialEndStr)
                                    : null;

                                bool isTrialActive =
                                    trialEnd != null &&
                                    DateTime.now().isBefore(trialEnd);

                                String text;

                                if (isPremium) {
                                  text = "Premium Plan";
                                } else if (isTrialActive) {
                                  text = "Free Trial";
                                } else {
                                  text = "Free Plan";
                                }

                                return Text(
                                  text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),

                            // Usage Tracking Text
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return SizedBox();

                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;

                                int scans = data["scans"] ?? 0;
                                bool isPremium = data["isPremium"] ?? false;

                                return Text(
                                  isPremium
                                      ? "Unlimited scans"
                                      : "${scans.clamp(0, 3)}/3 scans used today",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Upgrade Button with Gradient Effect
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox();
                                }

                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                bool isPremium = data["premium"] ?? false;

                                return Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      colors: isPremium
                                          ? [Colors.redAccent, Colors.red]
                                          : [
                                              const Color(0xFF4ADE80),
                                              const Color(0xFF22C55E),
                                            ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isPremium
                                                    ? Colors.red
                                                    : const Color(0xFF4ADE80))
                                                .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (isPremium) {
                                        // 🔥 CANCEL PREMIUM FLOW
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            backgroundColor: const Color(
                                              0xFF0F172A,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: const Text(
                                              "Cancel Subscription",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            content: const Text(
                                              "Are you sure you want to cancel your premium subscription?",
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                                child: const Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),

                                              TextButton(
                                                onPressed: () async {
                                                  final user = FirebaseAuth
                                                      .instance
                                                      .currentUser;

                                                  if (user == null) return;

                                                  try {
                                                    // 🔥 CLOSE DIALOG FIRST
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );

                                                    // 🔥 UPDATE FIREBASE (CANCEL PREMIUM)
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(user.uid)
                                                        .set(
                                                          {
                                                            "premium": false,
                                                            "premiumPlan": null,
                                                            "premiumStart":
                                                                null,
                                                            "trialStart": null,
                                                            "trialEnd": null,
                                                          },
                                                          SetOptions(
                                                            merge: true,
                                                          ),
                                                        );

                                                    // 🔥 SUCCESS MESSAGE
                                                    showCustomSnackBar(
                                                      context,
                                                      "Subscription cancelled successfully",
                                                      true,
                                                    );
                                                  } catch (e) {
                                                    showCustomSnackBar(
                                                      context,
                                                      "Failed to cancel subscription",
                                                      false,
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // 🔥 GO TO PREMIUM SCREEN
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PremiumScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      isPremium
                                          ? "Cancel Subscription"
                                          : "Upgrade to Premium",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  /// Setting Section
                  const SettingsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//============/// premium section

Future<bool> canUserScan() async {
  final user = FirebaseAuth.instance.currentUser;
  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user!.uid)
      .get();

  final data = doc.data()!;

  bool isPremium = data["isPremium"] ?? false;

  // Trial check
  String trialEndStr = data["trialEnd"] ?? "";
  DateTime? trialEnd = trialEndStr.isNotEmpty
      ? DateTime.parse(trialEndStr)
      : null;

  bool isTrialActive = trialEnd != null && DateTime.now().isBefore(trialEnd);

  int scans = data["scans"] ?? 0;
  String lastDate = data["lastScanDate"] ?? "";

  String today = DateTime.now().toString().substring(0, 10);

  // reset daily
  if (lastDate != today) {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "scans": 0,
      "lastScanDate": today,
    });
    scans = 0;
  }

  // PREMIUM = unlimited
  if (isPremium) return true;

  // TRIAL = unlimited (IMPORTANT 🔥)
  if (isTrialActive) return true;

  // FREE = limit 3
  if (scans >= 3) return false;

  await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
    "scans": FieldValue.increment(1),
  });

  return true;
}

int calculateStreak(List<QueryDocumentSnapshot> docs) {
  if (docs.isEmpty) return 0;

  List<DateTime> dates = [];

  for (var doc in docs) {
    try {
      final data = doc.data() as Map<String, dynamic>;

    final ts = data['createdAt'] ?? data['timestamp'];
if (ts == null) continue;

      DateTime d;

      // 🔥 handle both Timestamp & String
      if (ts is Timestamp) {
        d = ts.toDate();
      } else if (ts is String) {
        d = DateTime.parse(ts);
      } else {
        continue;
      }

      dates.add(DateTime(d.year, d.month, d.day));
    } catch (e) {
      print("Error parsing doc: $e");
    }
  }

  if (dates.isEmpty) return 0;

  // 🔥 remove duplicates (same day)
  dates = dates.toSet().toList();

  // 🔥 sort latest first
  dates.sort((a, b) => b.compareTo(a));

  print("📅 ALL DATES:");
  for (var d in dates) {
    print(d);
  }

  DateTime today = DateTime.now();
  DateTime normalizedToday = DateTime(today.year, today.month, today.day);

  int streak = 0;

  for (int i = 0; i < dates.length; i++) {
    if (i == 0) {
      int diff = normalizedToday.difference(dates[i]).inDays;

      print("🧠 FIRST DIFF: $diff");

      if (diff <= 1) {
        streak = 1;
      } else {
        return 0; // 🔥 no recent activity
      }
    } else {
      int diff = dates[i - 1].difference(dates[i]).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
  }

  return streak;
}

// Example logic
// String displayTip = (userProteinIntake < 50)
//     ? "Low protein detected! Try adding eggs to your breakfast."
//     : "Your metabolism is on track today!";
Widget _buildCategoryItem(BuildContext context, IconData icon, String label) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        // 🔥 Navigation Logic
        if (label == "Nutrition") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NutritionScreen()),
          );
        } else if (label == "Fat Loss") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Fatlossscreen()),
          );
        } else if (label == "Lifestyle") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Lifestylescreen()),
          );
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2623),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: _getColor(label), // 🎨 dynamic color
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

Color _getColor(String label) {
  switch (label) {
    case "Nutrition":
      return Colors.greenAccent;
    case "Fat Loss":
      return Colors.orangeAccent;
    case "Lifestyle":
      return Colors.purpleAccent;
    default:
      return Colors.white;
  }
}

Widget _buildWeightCard({
  required String weight,
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String changeText,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🏷 Label + Value
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weight",
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              weight,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        /// 🔥 RIGHT SIDE (Change + Edit)
        Row(
          children: [
            /// ⬆️⬇️ Change Indicator
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  changeText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            /// ✏️ Edit Icon
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWeightScreen(isEdit: true),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

/// Stat Item
class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}

Widget _buildGoalCard({
  required String label,
  required String value,
  required double progress,
  required String progressText,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2623),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Circular Progress Indicator with Text in Center
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 45,
                width: 45,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4ADE80),
                  ),
                ),
              ),
              Text(
                progressText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildHeader(BuildContext context, ProfileController controller) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        /// 🔥 AVATAR WITH GLOW
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.green],
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),

        const SizedBox(width: 15),

        /// 🔥 USER INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// NAME
              Text(
                controller.name.isNotEmpty ? controller.name : "User",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              /// STATUS BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: controller.status == "On Track"
                      ? Colors.greenAccent
                      : controller.status == "Needs Improvement"
                      ? Colors.orangeAccent
                      : Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.status,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// DAY TEXT
              Text(
                "Day ${controller.days} of your journey",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatCard({
  required String label,
  required String value,
  String? subtext,
  //required IconData icon,
  Widget? iconWidget,
  Color iconColor = Colors.white54,
  bool hasProgress = false,
  double progressValue = 0,
}) {
  return Container(
    height: 130, // 🔥 FIXED HEIGHT (IMPORTANT)
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF1E2623),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🔥 EVEN SPACING
      children: [
        iconWidget ?? const FirePulseIcon(),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        /// 🔥 Bottom Section (Fixed Space)
        if (hasProgress)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white10,
              color: Colors.greenAccent,
              minHeight: 3,
            ),
          )
        else
          SizedBox(
            height: 14, // 🔥 FIX SPACE (important for equal height)
            child: subtext != null
                ? Text(
                    subtext,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),
      ],
    ),
  );
}

/// About Tile
class AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;

  const AboutTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = Colors.blue,
    this.textColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // cardColor
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }
}
