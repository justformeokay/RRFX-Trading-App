import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/experimentals/charts/models/ohlc_data.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/ticker_model.dart';

class ChartControllerExperimentals extends GetxController {
  // --- States ---
  final isLoading = true.obs;

  // Parameter Chart
  final selectedAccountType = 'demo'.obs;
  final selectedMarket = 'EURUSD.db'.obs;
  final timeFrame = 'M1'.obs;

  // Data Akun (Dummy)
  final accountBalance = 10000.00.obs;
  final accountId = 'D1234567'.obs;

  // Data Real-time dari WebSocket
  final currentPrice = 0.0.obs;
  final spreadValue = 0.0.obs; // Digunakan untuk barrier spread
  final currentBid = 0.0.obs;
  final currentAsk = 0.0.obs;
  // Digits/Pip size didapat dari WS
  final marketDigits = 5.obs;

  // Data Trading
  final currentLot = 0.01.obs;

  // WebSocket
  WebSocketChannel? _channel;
  Timer? _refreshTimer;

  // Market & Timeframe Lists
  final List<String> marketList = ['EURUSD', 'XAUUSD', 'GBPUSD', 'AUDCAD'];
  final List<String> timeframeList = ['M1', 'M5', 'M15', 'H1', 'D1'];

  // --- Lifecycle ---
  @override
  void onInit() {
    super.onInit();
    // Memuat data pertama kali
    fetchOhlcData();
    // Memulai koneksi WebSocket
    connectWebSocket();
    // Memulai timer untuk refresh data
    startRefreshTimer();
  }

  @override
  void onClose() {
    _channel?.sink.close();
    _refreshTimer?.cancel();
    super.onClose();
  }

  // --- Logika API OHLC ---
  Future<void> fetchOhlcData() async {
    isLoading(true);
    // Batalkan timer refresh saat fetch data baru
    _refreshTimer?.cancel();

    final url =
        'http://139.180.219.85:6003/chart/${selectedAccountType.value}/${selectedMarket.value}?timeframe=${timeFrame.value}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final chartResponse = ChartResponse.fromJson(jsonResponse);

        // Konversi data OHLC ke model Candle untuk DerivChart
        // ohlcDataDeriv.value = chartResponse.chartData.map((data) => data.toCandle()).toList();

        // Update currentPrice dengan Close price bar terakhir
        // if (ohlcDataDeriv.isNotEmpty) {
        //   currentPrice.value = ohlcDataDeriv.last.close;
        // }
      } else {
        Get.snackbar(
          'Error',
          'Gagal memuat data chart: ${response.statusCode}',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat chart: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
      // Mulai ulang timer setelah data dimuat
      startRefreshTimer();
    }
  }

  void connectWebSocket() {
    _channel?.sink.close(); // Tutup koneksi lama jika ada

    try {
      // Menggunakan URL WebSocket yang baru
      _channel = WebSocketChannel.connect(
        Uri.parse(GlobalVariable.wsMarketURL),
      );

      _channel!.stream.listen(
        (data) {
          try {
                final jsonResponse = jsonDecode(data);

                // Helper to check match while preserving original symbols (do not modify suffixes)
                bool matchesSymbol(String wsSymbolRaw, String selMarketRaw) {
                  final wsSymbol = wsSymbolRaw.toLowerCase();
                  final sel = selMarketRaw.toLowerCase();
                  if (wsSymbol == sel) return true;
                  // If UI uses symbol without suffix (e.g. "XAUUSD") allow matching against WS "XAUUSD.db"
                  if (!sel.contains('.') && wsSymbol == '${sel}.db') return true;
                  return false;
                }

                // WS may send a single ticker object with "symbol" or a map keyed by symbol.
                if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('symbol')) {
                  final ticker = Ticker.fromJson(jsonResponse);
                  final wsSymbol = ticker.symbol;
                  if (matchesSymbol(wsSymbol, selectedMarket.value)) {
                    currentBid.value = ticker.bid;
                    currentAsk.value = ticker.ask;
                    marketDigits.value = ticker.digits;
                    currentPrice.value = (ticker.bid + ticker.ask) / 2;
                  }
                } else if (jsonResponse is Map<String, dynamic>) {
                  // multiple markets: { "XAUUSD.db": {..}, "GBPNZD.db": {..} }
                  jsonResponse.forEach((symbolKey, inner) {
                    try {
                      if (inner is Map<String, dynamic>) {
                        // build a ticker-like object using the outer key as symbol
                        final mapWithSymbol = Map<String, dynamic>.from(inner);
                        mapWithSymbol['symbol'] = symbolKey;
                        final ticker = Ticker.fromJson(mapWithSymbol);
                        if (matchesSymbol(symbolKey, selectedMarket.value)) {
                          currentBid.value = ticker.bid;
                          currentAsk.value = ticker.ask;
                          marketDigits.value = ticker.digits;
                          currentPrice.value = (ticker.bid + ticker.ask) / 2;
                        }
                      }
                    } catch (e) {
                      // ignore parse errors for non-ticker entries
                    }
                  });
                }
          } catch (e) {
            Get.log('⚠️ [experimentals] error parsing WS message: $e');
          }
        },
        onError: (error) {
          // Reconnect logic
          Future.delayed(const Duration(seconds: 5), connectWebSocket);
        },
        onDone: () {
          // Reconnect logic
          Future.delayed(const Duration(seconds: 5), connectWebSocket);
        },
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), connectWebSocket);
    }
  }

  int get pipSize => marketDigits.value;

  // --- Logika Refresh Chart (5 detik) ---
  void startRefreshTimer() {
    _refreshTimer?.cancel(); // Pastikan timer sebelumnya dihentikan
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Panggil fetchOhlcData untuk mendapatkan data terbaru dan 'bergerak'
      fetchOhlcData();
    });
  }

  // --- Aksi Pengguna ---
  void changeMarket(String? market) {
    if (market != null && market != selectedMarket.value) {
      selectedMarket.value = market;
      fetchOhlcData();
    }
  }

  void changeTimeframe(String? timeframe) {
    if (timeframe != null && timeframe != timeFrame.value) {
      timeFrame.value = timeframe;
      fetchOhlcData();
    }
  }

  void incrementLot() {
    if (currentLot.value < 10.0) {
      currentLot.value = (currentLot.value + 0.01).toPrecision(2);
    }
  }

  void decrementLot() {
    if (currentLot.value > 0.01) {
      currentLot.value = (currentLot.value - 0.01).toPrecision(2);
    }
  }

  // --- Helper untuk DerivChart ---
  // Contoh: M1=60, M5=300, H1=3600
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
      case 'D1':
        return 86400;
      default:
        return 60;
    }
  }
}
