import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import '../controllers/chart_execution_controller.dart';

class ChartTradingPanel extends StatefulWidget {
  final String login;
  final String symbol;
  final Function(String operation)? onOrderExecuted;

  const ChartTradingPanel({
    super.key,
    required this.login,
    required this.symbol,
    this.onOrderExecuted,
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

   @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    _audioPlayer.dispose();
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: operation == 'buy' ? Colors.green : Colors.red,
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: operation == 'buy' ? Colors.green : Colors.red,
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
          if (openPrice != null) ...[
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
              openPrice.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: operation == 'buy' ? Colors.green : Colors.red,
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
                  operation == 'buy' ? Colors.green : Colors.red,
                ),
              ),
            )
          else if (status == 'success')
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: operation == 'buy' ? Colors.green : Colors.red,
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
      
      // Show error snackbar with more details
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (errorMsg.contains('524')) {
          errorMsg = 'Server timeout. Coba lagi dalam beberapa saat.';
        } else if (errorMsg.contains('500')) {
          errorMsg = 'Server error. Silakan coba lagi.';
        }
        
        Get.snackbar(
          'Order Gagal',
          errorMsg,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          icon: const Icon(Iconsax.close_circle_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
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
        child: Obx(() => Row(
          children: [
            // SELL button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _executeSell,
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade500,
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
                      'SELL',
                      style: GoogleFonts.inter(
                        fontSize: 14,
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
                onTap: _executeBuy,
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade500,
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
                      'BUY',
                      style: GoogleFonts.inter(
                        fontSize: 14,
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
        )),
      ),
    );
  }
}
