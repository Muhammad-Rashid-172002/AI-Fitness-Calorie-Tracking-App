import 'dart:io';
import 'dart:ui';

import 'package:fitmind_ai/view/food_medicine/FaceAnalyzingScreen.dart';
import 'package:fitmind_ai/view/food_medicine/MedicineAnalyzingScreen.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai/controller/scan_controller.dart';
import 'package:fitmind_ai/view/analyzing_screen.dart';
import 'package:fitmind_ai/view/quick_add_meal_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum ScanMode { food, face, medicine }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScanController controller = ScanController();

  File? selectedImage;
  ScanMode selectedMode = ScanMode.food;

  static const Color bgColor = Color(0xFF0B1220);
  static const Color surfaceColor = Color(0xFF111C2E);
  static const Color primary = Color(0xFF22C55E);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color blue = Color(0xFF2563EB);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSub = Color(0xFF94A3B8);

  String get modeTitle {
    switch (selectedMode) {
      case ScanMode.food:
        return "Scan Your Meal";
      case ScanMode.face:
        return "Scan Your Face";
      case ScanMode.medicine:
        return "Scan Medicine";
    }
  }

  String get modeSubtitle {
    switch (selectedMode) {
      case ScanMode.food:
        return "Point your camera at food\nand get calories & macros instantly";
      case ScanMode.face:
        return "Take a clear face photo\nand get AI skin insights";
      case ScanMode.medicine:
        return "Scan medicine label or tablet\nand get helpful AI information";
    }
  }

  IconData get modeIcon {
    switch (selectedMode) {
      case ScanMode.food:
        return Icons.restaurant_rounded;
      case ScanMode.face:
        return Icons.face_retouching_natural_rounded;
      case ScanMode.medicine:
        return Icons.medication_liquid_rounded;
    }
  }

  List<Color> get modeColors {
    switch (selectedMode) {
      case ScanMode.food:
        return const [primary, cyan];
      case ScanMode.face:
        return const [purple, pink];
      case ScanMode.medicine:
        return const [cyan, blue];
    }
  }

  Future<void> _takePhoto() async {
    final image = await controller.pickFromCamera();
    if (image != null) _handleImage(image);
  }

  Future<void> _pickGallery() async {
    final image = await controller.pickFromGallery();
    if (image != null) _handleImage(image);
  }

  void _handleImage(File image) {
    _showAdAfterEvery3Scans();
    setState(() => selectedImage = image);

    if (selectedMode == ScanMode.food) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyzingScreen(
            image: image,
            analyzeFuture: controller.analyzeFoodImage(image),
          ),
        ),
      );
    } else if (selectedMode == ScanMode.face) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FaceAnalyzingScreen(
            image: image,
            analyzeFuture: controller.analyzeFaceImage(image),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineAnalyzingScreen(
            image: image,
            analyzeFuture: controller.analyzeMedicineImage(image),
          ),
        ),
      );
    }
  }

  void _openQuickAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuickAddMealScreen()),
    );
  }

  // ads
  InterstitialAd? _interstitialAd;
  int scanCount = 0;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial failed: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showAdAfterEvery3Scans() {
    scanCount++;
    print("Scan Count: $scanCount");

    if (scanCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();

      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = modeColors;

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
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _topBar(),
                      const SizedBox(height: 22),
                      _heroCard(colors),
                      const SizedBox(height: 18),
                      _scanModeSelector(),
                      const SizedBox(height: 18),
                      _mainScannerCard(colors),
                      const SizedBox(height: 18),
                      _quickActions(),
                      const SizedBox(height: 24),
                      _sectionTitle("Smart AI Tools"),
                      const SizedBox(height: 14),
                      _featureGrid(),
                      const SizedBox(height: 24),
                      _tipCard(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            gradient: LinearGradient(
              colors: modeColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: modeColors.first.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(modeIcon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AI Scanner",
                style: TextStyle(
                  color: textMain,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                selectedMode == ScanMode.food
                    ? "Calories, macros & nutrition insights"
                    : selectedMode == ScanMode.face
                    ? "Face scan & AI skin insights"
                    : "Medicine scan & AI safety information",
                style: const TextStyle(
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

  Widget _heroCard(List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colors.first.withOpacity(0.22),
            colors.last.withOpacity(0.10),
            Colors.white.withOpacity(0.035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.09),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: colors.first,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedMode == ScanMode.food
                      ? "Scan smarter, eat better"
                      : selectedMode == ScanMode.face
                      ? "Understand your skin better"
                      : "Know your medicine faster",
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedMode == ScanMode.food
                      ? "Take a meal photo and get instant calories, protein, carbs and fats."
                      : selectedMode == ScanMode.face
                      ? "Scan your face and get basic AI skin insights with care suggestions."
                      : "Scan medicine packaging or label and get easy-to-read AI information.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 13,
                    height: 1.35,
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

  Widget _scanModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _scanModeCard(
            mode: ScanMode.food,
            icon: Icons.restaurant_rounded,
            title: "Food",
            subtitle: "Nutrition",
            colors: const [primary, cyan],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _scanModeCard(
            mode: ScanMode.face,
            icon: Icons.face_retouching_natural_rounded,
            title: "Face",
            subtitle: "Skin AI",
            colors: const [purple, pink],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _scanModeCard(
            mode: ScanMode.medicine,
            icon: Icons.medication_liquid_rounded,
            title: "Medicine",
            subtitle: "AI Info",
            colors: const [cyan, blue],
          ),
        ),
      ],
    );
  }

  Widget _scanModeCard({
    required ScanMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
  }) {
    final bool isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = mode;
          selectedImage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.065),
                    Colors.white.withOpacity(0.025),
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.26)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withOpacity(0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.18)
                    : colors.first.withOpacity(0.12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : colors.first,
                size: 25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : textMain,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.82) : textSub,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainScannerCard(List<Color> colors) {
    return GestureDetector(
      onTap: _takePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 360,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: surfaceColor,
          border: Border.all(color: Colors.white.withOpacity(0.09)),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.18),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            children: [
              if (selectedImage != null)
                Image.file(
                  selectedImage!,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

              if (selectedImage == null) _scannerEmptyContent(colors),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(
                          selectedImage == null ? 0.06 : 0.58,
                        ),
                        Colors.transparent,
                        Colors.black.withOpacity(
                          selectedImage == null ? 0.10 : 0.78,
                        ),
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
                  text: selectedMode == ScanMode.food
                      ? "Food AI Scan"
                      : selectedMode == ScanMode.face
                      ? "Face AI Scan"
                      : "Medicine AI Scan",
                ),
              ),

              Positioned(
                top: 18,
                right: 18,
                child: _glassBadge(
                  icon: Icons.verified_rounded,
                  text: "Smart Mode",
                ),
              ),

              Positioned(
                bottom: 18,
                left: 18,
                right: 18,
                child: selectedImage == null
                    ? _scanButton(colors)
                    : _selectedImageBottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scannerEmptyContent(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.first.withOpacity(0.22),
            const Color(0xFF0F172A),
            colors.last.withOpacity(0.17),
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
              height: 118,
              width: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.35),
                    blurRadius: 38,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Icon(
                selectedMode == ScanMode.food
                    ? Icons.camera_alt_rounded
                    : selectedMode == ScanMode.face
                    ? Icons.face_retouching_natural_rounded
                    : Icons.medication_liquid_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              modeTitle,
              style: const TextStyle(
                color: textMain,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              modeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.66),
                fontSize: 14,
                height: 1.42,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanButton(List<Color> colors) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 11),
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
              fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w800,
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
            subtitle: "Upload image",
            colors: const [Color(0xFF38BDF8), Color(0xFF2563EB)],
            onTap: _pickGallery,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _actionTile(
            icon: Icons.edit_note_rounded,
            title: "Quick Add",
            subtitle: "Manual meal",
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
        borderRadius: BorderRadius.circular(27),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.055),
              borderRadius: BorderRadius.circular(27),
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
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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
    final items = selectedMode == ScanMode.food
        ? [
            [Icons.local_fire_department_rounded, "Calories", "Smart estimate"],
            [Icons.pie_chart_rounded, "Macros", "Protein, carbs, fat"],
            [Icons.insights_rounded, "Insights", "Diet suggestions"],
            [Icons.trending_up_rounded, "Progress", "Daily tracking"],
          ]
        : selectedMode == ScanMode.face
        ? [
            [Icons.face_rounded, "Face Scan", "AI skin insights"],
            [Icons.health_and_safety_rounded, "Care Tips", "Basic advice"],
            [Icons.warning_amber_rounded, "Alerts", "Helpful warnings"],
            [Icons.auto_awesome_rounded, "Report", "AI summary"],
          ]
        : [
            [Icons.medication_rounded, "Medicine", "Label scan"],
            [Icons.info_rounded, "Details", "Usage info"],
            [Icons.warning_rounded, "Caution", "Safety notes"],
            [Icons.description_rounded, "Report", "AI summary"],
          ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _miniFeature(
                items[0][0] as IconData,
                items[0][1] as String,
                items[0][2] as String,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniFeature(
                items[1][0] as IconData,
                items[1][1] as String,
                items[1][2] as String,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _miniFeature(
                items[2][0] as IconData,
                items[2][1] as String,
                items[2][2] as String,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniFeature(
                items[3][0] as IconData,
                items[3][1] as String,
                items[3][2] as String,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniFeature(IconData icon, String title, String subtitle) {
    final colors = modeColors;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.first.withOpacity(0.13),
            ),
            child: Icon(icon, color: colors.first, size: 22),
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
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: textSub, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard() {
    final colors = modeColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: LinearGradient(
          colors: [
            colors.first.withOpacity(0.17),
            colors.last.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.first.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: colors.first, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              selectedMode == ScanMode.food
                  ? "Tip: Use clear lighting and keep the full plate inside the camera frame for better AI results."
                  : selectedMode == ScanMode.face
                  ? "Tip: Take the photo in natural light and avoid filters for better face scan results."
                  : "Tip: Scan the medicine box or label clearly. Always confirm details with a doctor or pharmacist.",
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

  Widget _glassBadge({required IconData icon, required String text}) {
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
              Icon(icon, color: modeColors.first, size: 19),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
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
          child: _blurCircle(purple.withOpacity(0.13), 250),
        ),
      ],
    );
  }

  Widget _blurCircle(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
