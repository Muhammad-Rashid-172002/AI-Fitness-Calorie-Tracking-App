import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:flutter/material.dart';

class QuickAddMealScreen extends StatefulWidget {
  const QuickAddMealScreen({super.key});

  @override
  State<QuickAddMealScreen> createState() => _QuickAddMealScreenState();
}

class _QuickAddMealScreenState extends State<QuickAddMealScreen> {
  final mealNameController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  bool isSaving = false;

  static const Color bgColor = Color(0xFF0B1220);
  static const Color primary = Color(0xFF22C55E);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSub = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    for (final c in [
      mealNameController,
      caloriesController,
      proteinController,
      carbsController,
      fatController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  double get protein => double.tryParse(proteinController.text.trim()) ?? 0;
  double get carbs => double.tryParse(carbsController.text.trim()) ?? 0;
  double get fat => double.tryParse(fatController.text.trim()) ?? 0;
  double get calories => double.tryParse(caloriesController.text.trim()) ?? 0;
  double get totalMacros => protein + carbs + fat;

  Future<void> saveMeal() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showCustomSnackBar(context, "User not logged in", false);
      return;
    }

    final mealName = mealNameController.text.trim();
    final caloriesText = caloriesController.text.trim();

    if (mealName.isEmpty || caloriesText.isEmpty) {
      showCustomSnackBar(context, "Please fill meal name and calories", false);
      return;
    }

    setState(() => isSaving = true);

    try {
      final uid = user.uid;
      final today = DateTime.now();

      final todayId =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("scans")
          .add({
        "result": mealName,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fat,
        "imagePath": null,
        "type": "manual",
        "timestamp": Timestamp.now(),
      });

      final dailyRef = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("dailyLogs")
          .doc(todayId);

      await dailyRef.set({
        "totalCalories": FieldValue.increment(calories),
        "totalProtein": FieldValue.increment(protein),
        "totalCarbs": FieldValue.increment(carbs),
        "totalFat": FieldValue.increment(fat),
        "mealCount": FieldValue.increment(1),
        "createdAt": Timestamp.now(),
      }, SetOptions(merge: true));

      final updatedDoc = await dailyRef.get();

      final consumedCalories =
          (updatedDoc.data()?["totalCalories"] ?? 0).toDouble();

      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      final targetCalories =
          (userDoc.data()?["dailyCalories"] ?? 2000).toDouble();

      final deficit = targetCalories - consumedCalories;
      final weightChange = deficit / 7700;

      await dailyRef.set({
        "deficit": deficit,
        "weightChange": weightChange,
      }, SetOptions(merge: true));

      final msg = weightChange < 0
          ? "🔥 Losing ${weightChange.abs().toStringAsFixed(2)} kg today\nDeficit: ${deficit.toStringAsFixed(0)} kcal"
          : "⚠️ Gaining ${weightChange.toStringAsFixed(2)} kg today\nExtra: ${deficit.abs().toStringAsFixed(0)} kcal";

      if (!mounted) return;
      showCustomSnackBar(context, msg, true);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, "Error saving meal", false);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    mealNameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _appBar(),
                  const SizedBox(height: 24),
                  _heroCard(),
                  const SizedBox(height: 22),
                  _mealFormCard(),
                  const SizedBox(height: 22),
                  _macroPreview(),
                  const SizedBox(height: 24),
                  _saveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _iconBox(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Add Meal",
                style: TextStyle(
                  color: textMain,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Manual calories & macros entry",
                style: TextStyle(
                  color: textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _premiumBadge(),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF22C55E),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cyan.withOpacity(0.30),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -45,
            child: _softCircle(Colors.white.withOpacity(0.14), 155),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Add nutrition manually",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Perfect when you already know your meal calories, protein, carbs and fats.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mealFormCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            icon: Icons.edit_note_rounded,
            title: "Meal Details",
            subtitle: "Fill required fields to save your meal",
          ),
          const SizedBox(height: 18),
          _inputField(
            label: "Meal Name",
            hint: "Example: Chicken rice",
            controller: mealNameController,
            icon: Icons.fastfood_rounded,
            color: primary,
          ),
          const SizedBox(height: 14),
          _inputField(
            label: "Calories",
            hint: "Example: 450",
            controller: caloriesController,
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFF97316),
            suffix: "kcal",
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  label: "Protein",
                  hint: "35",
                  controller: proteinController,
                  icon: Icons.fitness_center_rounded,
                  color: cyan,
                  suffix: "g",
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  label: "Carbs",
                  hint: "50",
                  controller: carbsController,
                  icon: Icons.rice_bowl_rounded,
                  color: const Color(0xFFF59E0B),
                  suffix: "g",
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _inputField(
            label: "Fat",
            hint: "Example: 12",
            controller: fatController,
            icon: Icons.opacity_rounded,
            color: const Color(0xFFEF4444),
            suffix: "g",
          ),
        ],
      ),
    );
  }

  Widget _macroPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.pie_chart_rounded,
          title: "Live Macro Preview",
          subtitle: totalMacros == 0
              ? "Enter macros to preview breakdown"
              : "Total macros: ${totalMacros.toStringAsFixed(0)}g",
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _macroCard(
              title: "Calories",
              value: calories.toStringAsFixed(0),
              unit: "kcal",
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(width: 12),
            _macroCard(
              title: "Protein",
              value: protein.toStringAsFixed(0),
              unit: "g",
              icon: Icons.fitness_center_rounded,
              color: cyan,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _macroCard(
              title: "Carbs",
              value: carbs.toStringAsFixed(0),
              unit: "g",
              icon: Icons.rice_bowl_rounded,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 12),
            _macroCard(
              title: "Fat",
              value: fat.toStringAsFixed(0),
              unit: "g",
              icon: Icons.opacity_rounded,
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
      ],
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: isSaving ? null : saveMeal,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isSaving
                ? [Colors.grey.shade700, Colors.grey.shade800]
                : const [primary, cyan],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.6,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Save Meal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    String? suffix,
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.075)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: suffix == null ? TextInputType.text : TextInputType.number,
        style: const TextStyle(
          color: textMain,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color, size: compact ? 20 : 22),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.w800,
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: 13,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.30),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 14,
          ),
        ),
      ),
    );
  }

  Widget _macroCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.075)),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$value $unit",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: primary.withOpacity(0.12),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSub,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _premiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: const Text(
        "Manual",
        style: TextStyle(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _backgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -95,
          right: -80,
          child: _blurCircle(primary.withOpacity(0.18), 260),
        ),
        Positioned(
          top: 310,
          left: -120,
          child: _blurCircle(cyan.withOpacity(0.13), 280),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _blurCircle(const Color(0xFF6366F1).withOpacity(0.12), 260),
        ),
      ],
    );
  }

  Widget _blurCircle(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
      child: _softCircle(color, size),
    );
  }

  Widget _softCircle(Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}