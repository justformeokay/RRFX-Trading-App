
/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/service/candlestick/api_services.dart';
import 'package:rrfx/src/service/candlestick/candle_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CandlestickChartView extends StatefulWidget {
  const CandlestickChartView({super.key});

  @override
  State<CandlestickChartView> createState() => _CandlestickChartViewState();
}

class _CandlestickChartViewState extends State<CandlestickChartView> {
  CandleController? controller; // nullable dulu
  TradingController tradingController = Get.find();
  bool isLoading = true;

  RxString selectedAccount = "0".obs;
  String selectedTimeframe = "H1";
  String selectedSymbol = "AUDCAD.db";
  RxList<String> itemAccounts = <String>[].obs;
  RxList<String> itemSymbols = <String>[].obs;

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    return accessToken;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final String? accessToken = await getAccessToken();
      if(accessToken?.isEmpty == true){
        return;
      }
      final resultTradingAccount = await tradingController.getAllTradingAccount();
      if (!resultTradingAccount) {
        CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
        return;
      }
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
      _initController(token: "Bearer $accessToken");
    });
  }

  Future<void> _initController({String? token}) async {
    final c = CandleController(ApiService(token ?? '0'));
    await c.init(
      account: selectedAccount.value,
      timeframe: selectedTimeframe,
      symbol: selectedSymbol,
    );
    setState(() {
      controller = c;
      isLoading = false;
    });
  }

  Future<void> _reloadChart() async {
    setState(() => isLoading = true);
    await controller?.init(
      account: selectedAccount.value,
      timeframe: selectedTimeframe,
      symbol: selectedSymbol,
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Loading saat pertama kali init
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    // Jika controller belum siap
    if (controller == null) {
      return const Scaffold(
        body: Center(child: Text("Controller belum siap")),
      );
    }

    // Ambil data candle dari controller
    final candles = controller?.candles ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Deriv Chart")),
      body: Column(
        children: [
          Row(
            children: [
              Obx(
                () => _dropdown("Account", selectedAccount.value, itemAccounts, (v) {
                  setState(() => selectedAccount.value = v!);
                  _reloadChart();
                }),
              ),
              _dropdown("Timeframe", selectedTimeframe,
                  ["M1", "M5", "H1", "D1"], (v) {
                setState(() => selectedTimeframe = v!);
                _reloadChart();
              }),
              Obx(
                () => _dropdown("Symbol", selectedSymbol, itemSymbols, (v) {
                  setState(() => selectedSymbol = v!);
                  _reloadChart();
                }),
              ),
            ],
          ),
          Expanded(
            child: controller!.candles?.isEmpty == true
              ? const Center(child: Text("No candle data"))
              : DerivChart(
                activeSymbol: selectedSymbol,
                mainSeries: CandleSeries(controller!.candles!),
                pipSize: 5,
                granularity: 3600,
                loadingAnimationColor: Colors.transparent,
              ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(labelText: label),
          items:
              items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deriv_chart/deriv_chart.dart';
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

        if (controller.candles.isEmpty) {
          return const Center(child: Text('No candle data.'));
        }

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
              child: DerivChart(
                activeSymbol: selectedSymbol.value,
                mainSeries: CandleSeries(controller.candles),
                pipSize: 5,
                granularity: 3600, // 1 jam
                loadingAnimationColor: Colors.transparent,
              ),
            ),
          ],
        );
      }),
    );
  }
}
