import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/advance_charts/widgets/pending_order_sheets.dart';
import '../controllers/chart_execution_controller.dart';

class ChartTradingPanel extends StatefulWidget {
  final String login;
  final String symbol;
  final Function(String operation)? onOrderExecuted;
  final RxnDouble? currentPrice;
  final RxString? bidObs;
  final RxString? askObs;

  const ChartTradingPanel({
    super.key,
    required this.login,
    required this.symbol,
    this.onOrderExecuted,
    this.currentPrice,
    this.bidObs,
    this.askObs,
  });

  @override
  State<ChartTradingPanel> createState() => _ChartTradingPanelState();
}

class _ChartTradingPanelState extends State<ChartTradingPanel> {
  final executionController = Get.put(ChartExecutionController());
  // AudioPool? _audioPool;

  Timer? _incrementTimer;
  Timer? _decrementTimer;

  // Queue untuk mengelola multiple executions
  final RxList<Map<String, dynamic>> _executionQueue =
      <Map<String, dynamic>>[].obs;

  // Per-item reactive status — keyed by item['id'] (int for market, String for pending).
  // Updating a single entry here does NOT rebuild the entire queue overlay.
  final _itemStatuses = <dynamic, RxString>{};

  // Concurrency limit untuk scalping — 8 slot parallel.
  // http.get() top-level membuat koneksi baru per call (tidak ada pool/shared client),
  // sehingga tidak ada batas teknis di sisi client. Batas aktual ada di server MT5 API
  // (techcrm/gaintactics) — turunkan jika muncul error 429 atau INVALID_TOKEN massal.
  static const int _maxConcurrentOrders = 10;
  int _activeOrders = 0;

  OverlayEntry? _overlayEntry;

  // Global variable untuk lot step increment/decrement
  static const double LOT_STEP = 0.10;

  // Execution type tracking
  late RxString _executionType = 'Execution Market'.obs;

  // Market order SL/TP
  final RxBool _showMarketSlTp = false.obs;
  final TextEditingController _marketSlController = TextEditingController();
  final TextEditingController _marketTpController = TextEditingController();

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
    // Init AudioPool — 4 instance concurrent, no conflict saat rapid tap
    // AudioPool.create(
    //   source: AssetSource('sounds/applepay.mp3'),
    //   maxPlayers: 4,
    // ).then((pool) {
    //   if (mounted) _audioPool = pool;
    // });
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
    // _audioPool?.dispose();
    // _audioPool = null;
    _entryPriceController.dispose();
    _slPointsController.dispose();
    _slPriceController.dispose();
    _tpPointsController.dispose();
    _tpPriceController.dispose();
    _marketSlController.dispose();
    _marketTpController.dispose();
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        // print('Error removing overlay on dispose: $e');
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

  /// Success notification — sound and haptic disabled.
  void _playSuccessNotification() {}

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
    final itemId = item['id'];
    final itemSymbol = item['symbol'] as String? ?? widget.symbol;
    final symbolClean = itemSymbol.replaceAll('.db', '');
    final operation = item['operation'] as String;
    final lot = item['lot'] as double;
    final pendingPrice = item['price']; // For pending orders

    // Determine color based on operation type
    final isBuyOperation = operation.toLowerCase().contains('buy');
    final operationColor = isBuyOperation ? Colors.green : Colors.red;
    // Cache theme once — theme cannot change between frames.
    final isDark = Get.isDarkMode;

    // Obx watches only this item's RxString — other items won't rebuild.
    return Obx(() {
      final status = _itemStatuses[itemId]?.value ?? 'loading';
      final openPrice = item['openPrice'];
      final execMs = item['execMs'] as int?;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                        color: isDark ? Colors.white : Colors.black,
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
                      color: isDark ? Colors.white70 : Colors.black87,
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
                        color: isDark ? Colors.white38 : Colors.black38,
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
            else if (status == 'success') ...[
              if (execMs != null && GlobalVariable.showExecutionSpeed) ...[
                Text(
                  '${execMs}ms',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: execMs < 3000
                        ? Colors.green
                        : execMs < 5000
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
              ],
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
              ),
            ]
            else if (status == 'error')
              const Icon(Icons.close_rounded, color: Colors.red, size: 16),
          ],
        ),
      );
    });
  }

  void _addToQueue(String operation) {
    final lot = executionController.lot.value;

    // Capture SL/TP values for market orders
    double? sl;
    double? tp;
    if (_showMarketSlTp.value) {
      final slText = _marketSlController.text.trim();
      final tpText = _marketTpController.text.trim();
      if (slText.isNotEmpty) sl = double.tryParse(slText);
      if (tpText.isNotEmpty) tp = double.tryParse(tpText);
    }

    final newItem = {
      'operation': operation,
      'lot': lot,
      'symbol': widget.symbol,  // Simpan symbol agar tidak berubah saat pindah market
      'status': 'loading',
      'id': DateTime.now().millisecondsSinceEpoch,
      if (sl != null) 'sl': sl,
      if (tp != null) 'tp': tp,
    };

    _executionQueue.add(newItem);
    _itemStatuses[newItem['id']] = RxString('loading');

    // Show overlay entry
    _showQueueOverlay();

    // Fire immediately in parallel — don't wait for previous orders
    _executeItem(newItem);
  }

  void _showQueueOverlay() {
    // Jika overlay sudah ada dan ter-mount, Obx() di dalamnya otomatis
    // merender ulang saat _executionQueue berubah — tidak perlu recreate.
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 140,
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
                        // Overlay already removed
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
    } catch (_) {
      // Overlay already removed or context unavailable
    }
  }

  Future<void> _executeItem(Map<String, dynamic> item) async {
    final operation = item['operation'] as String;
    final itemSymbol = item['symbol'] as String? ?? widget.symbol;
    final itemId = item['id'];
    final sl = item['sl'] as double?;
    final tp = item['tp'] as double?;

    // Jika sudah mencapai batas concurrent, tandai item sebagai error langsung.
    if (_activeOrders >= _maxConcurrentOrders) {
      _itemStatuses[itemId]?.value = 'error';
      if (mounted) {
        ModernAlertDialog.error(
          title: 'Terlalu Banyak Order',
          message: 'Maksimal $_maxConcurrentOrders order bersamaan. Coba lagi sesaat.',
          onPressed: () => Get.back(),
        );
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      _itemStatuses.remove(itemId);
      _executionQueue.removeWhere((e) => e['id'] == itemId);
      return;
    }

    _activeOrders++;
    try {
      final stopwatch = Stopwatch()..start();

      Map<String, dynamic> response;
      if (operation == 'buy') {
        response = await executionController.executeBuy(
          login: widget.login,
          symbol: itemSymbol,
          sl: sl,
          tp: tp,
        );
      } else {
        response = await executionController.executeSell(
          login: widget.login,
          symbol: itemSymbol,
          sl: sl,
          tp: tp,
        );
      }

      stopwatch.stop();
      final execMs = stopwatch.elapsedMilliseconds;

      // Extract openPrice from response
      final openPrice = response['response']?['openPrice'];

      // Update status to success and add openPrice
      final index = _executionQueue.indexWhere((e) => e['id'] == itemId);
      if (index != -1) {
        _executionQueue[index]['openPrice'] = openPrice;
        _executionQueue[index]['execMs'] = execMs;
        _itemStatuses[itemId]?.value = 'success';
      }

      // Play success notification (sound + haptic) — fire-and-forget
      _playSuccessNotification();

      // Remove after 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
      _itemStatuses.remove(itemId);
      _executionQueue.removeWhere((e) => e['id'] == itemId);

      if (mounted) {
        widget.onOrderExecuted?.call(operation);
      }
    } catch (e) {
      // Update status to error
      final index = _executionQueue.indexWhere((e) => e['id'] == itemId);
      if (index != -1) {
        _itemStatuses[itemId]?.value = 'error';
      }

      // Show error popup dengan ModernAlertDialog
      if (mounted) {
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
      _itemStatuses.remove(itemId);
      _executionQueue.removeWhere((e) => e['id'] == itemId);
    } finally {
      _activeOrders--;
    }
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
                        onTap: () async {
                          if (kDebugMode) print("Selected execution type: $type");
                          _executionType.value = type;
                          
                          if (type == 'Execution Market') {
                            _lastAutoShownType = null;
                            Navigator.pop(context);
                            return;
                          }

                          // Tutup menu pilihan dulu
                          Get.back();

                          // Berikan sedikit jeda agar animasi penutupan selesai
                          await Future.delayed(const Duration(milliseconds: 550));

                          // Baru buka config yang baru
                          openPendingOrderConfig(type);
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
                    }),

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

  
  void openPendingOrderConfig(String selectedType) {
    // 1. Ambil harga awal dari widget.bid, jika null atau 0 gunakan default 0
    final double initialPrice = double.tryParse(widget.bidObs?.value ?? '0') ?? 0;

    Get.dialog(
      PendingOrderDialog(
        symbol: widget.symbol,
        type: selectedType,
        initialPrice: initialPrice,
        digits: _getDigitsForSymbol(widget.symbol), // Gunakan fungsi dinamis untuk digit
        onConfirm: (entry, sl, tp) {
          if (kDebugMode) print("SL: $sl, TP: $tp");
          // 2. Simpan hasil input dari sheet ke controller utama jika diperlukan
          // SL/TP dari dialog adalah PRICE — simpan ke _slPriceController/_tpPriceController
          _slPriceController.text = sl != null ? _formatPrice(sl, widget.symbol) : '';
          _tpPriceController.text = tp != null ? _formatPrice(tp, widget.symbol) : '';
          _slPointsController.text = ''; // clear points fields
          _tpPointsController.text = '';
          _entryPriceController.text = _formatPrice(entry, widget.symbol);
          if (kDebugMode) print("Entry Price set to: ${_entryPriceController.text}");
          if (kDebugMode) print("SL Points Controller: ${_slPointsController.text}, TP Points Controller: ${_tpPointsController.text}");
          
          // 3. Eksekusi Order
          final side = selectedType.toLowerCase().contains('buy') ? 'buy' : 'sell';
          _executePendingOrder(side);
          
          // Navigator.pop tidak perlu jika sudah pakai Get.back() di dalam onConfirm 
          // tapi jika ingin memastikan sheet tertutup:
          if (Get.isBottomSheetOpen ?? false) Get.back();
        },
      ),
    );
  }

  Widget _buildMarketSlTpFields(bool isDark) {
    return Obx(() {
      if (_executionType.value != 'Execution Market') {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          // Toggle row
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showMarketSlTp.value = !_showMarketSlTp.value;
              if (!_showMarketSlTp.value) {
                _marketSlController.clear();
                _marketTpController.clear();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.shield_tick_bold,
                    size: 14,
                    color: _showMarketSlTp.value
                        ? Colors.blue
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SL / TP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _showMarketSlTp.value
                          ? Colors.blue
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _showMarketSlTp.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SL/TP input fields
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _showMarketSlTp.value
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Stop Loss field
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.red.shade900.withOpacity(0.2)
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.red.shade700.withOpacity(0.4)
                                    : Colors.red.shade200,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'SL',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 0.5,
                                  height: 20,
                                  color: isDark
                                      ? Colors.red.shade700.withOpacity(0.4)
                                      : Colors.red.shade200,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _marketSlController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Price',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 0,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Take Profit field
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.green.shade900.withOpacity(0.2)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.green.shade700.withOpacity(0.4)
                                    : Colors.green.shade200,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'TP',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 0.5,
                                  height: 20,
                                  color: isDark
                                      ? Colors.green.shade700.withOpacity(0.4)
                                      : Colors.green.shade200,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _marketTpController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Price',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 0,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
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
              // _buildPendingOrderFields(isDark), // saya komentari karena sekarang kita pakai dialog terpisah untuk pending order

              // Market order SL/TP fields
              _buildMarketSlTpFields(isDark),
              Row(
                children: [
                  // SELL button
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: _executionType.value == 'Execution Market'
                          ? _executeSell
                          : () => openPendingOrderConfig(_executionType.value),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _executionType.value == 'Execution Market' 
                                    ? 'SELL' 
                                    : _executionType.value.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: _executionType.value == 'Execution Market' ? 14 : 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (widget.askObs != null)
                                Obx(() => Text(
                                  widget.askObs!.value,
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
                                ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Lot selector in the middle
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) => _startDecrementTimer(),
                              onTapUp: (_) => _stopDecrementTimer(),
                              onTapCancel: _stopDecrementTimer,
                              child: Center(
                                child: Text('-', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showEditLotDialog,
                              child: Center(
                                child: Text(
                                  executionController.lot.value.toStringAsFixed(1),
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) => _startIncrementTimer(),
                              onTapUp: (_) => _stopIncrementTimer(),
                              onTapCancel: _stopIncrementTimer,
                              child: Center(
                                child: Text('+', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
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
                          : () => openPendingOrderConfig(_executionType.value),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _executionType.value == 'Execution Market' 
                                    ? 'BUY' 
                                    : _executionType.value.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: _executionType.value == 'Execution Market' ? 14 : 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (widget.bidObs != null)
                                Obx(() => Text(
                                  widget.bidObs!.value,
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
                                ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
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

    // API sekarang menerima SL/TP dalam bentuk PRICE (bukan points lagi)
    // Prioritas: ambil dari _slPriceController, jika kosong maka konversi dari _slPointsController
    double? slPrice;
    double? tpPrice;

    final slPointsText = _slPointsController.text.replaceAll(',', '');
    final tpPointsText = _tpPointsController.text.replaceAll(',', '');
    final slPriceText = _slPriceController.text.replaceAll(',', '');
    final tpPriceText = _tpPriceController.text.replaceAll(',', '');

    // SL Price
    if (slPriceText.isNotEmpty) {
      final parsed = double.tryParse(slPriceText);
      if (parsed != null && parsed > 0) slPrice = parsed;
    } else if (slPointsText.isNotEmpty) {
      // Konversi dari points ke price
      final slPts = double.tryParse(slPointsText);
      if (slPts != null && slPts > 0) {
        final pointValue = _getPointValue(capturedSymbol);
        final isBuy = direction == 'buy';
        slPrice = isBuy
            ? entryPrice - (slPts * pointValue)
            : entryPrice + (slPts * pointValue);
      }
    }

    // TP Price
    if (tpPriceText.isNotEmpty) {
      final parsed = double.tryParse(tpPriceText);
      if (parsed != null && parsed > 0) tpPrice = parsed;
    } else if (tpPointsText.isNotEmpty) {
      // Konversi dari points ke price
      final tpPts = double.tryParse(tpPointsText);
      if (tpPts != null && tpPts > 0) {
        final pointValue = _getPointValue(capturedSymbol);
        final isBuy = direction == 'buy';
        tpPrice = isBuy
            ? entryPrice + (tpPts * pointValue)
            : entryPrice - (tpPts * pointValue);
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
      'sl': slPrice,
      'tp': tpPrice,
      'status': 'loading',
      'openPrice': null,
    });

    _itemStatuses[id] = RxString('loading');
    // Show overlay if not already showing
    _showQueueOverlay();

    // Concurrency guard — same limit as market orders
    if (_activeOrders >= _maxConcurrentOrders) {
      _itemStatuses[id]?.value = 'error';
      if (mounted) {
        ModernAlertDialog.error(
          title: 'Terlalu Banyak Order',
          message: 'Maksimal $_maxConcurrentOrders order bersamaan. Coba lagi sesaat.',
          onPressed: () => Get.back(),
        );
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      _itemStatuses.remove(id);
      _executionQueue.removeWhere((e) => e['id'] == id);
      return;
    }
    _activeOrders++;

    try {
      final stopwatch = Stopwatch()..start();

      final response = await executionController.executePendingOrder(
        login: widget.login,
        symbol: capturedSymbol,  // Gunakan captured symbol
        operation: operation,
        price: entryPrice,
        volume: lot,
        sl: slPrice,
        tp: tpPrice,
      );

      stopwatch.stop();
      final execMs = stopwatch.elapsedMilliseconds;

      // Extract response data
      final responseData = response['response'];
      final orderTicket = responseData?['order'] ?? responseData?['ticket'];

      // Update status to success
      final index = _executionQueue.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        _executionQueue[index]['ticket'] = orderTicket;
        _executionQueue[index]['execMs'] = execMs;
        _itemStatuses[id]?.value = 'success';
      }

      // Play success notification — fire-and-forget
      _playSuccessNotification();

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
      _itemStatuses.remove(id);
      _executionQueue.removeWhere((e) => e['id'] == id);

      // Callback
      if (mounted) {
        widget.onOrderExecuted?.call(operation);
      }
    } catch (e) {
      // Update status to error
      final index = _executionQueue.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        _itemStatuses[id]?.value = 'error';
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
      _itemStatuses.remove(id);
      _executionQueue.removeWhere((e) => e['id'] == id);
    } finally {
      _activeOrders--;
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
