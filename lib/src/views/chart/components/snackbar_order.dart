import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';

void showOrderProcessSnackbar({
  required String symbol,
  required String type, // Sell / Buy
  required double lot,
  required Future<void> Function() onProcess,
}) async {
  final isDone = false.obs;

  final isDark = Get.isDarkMode;

  final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white : Colors.black87;

  Get.rawSnackbar(
    snackPosition: SnackPosition.BOTTOM, // muncul dari bawah
    backgroundColor: Colors.transparent,
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
    padding: EdgeInsets.zero,
    borderRadius: 0,
    duration: const Duration(days: 1),

    messageText: Center(
      child: Obx(
        () => Container(
          width: Get.width * 0.55, // setengah layar
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: textColor.withOpacity(0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // LEFT CONTENT
              Expanded(
                child: Row(
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type,
                      style: TextStyle(
                        color: type == "SELL"
                            ? Colors.redAccent
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      lot.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // RIGHT ICON (loading → done)
              isDone.value
                  ? Icon(
                      Icons.check_circle,
                      color: CustomColor.secondaryColor,
                      size: 22,
                    )
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: CustomColor.secondaryColor),
                    ),
            ],
          ),
        ),
      ),
    ),
  );

  // Jalankan proses
  await onProcess();

  // Tampilkan "done"
  isDone.value = true;

  await Future.delayed(const Duration(milliseconds: 500));

  Get.closeAllSnackbars();
}
