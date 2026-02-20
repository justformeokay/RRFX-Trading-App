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
  final RxList<Map<String, dynamic>> _executionQueue =
      <Map<String, dynamic>>[].obs;
  bool _isProcessingQueue = false;

  OverlayEntry? _overlayEntry;

  // Global variable untuk lot step increment/decrement
  static const double LOT_STEP = 0.10;

  // Execution type tracking
  late RxString _executionType = 'Execution Market'.obs;

  // Track apakah pending order dialog sedang terbuka (cegah numpuk)
  bool _isPendingDialogOpen = false;
  // Track execution type terakhir yang sudah auto-show dialog
  String? _lastAutoShownType;

  // Pending order fields
  final TextEditingController _entryPriceController = TextEditingController();
  // SL/TP: 4 controller terpisah untuk Points dan Prices
  final TextEditingController _slPointsController = TextEditingController();
  final TextEditingController _slPriceController = TextEditingController();
  final TextEditingController _tpPointsController = TextEditingController();
  final TextEditingController _tpPriceController = TextEditingController();
  // Flag untuk mencegah recursive sync
  bool _isSyncingSl = false;
  bool _isSyncingTp = false;

  @override
  void initState() {
    super.initState();
    // Listener: saat SL Points berubah → update SL Prices
    _slPointsController.addListener(() {
      _syncSlPriceFromPoints(_slPointsController.text);
    });
    // Listener: saat SL Prices berubah → update SL Points
    _slPriceController.addListener(() {
      _syncSlPointsFromPrice(_slPriceController.text);
    });
    // Listener: saat TP Points berubah → update TP Prices
    _tpPointsController.addListener(() {
      _syncTpPriceFromPoints(_tpPointsController.text);
    });
    // Listener: saat TP Prices berubah → update TP Points
    _tpPriceController.addListener(() {
      _syncTpPointsFromPrice(_tpPriceController.text);
    });
    // Listener: saat Entry Price berubah → recalculate Prices dari Points yang sudah ada
    _entryPriceController.addListener(() {
      if (_slPointsController.text.isNotEmpty) {
        _syncSlPriceFromPoints(_slPointsController.text);
      }
      if (_tpPointsController.text.isNotEmpty) {
        _syncTpPriceFromPoints(_tpPointsController.text);
      }
    });
  }

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    _audioPlayer.dispose();
    _entryPriceController.dispose();
    _slPointsController.dispose();
    _slPriceController.dispose();
    _tpPointsController.dispose();
    _tpPriceController.dispose();
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
    _incrementTimer = Timer.periodic(const Duration(milliseconds: 300), (
      timer,
    ) {
      executionController.incrementLot();
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
    _incrementTimer = null;
  }

  void _startDecrementTimer() {
    executionController.decrementLot();
    _decrementTimer = Timer.periodic(const Duration(milliseconds: 300), (
      timer,
    ) {
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
    return remainder < 0.001 ||
        remainder > 0.999; // Toleransi untuk floating point
  }

  void _showEditLotDialog() {
    final TextEditingController lotController = TextEditingController(
      text: executionController.lot.value.toStringAsFixed(1),
    );
    final RxBool isValid = true.obs;
    final RxDouble inputValue = executionController.lot.value.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Obx(
                () => TextField(
                  controller: lotController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Lot',
                    hintText:
                        'Enter lot size (multiples of ${LOT_STEP.toStringAsFixed(2)})',
                    suffixText: 'Lot',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText:
                        !isValid.value
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
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Increment step: ${LOT_STEP.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
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
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          isValid.value
                              ? () {
                                executionController.lot.value =
                                    inputValue.value;
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
                          color:
                              isValid.value
                                  ? Colors.white
                                  : Colors.grey.shade500,
                        ),
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
  }

  Widget _buildExecutionItem(Map<String, dynamic> item) {
    // Gunakan symbol dari item, bukan widget.symbol (fix bug: symbol berubah saat pindah market)
    final itemSymbol = item['symbol'] as String? ?? widget.symbol;
    final symbolClean = itemSymbol.replaceAll('.db', '');
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
        border: Border.all(color: operationColor, width: 2),
      ),
      child: Row(
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    symbolClean,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  operation.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: operationColor,
                  ),
                ),
                const SizedBox(width: 8),
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
                  const SizedBox(width: 6),
                  Text(
                    '@',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Get.isDarkMode ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      (openPrice ?? pendingPrice).toString(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: operationColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (status == 'loading')
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(operationColor),
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
            const Icon(Icons.close_rounded, color: Colors.red, size: 16),
        ],
      ),
    );
  }

  void _addToQueue(String operation) {
    final lot = executionController.lot.value;
    final newItem = {
      'operation': operation,
      'lot': lot,
      'symbol': widget.symbol,  // Simpan symbol agar tidak berubah saat pindah market
      'status': 'loading',
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    _executionQueue.add(newItem);
    print(
      'Added to queue: $operation $lot, Total items: ${_executionQueue.length}',
    );

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
      builder:
          (context) => Positioned(
            bottom:
                140, // Naikkan dari 80 ke 140 agar tidak menutupi button Buy
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
                      constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children:
                            _executionQueue
                                .map((item) => _buildExecutionItem(item))
                                .toList(),
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
    // Gunakan symbol dari item, bukan widget.symbol (fix bug: symbol berubah saat pindah market)
    final itemSymbol = item['symbol'] as String? ?? widget.symbol;

    try {
      print('🔄 Processing order: $operation for $itemSymbol');
      print('📊 Login: ${widget.login}, Lot: ${item['lot']}');

      Map<String, dynamic> response;
      if (operation == 'buy') {
        response = await executionController.executeBuy(
          login: widget.login,
          symbol: itemSymbol,
        );
      } else {
        response = await executionController.executeSell(
          login: widget.login,
          symbol: itemSymbol,
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
        // Gunakan message langsung dari response API
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        ModernAlertDialog.error(
          title: 'Order Gagal',
          message: errorMsg,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                          color:
                              isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
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
                          // Reset auto-show tracker saat ganti type
                          if (type == 'Execution Market') {
                            _lastAutoShownType = null;
                          }
                          Get.back();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.withOpacity(0.1)
                                    : isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
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
                                color:
                                    isSelected
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
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                    color:
                                        isSelected
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

  void _showFloatingPendingOrderCard(bool isDark) {
    if (_executionType.value == 'Execution Market') return;
    // Cegah numpuk: jangan buka dialog jika sudah ada yang terbuka
    if (_isPendingDialogOpen) return;

    _isPendingDialogOpen = true;
    
    // Selalu clear Entry Price dan isi ulang dengan current price saat dialog dibuka
    final currentPrice = widget.currentPrice?.value;
    _entryPriceController.clear();
    if (currentPrice != null && currentPrice > 0) {
      _entryPriceController.text = _formatPrice(currentPrice, widget.symbol);
    }

    // Reinisialisasi SL/TP Price ke 0000.00 (format ATM dengan leading zeros) setiap kali dialog dibuka
    final zeroPrice = _formatPriceWithLeadingZeros(0.0, widget.symbol, referencePrice: currentPrice);
    _slPriceController.text = zeroPrice;
    _tpPriceController.text = zeroPrice;
    
    // Clear SL/TP Points controllers agar kosong seperti awal
    _slPointsController.clear();
    _tpPointsController.clear();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.15),
      builder:
          (context) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDark
                                ? [Colors.grey.shade800, Colors.grey.shade900]
                                : [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header dengan icon dan title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Iconsax.setting_2_bold,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _executionType.value,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Configure order details',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color:
                                          isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Iconsax.close_circle_bold,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Entry Price Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Entry Price',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Decrement Button
                                GestureDetector(
                                  onTap: _decrementEntryPrice,
                                  onLongPressStart: (_) {
                                    // Start continuous decrement
                                    _decrementEntryPrice();
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                                  .withOpacity(0.6)
                                              : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _entryPriceController,
                                      textAlign: TextAlign.center,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]'),
                                        ),
                                      ],
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'e.g., 4850.50',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 11,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        prefixIcon: Icon(
                                          Iconsax.tag_bold,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Increment Button
                                GestureDetector(
                                  onTap: _incrementEntryPrice,
                                  onLongPressStart: (_) {
                                    // Start continuous increment
                                    _incrementEntryPrice();
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Current Price Button
                                if (widget.currentPrice != null)
                                  Obx(() {
                                    final price = widget.currentPrice?.value;
                                    if (price == null) {
                                      return const SizedBox.shrink();
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        _entryPriceController.text = _formatPrice(price, widget.symbol);
                                        HapticFeedback.mediumImpact();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.withOpacity(0.2),
                                              Colors.blue.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Now',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Text(
                                              _formatPrice(price, widget.symbol),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                else
                                  const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // SL & TP Section
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stop Loss (Points)',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                                  .withOpacity(0.6)
                                              : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _slPointsController,
                                      textAlign: TextAlign.center,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'e.g., 50',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 11,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        prefixIcon: Icon(
                                          Iconsax.shield_cross_bold,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Take Profit (Points)',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                                  .withOpacity(0.6)
                                              : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _tpPointsController,
                                      textAlign: TextAlign.center,
                                      textAlignVertical: TextAlignVertical.center,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'e.g., 100',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 11,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        prefixIcon: Icon(
                                          Iconsax.medal_star_bold,
                                          size: 16,
                                          color: Colors.green.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(child: Text("Atau")),
                        const SizedBox(height: 8),
                        // SL & TP by Prices
                        Obx(
                          () {
                            final price = widget.currentPrice?.value;
                            if (price == null) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stop Loss (Prices)',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              isDark
                                                  ? Colors.grey.shade800
                                                      .withOpacity(0.6)
                                                  : Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                isDark
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _slPriceController,
                                          textAlign: TextAlign.center,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            PriceShiftInputFormatter(
                                              decimalPlaces: _getDigitsForSymbol(widget.symbol),
                                              integerDigits: price > 0 ? price.truncate().toString().length : 4,
                                            ),
                                          ],
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'e.g., ${_formatPrice(price - 0.005, widget.symbol)}',

                                            hintStyle: GoogleFonts.inter(
                                              fontSize: 11,
                                              color:
                                                  isDark
                                                      ? Colors.grey.shade500
                                                      : Colors.grey.shade400,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                            prefixIcon: Icon(
                                              Iconsax.shield_cross_bold,
                                              size: 16,
                                              color: Colors.red.shade400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                            
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Take Profit (Prices)',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              isDark
                                                  ? Colors.grey.shade800
                                                      .withOpacity(0.6)
                                                  : Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                isDark
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _tpPriceController,
                                          textAlign: TextAlign.center,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            PriceShiftInputFormatter(
                                              decimalPlaces: _getDigitsForSymbol(widget.symbol),
                                              integerDigits: price > 0 ? price.truncate().toString().length : 4,
                                            ),
                                          ],
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'e.g., ${_formatPrice(price + 0.005, widget.symbol)}',

                                            hintStyle: GoogleFonts.inter(
                                              fontSize: 11,
                                              color:
                                                  isDark
                                                      ? Colors.grey.shade500
                                                      : Colors.grey.shade400,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                            prefixIcon: Icon(
                                              Iconsax.medal_star_bold,
                                              size: 16,
                                              color: Colors.green.shade400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } 
                        ),

                        const SizedBox(height: 16),

                        // Execute Button
                        Builder(
                          builder: (context) {
                            final isBuy =
                                _executionType.value == 'Buy Limit' ||
                                _executionType.value == 'Buy Stop';
                            final buttonColor =
                                isBuy
                                    ? Colors.green.shade500
                                    : Colors.red.shade500;
                            final buttonLabel =
                                _executionType.value == 'Buy Limit'
                                    ? 'BUY LIMIT'
                                    : _executionType.value == 'Buy Stop'
                                    ? 'BUY STOP'
                                    : _executionType.value == 'Sell Limit'
                                    ? 'SELL LIMIT'
                                    : 'SELL STOP';

                            return GestureDetector(
                              onTap: () {
                                Get.back();
                                Future.delayed(
                                  const Duration(milliseconds: 150),
                                  () => _executePendingOrder(
                                    isBuy ? 'buy' : 'sell',
                                  ),
                                );
                              },
                              child: Container(
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      buttonColor,
                                      buttonColor.withOpacity(0.85),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: buttonColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isBuy
                                            ? Iconsax.arrow_up_2_bold
                                            : Iconsax.arrow_down_2_bold,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        buttonLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    ).then((_) {
      // Reset flag saat dialog ditutup (baik via back, tap outside, dll)
      _isPendingDialogOpen = false;
    });
  }

  Widget _buildPendingOrderFields(bool isDark) {
    if (_executionType.value != 'Execution Market') {
      // Hanya auto-show dialog saat execution type BARU berubah,
      // bukan setiap kali widget rebuild
      if (_lastAutoShownType != _executionType.value) {
        _lastAutoShownType = _executionType.value;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _showFloatingPendingOrderCard(isDark);
          }
        });
      }

      // Return a hint card to reopen settings
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.amber.shade900.withOpacity(0.3)
                  : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isDark
                    ? Colors.amber.shade700.withOpacity(0.4)
                    : Colors.amber.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.info_circle_bold,
              size: 16,
              color: Colors.amber.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap settings icon to modify order details',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showFloatingPendingOrderCard(isDark);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.amber.shade700.withOpacity(0.4)
                          : Colors.amber.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Iconsax.setting_2_bold,
                  size: 14,
                  color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Execution Type Selector Button
              GestureDetector(
                onTap: _showExecutionTypeBottomSheet,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                      onTap:
                          _executionType.value == 'Execution Market'
                              ? _executeSell
                              : () => _executePendingOrder('sell'),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                _executionType.value == 'Execution Market'
                                    ? [Colors.red.shade400, Colors.red.shade500]
                                    : (_executionType.value == 'Sell Limit' ||
                                        _executionType.value == 'Sell Stop')
                                    ? [Colors.red.shade400, Colors.red.shade500]
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
                              fontSize:
                                  _executionType.value == 'Execution Market'
                                      ? 14
                                      : 11,
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
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          top: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
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
                                    executionController.lot.value
                                        .toStringAsFixed(1),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark ? Colors.white : Colors.black,
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
                      onTap:
                          _executionType.value == 'Execution Market'
                              ? _executeBuy
                              : () => _executePendingOrder('buy'),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                _executionType.value == 'Execution Market'
                                    ? [
                                      Colors.green.shade400,
                                      Colors.green.shade500,
                                    ]
                                    : (_executionType.value == 'Buy Limit' ||
                                        _executionType.value == 'Buy Stop')
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
                              fontSize:
                                  _executionType.value == 'Execution Market'
                                      ? 14
                                      : 11,
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
          ),
        ),
      ),
    );
  }

  Future<void> _executePendingOrder(String direction) async {
    HapticFeedback.lightImpact();

    // Capture symbol di awal untuk menghindari race condition saat pindah market
    final capturedSymbol = widget.symbol;

    // Validate entry price
    final entryPrice = double.tryParse(
      _entryPriceController.text.replaceAll(',', ''),
    );
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
    final stopLevel = _getStopLevel(capturedSymbol);
    final digits = _getDigitsForSymbol(capturedSymbol);

    if (currentPrice != null && currentPrice > 0) {
      final validationResult = _validateEntryPrice(
        executionType: _executionType.value,
        entryPrice: entryPrice,
        currentPrice: currentPrice,
        stopLevel: stopLevel,
        digits: digits,
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

    // API menerima SL/TP dalam bentuk POINTS (integer), bukan prices
    // Prioritas: ambil dari _slPointsController, jika kosong maka konversi dari _slPriceController
    int? slPoints;
    int? tpPoints;

    final slPointsText = _slPointsController.text.replaceAll(',', '');
    final tpPointsText = _tpPointsController.text.replaceAll(',', '');
    final slPriceText = _slPriceController.text.replaceAll(',', '');
    final tpPriceText = _tpPriceController.text.replaceAll(',', '');

    // SL Points
    if (slPointsText.isNotEmpty) {
      slPoints = double.tryParse(slPointsText)?.round();
    } else if (slPriceText.isNotEmpty) {
      // Konversi dari price ke points
      final slPrice = double.tryParse(slPriceText);
      if (slPrice != null && slPrice > 0) {
        final pointValue = _getPointValue(capturedSymbol);
        final isBuy = direction == 'buy';
        final pointsCalc = isBuy
            ? (entryPrice - slPrice) / pointValue
            : (slPrice - entryPrice) / pointValue;
        if (pointsCalc > 0) {
          slPoints = pointsCalc.round();
        }
      }
    }

    // TP Points
    if (tpPointsText.isNotEmpty) {
      tpPoints = double.tryParse(tpPointsText)?.round();
    } else if (tpPriceText.isNotEmpty) {
      // Konversi dari price ke points
      final tpPrice = double.tryParse(tpPriceText);
      if (tpPrice != null && tpPrice > 0) {
        final pointValue = _getPointValue(capturedSymbol);
        final isBuy = direction == 'buy';
        final pointsCalc = isBuy
            ? (tpPrice - entryPrice) / pointValue
            : (entryPrice - tpPrice) / pointValue;
        if (pointsCalc > 0) {
          tpPoints = pointsCalc.round();
        }
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
      'symbol': capturedSymbol,  // Gunakan captured symbol
      'price': entryPrice,
      'sl': slPoints,
      'tp': tpPoints,
      'status': 'loading',
      'openPrice': null,
    });

    // Show overlay if not already showing
    _showQueueOverlay();

    // print('🔄 Processing pending order: $operation');
    // print('📊 Entry Price: $entryPrice');
    // print('📊 SL Points: ${slPoints ?? "Not set"}');
    // print('📊 TP Points: ${tpPoints ?? "Not set"}');
    // Get.snackbar("Data", "Entry Price: $entryPrice, SL: ${slPoints ?? "Not set"}, TP: ${tpPoints ?? "Not set"}", backgroundColor: Colors.white);
    try {

      final response = await executionController.executePendingOrder(
        login: widget.login,
        symbol: capturedSymbol,  // Gunakan captured symbol
        operation: operation,
        price: entryPrice,
        volume: lot,
        sl: slPoints,
        tp: tpPoints,
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
      _slPointsController.clear();
      _tpPointsController.clear();
      // Reset harga ke 0000.00 sesuai format ATM dengan leading zeros
      final currentPriceRef = widget.currentPrice?.value;
      final zeroPrice = _formatPriceWithLeadingZeros(0.0, widget.symbol, referencePrice: currentPriceRef);
      _slPriceController.text = zeroPrice;
      _tpPriceController.text = zeroPrice;

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
        // Gunakan message langsung dari response API
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        ModernAlertDialog.error(
          title: 'Pending Order Gagal',
          message: errorMsg,
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

  /// Nilai 1 point berdasarkan jumlah desimal instrumen
  double _getPointValue(String symbol) {
    final digits = _getDigitsForSymbol(symbol);
    double v = 1.0;
    for (int i = 0; i < digits; i++) {
      v /= 10.0;
    }
    return v;
  }

  /// Sync SL Prices dari SL Points
  void _syncSlPriceFromPoints(String value) {
    if (_isSyncingSl) return;
    final points = double.tryParse(value);
    if (points == null || points <= 0) {
      _isSyncingSl = true;
      _slPriceController.clear();
      _isSyncingSl = false;
      return;
    }
    final entryPrice = double.tryParse(
      _entryPriceController.text.replaceAll(',', ''),
    );
    if (entryPrice == null || entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.symbol);
    final isBuy = _executionType.value.toLowerCase().contains('buy');
    final slPrice = isBuy
        ? entryPrice - (points * pointValue)
        : entryPrice + (points * pointValue);
    _isSyncingSl = true;
    _slPriceController.text = _formatPrice(slPrice, widget.symbol);
    _isSyncingSl = false;
  }

  /// Sync SL Points dari SL Prices
  void _syncSlPointsFromPrice(String value) {
    if (_isSyncingSl) return;
    final slPrice = double.tryParse(value.replaceAll(',', ''));
    if (slPrice == null || slPrice <= 0) {
      _isSyncingSl = true;
      _slPointsController.clear();
      _isSyncingSl = false;
      return;
    }
    final entryPrice = double.tryParse(
      _entryPriceController.text.replaceAll(',', ''),
    );
    if (entryPrice == null || entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.symbol);
    final isBuy = _executionType.value.toLowerCase().contains('buy');
    final points = isBuy
        ? (entryPrice - slPrice) / pointValue
        : (slPrice - entryPrice) / pointValue;
    if (points < 0) {
      _isSyncingSl = true;
      _slPointsController.clear();
      _isSyncingSl = false;
      return;
    }
    _isSyncingSl = true;
    _slPointsController.text = points.round().toString();
    _isSyncingSl = false;
  }

  /// Sync TP Prices dari TP Points
  void _syncTpPriceFromPoints(String value) {
    if (_isSyncingTp) return;
    final points = double.tryParse(value);
    if (points == null || points <= 0) {
      _isSyncingTp = true;
      _tpPriceController.clear();
      _isSyncingTp = false;
      return;
    }
    final entryPrice = double.tryParse(
      _entryPriceController.text.replaceAll(',', ''),
    );
    if (entryPrice == null || entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.symbol);
    final isBuy = _executionType.value.toLowerCase().contains('buy');
    final tpPrice = isBuy
        ? entryPrice + (points * pointValue)
        : entryPrice - (points * pointValue);
    _isSyncingTp = true;
    _tpPriceController.text = _formatPrice(tpPrice, widget.symbol);
    _isSyncingTp = false;
  }

  /// Sync TP Points dari TP Prices
  void _syncTpPointsFromPrice(String value) {
    if (_isSyncingTp) return;
    final tpPrice = double.tryParse(value.replaceAll(',', ''));
    if (tpPrice == null || tpPrice <= 0) {
      _isSyncingTp = true;
      _tpPointsController.clear();
      _isSyncingTp = false;
      return;
    }
    final entryPrice = double.tryParse(
      _entryPriceController.text.replaceAll(',', ''),
    );
    if (entryPrice == null || entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.symbol);
    final isBuy = _executionType.value.toLowerCase().contains('buy');
    final points = isBuy
        ? (tpPrice - entryPrice) / pointValue
        : (entryPrice - tpPrice) / pointValue;
    if (points < 0) {
      _isSyncingTp = true;
      _tpPointsController.clear();
      _isSyncingTp = false;
      return;
    }
    _isSyncingTp = true;
    _tpPointsController.text = points.round().toString();
    _isSyncingTp = false;
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

  /// Get number of decimal places based on symbol type
  int _getDigitsForSymbol(String symbol) {
    final symbolUpper = symbol.toUpperCase();

    // Gold (XAU) - 2 decimal places
    if (symbolUpper.contains('XAU') || symbolUpper.contains('GOLD')) {
      return 2;
    }

    // Silver (XAG) - 3 decimal places
    if (symbolUpper.contains('XAG') || symbolUpper.contains('SILVER')) {
      return 3;
    }

    // JPY pairs - 3 decimal places
    if (symbolUpper.contains('JPY')) {
      return 3;
    }

    // Indices - 2 decimal places
    if (symbolUpper.contains('US30') ||
        symbolUpper.contains('NAS') ||
        symbolUpper.contains('SPX') ||
        symbolUpper.contains('DAX') ||
        symbolUpper.contains('UK100')) {
      return 2;
    }

    // Default for Forex pairs - 5 decimal places
    return 5;
  }

  /// Format price with correct number of digits based on symbol
  String _formatPrice(double price, String symbol) {
    final digits = _getDigitsForSymbol(symbol);
    return price.toStringAsFixed(digits);
  }

  /// Format price with leading zeros (ATM style: 0000.00)
  /// referencePrice digunakan untuk menentukan jumlah digit integer
  String _formatPriceWithLeadingZeros(double price, String symbol, {double? referencePrice}) {
    final digits = _getDigitsForSymbol(symbol);
    
    // Hitung jumlah digit integer berdasarkan referencePrice atau current price
    int integerDigits = 4; // default
    if (referencePrice != null && referencePrice > 0) {
      // Hitung berapa digit integer dari reference price
      integerDigits = referencePrice.truncate().toString().length;
    }
    
    String formatted = price.toStringAsFixed(digits);
    List<String> parts = formatted.split('.');
    String intPart = parts[0].padLeft(integerDigits, '0');
    String decPart = parts.length > 1 ? parts[1] : ''.padRight(digits, '0');
    
    return '$intPart.$decPart';
  }

  /// Get increment value based on symbol decimal places
  double _getIncrementForSymbol(String symbol) {
    final digits = _getDigitsForSymbol(symbol);
    switch (digits) {
      case 2:
        return 0.01; // Gold, Indices
      case 3:
        return 0.001; // Silver, JPY pairs
      case 5:
      default:
        return 0.00001; // Forex pairs
    }
  }

  /// Increment entry price
  void _incrementEntryPrice() {
    final currentText = _entryPriceController.text;
    final currentValue = double.tryParse(currentText) ?? 0.0;
    final increment = _getIncrementForSymbol(widget.symbol);
    final newValue = currentValue + increment;
    _entryPriceController.text = _formatPrice(newValue, widget.symbol);
    HapticFeedback.lightImpact();
  }

  /// Decrement entry price
  void _decrementEntryPrice() {
    final currentText = _entryPriceController.text;
    final currentValue = double.tryParse(currentText) ?? 0.0;
    final increment = _getIncrementForSymbol(widget.symbol);
    final newValue = currentValue - increment;
    if (newValue >= 0) {
      _entryPriceController.text = _formatPrice(newValue, widget.symbol);
      HapticFeedback.lightImpact();
    }
  }

  /// Validate entry price based on order type
  /// Returns Map with 'isValid' (bool) and 'message' (String)
  Map<String, dynamic> _validateEntryPrice({
    required String executionType,
    required double entryPrice,
    required double currentPrice,
    required double stopLevel,
    required int digits,
  }) {
    String formatPrice(double price) => price.toStringAsFixed(digits);
    
    switch (executionType) {
      case 'Buy Limit':
        // Entry price harus DI BAWAH current price dengan minimal stopLevel
        if (entryPrice >= currentPrice) {
          return {
            'isValid': false,
            'message':
                'Buy Limit: Entry Price harus di BAWAH harga saat ini (${formatPrice(currentPrice)})',
          };
        }
        if ((currentPrice - entryPrice) < stopLevel) {
          return {
            'isValid': false,
            'message':
                'Buy Limit: Entry Price minimal ${stopLevel.toString()} di bawah harga saat ini.\nMinimal: ${formatPrice(currentPrice - stopLevel)}',
          };
        }
        break;

      case 'Sell Limit':
        // Entry price harus DI ATAS current price dengan minimal stopLevel
        if (entryPrice <= currentPrice) {
          return {
            'isValid': false,
            'message':
                'Sell Limit: Entry Price harus di ATAS harga saat ini (${formatPrice(currentPrice)})',
          };
        }
        if ((entryPrice - currentPrice) < stopLevel) {
          return {
            'isValid': false,
            'message':
                'Sell Limit: Entry Price minimal ${stopLevel.toString()} di atas harga saat ini.\nMinimal: ${formatPrice(currentPrice + stopLevel)}',
          };
        }
        break;

      case 'Buy Stop':
        // Entry price harus DI ATAS current price dengan minimal stopLevel
        if (entryPrice <= currentPrice) {
          return {
            'isValid': false,
            'message':
                'Buy Stop: Entry Price harus di ATAS harga saat ini (${formatPrice(currentPrice)})',
          };
        }
        if ((entryPrice - currentPrice) < stopLevel) {
          return {
            'isValid': false,
            'message':
                'Buy Stop: Entry Price minimal ${stopLevel.toString()} di atas harga saat ini.\nMinimal: ${formatPrice(currentPrice + stopLevel)}',
          };
        }
        break;

      case 'Sell Stop':
        // Entry price harus DI BAWAH current price dengan minimal stopLevel
        if (entryPrice >= currentPrice) {
          return {
            'isValid': false,
            'message':
                'Sell Stop: Entry Price harus di BAWAH harga saat ini (${formatPrice(currentPrice)})',
          };
        }
        if ((currentPrice - entryPrice) < stopLevel) {
          return {
            'isValid': false,
            'message':
                'Sell Stop: Entry Price minimal ${stopLevel.toString()} di bawah harga saat ini.\nMinimal: ${formatPrice(currentPrice - stopLevel)}',
          };
        }
        break;
    }

    return {'isValid': true, 'message': ''};
  }
}

/// Custom TextInputFormatter untuk input style ATM/Calculator
/// Digit masuk dari kanan dan bergeser ke kiri
/// Contoh (2 desimal): 0000.00 -> 0000.05 -> 0000.50 -> 0005.02 -> ...
class PriceShiftInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final int integerDigits;

  PriceShiftInputFormatter({
    required this.decimalPlaces,
    this.integerDigits = 4, // Default 4 digit integer
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ambil hanya digit dari input baru
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Jika kosong, kembalikan format zero
    if (digits.isEmpty) {
      final zero = _formatNumber(0);
      return TextEditingValue(
        text: zero,
        selection: TextSelection.collapsed(offset: zero.length),
      );
    }

    // Parse sebagai integer untuk shift calculation
    int value = int.tryParse(digits) ?? 0;

    // Format dengan desimal yang benar
    String formatted = _formatNumber(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int value) {
    // Konversi ke double dengan pembagian berdasarkan desimal
    double divisor = 1.0;
    for (int i = 0; i < decimalPlaces; i++) {
      divisor *= 10;
    }
    double result = value / divisor;

    // Format dengan leading zeros
    String formatted = result.toStringAsFixed(decimalPlaces);

    // Pad integer part dengan leading zeros
    List<String> parts = formatted.split('.');
    String intPart = parts[0].padLeft(integerDigits, '0');
    String decPart = parts.length > 1 ? parts[1] : ''.padRight(decimalPlaces, '0');

    return '$intPart.$decPart';
  }
}
