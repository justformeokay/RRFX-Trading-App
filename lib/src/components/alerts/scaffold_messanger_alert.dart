import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

// Enum untuk tipe SnackBar, memudahkan kustomisasi
enum SnackBarType {
  success,
  error,
  info,
  warning,
}

class CustomScaffoldMessanger {
  static void showAppSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    Color backgroundColor;
    Color textColor = Colors.black;

    switch (type) {
      case SnackBarType.success:
        textColor = Colors.white;
        backgroundColor = Colors.green;
        break;
      case SnackBarType.error:
        textColor = Colors.white;
        backgroundColor = Colors.red;
        break;
      case SnackBarType.info:
        backgroundColor = CustomColor.secondaryColor;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent, // biar transparan, isi kita custom
      margin: const EdgeInsets.all(10),
      content: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
        duration: const Duration(seconds: 1),
        curve: Curves.elasticOut, // efek bouncing halus
        builder: (context, offset, child) {
          return Transform.translate(
            offset: offset * 50, // geser dari bawah
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class AppSnackbar {
  static void success(String message, {String title = "Success"}) {
    _show(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      color: Colors.greenAccent.shade400,
    );
  }

  static void error(String message, {String title = "Gagal"}) {
    _show(
      title: title,
      message: message,
      icon: Icons.error_rounded,
      color: Colors.redAccent.shade400,
    );
  }

  static void info(String message, {String title = "Info"}) {
    _show(
      title: title,
      message: message,
      icon: Icons.info_rounded,
      color: Colors.blueAccent.shade400,
    );
  }

  // ===========================================================
  // INTERNAL SNACKBAR BUILDER
  // ===========================================================
  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Get.isDarkMode;

    Get.snackbar(
      "",
      "",
      titleText: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.4,
          color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
        ),
      ),

      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),

      snackPosition: SnackPosition.TOP,
      borderRadius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      boxShadows: [
        BoxShadow(
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
          color: isDark
              ? Colors.black.withOpacity(0.5)
              : Colors.black.withOpacity(0.08),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 360),
      overlayBlur: 0,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutExpo,
      reverseAnimationCurve: Curves.easeInExpo,
    );
  }
}
