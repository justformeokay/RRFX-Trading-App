import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';

// --- WIDGET POPUP KONFIRMASI ---
class PopupExecution {
  static Widget buildOrderConfirmationDialog({
    required BuildContext context,
    required String symbol,
    required String type,
    required double lot,
    required Rx<double> priceObservable, // Changed to Rx<double> untuk realtime
    required int priceDigits,
    required Function onConfirm,
  }) {
    final isDarkMode = Get.theme.brightness == Brightness.dark;
    final primaryColor = type == 'BUY' ? Colors.green : Colors.red;
    final secondaryColor = CustomColor.secondaryColor;
    final dialogBackgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Track previous price untuk deteksi perubahan
    final Rx<double> previousPrice = priceObservable.value.obs;
    final Rx<String> priceDirection = ''.obs; // 'up', 'down', ''

    return Dialog(
      backgroundColor: dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tipe Order dan Ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Konfirmasi Order $type',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  type == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: primaryColor,
                  size: 24,
                ),
              ],
            ),

            const Divider(height: 25, color: Colors.white12),

            // Detail Order
            _buildDetailRow('Pasangan', symbol, textColor),
            _buildDetailRow('Lot', lot.toStringAsFixed(2), textColor),

            // Harga Realtime dengan Obx dan animasi
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Harga Eksekusi',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    // Deteksi perubahan price
                    final currentPrice = priceObservable.value;
                    if (currentPrice > previousPrice.value) {
                      priceDirection.value = 'up';
                      Future.delayed(const Duration(milliseconds: 500), () {
                        priceDirection.value = '';
                      });
                    } else if (currentPrice < previousPrice.value) {
                      priceDirection.value = 'down';
                      Future.delayed(const Duration(milliseconds: 500), () {
                        priceDirection.value = '';
                      });
                    }
                    previousPrice.value = currentPrice;

                    Color priceColor = textColor;
                    if (priceDirection.value == 'up') {
                      priceColor = Colors.green;
                    } else if (priceDirection.value == 'down') {
                      priceColor = Colors.red;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            priceDirection.value.isNotEmpty
                                ? priceColor.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          if (priceDirection.value == 'up')
                            Icon(
                              Icons.arrow_upward,
                              size: 14,
                              color: Colors.green,
                            ),
                          if (priceDirection.value == 'down')
                            Icon(
                              Icons.arrow_downward,
                              size: 14,
                              color: Colors.red,
                            ),
                          if (priceDirection.value.isNotEmpty)
                            const SizedBox(width: 4),
                          Text(
                            currentPrice.toStringAsFixed(priceDigits),
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Apakah Anda yakin ingin mengeksekusi order ini?',
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tombol Batal
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Batal', style: TextStyle(color: secondaryColor)),
                ),
                const SizedBox(width: 10),
                // Tombol Konfirmasi
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Tutup dialog
                    onConfirm(); // Lakukan eksekusi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Konfirmasi $type',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk baris detail
  static Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: valueColor.withOpacity(0.6), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
