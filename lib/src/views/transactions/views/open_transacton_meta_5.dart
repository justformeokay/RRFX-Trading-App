import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/account_balance_ws_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/websocket_controller.dart';
import 'package:rrfx/src/views/transactions/views/popup_close_order.dart';
import 'package:rrfx/src/views/transactions/views/popup_edit_position.dart';
import 'package:shimmer/shimmer.dart';

class OpenTransactonMeta5 extends StatefulWidget {
  const OpenTransactonMeta5({super.key});

  @override
  State<OpenTransactonMeta5> createState() => _OpenTransactonMeta5State();
}

class _OpenTransactonMeta5State extends State<OpenTransactonMeta5> {
  final TradingController tradingController = Get.put(TradingController());
  final AccountController controller = Get.put(AccountController());
  final AccountBalanceWSController accountWS = Get.put(
    AccountBalanceWSController(),
    permanent: true,
  );

  // Ensure MarketWebSocketController is registered
  final MarketWebSocketController marketWS = Get.put(
    MarketWebSocketController(),
    permanent: true,
  );

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _subscribeToAccountWS();
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
    if (!controller.hasAccounts) {
      Get.log("TIDAK MEMILIKI AKUN TRADING DEMO MAUPUN REAL");
      return;
    }
    String? loginID = controller.selectedAccount.value?.login;
    if (loginID == null) return;
    await tradingController.openOrder(login: loginID);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasAccounts) return noAccountDetected();
      var opened = tradingController.openOrderModel.value?.response;
      if (opened == null) {
        return _buildShimmerList(context);
      }
      return Scaffold(
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

  Widget _buildShimmerList(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;

    // Base shimmer = permukaan + sedikit opasitas
    final base = onSurface.withOpacity(0.10);
    final highlight = onSurface.withOpacity(0.20);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 2,
      itemBuilder: (context, i) {
        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 80,
            decoration: BoxDecoration(color: surface.withOpacity(0.6)),
          ),
        );
      },
    );
  }
}

// ---------------- BALANCE SECTION --------------------
class _BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 180;

  @override
  double get maxExtent => 190;

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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _balanceRow(
              "Account ID",
              accountController.selectedAccount.value?.login ?? "N/A",
              context,
            ),
          ),
          // Only show Profit if there are open positions
          Obx(() {
            final tradingController = Get.find<TradingController>();
            final hasOpenPositions =
                tradingController.openOrderModel.value?.response?.isNotEmpty ??
                false;

            if (!hasOpenPositions) return SizedBox.shrink();

            return _balanceRow(
              "Profit",
              _formatProfit(accountWS.profit.value),
              context,
              color: accountWS.profit.value >= 0 ? Colors.blue : Colors.red,
            );
          }),
          Obx(
            () => _balanceRow(
              "Balance",
              _formatNumber(accountController.selectedAccount.value?.balance),
              context,
            ),
          ),
          Obx(
            () => _balanceRow(
              "Equity",
              _formatNumber(accountController.selectedAccount.value?.equity),
              context,
            ),
          ),
          Obx(
            () => _balanceRow(
              "Margin",
              _formatNumber(accountController.selectedAccount.value?.margin),
              context,
            ),
          ),
          Obx(
            () => _balanceRow(
              "Free Margin",
              _formatNumber(
                accountController.selectedAccount.value?.marginFree,
              ),
              context,
            ),
          ),
          Obx(
            () => _balanceRow(
              "Margin Level (%)",
              accountController.selectedAccount.value?.marginFreePercent != null
                  ? "${accountController.selectedAccount.value?.marginFreePercent}"
                  : "N/A",
              context,
            ),
          ),
        ],
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
          Text("$label:", style: GoogleFonts.roboto(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w800,
          )),
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
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w800,
            )
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

    return Slidable(
      key: ValueKey(positionId),

      // 👉 Geser ke kiri untuk Close Position
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.32,
        children: [
          SlidableAction(
            onPressed: (_) => _onEditPosition(context),
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: "Edit",
          ),
          SlidableAction(
            onPressed: (_) => _onClosePosition(context),
            backgroundColor: Colors.red,
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
        child: ExpansionTile(
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

          trailing: Text(
            profitText,
            style: GoogleFonts.oswald(
              color: profitColor,
              fontWeight: FontWeight.w800,
              fontSize: 16.0,
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
      ),
    );
  }

  void _onClosePosition(BuildContext context) async {
    final accountController = Get.put(AccountController());
    final tradingController = Get.put(TradingController());

    String? loginID = accountController.selectedAccount.value?.login;
    if (loginID == null) {
      AppSnackbar.error("Gagal mendapatkan Login ID akun trading.");
      return;
    }

    // Create reactive profit observable that updates from tradingController
    final realtimeProfit = (profit ?? "0.0").obs;

    // Use ever() to listen to openOrderModel changes and update this position's profit
    final worker = ever(tradingController.openOrderModel, (model) {
      if (model?.response != null) {
        final thisPosition = model!.response!.firstWhereOrNull(
          (pos) => pos.ticket.toString() == positionId,
        );
        if (thisPosition != null && thisPosition.profit != null) {
          realtimeProfit.value = thisPosition.profit.toString();
        }
      }
    });

    await showCloseConfirmationDialog(
      context: context,
      symbol: symbol ?? '-',
      lot: volume ?? '0.0',
      profit: realtimeProfit, // Pass Rx observable
      swap: swap.toString(),
      commission: "0.00",
      onConfirm: () async {
        worker.dispose(); // Dispose worker when closing
        await tradingController
            .closingOrder(loginID: loginID, ticketID: positionId ?? '')
            .then((result) {
              tradingController.openOrder(login: loginID);
              AppSnackbar.success("Posisi $positionId berhasil ditutup.");
            })
            .whenComplete(() {
              String? loginID = accountController.selectedAccount.value?.login;
              if (loginID == null) return;
              tradingController.openOrder(login: loginID);
            });
      },
    );

    // Dispose worker when dialog closes
    worker.dispose();
  }

  void _onEditPosition(BuildContext context) async {
    final tradingController = Get.put(TradingController());
    final accountController = Get.put(AccountController());

    String? loginID = accountController.selectedAccount.value?.login;
    if (loginID == null) {
      AppSnackbar.error("Gagal mendapatkan Login ID akun trading.");
      return;
    }

    // Get current price observable that updates from tradingController
    final currentPriceObs = (double.tryParse(currentPrice ?? "0") ?? 0.0).obs;

    // Listen to openOrderModel changes and update current price for this position
    final worker = ever(tradingController.openOrderModel, (model) {
      if (model?.response != null) {
        final thisPosition = model!.response!.firstWhereOrNull(
          (pos) => pos.ticket.toString() == positionId,
        );
        if (thisPosition != null && thisPosition.currentPrice != null) {
          currentPriceObs.value =
              double.tryParse(thisPosition.currentPrice.toString()) ??
              currentPriceObs.value;
        }
      }
    });

    // Get digits from symbol or use provided digits
    final symbolDigits = digits ?? _getDigitsForSymbol(symbol ?? '');

    await showEditPositionDialog(
      context: context,
      symbol: symbol?.replaceAll('.db', '') ?? '-',
      positionId: positionId ?? '-',
      direction: direction ?? 'buy',
      openPrice: double.tryParse(openPrice ?? "0") ?? 0.0,
      currentPrice: currentPriceObs.value,
      stopLoss: double.tryParse(stopLoss ?? "0") ?? 0.0,
      takeProfit: double.tryParse(takeProfit ?? "0") ?? 0.0,
      digits: symbolDigits,
      currentPriceObservable: currentPriceObs,
      onModify: (sl, tp) async {
        worker.dispose();
        
        try {
          // Show loading
          Get.dialog(
            Center(
              child: CircularProgressIndicator(),
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
          Get.back();
          
          if (result['status'] == true) {
            AppSnackbar.success(
              result['message'] ?? "Position berhasil dimodifikasi: SL=$sl, TP=$tp",
            );
            
            // Reload positions to get updated data
            await tradingController.openOrder(login: loginID);
          } else {
            AppSnackbar.error(
              result['message'] ?? "Gagal memodifikasi position",
            );
          }
        } catch (e) {
          // Close loading dialog if still open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          
          AppSnackbar.error("Error: ${e.toString()}");
        }
      },
    );

    worker.dispose();
  }

  int _getDigitsForSymbol(String symbol) {
    final symbolUpper = symbol.toUpperCase();
    if (symbolUpper.contains('JPY')) return 3;
    if (symbolUpper.contains('XAU') || symbolUpper.contains('GOLD')) return 2;
    return 5;
  }
}
