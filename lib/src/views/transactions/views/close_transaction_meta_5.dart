import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:shimmer/shimmer.dart';

class CloseTransactionMeta5 extends StatefulWidget {
  const CloseTransactionMeta5({super.key});

  @override
  State<CloseTransactionMeta5> createState() => _CloseTransactionMeta5State();
}

class _CloseTransactionMeta5State extends State<CloseTransactionMeta5> {
  final TradingController tradingController = Get.put(TradingController());
  final AccountController controller = Get.put(AccountController());
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadClosedOrders);
  }

  Future<void> _loadClosedOrders() async {
    if (!controller.hasAccounts) {
      Get.log("TIDAK MEMILIKI AKUN TRADING DEMO MAUPUN REAL");
      return;
    }

    isLoading.value = true;
    String? loginID = controller.selectedAccount.value?.login;

    if (loginID != null) {
      await tradingController.closedOrder(login: loginID);
    }

    isLoading.value = false;

    await Future.delayed(const Duration(milliseconds: 600)); // smooth
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      (){
        if(!controller.hasAccounts) return noAccountDetected();
        var closed = tradingController.tradingHistoryModel.value?.response;
        if (closed == null) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Text(
                    "Closed Positions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _PositionTile(
                      index: index,
                      positionId: "${closed[index].ticket}",
                      openTime: "${closed[index].openTime}",
                      swap: "-",
                      stopLoss: "${closed[index].stopLoss}",
                      takeProfit: "${closed[index].takeProfit}",
                      doubleProfit: -0.10 * index,
                      profit: closed[index].profit != null ? "${closed[index].profit}" : "0.00",
                      symbol: "${closed[index].symbol}",
                      direction: "${closed[index].orderType}",
                      volume: _formatLot(closed[index].lot),
                      openPrice: "${closed[index].openPrice}",
                      closePrice: "${closed[index].closePrice}",
                    );
                  },
                  childCount: closed.length,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  String _formatLot(dynamic lot) {
    if (lot == null) return "0.00";

    // Convert string angka seperti "0.10000" → double → format 2 decimal
    final value = double.tryParse(lot.toString()) ?? 0.0;

    return value.toStringAsFixed(2);
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
            decoration: BoxDecoration(
              color: surface.withOpacity(0.6),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- BALANCE SECTION --------------------
class _BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 140;

  @override
  double get maxExtent => 150;

  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => _balanceRow("Account ID", accountController.selectedAccount.value?.login ?? "N/A", context)),
          _balanceRow("Deposit", "0", context),
          _balanceRow("Swap", "0", context),
          _balanceRow("Commision", "0", context),
          Obx(() => _balanceRow("Balance", "${accountController.selectedAccount.value?.balance ?? "N/A"} ${accountController.selectedAccount.value?.currency ?? "0"}", context)),
        ],
      ),
    );
  }

  Widget _balanceRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _PositionTile extends StatelessWidget {
  final int index;
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

  const _PositionTile({
    required this.index,
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
  });

  @override
  Widget build(BuildContext context) {
    final double parsedProfit = double.tryParse(profit ?? "0") ?? 0.0;

    final bool isPositive = parsedProfit > 0;
    final bool isNegative = parsedProfit < 0;

    final String profitText = isPositive
        ? parsedProfit.toStringAsFixed(2)
        : isNegative
            ? "-${parsedProfit.abs().toStringAsFixed(2)}"
            : "0.00";

    final Color profitColor = isPositive
        ? Colors.blue
        : isNegative
            ? Colors.red
            : Theme.of(context).colorScheme.onSurfaceVariant;

    final Color buySellColor = direction?.toLowerCase() == "buy" ? Colors.blue : Colors.red;

    return Slidable(
      key: ValueKey(positionId),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: symbol ?? "-",
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: direction != null ? "${direction!.toLowerCase()} ${volume ?? "0.0"}" : "-",
                  style: GoogleFonts.inter(
                    color: buySellColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),


          subtitle: Text("${openPrice ?? '0.00000'} → ${closePrice == "null" || closePrice == null || closePrice == "" ? '0' : closePrice}", style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)),

          trailing: Text(
            profitText,
            style: GoogleFonts.inter(
              color: profitColor,
              fontWeight: FontWeight.w800,
              fontSize: 13.0,
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
                          style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Open: ",
                              style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
                            ),
                            Expanded(
                              child: Text(
                                openTime ?? "-",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
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
                              style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
                            ),
                            Expanded(
                              child: Text(
                                (stopLoss != null && stopLoss != "0") ? stopLoss! : "–",
                                style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
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
                              style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
                            ),
                            Expanded(
                              child: Text(
                                swap ?? "0.00",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
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
                        style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
                      ),
                      Text(
                        (takeProfit != null && takeProfit != "0") ? takeProfit! : "–",
                        style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w700, color: Get.theme.textTheme.bodySmall?.color)
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
}

