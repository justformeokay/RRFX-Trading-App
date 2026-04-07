import 'dart:async';
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

  // ── Close All Positions ────────────────────────────────────────────────────

  void _showCloseAllConfirmation(BuildContext context, List<dynamic> positions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPositions = positions.length;

    double totalProfit = 0;
    for (final p in positions) {
      totalProfit += double.tryParse('${p.profit ?? 0}') ?? 0;
    }

    final profitColor = totalProfit >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent.shade200;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: Icon(Icons.warning_amber_rounded, size: 36, color: Colors.red.shade400),
            ),
            const SizedBox(height: 18),
            Text(
              "Close All Positions?",
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Semua $totalPositions posisi aktif akan ditutup sekaligus.\nTindakan ini tidak bisa dibatalkan.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Posisi", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                      Text("$totalPositions posisi", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: profitColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Total P/L: ${totalProfit >= 0 ? '+' : ''}${totalProfit.toStringAsFixed(2)} USD",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: profitColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                    ),
                    child: Text("Batal", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _executeCloseAll(context, positions);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                    ),
                    child: Text("Close All", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _executeCloseAll(BuildContext context, List<dynamic> positions) async {
    final loginID = controller.selectedAccount.value?.login;
    if (loginID == null) return;

    final total = positions.length;
    final completed = 0.obs;
    final failed = <String>[].obs;
    final isCancelled = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => Obx(() => _CloseAllProgressDialog(
        total: total,
        completed: completed.value,
        failed: failed.length,
        isCancelled: isCancelled.value,
        onCancel: () => isCancelled.value = true,
      )),
    );

    // Fire all close requests simultaneously for maximum speed
    final tickets = positions.map((p) => '${p.ticket}').toList();

    await Future.wait(tickets.map((ticket) async {
      if (isCancelled.value) return;
      try {
        final result = await tradingController.closingOrder(
          loginID: loginID,
          ticketID: ticket,
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('Timeout'),
        );
        if (result['status'] == true) {
          completed.value++;
        } else {
          failed.add(ticket);
          completed.value++;
        }
      } catch (_) {
        failed.add(ticket);
        completed.value++;
      }
    }));

    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}

    final successCount = completed.value - failed.length;
    if (failed.isEmpty && !isCancelled.value) {
      AppSnackbar.success("Semua $total posisi berhasil ditutup.");
    } else if (isCancelled.value) {
      AppSnackbar.error("Dibatalkan. $successCount dari $total posisi berhasil ditutup.");
    } else {
      AppSnackbar.error("$successCount dari $total berhasil. ${failed.length} posisi gagal.");
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Positions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (opened != null && opened.isNotEmpty && !isForexHoliday())
                      GestureDetector(
                        onTap: () => _showCloseAllConfirmation(context, opened),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close_rounded, size: 14, color: Colors.red.shade400),
                              const SizedBox(width: 4),
                              Text(
                                "Close All",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
  // Static lock to prevent concurrent close operations
  static bool _isClosingPosition = false;

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
                          style: GoogleFonts.poppins(
                            fontSize: 11.0,
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
                              style: GoogleFonts.poppins(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatOpenTime(openTime),
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.0,
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
                              style: GoogleFonts.poppins(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                (stopLoss != null && stopLoss != "0")
                                    ? stopLoss!
                                    : "–",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.0,
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
                              style: GoogleFonts.poppins(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                swap ?? "0.00",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.0,
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
                        style: GoogleFonts.poppins(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        (takeProfit != null && takeProfit != "0")
                            ? takeProfit!
                            : "–",
                        style: GoogleFonts.poppins(
                          fontSize: 11.0,
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

  /// Format openTime to Meta-style format (YYYY.MM.DD HH:mm:ss) using device local timezone
  String _formatOpenTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    
    try {
      // Parse the DateTime from the string and convert to device local timezone
      DateTime dateTime = DateTime.parse(timeStr).toLocal();
      
      // Format as YYYY.MM.DD HH:mm:ss (Meta-style)
      return DateFormat('yyyy.MM.dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return timeStr; // Return original if parsing fails
    }
  }

  void _onClosePosition(BuildContext context) async {
    // Prevent concurrent close operations
    if (_isClosingPosition) {
      AppSnackbar.error("Sedang memproses penutupan posisi lain, harap tunggu.");
      return;
    }

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

        // Acquire lock
        _isClosingPosition = true;

        // Show loading dialog with force-cancel capability
        _showModernLoadingDialog(context, "Closing Position...");

        try {
          // Use .timeout() directly on the API call for guaranteed timeout
          final result = await tradingController.closingOrder(
            loginID: loginID,
            ticketID: positionId ?? '',
          ).timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw Exception('Request timeout - koneksi memakan waktu terlalu lama'),
          );

          // Close loading dialog reliably
          _dismissLoadingDialog(context);

          if (result['status'] == true) {
            AppSnackbar.success("Posisi $positionId berhasil ditutup.");
          } else {
            final msg = result['message'] ?? 'Gagal menutup posisi';
            AppSnackbar.error(msg.toString());
          }
        } catch (e) {
          // Close loading dialog reliably
          _dismissLoadingDialog(context);

          final errMsg = e.toString().replaceAll('Exception: ', '');
          if (errMsg.contains('timeout') || errMsg.contains('terlalu lama')) {
            AppSnackbar.error("Request timeout - silakan coba lagi.");
          } else {
            await ErrorHandler.showErrorDialog(
              e,
              title: 'Gagal Menutup Posisi',
              onRetry: () => _onClosePosition(context),
            );
          }
        } finally {
          // Always release the lock
          _isClosingPosition = false;
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
            // Show modern loading
            _showModernLoadingDialog(context, "Updating Position...");

            // Call modify API
            final result = await tradingController.modifyPosition(
              login: loginID,
              ticket: positionId ?? '',
              stopLoss: sl,
              takeProfit: tp,
              isPending: false,
            );

            // Close loading dialog reliably
            _dismissLoadingDialog(context);

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
            // Close loading dialog reliably
            _dismissLoadingDialog(context);
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

  /// 🎯 Modern loading dialog dengan force-cancel button
  void _showModernLoadingDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => _LoadingDialogContent(title: title),
    );
  }

  /// Dismiss loading dialog reliably using Navigator (not GetX)
  void _dismissLoadingDialog(BuildContext context) {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}
  }
}

/// Stateful loading dialog that shows a cancel button after 8 seconds
class _LoadingDialogContent extends StatefulWidget {
  final String title;
  const _LoadingDialogContent({required this.title});

  @override
  State<_LoadingDialogContent> createState() => _LoadingDialogContentState();
}

class _LoadingDialogContentState extends State<_LoadingDialogContent> {
  bool _showCancel = false;
  Timer? _cancelTimer;

  @override
  void initState() {
    super.initState();
    _cancelTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _showCancel = true);
    });
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CustomColor.secondaryColor.withValues(alpha: 0.1),
                      Colors.blue.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: CustomColor.secondaryColor,
                    strokeWidth: 3,
                    backgroundColor: CustomColor.secondaryColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please wait while we process your request",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (_showCancel) ...[
                const SizedBox(height: 20),
                Text(
                  "Proses memakan waktu lebih lama dari biasanya",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.orange,
                  ),
                ),
                // const SizedBox(height: 12),
                // SizedBox(
                //   width: double.infinity,
                //   child: TextButton(
                //     onPressed: () {
                //       _PositionTile._isClosingPosition = false;
                //       if (Get.isDialogOpen ?? false) Get.back();
                //       AppSnackbar.error("Proses dibatalkan. Silakan coba lagi.");
                //     },
                //     style: TextButton.styleFrom(
                //       foregroundColor: Colors.red,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //         side: BorderSide(color: Colors.red.withOpacity(0.3)),
                //       ),
                //     ),
                //     child: Text(
                //       "Batalkan",
                //       style: GoogleFonts.inter(
                //         fontWeight: FontWeight.w600,
                //         fontSize: 13,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Close All Progress Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CloseAllProgressDialog extends StatelessWidget {
  final int total;
  final int completed;
  final int failed;
  final bool isCancelled;
  final VoidCallback onCancel;

  const _CloseAllProgressDialog({
    required this.total,
    required this.completed,
    required this.failed,
    required this.isCancelled,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total > 0 ? completed / total : 0.0;
    final successCount = completed - failed;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress ring
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: CustomColor.secondaryColor.withOpacity(0.15),
                    color: failed > 0 ? Colors.orange : CustomColor.secondaryColor,
                  ),
                  Center(
                    child: Text(
                      "$completed/$total",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isCancelled ? "Membatalkan..." : "Menutup Posisi...",
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Status text
            if (failed > 0)
              Text(
                "$failed posisi gagal",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade400, fontWeight: FontWeight.w600),
              ),
            if (successCount > 0)
              Text(
                "$successCount berhasil ditutup",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.greenAccent.shade400, fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 6),
            Text(
              "Mohon tunggu, jangan tutup halaman ini",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),

            // if (!isCancelled && completed < total) ...[
            //   const SizedBox(height: 18),
            //   SizedBox(
            //     width: double.infinity,
            //     child: TextButton(
            //       onPressed: onCancel,
            //       style: TextButton.styleFrom(
            //         foregroundColor: Colors.red,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //           side: BorderSide(color: Colors.red.withOpacity(0.3)),
            //         ),
            //       ),
            //       child: Text(
            //         "Batalkan Sisa",
            //         style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
