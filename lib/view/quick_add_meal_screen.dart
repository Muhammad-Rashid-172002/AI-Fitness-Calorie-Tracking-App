import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/components/showCustomSnackBar.dart';
import 'package:fitmind_ai/resources/custom_gradient_button.dart';
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

  @override
  void initState() {
    super.initState();

    proteinController.addListener(() => setState(() {}));
    carbsController.addListener(() => setState(() {}));
    fatController.addListener(() => setState(() {}));
  }

  Future<void> saveMeal() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showCustomSnackBar(context, "User not logged in", false);
      return;
    }

    final mealName = mealNameController.text.trim();
    final caloriesText = caloriesController.text.trim();
    final proteinText = proteinController.text.trim();
    final carbsText = carbsController.text.trim();
    final fatText = fatController.text.trim();

    if (mealName.isEmpty || caloriesText.isEmpty) {
      showCustomSnackBar(context, "Please fill required fields", false);
      return;
    }

    final calories = double.tryParse(caloriesText) ?? 0;
    final protein = double.tryParse(proteinText) ?? 0;
    final carbs = double.tryParse(carbsText) ?? 0;
    final fat = double.tryParse(fatText) ?? 0;

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

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final targetCalories =
          (userDoc.data()?["dailyCalories"] ?? 2000).toDouble();

      final deficit = targetCalories - consumedCalories;
      final weightChange = deficit / 7700;

      await dailyRef.set({
        "deficit": deficit,
        "weightChange": weightChange,
      }, SetOptions(merge: true));

      String msg;

      if (weightChange < 0) {
        msg =
            "🔥 Losing ${weightChange.abs().toStringAsFixed(2)} kg today\nDeficit: ${deficit.toStringAsFixed(0)} kcal";
      } else {
        msg =
            "⚠️ Gaining ${weightChange.toStringAsFixed(2)} kg today\nExtra: ${deficit.abs().toStringAsFixed(0)} kcal";
      }

      if (!mounted) return;

      showCustomSnackBar(context, msg, true);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, "Error saving meal", false);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
    final totalMacros =
        (double.tryParse(proteinController.text) ?? 0) +
        (double.tryParse(carbsController.text) ?? 0) +
        (double.tryParse(fatController.text) ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glowCircle(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              size: 260,
            ),
          ),

          Positioned(
            bottom: -140,
            left: -90,
            child: _glowCircle(
              color: const Color(0xFF06B6D4).withOpacity(0.10),
              size: 280,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _iconBox(Icons.arrow_back_ios_new_rounded),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.28),
                          ),
                        ),
                        child: const Text(
                          "Manual Entry",
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  _heroCard(),

                  const SizedBox(height: 24),

                  _sectionTitle(
                    title: "Meal Details",
                    subtitle: "Add your calories and macros manually",
                  ),

                  const SizedBox(height: 14),

                  _glassCard(
                    child: Column(
                      children: [
                        _buildField(
                          label: "Meal Name",
                          hint: "Example: Chicken Rice",
                          controller: mealNameController,
                          icon: Icons.restaurant_menu_rounded,
                          color: const Color(0xFF22C55E),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Calories",
                          hint: "Example: 450",
                          controller: caloriesController,
                          keyboard: TextInputType.number,
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF97316),
                          suffix: "kcal",
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Protein",
                          hint: "Example: 35",
                          controller: proteinController,
                          keyboard: TextInputType.number,
                          icon: Icons.fitness_center_rounded,
                          color: const Color(0xFF06B6D4),
                          suffix: "g",
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Carbs",
                          hint: "Example: 50",
                          controller: carbsController,
                          keyboard: TextInputType.number,
                          icon: Icons.rice_bowl_rounded,
                          color: const Color(0xFFF59E0B),
                          suffix: "g",
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Fat",
                          hint: "Example: 12",
                          controller: fatController,
                          keyboard: TextInputType.number,
                          icon: Icons.opacity_rounded,
                          color: const Color(0xFFEF4444),
                          suffix: "g",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle(
                    title: "Macro Preview",
                    subtitle: totalMacros == 0
                        ? "Enter macros to preview meal breakdown"
                        : "Total entered macros: ${totalMacros.toStringAsFixed(0)}g",
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _macroCard(
                        title: "Protein",
                        value: proteinController.text,
                        icon: Icons.fitness_center_rounded,
                        color: const Color(0xFF06B6D4),
                      ),
                      const SizedBox(width: 12),
                      _macroCard(
                        title: "Carbs",
                        value: carbsController.text,
                        icon: Icons.rice_bowl_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 12),
                      _macroCard(
                        title: "Fat",
                        value: fatController.text,
                        icon: Icons.opacity_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: isSaving
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF22C55E),
                                  Color(0xFF06B6D4),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : CustomGradientButton(
                            text: "Save Meal",
                            onPressed: saveMeal,
                          ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
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
            color: const Color(0xFF06B6D4).withOpacity(0.32),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            right: -45,
            child: _glowCircle(
              color: Colors.white.withOpacity(0.14),
              size: 150,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 66,
                width: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Quick Add Meal",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Manually add your meal nutrition when you already know calories and macros.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 12,
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
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    String? suffix,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.bold,
          ),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.32)),
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
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value.isEmpty ? "0g" : "$value g",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                fontSize: 11,
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
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