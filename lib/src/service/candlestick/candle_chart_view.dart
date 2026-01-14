import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/service/candlestick/candle_controller.dart';

class CandleChartPage extends StatefulWidget {

  const CandleChartPage({super.key});

  @override
  State<CandleChartPage> createState() => _CandleChartPageState();
}

class _CandleChartPageState extends State<CandleChartPage> {
  final controller = Get.put(CandlestickController());
  TradingController tradingController = Get.find();
  RxList<String> itemAccounts = <String>[].obs;
  RxList<String> itemSymbols = <String>[].obs;

  final RxString selectedSymbol = 'AUDCAD.db'.obs;

  final RxString selectedTimeframe = 'H1'.obs;

  final RxString selectedAccount = '374492'.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (tradingController.allAccounts.isNotEmpty) {
        final firstAcc = tradingController.allAccounts.first;
        selectedAccount.value = firstAcc.login ?? '0';
        for(int i = 0; i < tradingController.allAccounts.length; i++){
          itemAccounts.add(tradingController.allAccounts[i].login.toString());
        }
      }
      final resultSymbols = await tradingController.getSymbols(
        loginID: selectedAccount.value,
      );
      if (!resultSymbols) {
        CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
        return;
      }
      for(int i = 0; i < tradingController.symbolModel.value!.response!.length; i++){
        itemSymbols.add(tradingController.symbolModel.value!.response![i].symbol.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.startFeed(
      symbol: selectedSymbol.value,
      timeframe: selectedTimeframe.value,
      account: selectedAccount.value,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Deriv Candlestick')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // if (controller.candles.isEmpty) {
        //   return const Center(child: Text('No candle data.'));
        // }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButton<String>(
                      value: selectedSymbol.value,
                      items: itemSymbols
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          selectedSymbol.value = v;
                          await controller.startFeed(
                            symbol: v,
                            timeframe: selectedTimeframe.value,
                            account: selectedAccount.value,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(),
              // child: DerivChart(
              //   activeSymbol: selectedSymbol.value,
              //   mainSeries: CandleSeries(controller.candles),
              //   pipSize: 5,
              //   granularity: 3600, // 1 jam
              //   loadingAnimationColor: Colors.transparent,
              // ),
            ),
          ],
        );
      }),
    );
  }
}
