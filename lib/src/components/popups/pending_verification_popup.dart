import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class PendingVerificationPopup extends StatelessWidget {
  final String? title;
  final String? message;
  final String? submittedDate;
  final VoidCallback? onContactSupport;

  const PendingVerificationPopup({
    super.key,
    this.title,
    this.message,
    this.submittedDate,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Animated Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse animation background
                        _PulseAnimation(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Icon
                        Icon(
                          Iconsax.clock_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title ?? 'Verification Pending',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Message
                  Text(
                    message ??
                        'Your account is currently under review by our admin team. This process usually takes 1-2 business days.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Cards
                  _buildInfoCard(
                    context: context,
                    isDark: isDark,
                    icon: Iconsax.document_text_outline,
                    title: 'Document Submitted',
                    value: submittedDate ?? 'Recently',
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context: context,
                    isDark: isDark,
                    icon: Iconsax.timer_1_outline,
                    title: 'Estimated Time',
                    value: '1-2 Business Days',
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.2),
                  ),

                  const SizedBox(height: 24),

                  // What happens next
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: CustomColor.secondaryColor.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Iconsax.info_circle_outline,
                              size: 16,
                              color: CustomColor.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'What happens next?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStep(
                        context: context,
                        isDark: isDark,
                        number: '1',
                        text: 'Admin reviews your documents',
                        isCompleted: false,
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        context: context,
                        isDark: isDark,
                        number: '2',
                        text: 'You\'ll receive email notification',
                        isCompleted: false,
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        context: context,
                        isDark: isDark,
                        number: '3',
                        text: 'Full access to all features',
                        isCompleted: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      // Contact Support Button
                      if (onContactSupport != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onContactSupport,
                            icon: Icon(Iconsax.message_outline, size: 18),
                            label: Text(
                              'Contact',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CustomColor.secondaryColor,
                              side: BorderSide(
                                color: CustomColor.secondaryColor,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (onContactSupport != null) const SizedBox(width: 12),
                      // OK Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: Icon(Iconsax.tick_circle_bold, size: 18),
                          label: Text(
                            'Got it',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColor.secondaryColor,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required bool isDark,
    required String number,
    required String text,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? CustomColor.secondaryColor
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isCompleted
                      ? CustomColor.secondaryColor
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: 2,
            ),
          ),
          child: Center(
            child:
                isCompleted
                    ? Icon(Icons.check, size: 16, color: Colors.black)
                    : Text(
                      number,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

// Helper function to show the popup
void showPendingVerificationPopup({
  String? title,
  String? message,
  String? submittedDate,
  VoidCallback? onContactSupport,
}) {
  Get.dialog(
    PendingVerificationPopup(
      title: title,
      message: message,
      submittedDate: submittedDate,
      onContactSupport: onContactSupport,
    ),
    barrierDismissible: false,
  );
}

// Pulse Animation Widget
class _PulseAnimation extends StatefulWidget {
  final Widget child;

  const _PulseAnimation({required this.child});

  @override
  State<_PulseAnimation> createState() => __PulseAnimationState();
}

class __PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}
