import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
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
  
  Timer? _incrementTimer;
  Timer? _decrementTimer;
  
  // Queue untuk mengelola multiple executions
  final RxList<Map<String, dynamic>> _executionQueue = <Map<String, dynamic>>[].obs;
  bool _isProcessingQueue = false;
  
OverlayEntry? _overlayEntry;

   @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
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

  Widget _buildExecutionItem(Map<String, dynamic> item) {
    final symbolClean = widget.symbol.replaceAll('.db', '');
    final operation = item['operation'] as String;
    final lot = item['lot'] as double;
    final status = item['status'] as String; // 'loading', 'success', 'error'
    
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
        bottom: 80,
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
      if (operation == 'buy') {
        await executionController.executeBuy(
          login: widget.login,
          symbol: widget.symbol,
        );
      } else {
        await executionController.executeSell(
          login: widget.login,
          symbol: widget.symbol,
        );
      }
      
      // Update status to success
      final index = _executionQueue.indexWhere((e) => e['id'] == item['id']);
      if (index != -1) {
        _executionQueue[index]['status'] = 'success';
        _executionQueue.refresh();
      }
      
      // Remove after 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
      _executionQueue.removeWhere((e) => e['id'] == item['id']);
      
      if (mounted) {
        widget.onOrderExecuted?.call(operation);
      }
      
    } catch (e) {
      // Update status to error
      final index = _executionQueue.indexWhere((e) => e['id'] == item['id']);
      if (index != -1) {
        _executionQueue[index]['status'] = 'error';
        _executionQueue.refresh();
      }
      
      // Show error snackbar
      if (mounted) {
        Get.snackbar(
          'Order Gagal',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          icon: const Icon(Iconsax.close_circle_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
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
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 2,
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
