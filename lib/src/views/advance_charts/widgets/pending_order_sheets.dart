import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class PendingOrderDialog extends StatefulWidget {
  final String symbol;
  final String type;
  final double initialPrice;
  final int digits;
  final Function(double entry, double? sl, double? tp) onConfirm;

  const PendingOrderDialog({
    super.key,
    required this.symbol,
    required this.type,
    required this.initialPrice,
    required this.digits,
    required this.onConfirm,
  });

  @override
  State<PendingOrderDialog> createState() => _PendingOrderDialogState();
}

class _PendingOrderDialogState extends State<PendingOrderDialog> {
  late TextEditingController _entryController;
  late TextEditingController _slController;
  late TextEditingController _tpController;
  final RxString _displayEntryPrice = ''.obs;

  @override
  void initState() {
    super.initState();
    _entryController = TextEditingController(
      text: widget.initialPrice.toStringAsFixed(widget.digits),
    );
    _slController = TextEditingController();
    _tpController = TextEditingController();
    _displayEntryPrice.value = _entryController.text;

    _entryController.addListener(() {
      _displayEntryPrice.value = _entryController.text;
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _slController.dispose();
    _tpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final isBuy = widget.type.toLowerCase().contains('buy');
    final accentColor = isBuy ? Colors.green.shade500 : Colors.red.shade500;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: SingleChildScrollView( // Pengaman jika layar HP sangat pendek
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isBuy ? Iconsax.arrow_up_3_outline : Iconsax.arrow_bottom_outline,
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.type.toUpperCase(),
                              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(widget.symbol,
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Iconsax.close_circle_outline, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Input Entry Price
                _buildInputLabel("Entry Price", isDark),
                _buildPriceField(_entryController, "0.00000", isDark, Iconsax.tag_2_outline),
                const SizedBox(height: 16),

                // SL & TP
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Stop Loss", isDark),
                          _buildPriceField(_slController, "Optional", isDark,
                              Iconsax.shield_cross_outline, Colors.red.shade400),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Take Profit", isDark),
                          _buildPriceField(_tpController, "Optional", isDark,
                              Iconsax.medal_star_outline, Colors.green.shade400),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Button
                ElevatedButton(
                  onPressed: () {
                    // 1. Parsing Entry Price (Wajib ada)
                    final entry = double.tryParse(_entryController.text.replaceAll(',', '')) ?? 0;

                    // 2. Parsing SL dan TP (Bisa null jika kosong/Optional)
                    final slText = _slController.text.replaceAll(',', '');
                    final tpText = _tpController.text.replaceAll(',', '');
                    
                    final double? sl = slText.isNotEmpty ? double.tryParse(slText) : null;
                    final double? tp = tpText.isNotEmpty ? double.tryParse(tpText) : null;

                    // Pastikan kamu mengambil current market price di sini
                    // Contoh: final currentPrice = widget.currentPrice; 
                    // atau: final currentPrice = Get.find<TradeController>().currentPrice.value;
                    final currentPrice = widget.initialPrice; // Sesuaikan dengan kodemu

                    // 3. Logika Validasi Entry Price Dasar
                    if (entry <= 0) {
                      Get.snackbar(
                        "Invalid Entry", 
                        "Please enter a valid entry price.", 
                        backgroundColor: Colors.red.shade400, 
                        colorText: Colors.white
                      );
                      return;
                    }

                    // 4. Logika Validasi Pending Order berdasarkan Type dan Current Price
                    final String orderType = widget.type.toLowerCase();

                    if (orderType == 'buy limit' && entry >= currentPrice) {
                      Get.snackbar(
                        "Invalid Price", 
                        "Buy Limit entry price must be strictly below the current price.", 
                        backgroundColor: Colors.red.shade400, 
                        colorText: Colors.white
                      );
                      return;
                    } else if (orderType == 'sell limit' && entry <= currentPrice) {
                      Get.snackbar(
                        "Invalid Price", 
                        "Sell Limit entry price must be strictly above the current price.", 
                        backgroundColor: Colors.red.shade400, 
                        colorText: Colors.white
                      );
                      return;
                    } else if (orderType == 'buy stop' && entry <= currentPrice) {
                      Get.snackbar(
                        "Invalid Price", 
                        "Buy Stop entry price must be strictly above the current price.", 
                        backgroundColor: Colors.red.shade400, 
                        colorText: Colors.white
                      );
                      return;
                    } else if (orderType == 'sell stop' && entry >= currentPrice) {
                      Get.snackbar(
                        "Invalid Price", 
                        "Sell Stop entry price must be strictly below the current price.", 
                        backgroundColor: Colors.red.shade400, 
                        colorText: Colors.white
                      );
                      return;
                    }

                    // (Opsional) Kamu juga bisa menambahkan validasi SL & TP di sini jika diperlukan
                    // sebelum mengirim data.

                    // 5. Kirim data yang sudah divalidasi dan diparsing
                    widget.onConfirm(entry, sl, tp);
                    
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Obx(() => Text(
                        "${widget.type.toUpperCase()} AT ${_displayEntryPrice.value}",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: 1),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
    );
  }

  Widget _buildPriceField(TextEditingController ctrl, String hint, bool isDark, IconData icon,
      [Color? iconColor]) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: iconColor ?? Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}