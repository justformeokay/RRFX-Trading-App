import 'dart:async';
import 'package:get/get.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/candle_model.dart';
import '../repositories/market_repository.dart';
import 'candle_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tick model dari Supabase
class SupabaseTick {
  final double bid;
  final double ask;
  final int datetimeMsc;

  SupabaseTick({
    required this.bid,
    required this.ask,
    required this.datetimeMsc,
  });

  factory SupabaseTick.fromJson(Map<String, dynamic> json) {
    return SupabaseTick(
      bid: (json['bid'] as num).toDouble(),
      ask: (json['ask'] as num).toDouble(),
      datetimeMsc: (json['datetime_msc'] ?? json['datetimeMsc']) as int,
    );
  }
}

class CandleController extends GetxController {
  final candles = <CandleModel>[].obs;

  final MarketRepository repo = MarketRepository();
  final CandleDatabase db = CandleDatabase.instance;
  AccountController accountController = Get.find<AccountController>();

  String symbol = '';
  String timeframe = '';

  StreamSubscription<List<Map<String, dynamic>>>? _supaSub;

  /// Getter: data OHLC untuk DerivChart
  List<Candle> get ohlcDeriv {
    return candles.map((c) {
      return Candle(
        epoch: (c.time.millisecondsSinceEpoch / 1000).round(),
        open: c.open,
        high: c.high,
        low: c.low,
        close: c.close,
      );
    }).toList();
  }

  /// ----------------------------------------
  /// INIT
  /// ----------------------------------------
  Future<void> init(String symbol, String timeframe) async {
    this.symbol = symbol;
    this.timeframe = timeframe;
    final accessToken = await getAccessToken();
    await loadInitialHistory(accessToken: accessToken ?? '');
    listenRealtime();
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    return accessToken;
  }

  /// ----------------------------------------
  /// LOAD HISTORY AWAL dari API → DB → Memory
  /// ----------------------------------------
  Future<void> loadInitialHistory({
    required String accessToken,
  }) async {
    try {
      final history = await repo.fetchHistory(
        symbol: symbol,
        timeframe: timeframe,
        account: accountController.selectedAccount.value?.login ?? '',
        accessToken: accessToken,
      );

      candles.assignAll(history);

      await db.deleteCandlesFor(symbol, timeframe);

      for (var c in history) {
        await db.insertCandle(symbol, timeframe, c);
      }
    } catch (e) {
      print("loadInitialHistory failed: $e");
    }
  }

  /// ----------------------------------------
  /// REALTIME SUPABASE STREAM
  /// ----------------------------------------
  void listenRealtime() {
    final client = Supabase.instance.client;

    final stream = client
        .from('latest_ticks')
        .stream(primaryKey: ['id'])
        .eq('symbol', symbol);

    print("Listening realtime for symbol: $symbol");

    _supaSub = stream.listen((List<Map<String, dynamic>> rows) {
      for (var row in rows) {
        try {
          final tick = SupabaseTick.fromJson(row);
          applyTick(tick);
        } catch (e) {
          print("Tick JSON parse error: $e");
        }
      }
    });
  }

  /// ----------------------------------------
  /// UPDATE CANDLE AKTIF oleh TICK BARU
  /// ----------------------------------------
  void applyTick(SupabaseTick t) {
    if (candles.isEmpty) return;

    final idx = candles.length - 1;
    final last = candles[idx];
    final price = t.bid;

    final updated = CandleModel(
      time: last.time,
      open: last.open,
      high: price > last.high ? price : last.high,
      low: price < last.low ? price : last.low,
      close: price,
      digits: last.digits,
      tickVolume: last.tickVolume + 1,
    );

    candles[idx] = updated;
    db.updateLastCandle(symbol, timeframe, updated);

    /// Jika timeframe sudah selesai → buat candle baru
    if (isTimeframeFinished(last.time, t.datetimeMsc)) {
      createNewCandle(updated.close, t.datetimeMsc);
    }
  }

  /// ----------------------------------------
  /// CEK apakah timeframe sudah selesai
  /// ----------------------------------------
  bool isTimeframeFinished(DateTime last, int tickMsc) {
    final dt = DateTime.fromMillisecondsSinceEpoch(tickMsc).toUtc();

    switch (timeframe) {
      case 'H1':
        return dt.hour != last.toUtc().hour || dt.day != last.toUtc().day;

      case 'M15':
        return (dt.minute ~/ 15) != (last.minute ~/ 15);

      default:
        return false;
    }
  }

  /// ----------------------------------------
  /// CREATE NEW CANDLE
  /// ----------------------------------------
  Future<void> createNewCandle(double price, int tickMsc) async {
    final dt = DateTime.fromMillisecondsSinceEpoch(tickMsc).toUtc();

    final c = CandleModel(
      time: dt,
      open: price,
      high: price,
      low: price,
      close: price,
      digits: candles.last.digits,
      tickVolume: 0,
    );

    candles.add(c);
    await db.insertCandle(symbol, timeframe, c);
  }

  @override
  void onClose() {
    _supaSub?.cancel();
    super.onClose();
  }
}
