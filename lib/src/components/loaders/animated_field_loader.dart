import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rrfx/src/components/colors/default.dart';

/// Animated field loader widget with dual-ring spinner and shimmer text
/// Used as overlay on form fields during async operations
class AnimatedFieldLoader extends StatelessWidget {
  final String loadingText;
  final bool isDark;
  final Color? spinnerColor;
  final Color? textColor;

  const AnimatedFieldLoader({
    super.key,
    this.loadingText = 'Mengambil Data...',
    required this.isDark,
    this.spinnerColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = spinnerColor ?? CustomColor.secondaryColor;
    final secondaryColor = textColor ?? CustomColor.secondaryColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.85),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Spinner with dual rings
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  // Outer rotating ring
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.linear,
                    onEnd: () {},
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 3.14159 * 2,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Inner rotating dot
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.linear,
                    onEnd: () {},
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 3.14159 * 2,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Loading text with shimmer effect
            Shimmer.fromColors(
              baseColor: secondaryColor.withOpacity(0.3),
              highlightColor: secondaryColor.withOpacity(0.8),
              period: const Duration(milliseconds: 1500),
              child: Text(
                loadingText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
