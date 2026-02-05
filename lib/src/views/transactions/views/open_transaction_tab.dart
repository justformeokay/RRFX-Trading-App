import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/error_handler.dart';
import 'package:rrfx/src/views/transactions/views/opened_tile.dart';
import 'package:rrfx/src/views/transactions/views/popup_close_order.dart';
import 'package:shimmer/shimmer.dart'; // pastikan tambahkan di pubspec.yaml

class OpenTransactionTab extends StatefulWidget {
  const OpenTransactionTab({super.key});

  @override
  State<OpenTransactionTab> createState() => _OpenTransactionTabState();
}

class _OpenTransactionTabState extends State<OpenTransactionTab> {
  final TradingController tradingController = Get.put(TradingController());
  final AccountController controller = Get.put(AccountController());

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if(!controller.hasAccounts){
      Get.log("TIDAK MEMILIKI AKUN TRADING DEMO MAUPUN REAL");
      return;
    }
    String? loginID = controller.selectedAccount.value?.login;
    if (loginID == null) return;
    await tradingController.openOrder(login: loginID);
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 700)); // biar animasi halus
    await _loadOrders();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(!controller.hasAccounts) return noAccountDetected();
      var opened = tradingController.openOrderModel.value?.response;

      if (opened == null) {
        return _buildShimmerList(context);
      }

      if (opened.isEmpty) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.amberAccent,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.transaction_minus_outline, size: 45),
                  const SizedBox(height: 8.0),
                  Text("Transaction", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text("Tidak ada transaksi OPEN aktif.", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Get.textTheme.bodySmall?.color)),
                ],
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.amberAccent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: _isRefreshing
            ? _buildShimmerList(context)
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: Column(
                children: List.generate(opened.length, (i) {
                  return OpenedTile(
                    onEndPosition: () async {
                      String? loginID = controller.selectedAccount.value?.login;
                      if (loginID == null) {
                        CustomScaffoldMessanger.showAppSnackBar(
                          context,
                          message: "Gagal close market, ID Akun tidak ditemukan.",
                        );
                        return;
                      }

                      final item = opened[i];

                      await showCloseConfirmationDialog(
                        context: context,
                        symbol: item.symbol ?? '-',
                        lot: item.lot.toString(),
                        profit: item.profit.toString(),
                        swap: item.swap.toString(),
                        commission: "0.00",
                        onConfirm: () async {
                          try {
                            await tradingController.closingOrder(
                              loginID: loginID,
                              ticketID: item.ticket.toString(),
                            );
                            _loadOrders();
                          } catch (e) {
                            await ErrorHandler.showErrorDialog(
                              e,
                              title: 'Gagal Menutup Posisi',
                            );
                          }
                        },
                      );
                    },
                    lot: opened[i].lot.toString(),
                    currentPrice: opened[i].currentPrice.toString(),
                    digits: opened[i].digits.toString(),
                    openTime: opened[i].openTime?.toString() ?? '',
                    openPrice: opened[i].openPrice.toString(),
                    orderType: opened[i].orderType?.toString() ?? '',
                    profit: opened[i].profit.toString(),
                    stopLoss: opened[i].stopLoss.toString(),
                    swap: opened[i].swap.toString(),
                    symbol: opened[i].symbol?.toString() ?? '',
                    takeProfit: opened[i].takeProfit.toString(),
                    ticket: opened[i].ticket.toString(),
                  );
                }),
              ),
            ),
        ),
      );
    });
  }

  /// shimmer placeholder list saat loading
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
            margin: const EdgeInsets.symmetric(vertical: 6),
            height: 220,
            decoration: BoxDecoration(
              color: surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }
}
