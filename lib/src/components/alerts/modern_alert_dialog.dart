import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

/// Enum untuk tipe alert popup
enum AlertType {
  success,
  error,
  warning,
  info,
}

/// Modern Alert Dialog - Popup yang bagus dan kekinian
class ModernAlertDialog {
  /// Tampilkan alert dengan style modern
  static void show({
    required String message,
    String? title,
    AlertType type = AlertType.info,
    String buttonText = "OK",
    VoidCallback? onPressed,
    bool barrierDismissible = true,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    final isDark = Get.isDarkMode;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _ModernAlertContent(
          message: message,
          title: title,
          type: type,
          buttonText: buttonText,
          onPressed: onPressed,
          duration: duration,
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: isDark ? Colors.black54 : Colors.black.withOpacity(0.35),
    );
  }

  /// Alert Success
  static void success({
    required String message,
    String? title,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    show(
      message: message,
      title: title ?? "Berhasil",
      type: AlertType.success,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Alert Error
  static void error({
    required String message,
    String? title,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    show(
      message: message,
      title: title ?? "Gagal",
      type: AlertType.error,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Alert Warning
  static void warning({
    required String message,
    String? title,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    show(
      message: message,
      title: title ?? "Peringatan",
      type: AlertType.warning,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Alert Info
  static void info({
    required String message,
    String? title,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    show(
      message: message,
      title: title ?? "Informasi",
      type: AlertType.info,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }
}

class _ModernAlertContent extends StatefulWidget {
  final String message;
  final String? title;
  final AlertType type;
  final String buttonText;
  final VoidCallback? onPressed;
  final Duration duration;

  const _ModernAlertContent({
    required this.message,
    this.title,
    required this.type,
    required this.buttonText,
    this.onPressed,
    required this.duration,
  });

  @override
  State<_ModernAlertContent> createState() => _ModernAlertContentState();
}

class _ModernAlertContentState extends State<_ModernAlertContent>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case AlertType.success:
        return Colors.green.shade500;
      case AlertType.error:
        return Colors.red.shade500;
      case AlertType.warning:
        return Colors.orange.shade500;
      case AlertType.info:
        return CustomColor.secondaryColor;
    }
  }

  Color _getLightBackgroundColor() {
    switch (widget.type) {
      case AlertType.success:
        return Colors.green.shade50;
      case AlertType.error:
        return Colors.red.shade50;
      case AlertType.warning:
        return Colors.orange.shade50;
      case AlertType.info:
        return CustomColor.secondaryColor.withOpacity(0.1);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check_circle_rounded;
      case AlertType.error:
        return Icons.error_rounded;
      case AlertType.warning:
        return Icons.warning_rounded;
      case AlertType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final bgColor = _getBackgroundColor();
    final lightBgColor = _getLightBackgroundColor();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON CIRCLE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightBgColor,
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getIcon(),
                  size: 40,
                  color: bgColor,
                ),
              ),

              const SizedBox(height: 20),

              // TITLE
              if (widget.title != null)
                Text(
                  widget.title!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),

              if (widget.title != null) const SizedBox(height: 12),

              // MESSAGE
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        bgColor,
                        bgColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.onPressed?.call();
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Text(
                          widget.buttonText,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
