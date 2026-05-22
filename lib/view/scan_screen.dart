import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/view/analyzing_screen.dart';
import 'package:fitmind_ai/view/quick_add_meal_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScanController controller = ScanController();
  File? selectedImage;

  static const Color bgColor = Color(0xFF0B1220);
  static const Color surfaceColor = Color(0xFF111C2E);
  static const Color primary = Color(0xFF22C55E);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSub = Color(0xFF94A3B8);

  Future<void> _takePhoto() async {
    final image = await controller.pickFromCamera();
    if (image != null) _handleImage(image);
  }

  Future<void> _pickGallery() async {
    final image = await controller.pickFromGallery();
    if (image != null) _handleImage(image);
  }

  void _handleImage(File image) {
    setState(() => selectedImage = image);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          image: image,
          analyzeFuture: controller.analyzeFoodImage(image),
        ),
      ),
    );
  }

  void _openQuickAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuickAddMealScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _backgroundGlow(),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _topBar(),
                        const SizedBox(height: 24),
                        _premiumHeroCard(),
                        const SizedBox(height: 18),
                        _mainScannerCard(),
                        const SizedBox(height: 18),
                        _quickActions(),
                        const SizedBox(height: 24),
                        _sectionTitle("AI Nutrition Tools"),
                        const SizedBox(height: 14),
                        _featureGrid(),
                        const SizedBox(height: 24),
                        _dietTipCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -80,
          child: _blurCircle(primary.withOpacity(0.20), 260),
        ),
        Positioned(
          top: 260,
          left: -120,
          child: _blurCircle(cyan.withOpacity(0.14), 280),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: _blurCircle(const Color(0xFF6366F1).withOpacity(0.12), 250),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [primary, cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.30),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.document_scanner_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Food Scanner",
                style: TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "AI powered calories & macro analysis",
                style: TextStyle(
                  color: textSub,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _circleIcon(Icons.history_rounded),
      ],
    );
  }

  Widget _premiumHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.09),
            Colors.white.withOpacity(0.035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Scan smarter, eat better",
                  style: TextStyle(
                    color: textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Take a meal photo and get instant calories, protein, carbs and fats.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainScannerCard() {
    return GestureDetector(
      onTap: _takePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 330,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          color: surfaceColor,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            children: [
              if (selectedImage != null)
                Image.file(
                  selectedImage!,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

              if (selectedImage == null) _scannerEmptyContent(),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(selectedImage == null ? 0.05 : 0.55),
                        Colors.transparent,
                        Colors.black.withOpacity(selectedImage == null ? 0.10 : 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 18,
                left: 18,
                child: _glassBadge(
                  icon: Icons.bolt_rounded,
                  text: "Instant AI Scan",
                ),
              ),

              Positioned(
                bottom: 18,
                left: 18,
                right: 18,
                child: selectedImage == null
                    ? _scanButton()
                    : _selectedImageBottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scannerEmptyContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF13233A),
            Color(0xFF0F172A),
            Color(0xFF102A33),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 112,
              width: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.95),
                    cyan.withOpacity(0.95),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: cyan.withOpacity(0.30),
                    blurRadius: 35,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              "Scan Your Meal",
              style: TextStyle(
                color: textMain,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Point your camera at food\nand get nutrition details instantly",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [primary, cyan],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_rounded, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Open Camera",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedImageBottomBar() {
    return Row(
      children: [
        Expanded(
          child: _glassBadge(
            icon: Icons.check_circle_rounded,
            text: "Image selected",
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Center(
              child: Text(
                "Retake",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionTile(
            icon: Icons.photo_library_rounded,
            title: "Gallery",
            subtitle: "Upload food photo",
            colors: const [Color(0xFF38BDF8), Color(0xFF2563EB)],
            onTap: _pickGallery,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _actionTile(
            icon: Icons.edit_note_rounded,
            title: "Quick Add",
            subtitle: "Add meal manually",
            colors: const [Color(0xFFF97316), Color(0xFFEF4444)],
            onTap: _openQuickAdd,
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.055),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: colors),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textSub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _miniFeature(
                Icons.local_fire_department_rounded,
                "Calories",
                "Smart estimate",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniFeature(
                Icons.pie_chart_rounded,
                "Macros",
                "Protein, carbs, fat",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _miniFeature(
                Icons.insights_rounded,
                "Insights",
                "Diet suggestions",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniFeature(
                Icons.trending_up_rounded,
                "Progress",
                "Daily tracking",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniFeature(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.12),
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textMain,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textSub,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dietTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.16),
            cyan.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: primary, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Tip: Use clear lighting and keep the full plate inside the camera frame for better AI results.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textMain,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _glassBadge({
    required IconData icon,
    required String text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: primary, size: 19),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 22),
    );
  }

  Widget _blurCircle(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}