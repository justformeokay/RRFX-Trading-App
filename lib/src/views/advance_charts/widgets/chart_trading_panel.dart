import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
import '../controllers/chart_execution_controller.dart';

class ChartTradingPanel extends StatefulWidget {
  final String login;
  final String symbol;
  final Function(String operation)? onOrderExecuted;
  final RxnDouble? currentPrice;

  const ChartTradingPanel({
    super.key,
    required this.login,
    required this.symbol,
    this.onOrderExecuted,
    this.currentPrice,
  });

  @override
  State<ChartTradingPanel> createState() => _ChartTradingPanelState();
}

class _ChartTradingPanelState extends State<ChartTradingPanel> {
  final executionController = Get.put(ChartExecutionController());
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Timer? _incrementTimer;
  Timer? _decrementTimer;
  
  // Queue untuk mengelola multiple executions
  final RxList<Map<String, dynamic>> _executionQueue = <Map<String, dynamic>>[].obs;
  bool _isProcessingQueue = false;
  
  OverlayEntry? _overlayEntry;
  
  // Global variable untuk lot step increment/decrement
  static const double LOT_STEP = 0.10;
  
  // Execution type tracking
  late RxString _executionType = 'Execution Market'.obs;
  
  // Pending order fields
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _takeProfitController = TextEditingController();

   @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    _audioPlayer.dispose();
    _entryPriceController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        print('Error removing overlay on dispose: $e');
      }
    }
    super.dispose();
  }

  void _startIncrementTimer() {
    executionController.incrementLot();
    _incrementTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      executionController.incrementLot();
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
    _incrementTimer = null;
  }

  void _startDecrementTimer() {
    executionController.decrementLot();
    _decrementTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      executionController.decrementLot();
    });
  }

  void _stopDecrementTimer() {
    _decrementTimer?.cancel();
    _decrementTimer = null;
  }

  /// Play success sound and trigger haptic feedback
  Future<void> _playSuccessNotification() async {
    try {
      // Trigger haptic feedback (vibration)
      await HapticFeedback.mediumImpact();
      
      // Play success sound
      await _audioPlayer.play(AssetSource('sounds/applepay.mp3'));
      
      print('✅ Success notification played');
    } catch (e) {
      print('⚠️ Error playing notification: $e');
    }
  }

  // Validasi apakah lot adalah kelipatan dari LOT_STEP
  bool _isValidLot(double lot) {
    if (lot <= 0) return false;
    // Cek apakah lot adalah kelipatan dari LOT_STEP
    final remainder = (lot / LOT_STEP) % 1;
    return remainder < 0.001 || remainder > 0.999; // Toleransi untuk floating point
  }

  void _showEditLotDialog() {
    final TextEditingController lotController = TextEditingController(
      text: executionController.lot.value.toStringAsFixed(1),
    );
    final RxBool isValid = true.obs;
    final RxDouble inputValue = executionController.lot.value.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Lot Size',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                controller: lotController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Lot',
                  hintText: 'Enter lot size (multiples of ${LOT_STEP.toStringAsFixed(2)})',
                  suffixText: 'Lot',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: !isValid.value 
                    ? 'Must be multiple of ${LOT_STEP.toStringAsFixed(2)}' 
                    : null,
                ),
                onChanged: (value) {
                  final lot = double.tryParse(value);
                  if (lot != null) {
                    inputValue.value = lot;
                    isValid.value = _isValidLot(lot);
                  } else {
                    isValid.value = false;
                  }
                },
              )),
              const SizedBox(height: 8),
              Text(
                'Increment step: ${LOT_STEP.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                    onPressed: isValid.value
                      ? () {
                          executionController.lot.value = inputValue.value;
                          Get.back();
                        }
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Set',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isValid.value ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionItem(Map<String, dynamic> item) {
    final symbolClean = widget.symbol.replaceAll('.db', '');
    final operation = item['operation'] as String;
    final lot = item['lot'] as double;
    final status = item['status'] as String; // 'loading', 'success', 'error'
    final openPrice = item['openPrice']; // Can be null
    final pendingPrice = item['price']; // For pending orders
    
    // Determine color based on operation type
    final isBuyOperation = operation.toLowerCase().contains('buy');
    final operationColor = isBuyOperation ? Colors.green : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: operationColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbolClean,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            operation.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: operationColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            lot.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          // Show pending price for pending orders or open price for market orders
          if (pendingPrice != null || openPrice != null) ...[
            const SizedBox(width: 8),
            Text(
              '@',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              (openPrice ?? pendingPrice).toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: operationColor,
              ),
            ),
          ],
          const SizedBox(width: 12),
          if (status == 'loading')
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  operationColor,
                ),
              ),
            )
          else if (status == 'success')
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: operationColor,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 12,
              ),
            )
          else if (status == 'error')
            const Icon(
              Icons.close_rounded,
              color: Colors.red,
              size: 16,
            ),
        ],
      ),
    );
  }

  void _addToQueue(String operation) {
    final lot = executionController.lot.value;
    final newItem = {
      'operation': operation,
      'lot': lot,
      'status': 'loading',
      'id': DateTime.now().millisecondsSinceEpoch,
    };
    
    _executionQueue.add(newItem);
    print('Added to queue: $operation $lot, Total items: ${_executionQueue.length}');
    
    // Show overlay entry
    _showQueueOverlay();
    
    if (!_isProcessingQueue) {
      _processQueue();
    }
  }

  void _showQueueOverlay() {
    // Remove old overlay if exists and is mounted
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        print('Error removing overlay: $e');
      }
      _overlayEntry = null;
    }
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 140, // Naikkan dari 80 ke 140 agar tidak menutupi button Buy
        left: 0,
        right: 0,
        child: SafeArea(
          child: Obx(() {
            if (_executionQueue.isEmpty) {
              Future.microtask(() {
                if (_overlayEntry != null) {
                  try {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  } catch (e) {
                    print('Error removing overlay on empty: $e');
                  }
                }
              });
              return const SizedBox.shrink();
            }
            
            return Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: _executionQueue.map((item) => _buildExecutionItem(item)).toList(),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
    
    try {
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      print('Error inserting overlay: $e');
    }
  }

  Future<void> _processQueue() async {
    if (_executionQueue.isEmpty) {
      _isProcessingQueue = false;
      return;
    }
    
    _isProcessingQueue = true;
    final item = _executionQueue.first;
    final operation = item['operation'] as String;
    
    try {
      print('🔄 Processing order: $operation for ${widget.symbol}');
      print('📊 Login: ${widget.login}, Lot: ${item['lot']}');
      
      Map<String, dynamic> response;
      if (operation == 'buy') {
        response = await executionController.executeBuy(
          login: widget.login,
          symbol: widget.symbol,
        );
      } else {
        response = await executionController.executeSell(
          login: widget.login,
          symbol: widget.symbol,
        );
      }
      
      print('✅ Order response received:');
      print('   Status: ${response['status']}');
      print('   Message: ${response['message']}');
      print('   Response: ${response['response']}');
      
      // Extract openPrice from response
      final openPrice = response['response']?['openPrice'];
      
      // Update status to success and add openPrice
      final index = _executionQueue.indexWhere((e) => e['id'] == item['id']);
      if (index != -1) {
        _executionQueue[index]['status'] = 'success';
        _executionQueue[index]['openPrice'] = openPrice;
        _executionQueue.refresh();
      }
      
      // Play success notification (sound + haptic)
      await _playSuccessNotification();
      
      // Show success snackbar
      // if (mounted) {
      //   Get.snackbar(
      //     'Order Berhasil',
      //     '${operation.toUpperCase()} ${item['lot']} lot ${widget.symbol.replaceAll('.db', '')} @ $openPrice',
      //     backgroundColor: operation == 'buy' ? Colors.green.shade800 : Colors.red.shade800,
      //     colorText: Colors.white,
      //     icon: Icon(Iconsax.tick_circle_bold, color: Colors.white),
      //     snackPosition: SnackPosition.TOP,
      //     duration: const Duration(seconds: 2),
      //   );
      // }
      
      // Remove after 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
      _executionQueue.removeWhere((e) => e['id'] == item['id']);
      
      if (mounted) {
        widget.onOrderExecuted?.call(operation);
      }
      
    } catch (e) {
      print('❌ Order execution error:');
      print('   Error type: ${e.runtimeType}');
      print('   Error message: $e');
      
      // Update status to error
      final index = _executionQueue.indexWhere((e) => e['id'] == item['id']);
      if (index != -1) {
        _executionQueue[index]['status'] = 'error';
        _executionQueue.refresh();
      }
      
      // Show error popup dengan ModernAlertDialog
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        String userFriendlyMsg = 'Order gagal dilakukan. Silakan periksa kembali data Anda dan coba lagi.';
        
        // Map error codes ke pesan yang user-friendly
        if (errorMsg.contains('524')) {
          userFriendlyMsg = 'Koneksi ke server bermasalah. Silakan coba lagi dalam beberapa saat.';
        } else if (errorMsg.contains('500') || errorMsg.contains('502')) {
          userFriendlyMsg = 'Server sedang mengalami gangguan. Silakan coba lagi.';
        } else if (errorMsg.toLowerCase().contains('invalid') || errorMsg.toLowerCase().contains('ticket')) {
          userFriendlyMsg = 'Pesanan tidak dapat diproses karena data tidak valid. Silakan coba lagi.';
        } else if (errorMsg.toLowerCase().contains('insufficient') || errorMsg.toLowerCase().contains('balance')) {
          userFriendlyMsg = 'Saldo Anda tidak cukup untuk melakukan pesanan ini.';
        } else if (errorMsg.toLowerCase().contains('market')) {
          userFriendlyMsg = 'Pasar sedang ditutup atau tidak tersedia saat ini.';
        }
        
        ModernAlertDialog.error(
          title: 'Order Gagal',
          message: userFriendlyMsg,
          onPressed: () {
            Get.back();
          },
        );
      }
      
      // Remove after 1 second
      await Future.delayed(const Duration(milliseconds: 1000));
      _executionQueue.removeWhere((e) => e['id'] == item['id']);
    }
    
    // Process next item
    _processQueue();
  }

  Future<void> _executeBuy() async {
    _addToQueue('buy');
  }

  Future<void> _executeSell() async {
    _addToQueue('sell');
  }

  void _showExecutionTypeBottomSheet() {
    final isDark = Get.isDarkMode;
    final executionTypes = [
      'Execution Market',
      'Buy Limit',
      'Sell Limit',
      'Buy Stop',
      'Sell Stop',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Wrap dengan PointerInterceptor untuk web platform agar bisa menangkap tap di atas WebView
        Widget bottomSheetContent = Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Pilih Tipe Eksekusi',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu items
                    ...executionTypes.map((type) {
                      final isSelected = _executionType.value == type;
                      final icon = _getExecutionTypeIcon(type);
                      
                      return GestureDetector(
                        onTap: () {
                          _executionType.value = type;
                          Get.back();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                              ? Colors.blue.withOpacity(0.1)
                              : isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                ? Colors.blue
                                : isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                size: 24,
                                color: isSelected
                                  ? Colors.blue
                                  : isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  type,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                    color: isSelected
                                      ? Colors.blue
                                      : isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Iconsax.tick_circle_bold,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
        
        // Gunakan PointerInterceptor untuk web platform
        if (kIsWeb) {
          return PointerInterceptor(child: bottomSheetContent);
        }
        return bottomSheetContent;
      },
    );
  }

  IconData _getExecutionTypeIcon(String type) {
    switch (type) {
      case 'Execution Market':
        return Iconsax.chart_success_bold;
      case 'Buy Limit':
        return Iconsax.arrow_down_bold;
      case 'Sell Limit':
        return Iconsax.arrow_up_bold;
      case 'Buy Stop':
        return Iconsax.arrow_up_2_bold;
      case 'Sell Stop':
        return Iconsax.arrow_down_2_bold;
      default:
        return Iconsax.chart_success_bold;
    }
  }

  Widget _buildPendingOrderFields(bool isDark) {
    if (_executionType.value == 'Execution Market') {
      return const SizedBox.shrink(); // No additional fields for market execution
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with Info Icon
          Row(
            children: [
              Icon(
                Iconsax.setting_2_bold,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pending Order Settings',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    Dialog(
                      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.info_circle_bold,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Entry Price Requirements',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Icon(
                                    Iconsax.close_square_bold,
                                    size: 20,
                                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Obx(() {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getInfoText(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Close',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Icon(
                  Iconsax.info_circle_bold,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Entry Price (Required)
          _buildInputField(
            controller: _entryPriceController,
            label: 'Entry Price',
            hint: _getEntryPriceHint(),
            icon: Iconsax.tag_bold,
            isDark: isDark,
            isRequired: true,
          ),
          const SizedBox(height: 10),

          // Stop Loss (Optional) and Take Profit (Optional) - Side by side
          Row(
            children: [
              // Stop Loss
              Expanded(
                child: _buildInputField(
                  controller: _stopLossController,
                  label: 'Stop Loss (Points)',
                  hint: 'e.g., 50',
                  icon: Iconsax.shield_cross_bold,
                  isDark: isDark,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 8),
              // Take Profit
              Expanded(
                child: _buildInputField(
                  controller: _takeProfitController,
                  label: 'Take Profit (Points)',
                  hint: 'e.g., 100',
                  icon: Iconsax.medal_star_bold,
                  isDark: isDark,
                  isRequired: false,
                ),
              ),
            ],
          ),
          
          // Info text for SL/TP points
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle_bold,
                  size: 12,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'SL/TP menggunakan points. Contoh: 50 points = 0.0050 dari entry price',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required bool isRequired,
  }) {
    // Check if this is the Entry Price field
    final isEntryPrice = controller == _entryPriceController;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
            if (isEntryPrice && widget.currentPrice != null) ...[
              const SizedBox(width: 8),
              Obx(() {
                final price = widget.currentPrice?.value;
                if (price == null) return const SizedBox.shrink();
                
                return GestureDetector(
                  onTap: () {
                    controller.text = price.toStringAsFixed(2);
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.refresh_bold,
                          size: 10,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          price.toStringAsFixed(2),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getEntryPriceHint() {
    switch (_executionType.value) {
      case 'Buy Limit':
        return 'Below current price';
      case 'Sell Limit':
        return 'Above current price';
      case 'Buy Stop':
        return 'Above current price';
      case 'Sell Stop':
        return 'Below current price';
      default:
        return 'Enter price';
    }
  }

  String _getInfoText() {
    final currentPrice = widget.currentPrice?.value;
    final stopLevel = _getStopLevel(widget.symbol);
    
    // Format harga sesuai desimal symbol
    String formatPrice(double price) {
      if (widget.symbol.toUpperCase().contains('XAU')) {
        return price.toStringAsFixed(2);
      } else if (widget.symbol.toUpperCase().contains('XAG')) {
        return price.toStringAsFixed(3);
      } else if (widget.symbol.toUpperCase().contains('JPY') || 
                 widget.symbol.toUpperCase().contains('US30') || 
                 widget.symbol.toUpperCase().contains('NAS')) {
        return price.toStringAsFixed(3);
      } else {
        return price.toStringAsFixed(5);
      }
    }
    
    switch (_executionType.value) {
      case 'Buy Limit':
        if (currentPrice != null && currentPrice > 0) {
          final maxEntry = currentPrice - stopLevel;
          return 'Entry Price harus DI BAWAH harga saat ini.\n'
                 'Harga saat ini: ${formatPrice(currentPrice)}\n'
                 'Entry maksimal: ${formatPrice(maxEntry)}';
        }
        return 'Order akan dieksekusi ketika harga turun mencapai Entry Price. Entry Price harus di bawah harga saat ini.';
      case 'Sell Limit':
        if (currentPrice != null && currentPrice > 0) {
          final minEntry = currentPrice + stopLevel;
          return 'Entry Price harus DI ATAS harga saat ini.\n'
                 'Harga saat ini: ${formatPrice(currentPrice)}\n'
                 'Entry minimal: ${formatPrice(minEntry)}';
        }
        return 'Order akan dieksekusi ketika harga naik mencapai Entry Price. Entry Price harus di atas harga saat ini.';
      case 'Buy Stop':
        if (currentPrice != null && currentPrice > 0) {
          final minEntry = currentPrice + stopLevel;
          return 'Entry Price harus DI ATAS harga saat ini.\n'
                 'Harga saat ini: ${formatPrice(currentPrice)}\n'
                 'Entry minimal: ${formatPrice(minEntry)}';
        }
        return 'Order akan dieksekusi ketika harga naik menembus Entry Price. Entry Price harus di atas harga saat ini.';
      case 'Sell Stop':
        if (currentPrice != null && currentPrice > 0) {
          final maxEntry = currentPrice - stopLevel;
          return 'Entry Price harus DI BAWAH harga saat ini.\n'
                 'Harga saat ini: ${formatPrice(currentPrice)}\n'
                 'Entry maksimal: ${formatPrice(maxEntry)}';
        }
        return 'Order akan dieksekusi ketika harga turun menembus Entry Price. Entry Price harus di bawah harga saat ini.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Execution Type Selector Button
            GestureDetector(
              onTap: _showExecutionTypeBottomSheet,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getExecutionTypeIcon(_executionType.value),
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _executionType.value,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Icon(
                      Iconsax.arrow_swap_horizontal_outline,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            // Pending Order Fields (shown for non-market execution types)
            _buildPendingOrderFields(isDark),

            // Trading Panel Row
            Row(
          children: [
            // SELL button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _executionType.value == 'Execution Market' 
                    ? _executeSell 
                    : () => _executePendingOrder('sell'),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _executionType.value == 'Execution Market'
                          ? [
                              Colors.red.shade400,
                              Colors.red.shade500,
                            ]
                          : (_executionType.value == 'Sell Limit' || _executionType.value == 'Sell Stop')
                            ? [
                                Colors.red.shade400,
                                Colors.red.shade500,
                              ]
                            : [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _executionType.value == 'Sell Limit' 
                          ? 'SELL LIMIT' 
                          : _executionType.value == 'Sell Stop' 
                            ? 'SELL STOP' 
                            : 'SELL',
                      style: GoogleFonts.inter(
                        fontSize: _executionType.value == 'Execution Market' ? 14 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Lot selector in the middle
            Expanded(
              flex: 3,
              child: Container(
                height: 38.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 2,
                  ),
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 2,
                  ))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Decrement button
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => _startDecrementTimer(),
                        onTapUp: (_) => _stopDecrementTimer(),
                        onTapCancel: _stopDecrementTimer,
                        child: Center(
                          child: Text(
                            '-',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Lot display
                    Expanded(
                      child: GestureDetector(
                        onTap: _showEditLotDialog,
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              executionController.lot.value.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Increment button
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => _startIncrementTimer(),
                        onTapUp: (_) => _stopIncrementTimer(),
                        onTapCancel: _stopIncrementTimer,
                        child: Center(
                          child: Text(
                            '+',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // BUY button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _executionType.value == 'Execution Market' 
                    ? _executeBuy 
                    : () => _executePendingOrder('buy'),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _executionType.value == 'Execution Market'
                          ? [
                              Colors.green.shade400,
                              Colors.green.shade500,
                            ]
                          : (_executionType.value == 'Buy Limit' || _executionType.value == 'Buy Stop')
                            ? [
                                Colors.green.shade400,
                                Colors.green.shade500,
                              ]
                            : [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _executionType.value == 'Buy Limit' 
                          ? 'BUY LIMIT' 
                          : _executionType.value == 'Buy Stop' 
                            ? 'BUY STOP' 
                            : 'BUY',
                      style: GoogleFonts.inter(
                        fontSize: _executionType.value == 'Execution Market' ? 14 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
            ),
          ],
        )),
      ),
    );
  }

  Future<void> _executePendingOrder(String direction) async {
    HapticFeedback.lightImpact();
    
    // Validate entry price
    final entryPrice = double.tryParse(_entryPriceController.text.replaceAll(',', ''));
    if (entryPrice == null || entryPrice <= 0) {
      Get.snackbar(
        'Error',
        'Entry Price harus diisi dengan nilai yang valid',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        icon: const Icon(Iconsax.warning_2_bold, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Get current price for validation
    final currentPrice = widget.currentPrice?.value;
    
    // Validate entry price based on order type with stop level requirement
    // Stop Level: minimal jarak dari current price (biasanya 50-100 points untuk Gold, 10-30 untuk Forex)
    final stopLevel = _getStopLevel(widget.symbol);
    
    if (currentPrice != null && currentPrice > 0) {
      final validationResult = _validateEntryPrice(
        executionType: _executionType.value,
        entryPrice: entryPrice,
        currentPrice: currentPrice,
        stopLevel: stopLevel,
      );
      
      if (!validationResult['isValid']) {
        Get.snackbar(
          'Entry Price Tidak Valid',
          validationResult['message'],
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          icon: const Icon(Iconsax.warning_2_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // Parse optional SL and TP (now in points, need to convert to price)
    final slPoints = double.tryParse(_stopLossController.text.replaceAll(',', ''));
    final tpPoints = double.tryParse(_takeProfitController.text.replaceAll(',', ''));
    
    // Convert points to price based on entry price and direction
    // For buy orders: SL = entryPrice - (slPoints * point), TP = entryPrice + (tpPoints * point)
    // For sell orders: SL = entryPrice + (slPoints * point), TP = entryPrice - (tpPoints * point)
    // point value = 0.0001 for most pairs (0.01 for JPY pairs)
    final pointValue = widget.symbol.toUpperCase().contains('JPY') ? 0.01 : 0.0001;
    
    double? sl;
    double? tp;
    
    if (slPoints != null && slPoints > 0) {
      if (direction == 'buy') {
        sl = entryPrice - (slPoints * pointValue);
      } else {
        sl = entryPrice + (slPoints * pointValue);
      }
    }
    
    if (tpPoints != null && tpPoints > 0) {
      if (direction == 'buy') {
        tp = entryPrice + (tpPoints * pointValue);
      } else {
        tp = entryPrice - (tpPoints * pointValue);
      }
    }

    // Determine operation type based on execution type and direction
    String operation;
    if (_executionType.value == 'Buy Limit' && direction == 'buy') {
      operation = 'buylimit';
    } else if (_executionType.value == 'Sell Limit' && direction == 'sell') {
      operation = 'selllimit';
    } else if (_executionType.value == 'Buy Stop' && direction == 'buy') {
      operation = 'buystop';
    } else if (_executionType.value == 'Sell Stop' && direction == 'sell') {
      operation = 'sellstop';
    } else {
      // Invalid combination (e.g., Buy Limit with sell direction)
      Get.snackbar(
        'Error',
        'Kombinasi tidak valid. Silakan pilih tipe eksekusi yang sesuai.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        icon: const Icon(Iconsax.warning_2_bold, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Create unique ID for this execution
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final lot = executionController.lot.value;

    // Add to queue with loading status
    _executionQueue.add({
      'id': id,
      'operation': operation,
      'lot': lot,
      'price': entryPrice,
      'sl': sl,
      'tp': tp,
      'status': 'loading',
      'openPrice': null,
    });

    // Show overlay if not already showing
    _showQueueOverlay();

    try {
      print('🔄 Processing pending order: $operation');
      print('📊 Entry Price: $entryPrice');
      print('📊 SL Points: ${slPoints ?? "Not set"} → Price: ${sl ?? "Not set"}');
      print('📊 TP Points: ${tpPoints ?? "Not set"} → Price: ${tp ?? "Not set"}');

      final response = await executionController.executePendingOrder(
        login: widget.login,
        symbol: widget.symbol,
        operation: operation,
        price: entryPrice,
        volume: lot,
        sl: sl,
        tp: tp,
      );

      print('✅ Pending order response: $response');

      // Extract response data
      final responseData = response['response'];
      final orderTicket = responseData?['order'] ?? responseData?['ticket'];

      // Update status to success
      final index = _executionQueue.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        _executionQueue[index]['status'] = 'success';
        _executionQueue[index]['ticket'] = orderTicket;
        _executionQueue.refresh();
      }

      // Play success notification
      await _playSuccessNotification();

      // Clear input fields
      _entryPriceController.clear();
      _stopLossController.clear();
      _takeProfitController.clear();

      // Remove after delay
      await Future.delayed(const Duration(milliseconds: 1500));
      _executionQueue.removeWhere((e) => e['id'] == id);

      // Callback
      if (mounted) {
        widget.onOrderExecuted?.call(operation);
      }

    } catch (e) {
      print('❌ Pending order error: $e');

      // Update status to error
      final index = _executionQueue.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        _executionQueue[index]['status'] = 'error';
        _executionQueue.refresh();
      }

      // Show error popup dengan ModernAlertDialog
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        String userFriendlyMsg = 'Pending order gagal dibuat. Silakan periksa kembali data Anda dan coba lagi.';
        
        // Map error codes ke pesan yang user-friendly
        if (errorMsg.contains('524')) {
          userFriendlyMsg = 'Koneksi ke server bermasalah. Silakan coba lagi dalam beberapa saat.';
        } else if (errorMsg.contains('500') || errorMsg.contains('502')) {
          userFriendlyMsg = 'Server sedang mengalami gangguan. Silakan coba lagi.';
        } else if (errorMsg.toLowerCase().contains('invalid') || errorMsg.toLowerCase().contains('ticket') || errorMsg.toLowerCase().contains('price')) {
          userFriendlyMsg = 'Data pending order tidak valid. Periksa entry price, SL, dan TP yang Anda masukkan.';
        } else if (errorMsg.toLowerCase().contains('insufficient') || errorMsg.toLowerCase().contains('balance')) {
          userFriendlyMsg = 'Saldo Anda tidak cukup untuk membuat pending order ini.';
        } else if (errorMsg.toLowerCase().contains('market')) {
          userFriendlyMsg = 'Pasar sedang ditutup atau tidak tersedia saat ini.';
        }
        
        ModernAlertDialog.error(
          title: 'Pending Order Gagal',
          message: userFriendlyMsg,
          onPressed: () {
            Get.back();
          },
        );
      }

      // Remove after delay
      await Future.delayed(const Duration(milliseconds: 1000));
      _executionQueue.removeWhere((e) => e['id'] == id);
    }
  }

  /// Get stop level (minimal distance from current price) based on symbol type
  /// Stop level in points:
  /// - Gold (XAU): 50 points = 0.50
  /// - Forex major (5 digits): 30 points = 0.00030
  /// - JPY pairs (3 digits): 30 points = 0.030
  double _getStopLevel(String symbol) {
    final symbolUpper = symbol.toUpperCase();
    
    // Gold pairs
    if (symbolUpper.contains('XAU') || symbolUpper.contains('GOLD')) {
      return 0.50; // 50 points for Gold
    }
    
    // Silver
    if (symbolUpper.contains('XAG') || symbolUpper.contains('SILVER')) {
      return 0.030; // 30 points for Silver
    }
    
    // JPY pairs (3 decimal places)
    if (symbolUpper.contains('JPY')) {
      return 0.030; // 30 points for JPY pairs
    }
    
    // Indices (like US30, NAS100, etc.)
    if (symbolUpper.contains('US30') || 
        symbolUpper.contains('NAS') || 
        symbolUpper.contains('SPX') ||
        symbolUpper.contains('DAX') ||
        symbolUpper.contains('UK100')) {
      return 5.0; // 50 points for indices
    }
    
    // Default for Forex pairs (5 decimal places)
    return 0.00030; // 30 points
  }

  /// Validate entry price based on order type
  /// Returns Map with 'isValid' (bool) and 'message' (String)
  Map<String, dynamic> _validateEntryPrice({
    required String executionType,
    required double entryPrice,
    required double currentPrice,
    required double stopLevel,
  }) {
    switch (executionType) {
      case 'Buy Limit':
        // Entry price harus DI BAWAH current price dengan minimal stopLevel
        if (entryPrice >= currentPrice) {
          return {
            'isValid': false,
            'message': 'Buy Limit: Entry Price harus di BAWAH harga saat ini (${currentPrice.toStringAsFixed(2)})',
          };
        }
        if ((currentPrice - entryPrice) < stopLevel) {
          return {
            'isValid': false,
            'message': 'Buy Limit: Entry Price minimal ${stopLevel.toString()} di bawah harga saat ini.\nMinimal: ${(currentPrice - stopLevel).toStringAsFixed(2)}',
          };
        }
        break;
        
      case 'Sell Limit':
        // Entry price harus DI ATAS current price dengan minimal stopLevel
        if (entryPrice <= currentPrice) {
          return {
            'isValid': false,
            'message': 'Sell Limit: Entry Price harus di ATAS harga saat ini (${currentPrice.toStringAsFixed(2)})',
          };
        }
        if ((entryPrice - currentPrice) < stopLevel) {
          return {
            'isValid': false,
            'message': 'Sell Limit: Entry Price minimal ${stopLevel.toString()} di atas harga saat ini.\nMinimal: ${(currentPrice + stopLevel).toStringAsFixed(2)}',
          };
        }
        break;
        
      case 'Buy Stop':
        // Entry price harus DI ATAS current price dengan minimal stopLevel
        if (entryPrice <= currentPrice) {
          return {
            'isValid': false,
            'message': 'Buy Stop: Entry Price harus di ATAS harga saat ini (${currentPrice.toStringAsFixed(2)})',
          };
        }
        if ((entryPrice - currentPrice) < stopLevel) {
          return {
            'isValid': false,
            'message': 'Buy Stop: Entry Price minimal ${stopLevel.toString()} di atas harga saat ini.\nMinimal: ${(currentPrice + stopLevel).toStringAsFixed(2)}',
          };
        }
        break;
        
      case 'Sell Stop':
        // Entry price harus DI BAWAH current price dengan minimal stopLevel
        if (entryPrice >= currentPrice) {
          return {
            'isValid': false,
            'message': 'Sell Stop: Entry Price harus di BAWAH harga saat ini (${currentPrice.toStringAsFixed(2)})',
          };
        }
        if ((currentPrice - entryPrice) < stopLevel) {
          return {
            'isValid': false,
            'message': 'Sell Stop: Entry Price minimal ${stopLevel.toString()} di bawah harga saat ini.\nMinimal: ${(currentPrice - stopLevel).toStringAsFixed(2)}',
          };
        }
        break;
    }
    
    return {'isValid': true, 'message': ''};
  }
}
