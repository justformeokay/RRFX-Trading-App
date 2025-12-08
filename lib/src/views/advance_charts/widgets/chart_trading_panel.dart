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

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
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

  Future<void> _executeBuy() async {
    try {
      await executionController.executeBuy(
        login: widget.login,
        symbol: widget.symbol,
      );
      
      if (mounted) {
        Get.snackbar(
          'Order Berhasil',
          'BUY ${widget.symbol.replaceAll('.db', '')} @ ${executionController.lot.value} lot',
          backgroundColor: Colors.green.shade800,
          colorText: Colors.white,
          icon: Icon(Iconsax.tick_circle_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        widget.onOrderExecuted?.call('buy');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Order Gagal',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          icon: Icon(Iconsax.close_circle_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _executeSell() async {
    try {
      await executionController.executeSell(
        login: widget.login,
        symbol: widget.symbol,
      );
      
      if (mounted) {
        Get.snackbar(
          'Order Berhasil',
          'SELL ${widget.symbol.replaceAll('.db', '')} @ ${executionController.lot.value} lot',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          icon: Icon(Iconsax.tick_circle_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        widget.onOrderExecuted?.call('sell');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Order Gagal',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          icon: Icon(Iconsax.close_circle_bold, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
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
        child: Obx(() => Row(
          children: [
            // SELL button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: executionController.isExecuting.value ? null : _executeSell,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: executionController.isExecuting.value
                          ? [
                              Colors.red.shade300.withOpacity(0.5),
                              Colors.red.shade400.withOpacity(0.5),
                            ]
                          : [
                              Colors.red.shade400,
                              Colors.red.shade500,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: executionController.isExecuting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'SELL',
                            style: GoogleFonts.inter(
                              fontSize: 20,
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
              flex: 2,
              child: Container(
                height: 56,
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
                            fontSize: 20,
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
                onTap: executionController.isExecuting.value ? null : _executeBuy,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: executionController.isExecuting.value
                          ? [
                              Colors.green.shade300.withOpacity(0.5),
                              Colors.green.shade400.withOpacity(0.5),
                            ]
                          : [
                              Colors.green.shade400,
                              Colors.green.shade500,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: executionController.isExecuting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'BUY',
                            style: GoogleFonts.inter(
                              fontSize: 20,
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
