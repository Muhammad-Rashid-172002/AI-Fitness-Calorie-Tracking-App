import 'dart:ui';
import 'package:flutter/material.dart';

/// ===============================
/// PREMIUM SNACKBAR
/// ===============================
void showCustomSnackBar(
  BuildContext context,
  String message,
  bool isSuccess,
) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final Color primaryColor = isSuccess
      ? const Color(0xFF22C55E)
      : const Color(0xFFEF4444);

  final Color secondaryColor = isSuccess
      ? const Color(0xFF06B6D4)
      : const Color(0xFFF97316);

  final IconData icon = isSuccess
      ? Icons.check_circle_rounded
      : Icons.error_rounded;

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 14,
    ),

    content: ClipRRect(
      borderRadius: BorderRadius.circular(26),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.95),
                secondaryColor.withOpacity(0.90),
              ],
            ),

            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),

            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),

          child: Row(
            children: [
              /// ICON
              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),

                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              /// MESSAGE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSuccess ? "Success" : "Oops!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// ===============================
/// PREMIUM DIALOG
/// ===============================
void showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required bool isSuccess,
}) {
  final Color primaryColor = isSuccess
      ? const Color(0xFF22C55E)
      : const Color(0xFFEF4444);

  final Color secondaryColor = isSuccess
      ? const Color(0xFF06B6D4)
      : const Color(0xFFF97316);

  final IconData icon = isSuccess
      ? Icons.check_circle_rounded
      : Icons.warning_amber_rounded;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "dialog",
    barrierColor: Colors.black.withOpacity(0.7),

    transitionDuration: const Duration(milliseconds: 350),

    pageBuilder: (_, __, ___) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),

            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 18,
                sigmaY: 18,
              ),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(26),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),

                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F172A).withOpacity(0.96),
                      const Color(0xFF111827).withOpacity(0.96),
                    ],
                  ),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.20),
                      blurRadius: 35,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ICON
                    Container(
                      height: 82,
                      width: 82,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            secondaryColor,
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// TITLE
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// MESSAGE
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// BUTTON
                    GestureDetector(
                      onTap: () => Navigator.pop(context),

                      child: Container(
                        height: 58,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),

                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              secondaryColor,
                            ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: const Center(
                          child: Text(
                            "Got it",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },

    transitionBuilder: (_, animation, __, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(animation.value),
        child: Opacity(
          opacity: animation.value,
          child: child,
        ),
      );
    },
  );
}