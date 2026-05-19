import 'dart:ui';
import 'package:flutter/material.dart';

class CustomGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<CustomGradientButton> createState() =>
      _CustomGradientButtonState();
}

class _CustomGradientButtonState
    extends State<CustomGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),

      child: GestureDetector(
        onTapDown: (_) {
          setState(() => isPressed = true);
        },

        onTapUp: (_) {
          setState(() => isPressed = false);
        },

        onTapCancel: () {
          setState(() => isPressed = false);
        },

        onTap: widget.isLoading ? null : widget.onPressed,

        child: AnimatedBuilder(
          animation: _controller,

          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 66,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Color.lerp(
                      const Color(0xFF22C55E),
                      const Color(0xFF06B6D4),
                      _controller.value,
                    )!,

                    Color.lerp(
                      const Color(0xFF06B6D4),
                      const Color(0xFF3B82F6),
                      _controller.value,
                    )!,
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4)
                        .withOpacity(0.32),
                    blurRadius: 28,
                    spreadRadius: 1,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),

                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ),

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),

                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),

                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )

                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [
                                Text(
                                  widget.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Container(
                                  height: 34,
                                  width: 34,

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                        .withOpacity(0.18),
                                  ),

                                  child: Icon(
                                    widget.icon ??
                                        Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
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
        ),
      ),
    );
  }
}