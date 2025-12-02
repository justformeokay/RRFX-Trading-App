import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart'; // Asumsi CustomColor di sini

// --- WIDGET POPUP KONFIRMASI ---
class PopupExecution {
  static Widget buildOrderConfirmationDialog({
    required BuildContext context,
    required String symbol,
    required String type,
    required double lot,
    required double price,
    required Function onConfirm,
  }) {
    final isDarkMode = Get.theme.brightness == Brightness.dark;
    final primaryColor = type == 'BUY' ? Colors.green : Colors.red;
    final secondaryColor = CustomColor.secondaryColor; 
    final dialogBackgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

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
            _buildDetailRow('Harga Eksekusi', price.toStringAsFixed(4), textColor),
            
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Konfirmasi ${type}',
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
            style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}