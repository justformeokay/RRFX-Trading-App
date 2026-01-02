import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorPopupAlert {
  static void showErrorDialog({
    required String title,
    required String message,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _ErrorAlertContent(
          title: title,
          message: message,
          buttonText: buttonText,
          onPressed: onPressed,
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class _ErrorAlertContent extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const _ErrorAlertContent({
    required this.title,
    required this.message,
    required this.buttonText,
    this.onPressed,
  });

  @override
  State<_ErrorAlertContent> createState() => _ErrorAlertContentState();
}

class _ErrorAlertContentState extends State<_ErrorAlertContent>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Shake Animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0),
    ).animate(_shakeController);

    // Trigger shake animation after scale animation
    _scaleController.forward().then((_) {
      _playShakeAnimation();
    });
  }

  void _playShakeAnimation() {
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: _shakeController,
            curve: Curves.elasticInOut,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon dengan animasi rotate
                _buildAnimatedIcon(),
                const SizedBox(height: 24),
                // Card dengan error content
                _buildErrorCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400,
              Colors.red.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
            boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Action Button dengan gradient
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade500,
            Colors.red.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.back();
            widget.onPressed?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 32,
            ),
            child: Text(
              widget.buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
