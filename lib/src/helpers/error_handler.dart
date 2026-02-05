import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class ErrorHandler {
  /// Tipe error untuk mapping ke pesan user-friendly
  static const Map<String, String> errorMessages = {
    'SocketException': 'Koneksi internet tidak stabil. Silakan periksa koneksi Anda dan coba lagi.',
    'No address associated with hostname': 'Tidak dapat terhubung ke server. Silakan coba lagi nanti.',
    'Failed host lookup': 'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda.',
    'Connection refused': 'Server sedang tidak tersedia. Silakan coba lagi nanti.',
    'Connection timed out': 'Koneksi memakan waktu terlalu lama. Silakan coba lagi.',
    'TimeoutException': 'Permintaan memakan waktu terlalu lama. Silakan coba lagi.',
  };

  /// Mengekstrak pesan error yang user-friendly dari exception
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Cek setiap error message yang dikenal
    for (var entry in errorMessages.entries) {
      if (errorString.contains(entry.key)) {
        return entry.value;
      }
    }

    // Jika error adalah string yang pendek, tampilkan sesuai kondisi
    if (errorString.contains('Exception')) {
      return 'Terjadi kesalahan saat memproses permintaan. Silakan coba lagi.';
    }

    // Default error message
    return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
  }

  /// Menampilkan error dialog yang modern dan user-friendly
  static Future<void> showErrorDialog(
    dynamic error, {
    String title = 'Oops, Terjadi Kesalahan!',
    String? customMessage,
    String buttonText = 'OK',
    VoidCallback? onRetry,
  }) async {
    final message = customMessage ?? getErrorMessage(error);

    return Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.all(16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.inter(
                  color: CustomColor.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              buttonText,
              style: GoogleFonts.inter(
                color: CustomColor.secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
      barrierDismissible: false,
    );
  }

  /// Menampilkan error snackbar yang elegan
  static void showErrorSnackbar(
    dynamic error, {
    String? customMessage,
  }) {
    final message = customMessage ?? getErrorMessage(error);

    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Terjadi Kesalahan',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
      backgroundColor: Colors.red.shade600,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  /// Untuk konteks UI yang lebih sederhana - hanya tunjukkan pesan
  static Future<void> showSimpleErrorDialog(String message) async {
    return Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Pemberitahuan',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Mengerti',
              style: GoogleFonts.inter(
                color: CustomColor.secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
