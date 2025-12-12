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
    tradingController.accountTrading.value = await tradingController
        .getTradingAccountV2()
        .then((result) => result);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      utilitiesController.getTradingSignals().then((result) {
        loadTradingAccount();
        if (!result) {}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Trading Signals",
        autoImplyLeading: true,
      ),
      body: Obx(() {
        // Loading state
        if (utilitiesController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty or null data
        final signals = utilitiesController.tradingSignal.value?.message;
        if (signals == null || signals.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_cellular_no_sim_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Sinyal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trading signals belum tersedia saat ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(right: 16.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: List.generate(signals.length, (index) {
                final signal = signals[index];
                flag = RegexFormatter.getFlagsFromPairName(
                  signal.symbol ?? "EURUSD",
                );

                return marketItem(
                  context,
                  size,
                  tradingAccountUser: tradingController.accountTrading,
                  marketName: signal.symbol ?? "N/A",
                  flagPair: flag?['flag_one'],
                  flagPaired: flag?['flag_two'],
                  ask: signal.analysis?.currentPrice?.ask?.toString() ?? "-",
                  recommendation:
                      signal.analysis?.recommendation?.toUpperCase() ?? "-",
                  bid: signal.analysis?.currentPrice?.bid?.toString() ?? "-",
                  stopLoss:
                      signal.analysis?.tradingSuggestions?.stopLoss
                          ?.toString() ??
                      "-",
                  date:
                      signal.analysis?.lastUpdate != null
                          ? DateFormat(
                            "EEEE, dd MMMM yyyy hh:mm:ss",
                          ).format(DateTime.parse(signal.analysis!.lastUpdate!))
                          : "-",
                  sma10:
                      signal.analysis?.indicators?.movingAverages?.sma_10
                          ?.toString() ??
                      "-",
                  sma20:
                      signal.analysis?.indicators?.movingAverages?.sma_20
                          ?.toString() ??
                      "-",
                  sma50:
                      signal.analysis?.indicators?.movingAverages?.sma_50
                          ?.toString() ??
                      "-",
                  priceVsSMA:
                      signal.analysis?.indicators?.movingAverages?.priceVsSma50
                          ?.toString() ??
                      "-",
                  macdLine:
                      signal.analysis?.indicators?.macd?.macdLine?.toString() ??
                      "-",
                  signalLine:
                      signal.analysis?.indicators?.macd?.signalLine
                          ?.toString() ??
                      "-",
                  histogram:
                      signal.analysis?.indicators?.macd?.histogram
                          ?.toString() ??
                      "-",
                  upper:
                      signal.analysis?.indicators?.bollingerBands?.upper
                          ?.toString() ??
                      "-",
                  lower:
                      signal.analysis?.indicators?.bollingerBands?.lower
                          ?.toString() ??
                      "-",
                  middle:
                      signal.analysis?.indicators?.bollingerBands?.middle
                          ?.toString() ??
                      "-",
                  pricePosition:
                      signal.analysis?.indicators?.bollingerBands?.pricePosition
                          ?.toString() ??
                      "-",
                  rsi: signal.analysis?.indicators?.rsi?.toString() ?? "-",
                  signalSummaryBollingerBands:
                      signal.analysis?.signals?.bollinger ?? "-",
                  signalSummarySMA: signal.analysis?.signals?.maCross ?? "-",
                  signalSummaryRSI: signal.analysis?.signals?.rsi ?? "-",
                  signalSummaryMACD: signal.analysis?.signals?.macd ?? "-",
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}
