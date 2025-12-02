import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'package:rrfx/src/views/charts_deriv/controllers/candle_controller.dart';

class CandleChartViewNew extends StatefulWidget {
  const CandleChartViewNew({super.key});

  @override
  State<CandleChartViewNew> createState() => _CandleChartViewNewState();
}

class _CandleChartViewNewState extends State<CandleChartViewNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: buildChart(),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildChart() {
  final candleController = Get.put(CandleController());
  final themeController = Get.find<ThemeController>();
  final chartController = Get.find<ChartControllers>();
  final accountController = Get.find<AccountController>();

  return Obx(() {
    if (!accountController.hasAccounts) {
      return Center(
        child: CircularProgressIndicator(color: CustomColor.secondaryColor),
      );
    }
    return DerivChart(
      granularity: timeframeToGranularity(candleController.timeframe),
      dataFitEnabled: true,
      showCrosshair: true,
      isLive: true,
      theme: themeController.isDark.value ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      mainSeries: CandleSeries(candleController.ohlcDeriv),
      pipSize: chartController.selectedMarket.value.contains("JPY") || chartController.selectedMarket.value.contains("XAU") ? 3 : 5,
      showCurrentTickBlinkAnimation: true,
      activeSymbol: chartController.selectedMarket.value,
      loadingAnimationColor: Colors.transparent,
      annotations: [
        HorizontalBarrier(
          id: "price",
          chartController.currentPrice.value,
          style: HorizontalBarrierStyle(
            color: Colors.green,
            lineColor: Colors.green,
          ),
        ),
      ],
    );
  });
}

int timeframeToGranularity(String tf) {
  switch (tf) {
    case 'M1':
      return 60;
    case 'M5':
      return 300;
    case 'M15':
      return 900;
    case 'M30':
      return 1800;
    case 'H1':
      return 3600;
    case 'H4':
      return 14400;
    default:
      return 3600;
  }
}
