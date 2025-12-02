import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:rrfx/src/service/candlestick/api_services.dart';
import 'package:rrfx/src/service/candlestick/database_helper.dart';

class CandlestickController extends GetxController {
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  RxList<Candle> candles = <Candle>[].obs;
  RxBool isLoading = false.obs;
  RxBool marketOpen = true.obs;

  Timer? _timer;
  String? _symbol;
  String? _timeframe;
  String? _account;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Inisialisasi feed market
  Future<void> startFeed({
    required String symbol,
    required String timeframe,
    required String account,
  }) async {
    _symbol = symbol;
    _timeframe = timeframe;
    _account = account;

    await loadFromDB();

    // cek apakah hari ini weekend
    await checkMarketStatus();

    // ambil data candle awal
    await fetchAndSaveCandles();

    // kalau market buka → start timer 5 detik
    if (marketOpen.value) {
      _startTimer();
      print("✅ Market buka — update tiap 5 detik.");
    } else {
      print("📅 Market libur (Sabtu/Minggu) — fetch 1x saja.");
    }
  }

  /// cek apakah hari ini sabtu atau minggu (libur)
  Future<void> checkMarketStatus() async {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'id_ID').format(now).toLowerCase();

    if (dayName.contains('sabtu') || dayName.contains('minggu')) {
      marketOpen.value = false;
    } else {
      marketOpen.value = true;
    }
  }

  /// timer periodic 5 detik
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await fetchAndSaveCandles();
    });
  }

  /// load dari database lokal
  Future<void> loadFromDB() async {
    if (_symbol == null || _timeframe == null || _account == null) return;
    isLoading.value = true;

    final localCandles = await dbHelper.getCandles(
      symbol: _symbol!,
      timeframe: _timeframe!,
      account: _account!,
    );

    candles.assignAll(localCandles);
    isLoading.value = false;
  }

  Future<void> fetchAndSaveCandles() async {
    if (_symbol == null || _timeframe == null || _account == null) return;

    try {
      final result = await apiService.get(
        'market/price-history?account=$_account&timeframe=$_timeframe&symbol=$_symbol',
      );

      if (result['status'] != true) return;

      final dynamic res = result['response'];

      List<dynamic> json = [];
      if (res is List) {
        json = res;
      } else if (res is Map<String, dynamic> && res['response'] is List) {
        json = res['response'];
      } else if (res is Map<String, dynamic>) {
        json = [res];
      } else {
        print("⚠️ Struktur response tidak dikenal: $res");
        return;
      }

      final List<Candle> newCandles = [];
      for (var i in json) {
        try {
          final candle = Candle(
            epoch: DateTime.parse(i['time']).millisecondsSinceEpoch ~/ 1000,
            open: double.parse(i['open'].toString()),
            high: double.parse(i['high'].toString()),
            low: double.parse(i['low'].toString()),
            close: double.parse(i['close'].toString()),
          );
          newCandles.add(candle);
        } catch (err) {
          print("⚠️ Error parsing candle: $err, data: $i");
        }
      }

      newCandles.sort((a, b) => a.epoch.compareTo(b.epoch));

      final dbCandles = await dbHelper.getCandles(
        symbol: _symbol!,
        timeframe: _timeframe!,
        account: _account!,
      );

      int lastEpoch = dbCandles.isNotEmpty ? dbCandles.last.epoch : 0;
      final fresh = newCandles.where((c) => c.epoch > lastEpoch).toList();

      if (fresh.isNotEmpty) {
        await dbHelper.insertOrReplaceCandles(
          fresh,
          symbol: _symbol!,
          timeframe: _timeframe!,
          account: _account!,
        );
        candles.addAll(fresh);

        print("🟢 ${fresh.length} candle baru disimpan (${_symbol!})");
      } else {
        print("⚪ Tidak ada candle baru (${_symbol!})");
      }
      await dbHelper.debugPrintCandles(_symbol!);
    } catch (e) {
      print("❌ Error fetchAndSaveCandles: $e");
    }
  }
}
