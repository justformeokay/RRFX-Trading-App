import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/account_balance_ws_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/websocket_controller.dart';
import 'package:rrfx/src/helpers/error_handler.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';
import 'package:rrfx/src/views/transactions/views/popup_close_order.dart';
import 'package:rrfx/src/views/transactions/views/edit_position_page.dart';

class OpenTransactonMeta5 extends StatefulWidget {
  const OpenTransactonMeta5({super.key});

  @override
  State<OpenTransactonMeta5> createState() => _OpenTransactonMeta5State();
}

class _OpenTransactonMeta5State extends State<OpenTransactonMeta5> {
  // ✅ Gunakan Get.find() karena controller sudah di-register saat login/main
  // Get.put() akan re-trigger onInit() jika controller pernah di-delete,
  // yang menyebabkan GET /account/info dipanggil berulang-ulang.
  late final TradingController tradingController;
  late final AccountController controller;
  late final AccountBalanceWSController accountWS;
  late final MarketWebSocketController marketWS;

  Worker? _accountListener;
  String? _lastLoadedLogin;
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();

    // ✅ Safe find: gunakan existing instance, hanya put() jika belum terdaftar
    tradingController = Get.isRegistered<TradingController>()
        ? Get.find<TradingController>()
        : Get.put(TradingController());
    controller = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());
    accountWS = Get.isRegistered<AccountBalanceWSController>()
        ? Get.find<AccountBalanceWSController>()
        : Get.put(AccountBalanceWSController(), permanent: true);
    marketWS = Get.isRegistered<MarketWebSocketController>()
        ? Get.find<MarketWebSocketController>()
        : Get.put(MarketWebSocketController(), permanent: true);

    // Setup listener ONCE for account changes
    _accountListener = ever(controller.selectedAccount, (account) {
      if (account != null) {
        final newLogin = account.login;

        // Only reload if account actually changed
        if (_lastLoadedLogin != newLogin) {
          // Clear old data immediately to prevent blinking
          tradingController.openOrderModel.value = null;
          accountWS.profit.value = 0.0;

          // Then load new data
          _loadOrders();
          _subscribeToAccountWS();

          _lastLoadedLogin = newLogin;
        }
      }
    });

    // Initial load — skip jika data sudah ada di cache dari page lain
    if (controller.selectedAccount.value != null) {
      _lastLoadedLogin = controller.selectedAccount.value!.login;

      // ✅ Hanya panggil API jika data belum ada atau login berbeda
      final cachedLogin = tradingController.openOrderModel.value?.response != null
          ? controller.selectedAccount.value!.login
          : null;
      if (tradingController.openOrderModel.value == null || cachedLogin != _lastLoadedLogin) {
        _loadOrders();
      }

      // ✅ Hanya subscribe WS jika belum connected ke akun yang sama
      _subscribeToAccountWS();
    }
  }

  @override
  void dispose() {
    // Dispose listener to prevent memory leaks
    _accountListener?.dispose();
    super.dispose();
  }

  void _subscribeToAccountWS() {
    if (!controller.hasAccounts) return;

    final login = controller.selectedAccount.value?.login;
    final serverType = controller.selectedAccount.value?.type;

    if (login != null && serverType != null) {
      accountWS.subscribe(login: login, serverType: serverType);
      print('✅ Subscribed to account WS: login=$login, server=$serverType');
    }
  }

  Future<void> _loadOrders() async {
    // Prevent duplicate API calls
    if (_isLoadingOrders) {
      // print('⏸️ [OpenTransaction] Already loading orders, skipping...');
      return;
    }

    if (!controller.hasAccounts) {
      Get.log("TIDAK MEMILIKI AKUN TRADING DEMO MAUPUN REAL");
      return;
    }

    String? loginID = controller.selectedAccount.value?.login;
    if (loginID == null) return;

    try {
      _isLoadingOrders = true;
      await tradingController.openOrder(login: loginID);
    } finally {
      _isLoadingOrders = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force rebuild when account changes to prevent showing old data
    final currentLogin = controller.selectedAccount.value?.login ?? '';

    return Obx(() {
      if (!controller.hasAccounts) return noAccountDetected();

      var opened = tradingController.openOrderModel.value?.response;

      return Scaffold(
        key: ValueKey(currentLogin), // Force rebuild on account change
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _BalanceHeaderDelegate(),
            ),

            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Text(
                  "Positions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Show loading indicator or positions list
            if (opened == null)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                ),
              )
            else if (opened.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Tambahkan agar Column tidak mengambil ruang berlebih
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon dengan gradient
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              CustomColor.secondaryColor.withValues(alpha: 0.15),
                              Colors.blue.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Iconsax.chart_21_outline,
                            size: 60,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Open Positions",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You don't have any active trading positions at the moment.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Info cards
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              icon: Iconsax.chart_outline,
                              title: "Start Trading",
                              description: "Open a new position from the chart or market list",
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              height: 1,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              icon: Iconsax.refresh_outline,
                              title: "Real-time Updates",
                              description: "Your positions will appear here automatically",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50), // Tambahkan padding bawah ekstra agar nyaman di-scroll
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _PositionTile(
                    index: index,
                    digits: opened[index].digits != null ? int.tryParse("${opened[index].digits}") : null,
                    positionId: "${opened[index].ticket}",
                    openTime: "${opened[index].openTime}",
                    swap: "${opened[index].swap}",
                    stopLoss: "${opened[index].stopLoss}",
                    takeProfit: "${opened[index].takeProfit}",
                    doubleProfit: -0.10 * index,
                    profit: opened[index].profit != null ? "${opened[index].profit}" : "0.00",
                    symbol: "${opened[index].symbol}",
                    direction: "${opened[index].orderType}",
                    volume: "${opened[index].lot}",
                    openPrice: "${opened[index].openPrice}",
                    closePrice: "-",
                    currentPrice: "${opened[index].currentPrice}",
                  );
                }, childCount: opened.length),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: CustomColor.secondaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- BALANCE SECTION --------------------
class _BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 170;

  @override
  double get maxExtent => 170;

  final accountController = Get.find<AccountController>();
  final accountWS = Get.find<AccountBalanceWSController>();

  String _formatNumber(String? value) {
    if (value == null || value == "N/A") return "N/A";
    final number = double.tryParse(value);
    if (number == null) return value;
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(number).replaceAll(',', ' ');
  }

  String _formatProfit(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      // Tambahkan SingleChildScrollView untuk membungkus Column
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Biarkan Sliver yang menangani scroll utama
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _balanceRow("Account ID", accountController.selectedAccount.value?.login ?? "N/A", context)),
            Obx(() {
              final tradingController = Get.find<TradingController>();
              if (!(tradingController.openOrderModel.value?.response?.isNotEmpty ?? false)) return const SizedBox.shrink();
              return _balanceRow("Profit", _formatProfit(accountWS.profit.value), context, color: accountWS.profit.value >= 0 ? Colors.blue : Colors.red.shade400);
            }),
            Obx(() => _balanceRow("Balance", _formatNumber(accountController.selectedAccount.value?.balance), context)),
            Obx(() => _balanceRow("Equity", _formatNumber(accountController.selectedAccount.value?.equity), context)),
            Obx(() => _balanceRow("Margin", _formatNumber(accountController.selectedAccount.value?.margin), context)),
            Obx(() => _balanceRow("Free Margin", _formatNumber(accountController.selectedAccount.value?.marginFree), context)),
            Obx(() => _balanceRow("Margin Level (%)", accountController.selectedAccount.value?.marginFreePercent?.toString() ?? "N/A", context)),
          ],
        ),
      ),
    );
  }

  Widget _balanceRow(
    String label,
    String value,
    BuildContext context, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '. ' * 100,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: GoogleFonts.roboto(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.3),
                ),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _PositionTile extends StatelessWidget {
  final int index;
  final int? digits;
  final String? positionId;
  final String? openTime;
  final String? swap;
  final String? stopLoss;
  final String? takeProfit;
  final double? doubleProfit;
  final String? profit;
  final String? symbol;
  final String? direction;
  final String? volume;
  final String? openPrice;
  final String? closePrice;
  final String? currentPrice;

  const _PositionTile({
    required this.index,
    this.digits,
    this.positionId,
    this.openTime,
    this.swap,
    this.stopLoss,
    this.takeProfit,
    this.doubleProfit,
    this.profit,
    this.symbol,
    this.direction,
    this.volume,
    this.openPrice,
    this.closePrice,
    this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final double parsedProfit = double.tryParse(profit ?? "0") ?? 0.0;

    final bool isPositive = parsedProfit > 0;
    final bool isNegative = parsedProfit < 0;

    final String profitText =
        isPositive
            ? parsedProfit.toStringAsFixed(2)
            : isNegative
            ? "-${parsedProfit.abs().toStringAsFixed(2)}"
            : "0.00";

    final Color profitColor =
        isPositive
            ? Colors.blue
            : isNegative
            ? Colors.red
            : Theme.of(context).colorScheme.onSurfaceVariant;

    final Color buySellColor =
        direction?.toLowerCase() == "buy" ? Colors.blue : Colors.red;

    // Check if market is closed (holiday/weekend)
    final bool isMarketClosed = isForexHoliday();

    return Slidable(
      key: ValueKey(positionId),

      // 👉 Geser ke kiri untuk Close Position
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.32,
        children: [
          SlidableAction(
            onPressed: isMarketClosed
                ? (_) => _showMarketHolidayDialog(context)
                : (_) => _onEditPosition(context),
            backgroundColor: isMarketClosed ? Colors.grey.withOpacity(0.5) : Colors.grey,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: "Edit",
          ),
          SlidableAction(
            onPressed: isMarketClosed
                ? (_) => _showMarketHolidayDialog(context)
                : (_) => _onClosePosition(context),
            backgroundColor: isMarketClosed ? Colors.red.withOpacity(0.5) : Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.close,
            label: "Close",
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
        ],
      ),

      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Stack(
          children: [
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: EdgeInsets.zero,
              dense: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: symbol ?? "-",
                      style: GoogleFonts.oswald(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(text: ", "),
                    TextSpan(
                      text:
                          direction != null
                              ? "${direction!.toLowerCase()} ${volume ?? "0.0"}"
                              : "-",
                      style: GoogleFonts.oswald(
                        color: buySellColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              subtitle: Text(
                "${openPrice ?? '0.00000'} → ${currentPrice ?? '-'}",
                style: GoogleFonts.oswald(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: Get.theme.textTheme.bodySmall?.color,
                ),
              ),

              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      profitText,
                      style: GoogleFonts.oswald(
                        color: profitColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.0,
                      ),
                    ),
                    if (isMarketClosed)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Iconsax.lock_outline,
                          size: 16,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Get.theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Position ID + Open Time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "#${positionId ?? "-"}",
                          style: GoogleFonts.oswald(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: Get.theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Open: ",
                              style: GoogleFonts.oswald(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                openTime ?? "-",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.oswald(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: Get.theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ROW 2: SL + Swap
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "S / L: ",
                              style: GoogleFonts.oswald(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                (stopLoss != null && stopLoss != "0")
                                    ? stopLoss!
                                    : "–",
                                style: GoogleFonts.oswald(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: Get.theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Swap: ",
                              style: GoogleFonts.oswald(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                swap ?? "0.00",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.oswald(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: Get.theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ROW 3: TP only (Left)
                  Row(
                    children: [
                      Text(
                        "T / P: ",
                        style: GoogleFonts.oswald(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        (takeProfit != null && takeProfit != "0")
                            ? takeProfit!
                            : "–",
                        style: GoogleFonts.oswald(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
            // 🎯 Market Closed Badge Overlay
           
          ],
        ),
      ),
    );
  }

  void _onClosePosition(BuildContext context) async {
    // ✅ Get.find() — controller sudah terdaftar, tidak perlu Get.put() lagi
    final accountController = Get.find<AccountController>();
    final tradingController = Get.find<TradingController>();

    String? loginID = accountController.selectedAccount.value?.login;
    if (loginID == null) {
      AppSnackbar.error("Gagal mendapatkan Login ID akun trading.");
      return;
    }

    // Create reactive profit observable
    final realtimeProfit = RxString(profit ?? "0.0");

    // Listen to position updates from API response (updated by WebSocket indirectly)
    final worker = ever(tradingController.openOrderModel, (model) {
      if (model?.response != null) {
        // Find this position in the updated list
        final position = model!.response!.firstWhereOrNull(
          (p) => p.ticket.toString() == positionId,
        );
        if (position != null && position.profit != null) {
          realtimeProfit.value = position.profit.toString();
        }
      }
    });

    await showCloseConfirmationDialog(
      context: context,
      symbol: symbol ?? '-',
      lot: volume ?? '0.0',
      profit: realtimeProfit,
      swap: swap.toString(),
      commission: "0.00",
      onConfirm: () async {
        // Dispose worker before closing
        worker.dispose();

        // Show loading indicator
        Get.dialog(
          Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          await tradingController.closingOrder(
            loginID: loginID,
            ticketID: positionId ?? '',
          );

          // Close loading
          if (Get.isDialogOpen ?? false) Get.back();

          AppSnackbar.success("Posisi $positionId berhasil ditutup.");

          // Reload positions once
          // [DISABLED] await tradingController.openOrder(login: loginID);
        } catch (e) {
          // Close loading
          if (Get.isDialogOpen ?? false) Get.back();
          // Show user-friendly error dialog
          await ErrorHandler.showErrorDialog(
            e,
            title: 'Gagal Menutup Posisi',
            onRetry: () {
              // Retry closing the position
              _onClosePosition(context);
            },
          );
        }
      },
    );

    // Dispose worker after dialog closes (in case user cancels)
    worker.dispose();
  }

  void _onEditPosition(BuildContext context) async {
    // ✅ Get.find() — controller sudah terdaftar, tidak perlu Get.put() lagi
    final tradingController = Get.find<TradingController>();
    final accountController = Get.find<AccountController>();
    final marketWS = Get.find<MarketWebSocketController>();

    String? loginID = accountController.selectedAccount.value?.login;
    if (loginID == null) {
      AppSnackbar.error("Gagal mendapatkan Login ID akun trading.");
      return;
    }

    // Get symbol name (remove .db suffix if exists)
    final cleanSymbol = symbol?.replaceAll('.db', '') ?? '';

    // Create reactive current price observable that updates from WebSocket
    final currentPriceObs = Rx<double>(
      double.tryParse(currentPrice ?? "0") ?? 0.0,
    );

    // Listen to WebSocket updates for this symbol
    final worker = ever(marketWS.marketData, (data) {
      final symbolData = data[cleanSymbol];
      if (symbolData != null) {
        // Use bid for sell positions, ask for buy positions
        final newPrice =
            direction?.toLowerCase() == 'buy' ? symbolData.bid : symbolData.ask;
        currentPriceObs.value = newPrice;
      }
    });

    // Get digits from symbol or use provided digits
    final symbolDigits = digits ?? _getDigitsForSymbol(symbol ?? '');

    // Navigate to new page
    await Get.to(
      () => EditPositionPage(
        symbol: cleanSymbol,
        positionId: positionId ?? '-',
        direction: direction ?? 'buy',
        openPrice: double.tryParse(openPrice ?? "0") ?? 0.0,
        currentPrice: currentPriceObs.value,
        stopLoss: double.tryParse(stopLoss ?? "0") ?? 0,
        takeProfit: double.tryParse(takeProfit ?? "0") ?? 0,
        digits: symbolDigits,
        currentPriceObservable: currentPriceObs,
        onModify: (sl, tp) async {
          try {
            // Show loading
            Get.dialog(
              Center(
                child: CircularProgressIndicator(
                  color: CustomColor.secondaryColor,
                ),
              ),
              barrierDismissible: false,
            );

            // Call modify API
            final result = await tradingController.modifyPosition(
              login: loginID,
              ticket: positionId ?? '',
              stopLoss: sl,
              takeProfit: tp,
              isPending: false,
            );

            // Close loading dialog
            if (Get.isDialogOpen ?? false) Get.back();

            if (result['status'] == true) {
              AppSnackbar.success(
                result['message'] ?? "Position berhasil dimodifikasi",
              );

              // WebSocket will auto-update the positions, no need for API call
              // Only reload if WebSocket is not connected
              if (Get.find<AccountBalanceWSController>().status.value !=
                  AccountWSStatus.connected) {
                await tradingController.openOrder(login: loginID);
              }
            } else {
              AppSnackbar.error(
                result['message'] ?? "Gagal memodifikasi position",
              );
            }
          } catch (e) {
            // Close loading dialog if still open
            if (Get.isDialogOpen ?? false) Get.back();
            // Show user-friendly error dialog
            await ErrorHandler.showErrorDialog(
              e,
              title: 'Gagal Memodifikasi Posisi',
            );
          }
        },
      ),
    );

    // Dispose worker after page closes
    worker.dispose();
  }

  /// 🎭 Show beautiful market holiday dialog
  void _showMarketHolidayDialog(BuildContext context) {
    final now = DateTime.now().toUtc();
    final dayName = DateFormat('EEEE').format(now);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎯 Icon dengan animasi background gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.withOpacity(0.3),
                      Colors.red.withOpacity(0.2),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Iconsax.close_circle_outline,
                    size: 48,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 📋 Title
              Text(
                "Market Closed",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // 📝 Description
              Text(
                "The Forex market is currently closed.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // 🗓️ Holiday info
              Text(
                "$dayName is a market holiday",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              // 📍 Info Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.info_circle_outline,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "You cannot edit or close positions during market holidays.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock_outline,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Please try again when the market reopens.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Got it",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getDigitsForSymbol(String symbol) {
    final symbolUpper = symbol.toUpperCase();
    if (symbolUpper.contains('JPY')) return 3;
    if (symbolUpper.contains('XAU') || symbolUpper.contains('GOLD')) return 2;
    return 5;
  }
}
