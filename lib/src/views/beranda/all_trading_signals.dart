import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';

import 'components/market_item.dart';

class AllTradingSignals extends StatefulWidget {
  const AllTradingSignals({super.key});

  @override
  State<AllTradingSignals> createState() => _AllTradingSignalsState();
}

class _AllTradingSignalsState extends State<AllTradingSignals> {
  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  TradingController tradingController = Get.put(TradingController());
  Map<String, String>? flag;
  Future<void> loadTradingAccount() async {
    tradingController.accountTrading.value = await tradingController.getTradingAccountV2().then((result) => result);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      utilitiesController.getTradingSignals().then((result){
        loadTradingAccount();
        if(!result){}
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Trading Signals",
        autoImplyLeading: true
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 16.0),
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: List.generate(utilitiesController.tradingSignal.value?.message?.length ?? 0, (index){
                flag = RegexFormatter.getFlagsFromPairName(utilitiesController.tradingSignal.value?.message?[index].symbol ?? "EURUSD");
                  return marketItem(
                    context,
                    size,
                    tradingAccountUser: tradingController.accountTrading,
                    marketName: utilitiesController.tradingSignal.value?.message?[index].symbol,
                    flagPair: flag?['flag_one'],
                    flagPaired: flag?['flag_two'],
                    ask: utilitiesController.tradingSignal.value?.message?[index].analysis?.currentPrice?.ask.toString(),
                    recommendation: utilitiesController.tradingSignal.value?.message?[index].analysis?.recommendation != null ? utilitiesController.tradingSignal.value?.message![index].analysis!.recommendation!.toUpperCase() : "-",
                    bid: utilitiesController.tradingSignal.value?.message?[index].analysis?.currentPrice?.bid.toString(),
                    stopLoss: utilitiesController.tradingSignal.value?.message?[index].analysis?.tradingSuggestions?.stopLoss.toString(),
                    date: utilitiesController.tradingSignal.value?.message?[index].analysis?.lastUpdate != null ? DateFormat("EEEE, dd MMMM yyyy hh:mm:ss").format(DateTime.parse(utilitiesController.tradingSignal.value!.message![index].analysis!.lastUpdate!)) : "-",
                    sma10: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.sma_10.toString(),
                    sma20: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.sma_20.toString(),
                    sma50: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.sma_50.toString(),
                    priceVsSMA: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.priceVsSma50.toString(),
                    macdLine: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.macd?.macdLine.toString(),
                    signalLine: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.macd?.signalLine.toString(),
                    histogram: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.macd?.histogram.toString(),
                    upper: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.upper.toString(),
                    lower: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.lower.toString(),
                    middle: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.middle.toString(),
                    pricePosition: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.pricePosition.toString(),
                    rsi: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.rsi.toString(),
                    signalSummaryBollingerBands: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.bollinger,
                    signalSummarySMA: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.maCross,
                    signalSummaryRSI: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.rsi,
                    signalSummaryMACD: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.macd,
                  );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
