import 'dart:collection';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/account_list/account_selection_bottom_sheet.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
// import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/views/advance_charts/views/expanded_advance_view.dart';
import 'package:rrfx/src/views/chart/components/popup_execution.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'package:rrfx/src/views/chart/views/market_bottom_sheet.dart';
import 'package:rrfx/src/views/trade/components/chart_section.dart';

class ChartTab extends StatefulWidget {
  const ChartTab({super.key});

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  final ChartControllers chartController = Get.put(ChartControllers());
  final accountController = Get.put(AccountController());
  ThemeController themeController = Get.find<ThemeController>();
  final TradingController tradingController = Get.put(TradingController());
  final planets = SplayTreeSet<Marker>((a, b) => a.compareTo(b));
  RegolController regolController = Get.put(RegolController());
  HomeController homeController = Get.put(HomeController());
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Obx(
        () {
          if(!accountController.hasAccounts) return noAccountDetected();
          return SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Obx(() => !accountController.hasAccounts ? const SizedBox() : _buildToolbar(size)),
                  Expanded(child: _buildChart()),
                  Obx(() => !accountController.hasAccounts ? const SizedBox() : _buildExecutionButton())
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildChart() {
    return Obx(
      () => DerivChart(
        key: Key('chart_${chartController.timeFrame.value}_${chartController.selectedMarket.value}'),
        // granularity: 3600
        granularity: chartController.timeframeToGranularity(chartController.timeFrame.value)  ,
        showScrollToLastTickButton: false,
        dataFitPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isLive: true,
        theme: themeController.isDark.value ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
        mainSeries: CandleSeries(tradingController.ohlcDataDeriv),
        showDataFitButton: true,
        pipSize: chartController.selectedMarket.value.contains("JPY") || chartController.selectedMarket.value.contains("XAU") ? 3 : 5,
        showCurrentTickBlinkAnimation: true,
        activeSymbol: chartController.selectedMarket.value,
        loadingAnimationColor: Colors.transparent,
        annotations: _buildAnnotations(),
      ),
    );
  }

  List<HorizontalBarrier> _buildAnnotations() {
    final List<HorizontalBarrier> annotations = [];
    annotations.add(
      HorizontalBarrier(
        id: "spread_barrier",
        chartController.currentPrice.value + chartController.spreadValue.value,
        style: HorizontalBarrierStyle(
          color: Colors.red,
          lineColor: Colors.red,
          titleBackgroundColor: Colors.red,
          labelShapeBackgroundColor: Colors.red,
          hasBlinkingDot: true,
        ),
      ),
    );

    // Current price barrier
    annotations.add(
      HorizontalBarrier(
        id: "current_price_barrier",
        chartController.currentPrice.value,
        style: HorizontalBarrierStyle(
          color: Colors.green,
          lineColor: Colors.green,
          titleBackgroundColor: Colors.green,
          labelShapeBackgroundColor: Colors.green,
          hasBlinkingDot: true,
        ),
      ),
    );

    // Open orders barriers
    final openOrders = tradingController.openOrderModel.value?.response ?? [];
    for (var order in openOrders) {
      final double openPrice = double.tryParse(order.openPrice.toString()) ?? 0.0;
      final String type = order.orderType?.toUpperCase() ?? "";
      final double lot = order.lot ?? 0.0;

      if (order.symbol == chartController.selectedMarket.value) {
        annotations.add(
          HorizontalBarrier(
            openPrice,
            id: "barrier_${order.ticket}_${order.orderType}",
            title: "$type ${lot.toStringAsFixed(2)} lot",
            style: HorizontalBarrierStyle(
              color: type == "BUY" ? Colors.blue : Colors.red,
              lineColor: type == "BUY" ? Colors.blue : Colors.red,
              titleBackgroundColor: type == "BUY" ? Colors.blue : Colors.red,
              labelShapeBackgroundColor: type == "BUY" ? Colors.blue : Colors.red,
              hasBlinkingDot: true,
            ),
          ),
        );
      }
    }
    return annotations;
  }

  Widget _buildToolbar(Size? size) {
    String? marketName = removeTextAfterDot(chartController.selectedMarket.value);
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
            _buildTimeframeDropdown(),
            // TradingProperty.textButton(context, title: "H1", onPressed: (){}),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TradingProperty.iconButton(context, AntDesign.function_outline, (){
              FeatureUnderDevPopup.show();
              // print("Open Expanded Chart View");
              // print("Symbol: ${chartController.selectedMarket.value}, Timeframe: ${chartController.timeFrame.value}, isReal: ${accountController.selectedAccount.value?.type == "demo" ? false : true}");
              // Get.to(() => ExpandedAdvanceView(
              //   symbol: chartController.selectedMarket.value,
              //   timeframe: chartController.timeFrame.value,
              //   isReal: accountController.selectedAccount.value?.type == "demo" ? false : true,
              // ));
            }),
            Obx(() => TradingProperty.textButton(context, title: "${accountController.selectedAccount.value?.namaTipeAkun != null ? accountController.selectedAccount.value!.namaTipeAkun!.capitalize : ''} - ${accountController.selectedAccount.value?.login ?? ''}", onPressed: (){
              final bool canPress = accountController.hasAccounts;
              if(canPress){
                AccountSelectionBottomSheet.show();
                chartController.loadChartData();
              }
            })),
          ],
        ),
      ],
    );
  }

  // --- WIDGET DROPDOWN TIMEFRAME BARU ---
  Widget _buildTimeframeDropdown() {
    return Obx(() {
      String currentValue = chartController.availableTimeframes.contains(chartController.timeFrame.value) ? chartController.timeFrame.value : 'H1';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: DropdownButton<String>(
          value: currentValue,
          borderRadius: BorderRadius.circular(10.0),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: Colors.grey[800], 
          underline: Container(), // Menghilangkan garis bawah default
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              // chartController.changeTimeframe(newValue);
              print("Timeframe changed to: $newValue");
              chartController.loadChartData(timeframe: newValue).then((_) {
                chartController.timeFrame.value = newValue;
              });
            }
          },
          items: chartController.availableTimeframes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: value == currentValue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildExecutionButton(){
    String? loginID = accountController.selectedAccount.value?.login;
    double finalCurrentPrice = chartController.currentPrice.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child:  Row(
        children: [
          TradingProperty.sellButton(
            price: double.tryParse(finalCurrentPrice.toStringAsFixed(4)), 
            onPressed: loginID == null ? null : () => _executeOrder("sell")
          ),
          TradingProperty.lotButton(context),
          TradingProperty.buyButton(price: double.tryParse(finalCurrentPrice.toStringAsFixed(4)), 
            onPressed: loginID == null ? null : () => _executeOrder("buy")
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memicu eksekusi order (diperbarui)
  void _executeOrder(String orderType) async {
    String? loginID = accountController.selectedAccount.value?.login;
    double finalCurrentPrice = chartController.currentPrice.value;
    double lot = chartController.lot.value;
    if (loginID == null) return;
    if(lot < 0.10){
      CustomScaffoldMessanger.showAppSnackBar(context, message: "Transaksi minimal harus 0.1 Lot", type: SnackBarType.info);
      return;
    }
    // 2. Tampilkan Dialog Konfirmasi
    Get.dialog(
      PopupExecution.buildOrderConfirmationDialog(
        context: context,
        symbol: chartController.selectedMarket.value,
        type: orderType.toUpperCase(),
        lot: lot,
        price: finalCurrentPrice,
        onConfirm: () async {
          // Logika eksekusi order HANYA dijalankan setelah user menekan tombol Konfirmasi
          final result = await tradingController.executionOrder(
            symbol: chartController.selectedMarket.value, 
            type: orderType, 
            login: loginID, 
            lot: lot.toString(), 
          );
          if(result['status']){
            CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
          }else{
            CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.error);
          }
        },
      ),
    );
  }

  String removeTextAfterDot(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input.split('.').first;
  }
}