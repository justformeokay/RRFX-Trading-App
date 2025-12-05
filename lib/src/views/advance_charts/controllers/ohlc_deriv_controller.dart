import 'dart:async';
import 'dart:convert';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/views/advance_charts/controllers/extension_candle_deriv.dart';
import '../models/advance_candle_model.dart';
import 'package:rrfx/src/controllers/websocket_controller.dart';

// Realtime prices from WebSocket
// This controller will listen to MarketWebSocketController.marketData and
// update liveBid/liveAsk accordingly for the currentSymbol.

class OhlcDerivController extends GetxController {
  /// RAW OHLC DATA
  final ohlcRaw = <AdvanceCandleModel>[].obs;

  /// Converted candles for chart
  final candles = <Candle>[].obs;
  final RxList<String> availableTimeframes =
      ['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1'].obs;
  String currentTimeframe = "H1";
  String currentSymbol = "";
  bool currentIsReal = false;

  /// REQUIRED BY PACKAGE
  int granularity = 3600; // default → 1H

  Timer? timer;
  bool firstLoadDone = false;

  // =============================================================
  // GRANULARITY REQUIRED BY CHART PACKAGE
  // =============================================================

  int convertGranularity(String tf) {
    switch (tf.toUpperCase()) {
      case "M1":
        return 60;
      case "M5":
        return 300;
      case "M15":
        return 900;
      case "M30":
        return 1800;
      case "H1":
        return 3600;
      case "H4":
        return 14400;
      case "D1":
        return 86400;
      default:
        return 3600;
    }
  }

  // =============================================================
  // ON TIMEFRAME CHANGE
  // =============================================================
  void changeTimeframe(String newTF) {
    currentTimeframe = newTF;
    startFetching(
      symbol: currentSymbol,
      timeframe: currentTimeframe,
      isReal: currentIsReal,
    );
    granularity = convertGranularity(newTF);
  }

  // =============================================================
  // ON SYMBOL CHANGE
  // =============================================================
  void changeSymbol(String newSymbol) {
    currentSymbol = newSymbol;
    startFetching(
      symbol: currentSymbol,
      timeframe: currentTimeframe,
      isReal: currentIsReal,
    );
  }

  // =============================================================
  // CURRENT PRICE FOR BARRIERS
  // =============================================================
  // liveBid/liveAsk will be updated from WebSocket (if available)
  final RxDouble liveBid = 0.0.obs;
  final RxDouble liveAsk = 0.0.obs;

  double get currentPrice {
    // Prefer live bid if available (realtime), fallback to last candle close
    if (liveBid.value != 0.0) return liveBid.value;
    if (candles.isEmpty) return 0;
    return candles.last.close;
  }

  // =============================================================
  // START FETCHING DATA (INITIAL + REALTIME)
  // =============================================================
  void startFetching({
    required String symbol,
    required String timeframe,
    required bool isReal,
  }) {
    timer?.cancel();
    firstLoadDone = false;

    /// PENTING – set granularity tiap kali start
    granularity = convertGranularity(timeframe);

    final server = isReal ? "real" : "demo";

    fetchInitial(server: server, symbol: symbol, timeframe: timeframe);

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) =>
          fetchLastCandle(server: server, symbol: symbol, timeframe: timeframe),
    );

    // Bind websocket updates for realtime price
    try {
      final MarketWebSocketController ws =
          Get.isRegistered<MarketWebSocketController>()
              ? Get.find<MarketWebSocketController>()
              : Get.put(MarketWebSocketController(), permanent: true);

      // Listen to changes in marketData and update liveBid/liveAsk when symbol matches
      ever(ws.marketData, (Map<String, MarketDataModel> data) {
        final key = currentSymbol;
        if (key.isEmpty) return;
        if (data.containsKey(key)) {
          final md = data[key];
          if (md != null) {
            liveBid.value = md.bid;
            liveAsk.value = md.ask;
          }
        }
      });
    } catch (_) {}
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  // =============================================================
  // FETCH INITIAL FULL OHLC DATA
  // =============================================================
  Future<void> fetchInitial({
    required String server,
    required String symbol,
    required String timeframe,
  }) async {
    try {
      final url = Uri.parse(
        "http://139.180.219.85:6003/chart/${server.toLowerCase()}/$symbol"
        "?timeframe=$timeframe"
        "&granularity=$granularity",
      );

      final res = await http.get(url);
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      List<dynamic> rows = data["chart_data"];

      final parsed = rows.map((e) => AdvanceCandleModel.fromJson(e)).toList();
      parsed.sort((a, b) => a.epoch.compareTo(b.epoch));

      ohlcRaw.value = parsed;
      candles.value = parsed.map((e) => e.toCandle()).toList();

      firstLoadDone = true;
    } catch (_) {}
  }

  // =============================================================
  // FETCH ONLY THE LAST CANDLE
  // =============================================================
  Future<void> fetchLastCandle({
    required String server,
    required String symbol,
    required String timeframe,
  }) async {
    if (!firstLoadDone) return;

    try {
      final url = Uri.parse(
        "http://139.180.219.85:6003/chart/${server.toLowerCase()}/$symbol"
        "?timeframe=$timeframe"
        "&granularity=$granularity",
      );

      final res = await http.get(url);
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      List<dynamic> rows = data["chart_data"];

      if (rows.isEmpty) return;

      final last = AdvanceCandleModel.fromJson(rows.last);

      if (ohlcRaw.isEmpty) {
        ohlcRaw.add(last);
        candles.add(last.toCandle());
        return;
      }

      final localLast = ohlcRaw.last;

      // -----------------------------------------------------------
      // SAME CANDLE → update realtime
      // -----------------------------------------------------------
      if (last.epoch == localLast.epoch) {
        ohlcRaw[ohlcRaw.length - 1] = last;
        candles[candles.length - 1] = last.toCandle();
      }
      // -----------------------------------------------------------
      // NEW CANDLE → append
      // -----------------------------------------------------------
      else if (last.epoch > localLast.epoch) {
        ohlcRaw.add(last);
        candles.add(last.toCandle());

        // Limit memory
        if (ohlcRaw.length > 500) {
          ohlcRaw.removeRange(0, ohlcRaw.length - 500);
          candles.removeRange(0, candles.length - 500);
        }
      }
    } catch (_) {}
  }

  List<ChartAnnotation> get currentPriceBarrier {
    if (candles.isEmpty) return [];

    return [
      HorizontalBarrier(
        currentPrice,
        id: "current_price",
        style: HorizontalBarrierStyle(
          color: Colors.green,
          lineColor: Colors.green,
          titleBackgroundColor: Colors.green,
          labelShapeBackgroundColor: Colors.green,
          hasBlinkingDot: true,
        ),
      ),
    ];
  }
}
