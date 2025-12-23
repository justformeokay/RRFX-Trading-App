import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';

/// Widget untuk menampilkan Network Speed Status di halaman
/// Gunakan di halaman transaksi atau tempat penting lainnya
class NetworkSpeedIndicator extends GetView<NetworkController> {
  final bool showDetailedInfo;
  
  const NetworkSpeedIndicator({
    super.key,
    this.showDetailedInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final speed = controller.networkSpeed.value;
      final isDark = themeController.isDark.value;
      
      if (speed == 0) {
        return const SizedBox.shrink();
      }

      // Determine status berdasarkan speed
      final isGood = speed <= 50;
      final isWarning = speed > 50 && speed <= 100;

      Color statusColor = isGood ? Colors.green : (isWarning ? Colors.amber : Colors.red);
      String statusText = isGood ? 'Optimal' : (isWarning ? 'Normal' : 'Lambat');
      IconData statusIcon = isGood ? Icons.check_circle : (isWarning ? Icons.warning : Icons.error);

      if (!showDetailedInfo) {
        // Compact view
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 6),
              Text(
                '${speed}ms',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        );
      }

      // Detailed view
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kecepatan Jaringan',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? CustomColor.textThemeDarkSoftColor
                        : CustomColor.textThemeLightSoftColor,
                  ),
                ),
                Row(
                  children: [
                    Icon(statusIcon, size: 18, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (speed / 200).clamp(0, 1),
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${speed}ms latency',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? CustomColor.textThemeDarkColor
                        : CustomColor.textThemeLightColor,
                  ),
                ),
                GestureDetector(
                  onTap: controller.checkNetworkSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColor.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Cek Ulang',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Extension untuk easy access di Scaffold
extension NetworkSpeedExtension on BuildContext {
  /// Trigger network speed check dengan optional callback
  Future<void> checkNetworkSpeed({
    VoidCallback? onComplete,
    Function(int)? onSpeedMeasured,
  }) async {
    final controller = Get.find<NetworkController>();
    await controller.checkNetworkSpeed();
    
    final speed = controller.networkSpeed.value;
    if (speed > 0) {
      onSpeedMeasured?.call(speed);
    }
    
    onComplete?.call();
  }

  /// Get current network speed
  int getNetworkSpeed() {
    final controller = Get.find<NetworkController>();
    return controller.networkSpeed.value;
  }

  /// Check if network is good (speed <= 100ms)
  bool isNetworkGood() {
    final controller = Get.find<NetworkController>();
    return controller.networkSpeed.value > 0 && controller.networkSpeed.value <= 100;
  }
}
