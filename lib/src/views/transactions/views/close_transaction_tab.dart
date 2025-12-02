import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/views/transactions/views/closed_tile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rrfx/src/components/colors/default.dart';

class ClosedTransactionTab extends StatefulWidget {
  const ClosedTransactionTab({super.key});

  @override
  State<ClosedTransactionTab> createState() => _ClosedTransactionTabState();
}

class _ClosedTransactionTabState extends State<ClosedTransactionTab> {
  final TradingController tradingController = Get.put(TradingController());
  final AccountController controller = Get.put(AccountController());
  RxBool isLoading = false.obs;

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
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadClosedOrders);
  }

  // -------------------------------------------------------
  // SHIMMER ADAPTIF THEME
  // -------------------------------------------------------
  Widget _buildShimmerList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    final highlightColor = isDark
        ? Colors.grey.shade600
        : Colors.grey.shade100;

    final containerColor = isDark
        ? Colors.grey.shade900
        : Colors.grey.shade200;

    return ListView.builder(
      itemCount: 2,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 230,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Obx(() {
      if (!controller.hasAccounts) return noAccountDetected();
      var closed = tradingController.tradingHistoryModel.value?.response;

      /// LOADING SHIMMER
      if (isLoading.value) {
        return _buildShimmerList(context);
      }

      /// EMPTY STATE
      if (closed == null || closed.isEmpty) {
        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          backgroundColor: theme.cardColor,
          onRefresh: _loadClosedOrders,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: Get.height * 0.25),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.clock_outline,
                    size: 45,
                    color: onSurface.withOpacity(0.45),
                  ),
                  const SizedBox(height: 8.0),

                  Text(
                    "Transaction",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),

                  Text(
                    "Tidak ada transaksi CLOSED tersedia.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: onSurface.withOpacity(0.55),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      }

      /// CLOSED LIST
      return RefreshIndicator(
        color: CustomColor.secondaryColor,
        backgroundColor: theme.cardColor,
        displacement: 30,
        edgeOffset: 10,
        onRefresh: _loadClosedOrders,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: closed.length,
          itemBuilder: (context, i) {
            final item = closed[i];
            return ClosedTile(
              ticket: item.ticket.toString(),
              profit: item.profit.toString(),
              closePrice: item.closePrice.toString(),
              closeTime: item.closeTime.toString(),
              openPrice: item.openPrice.toString(),
              openTime: item.openTime.toString(),
              lot: item.lot.toString(),
              orderType: item.orderType.toString(),
              symbol: item.symbol.toString(),
              stopLoss: item.stopLoss.toString(),
              takeProfit: item.takeProfit.toString(),
              digits: item.digits.toString(),
            );
          },
        ),
      );
    });
  }
}
