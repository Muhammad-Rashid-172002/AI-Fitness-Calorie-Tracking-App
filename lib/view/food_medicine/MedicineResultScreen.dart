import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MedicineResultScreen extends StatefulWidget {
  final File image;
  final String result;

  const MedicineResultScreen({
    super.key,
    required this.image,
    required this.result,
  });

  static const bg = Color(0xFF07111F);
  static const cyan = Color(0xFF06B6D4);
  static const blue = Color(0xFF2563EB);
  static const textMain = Color(0xFFF8FAFC);
  static const textSub = Color(0xFF94A3B8);

  @override
  State<MedicineResultScreen> createState() => _MedicineResultScreenState();
}

class _MedicineResultScreenState extends State<MedicineResultScreen> {
  bool isSaved = false;
  bool isPremiumUnlocked = false;
  RewardedAd? _rewardedAd;

  String get result => widget.result;
  File get image => widget.image;

  String _getValue(String key) {
    final regex = RegExp('$key:\\s*(.*)', caseSensitive: false);
    final match = regex.firstMatch(result);
    return match?.group(1)?.trim() ?? "Not available";
  }

  Future<void> saveMedicineScanToFirebase() async {
    if (isSaved) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final medicineName = _getValue("Medicine Name");
    final purpose = _getValue("Purpose");
    final usage = _getValue("Usage");
    final caution = _getValue("Caution");
    final aiInsight = _getValue("AI Insight");
    final doctorNote = _getValue("Doctor Note");
    final formula = _getValue("Generic Formula / Active Ingredient");
    final strength = _getValue("Strength");
    final alternatives = _getValue("Same Formula Alternatives");
    final ifNotAvailable = _getValue("If Not Available");

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("scans")
        .add({
          "type": "medicine",
          "title": "Medicine Scan",
          "result": result,
          "medicineName": medicineName,
          "purpose": purpose,
          "usage": usage,
          "caution": caution,
          "aiInsight": aiInsight,
          "doctorNote": doctorNote,
          "formula": formula,
          "strength": strength,
          "alternatives": alternatives,
          "ifNotAvailable": ifNotAvailable,
          "timestamp": FieldValue.serverTimestamp(),
        });

    setState(() => isSaved = true);
  }

  @override
  void initState() {
    super.initState();
    loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      saveMedicineScanToFirebase();
    });

    final medicineName = _getValue("Medicine Name");
    final purpose = _getValue("Purpose");
    final usage = _getValue("Usage");
    final caution = _getValue("Caution");
    final aiInsight = _getValue("AI Insight");
    final doctorNote = _getValue("Doctor Note");
    final formula = _getValue("Generic Formula / Active Ingredient");
    final strength = _getValue("Strength");
    final alternatives = _getValue("Same Formula Alternatives");
    final ifNotAvailable = _getValue("If Not Available");

    return Scaffold(
      backgroundColor: MedicineResultScreen.bg,
      body: Stack(
        children: [
          _glow(
            top: -100,
            right: -90,
            color: MedicineResultScreen.cyan.withOpacity(.18),
          ),
          _glow(
            bottom: -100,
            left: -80,
            color: MedicineResultScreen.blue.withOpacity(.16),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),

                  const SizedBox(height: 18),

                  _imageCard(),

                  const SizedBox(height: 20),

                  _medicineCard(medicineName),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _miniCard(
                          icon: Icons.medication_rounded,
                          title: "Purpose",
                          value: purpose,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniCard(
                          icon: Icons.warning_amber_rounded,
                          title: "Safety",
                          value: caution,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _infoCard(
                    icon: Icons.info_outline_rounded,
                    title: "Usage Information",
                    value: usage,
                  ),

                  if (isPremiumUnlocked) ...[
                    _infoCard(
                      icon: Icons.auto_awesome_rounded,
                      title: "AI Insight",
                      value: aiInsight,
                    ),

                    _infoCard(
                      icon: Icons.science_rounded,
                      title: "Generic Formula",
                      value: formula,
                    ),

                    _infoCard(
                      icon: Icons.monitor_weight_rounded,
                      title: "Strength",
                      value: strength,
                    ),

                    _infoCard(
                      icon: Icons.compare_arrows_rounded,
                      title: "Same Formula Alternatives",
                      value: alternatives,
                    ),

                    _infoCard(
                      icon: Icons.local_pharmacy_rounded,
                      title: "If Not Available",
                      value: ifNotAvailable,
                    ),

                    _doctorNote(doctorNote),
                  ] else ...[
                    _unlockCard(),
                  ],

                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unlockCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(.055),
        border: Border.all(color: MedicineResultScreen.cyan.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🔒 Unlock Advanced Medicine Report",
            style: TextStyle(
              color: MedicineResultScreen.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Watch a short ad to unlock AI Insight, Generic Formula, Strength, Alternatives, and Doctor Recommendation.",
            style: TextStyle(
              color: Colors.white.withOpacity(.70),
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [MedicineResultScreen.cyan, MedicineResultScreen.blue],
              ),
            ),
            child: ElevatedButton(
              onPressed: showRewardedAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "🎁 Watch Ad & Unlock Report",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showRewardedAd() {
    if (_rewardedAd == null) {
      print("Rewarded ad not ready");
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        setState(() {
          isPremiumUnlocked = true;
        });
      },
    );

    _rewardedAd = null;
    loadRewardedAd();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // testing id 
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print("Rewarded Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          print(error);
        },
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _iconBox(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            "Medicine Scan Result",
            style: TextStyle(
              color: MedicineResultScreen.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        _iconBox(Icons.verified_rounded),
      ],
    );
  }

  Widget _imageCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.08),
            Colors.white.withOpacity(.025),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.file(
          widget.image,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _medicineCard(String medicineName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [MedicineResultScreen.cyan, MedicineResultScreen.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MedicineResultScreen.cyan.withOpacity(.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.18),
            ),
            child: const Icon(
              Icons.medication_liquid_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detected Medicine",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  medicineName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MedicineResultScreen.cyan, size: 28),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: MedicineResultScreen.textSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MedicineResultScreen.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MedicineResultScreen.cyan, size: 25),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: MedicineResultScreen.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.68),
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorNote(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.orange.withOpacity(.08),
        border: Border.all(color: Colors.orange.withOpacity(.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_hospital_rounded, color: Colors.orange),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              note,
              style: TextStyle(
                color: Colors.white.withOpacity(.78),
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          height: 260,
          width: 260,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
