import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/account_list/account_selection_bottom_sheet.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/views/advance_charts/views/timeframe_selector.dart';
import 'package:rrfx/src/views/chart/components/popup_execution.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'package:rrfx/src/views/chart/views/market_bottom_sheet.dart';
import 'package:rrfx/src/views/trade/components/chart_section.dart';
import '../controllers/ohlc_deriv_controller.dart';

class ExpandedAdvanceView extends StatelessWidget {
  final String symbol;
  final String timeframe;
  final bool isReal;

  ExpandedAdvanceView({
    super.key,
    required this.symbol,
    required this.timeframe,
    this.isReal = false,
  });

  final OhlcDerivController ohlcController = Get.put(OhlcDerivController());
  final ThemeController themeController = Get.find();
  final accountController = Get.put(AccountController());
  final ChartControllers chartController = Get.put(ChartControllers());
  final TradingController tradingController = Get.put(TradingController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ohlcController.currentSymbol = symbol;
    ohlcController.currentTimeframe = timeframe;
    ohlcController.currentIsReal = isReal;
    // Start fetching data
    ohlcController.startFetching(
      symbol: symbol,
      timeframe: timeframe,
      isReal: isReal,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            Obx(
              () =>
                  !accountController.hasAccounts
                      ? const SizedBox()
                      : _buildToolbar(size, context),
            ),
            const SizedBox(height: 5.0),
            Obx(
              () =>
                  ohlcController.ohlcRaw.isNotEmpty
                      ? TimeframeSelector(
                        selected: ohlcController.currentTimeframe,
                        onChanged: (tf) {
                          ohlcController.changeTimeframe(tf);
                        },
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (ohlcController.candles.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: CustomColor.secondaryColor,
                    ),
                  );
                }
                return DerivChart(
                  key: Key(
                    "chart_${ohlcController.currentSymbol}_${ohlcController.currentTimeframe}",
                  ),
                  isLive: true,
                  loadingAnimationColor: Colors.transparent,
                  granularity: ohlcController.convertGranularity(
                    ohlcController.currentTimeframe,
                  ),
                  theme:
                      themeController.isDark.value
                          ? ChartDefaultDarkTheme()
                          : ChartDefaultLightTheme(),
                  dataFitPadding: const EdgeInsets.all(10),
                  mainSeries: CandleSeries(ohlcController.candles),
                  showDataFitButton: true,
                  pipSize:
                      symbol.contains("JPY") || symbol.contains("XAU") ? 3 : 5,
                  activeSymbol: ohlcController.currentSymbol,
                  showCurrentTickBlinkAnimation: true,
                  annotations: [...ohlcController.currentPriceBarrier],
                );
              }),
            ),
            Obx(
              () =>
                  !accountController.hasAccounts
                      ? const SizedBox()
                      : _buildExecutionButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionButton(BuildContext context) {
    String? loginID = accountController.selectedAccount.value?.login;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Obx(() {
            final double sellPrice =
                ohlcController.liveBid.value != 0.0
                    ? ohlcController.liveBid.value
                    : ohlcController.currentPrice;
            return TradingProperty.sellButton(
              price: double.tryParse(sellPrice.toStringAsFixed(5)),
              onPressed:
                  loginID == null ? null : () => _executeOrder(context, "sell"),
            );
          }),
          TradingProperty.lotButton(context),
          Obx(() {
            final double buyPrice =
                ohlcController.liveAsk.value != 0.0
                    ? ohlcController.liveAsk.value
                    : ohlcController.currentPrice;
            return TradingProperty.buyButton(
              price: double.tryParse(buyPrice.toStringAsFixed(5)),
              onPressed:
                  loginID == null ? null : () => _executeOrder(context, "buy"),
            );
          }),
        ],
      ),
    );
  }

  // Fungsi untuk memicu eksekusi order (dengan realtime price)
  void _executeOrder(BuildContext context, String orderType) async {
    String? loginID = accountController.selectedAccount.value?.login;
    double lot = chartController.lot.value;

    if (loginID == null) return;
    if (lot < 0.10) {
      AppSnackbar.error("Transaksi minimal harus 0.1 Lot");
      return;
    }

    // Gunakan currentPrice sebagai observable untuk realtime
    // Atau bisa gunakan bidPrice/askPrice jika tersedia
    final Rx<double> realtimePrice = chartController.currentPrice;

    // Tampilkan Dialog Konfirmasi dengan realtime price
    Get.dialog(
      PopupExecution.buildOrderConfirmationDialog(
        context: context,
        symbol: chartController.selectedMarket.value,
        type: orderType.toUpperCase(),
        lot: lot,
        priceObservable: realtimePrice,
        priceDigits: chartController.priceDigits.value,
        onConfirm: () async {
          // Logika eksekusi order dengan harga terkini saat konfirmasi
          final result = await tradingController.executionOrder(
            symbol: chartController.selectedMarket.value,
            type: orderType,
            login: loginID,
            lot: lot.toString(),
          );
          if (result['status']) {
            CustomScaffoldMessanger.showAppSnackBar(
              context,
              message: result['message'],
              type: SnackBarType.success,
            );
          } else {
            CustomScaffoldMessanger.showAppSnackBar(
              context,
              message: result['message'],
              type: SnackBarType.error,
            );
          }
        },
      ),
    );
  }

  Widget _buildToolbar(Size? size, BuildContext context) {
    String? marketName = removeTextAfterDot(
      chartController.selectedMarket.value,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TradingProperty.textButton(
              context,
              title: marketName,
              onPressed: () {
                showMarketBottomSheet(context);
              },
            ),
            // TradingProperty.textButton(context, title: "H1", onPressed: (){}),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TradingProperty.iconButton(context, AntDesign.function_outline, () {
              Get.to(
                () => ExpandedAdvanceView(
                  symbol: chartController.selectedMarket.value,
                  timeframe: chartController.timeFrame.value,
                  isReal:
                      accountController.selectedAccount.value?.type == "demo"
                          ? false
                          : true,
                ),
              );
            }),
            Obx(
              () => TradingProperty.textButton(
                context,
                title:
                    "${accountController.selectedAccount.value?.namaTipeAkun != null ? accountController.selectedAccount.value!.namaTipeAkun!.capitalize : ''} - ${accountController.selectedAccount.value?.login ?? ''}",
                onPressed: () {
                  final bool canPress = accountController.hasAccounts;
                  if (canPress) {
                    AccountSelectionBottomSheet.show();
                    chartController.loadChartData();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String removeTextAfterDot(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input.split('.').first;
  }
}
