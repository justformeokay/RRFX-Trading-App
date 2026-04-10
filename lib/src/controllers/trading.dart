import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/controllers/two_factory_auth.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/models/trades/candle_model.dart';
import 'package:rrfx/src/models/trades/ohlc_models.dart';
import 'package:rrfx/src/models/trades/open_order_model.dart';
import 'package:rrfx/src/models/trades/symbol_model.dart';
import 'package:rrfx/src/models/trades/trading_account_model_v2.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';
import 'package:rrfx/src/service/account_credentials_service.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/auth_service.dart';
import '../models/trades/trading_order_history_model.dart';

class OHLCDataModel {
  DateTime? date;
  double? open;
  double? high;
  double? low;
  double? close;
  OHLCDataModel({this.date, this.open, this.high, this.low, this.close});
}

class TradingController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingConnct = false.obs;
  RxString responseMessage = "".obs;
  var candleModel = <CandleModel>[].obs;
  Rxn<SymbolModels> symbolModel = Rxn<SymbolModels>();
  Rxn<OHLCModels> ohlcModels = Rxn<OHLCModels>();
  RxList<OHLCDataModel> ohlcData = <OHLCDataModel>[].obs;
  // RxList<Candle> ohlcDataDeriv = <Candle>[].obs;
  Rxn<TradingAccountModels> tradingAccountModels = Rxn<TradingAccountModels>();
  Rxn<ClosedOrderModel> tradingHistoryModel = Rxn<ClosedOrderModel>();
  Rxn<OpenOrderModel> openOrderModel = Rxn<OpenOrderModel>();
  /// Incremented when a position is closed, so the chart WebView can detect it and reload.
  RxInt chartRefreshTrigger = 0.obs;
  TwoFactoryAuth twoFactoryAuth = Get.put(TwoFactoryAuth());
  AuthController authController = Get.put(AuthController());
  AuthService authService = AuthService();
  RxList<Map<String, dynamic>> accountTrading = <Map<String, dynamic>>[].obs;
  final RxList<TradingAccountModelV2> allAccounts =
      <TradingAccountModelV2>[].obs;
  RxList symbols = [].obs;
  RxDouble minPrice = 0.0.obs;
  RxDouble maxPrice = 0.0.obs;
  RxList allTradingAccounts = [].obs;

  // ── Caching untuk getTradingAccount (account/info) ──
  DateTime? _accountInfoFetchedAt;
  Future<bool>? _accountInfoFetchInProgress;
  static const Duration _accountInfoCacheTTL = Duration(minutes: 2);

  // ── Caching untuk getTradingAccountV2 (market/account/list) ──
  DateTime? _accountListFetchedAt;
  Future<List<Map<String, dynamic>>>? _accountListFetchInProgress;
  static const Duration _accountListCacheTTL = Duration(minutes: 2);
  List<Map<String, dynamic>>? _cachedAccountList;
  // static final Random _random = Random(42);

  // WebSocket controller untuk realtime updates
  // MarketWebSocketController? _wsController;
  // String? _currentSymbol;
  // bool _isListening = false;

  @override
  void onInit() {
    super.onInit();
    // WebSocket listener akan di-setup saat getMarketForDerivChartV4 dipanggil pertama kali
  }

  // void _ensureWebSocketListener() {
  //   if (_isListening) return; // Sudah listening, skip

  //   // Get WebSocket controller instance
  //   try {
  //     _wsController = Get.find<MarketWebSocketController>();
  //     _listenToWebSocketUpdates();
  //     _isListening = true;
  //     // print('✅ WebSocket listener initialized for TradingController');
  //   } catch (e) {
  //     // print('⚠️ WebSocket controller not available yet: $e');
  //   }
  // }

  // void _listenToWebSocketUpdates() {
  //   if (_wsController == null) return;

  //   // Listen to WebSocket market data updates
  //   ever(_wsController!.marketData, (data) {
  //     // if (_currentSymbol == null || ohlcDataDeriv.isEmpty) return;

  //     // Cari data untuk symbol yang sedang aktif
  //     final marketData = data[_currentSymbol];
  //     if (marketData != null) {
  //       // Update candle terakhir dengan bid price dari WebSocket
  //       // final lastCandle = ohlcDataDeriv.last;
  //       // final updatedCandle = Candle(
  //       //   epoch: lastCandle.epoch,
  //       //   open: lastCandle.open,
  //       //   high: lastCandle.high > marketData.bid ? lastCandle.high : marketData.bid,
  //       //   low: lastCandle.low < marketData.bid ? lastCandle.low : marketData.bid,
  //       //   close: marketData.bid, // Close = bid price dari WebSocket
  //       // );

  //       // Replace candle terakhir
  //       // ohlcDataDeriv[ohlcDataDeriv.length - 1] = updatedCandle;
  //       // print(
  //       //   '📊 Updated last candle for $_currentSymbol - close: ${marketData.bid}',
  //       // );
  //     }
  //   });
  // }

  Future<bool> getSymbols({String? loginID}) async {
    try {
      Map<String, dynamic> result = await authService.get(
        "market/symbols?account=$loginID",
      );
      if (result['status'] == true) {
        symbolModel(SymbolModels.fromJson(result));
        return true;
      } else {
        responseMessage(result['message'] ?? "Terjadi kesalahan");
        return false;
      }
    } catch (e) {
      responseMessage("getSymbols error: $e");
      return false;
    }
  }

  Future<bool> getOHLC({
    String? loginID,
    String? timeFrame,
    String? symbol,
  }) async {
    try {
      final result = await authService.get(
        "market/price-history?account=$loginID&timeframe=$timeFrame&symbol=${symbol ?? 'AUDCAD.db'}",
      );
      if (result['statusCode'] == 200 && result['status'] == true) {
        final List<dynamic> response = result['response'] ?? [];
        final candles = response.map((e) => CandleModel.fromJson(e)).toList();
        candleModel.assignAll(candles);
        return true;
      } else {
        responseMessage(result['message'] ?? "Gagal ambil data OHLC");
        return false;
      }
    } catch (e) {
      responseMessage("Get OHLC error: $e");
      return false;
    }
  }

  /// Get Market History SyncFusion
  Future<bool> getMarket({String? market, String? timeframe}) async {
    try {
      market = market ?? "-";
      timeframe = timeframe ?? "H1";
      Map<String, dynamic> result = await authService.get(
        "market/price-history?symbol=$market&timeframe=$timeframe",
      );
      if (result['status'] != true) {
        return false;
      }

      List<dynamic> json =
          result['response'].map((e) => e as Map<String, dynamic>).toList();
      minPrice.value = 0.0;
      maxPrice.value = 0.0;
      ohlcData.clear();
      for (var i in json) {
        minPrice.value =
            (minPrice.value < double.parse(i['open'].toString()) &&
                    minPrice.value != 0.0)
                ? minPrice.value
                : double.parse(i['open'].toString());
        maxPrice.value =
            maxPrice.value > double.parse(i['open'].toString())
                ? maxPrice.value
                : double.parse(i['open'].toString());

        ohlcData.add(
          OHLCDataModel(
            date: DateTime.parse(i['date']),
            open: double.parse(i['open'].toString()),
            high: double.parse(i['high'].toString()),
            low: double.parse(i['low'].toString()),
            close: double.parse(i['close'].toString()),
          ),
        );
      }

      return true;
    } catch (e) {
      throw Exception("getMarket error: $e");
    }
  }

  // Future<bool> getMarketForDerivChartV3({
  //   String? loginID,
  //   String? symbol,
  //   String? timeframe,
  // }) async {
  //   try {
  //     symbol = symbol ?? GlobalVariable.symbolHardCode[0];
  //     final Map<String, dynamic> result = await authService.get(
  //       "market/price-history?account=$loginID&timeframe=$timeframe&symbol=$symbol",
  //     );
  //     if (result['status'] != true) {
  //       return false;
  //     }

  //     final List<dynamic> json =
  //         result['response'].map((e) => e as Map<String, dynamic>).toList();
  //     List<Candle> newCandles = [];
  //     for (var i in json) {
  //       try {
  //         final candle = Candle(
  //           epoch: DateTime.parse(i['time']).millisecondsSinceEpoch ~/ 1000,
  //           open: double.parse(i['open'].toString()),
  //           high: double.parse(i['high'].toString()),
  //           low: double.parse(i['low'].toString()),
  //           close: double.parse(i['close'].toString()),
  //         );
  //         newCandles.add(candle);
  //       } catch (_) {
  //         continue;
  //       }
  //     }

  //     // Sort by epoch (asc)
  //     newCandles.sort((a, b) => a.epoch.compareTo(b.epoch));

  //     // Clear & replace
  //     ohlcDataDeriv.clear();
  //     ohlcDataDeriv.addAll(newCandles);

  //     // Optional: limit data
  //     if (ohlcDataDeriv.length > 500) {
  //       ohlcDataDeriv.removeRange(0, ohlcDataDeriv.length - 500);
  //     }
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Future<bool> getMarketForDerivChartV2({
  //   String? loginID,
  //   String? timeFrame,
  //   String? symbol,
  // }) async {
  //   try {
  //     final Map<String, dynamic> result = await authService.get(
  //       "market/price-history?account=$loginID&timeframe=$timeFrame&symbol=${symbol ?? 'AUDCAD.db'}",
  //     );
  //     if (result['status'] != true) {
  //       return false;
  //     }
  //     final List<dynamic> json =
  //         result['response'].map((e) => e as Map<String, dynamic>).toList();
  //     List<Candle> newCandles = [];
  //     for (var i in json) {
  //       try {
  //         final candle = Candle(
  //           epoch: DateTime.parse(i['time']).millisecondsSinceEpoch ~/ 1000,
  //           open: double.parse(i['open'].toString()),
  //           high: double.parse(i['high'].toString()),
  //           low: double.parse(i['low'].toString()),
  //           close: double.parse(i['close'].toString()),
  //         );
  //         newCandles.add(candle);
  //       } catch (_) {
  //         continue;
  //       }
  //     }
  //     newCandles.sort((a, b) => a.epoch.compareTo(b.epoch));

  //     if (ohlcDataDeriv.isEmpty) {
  //       ohlcDataDeriv.assignAll(newCandles);
  //     } else {
  //       final lastEpoch = ohlcDataDeriv.last.epoch;
  //       final freshCandles =
  //           newCandles.where((c) => c.epoch > lastEpoch).toList();
  //       if (freshCandles.isNotEmpty) {
  //         ohlcDataDeriv.addAll(freshCandles);
  //       } else {
  //         final lastNewCandle = newCandles.last;
  //         if (lastNewCandle.epoch == lastEpoch) {
  //           ohlcDataDeriv[ohlcDataDeriv.length - 1] = lastNewCandle;
  //         }
  //       }
  //     }
  //     if (ohlcDataDeriv.length > 500) {
  //       ohlcDataDeriv.removeRange(0, ohlcDataDeriv.length - 500);
  //     }
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Future<bool> getMarketForDerivChartV4({
  //   String? loginID,
  //   String? timeFrame,
  //   String? symbol,
  //   String? accountType,
  // }) async {
  //   try {
  //     // Simpan symbol saat ini untuk WebSocket updates
  //     _currentSymbol = symbol;

  //     // Ensure WebSocket listener is initialized (lazy init)
  //     _ensureWebSocketListener();

  //     final response = await http.get(
  //       Uri.tryParse(
  //         "http://139.180.219.85:6003/chart/$accountType/$symbol?timeframe=$timeFrame",
  //       )!,
  //     );
  //     if (response.statusCode != 200) {
  //       return false;
  //     }
  //     final List<dynamic> json =
  //         jsonDecode(
  //           response.body,
  //         )['chart_data'].map((e) => e as Map<String, dynamic>).toList();
  //     List<Candle> newCandles = [];
  //     for (var i in json) {
  //       try {
  //         // API v4 returns 'time' as Unix timestamp (integer), not string
  //         final candle = Candle(
  //           epoch: (i['time'] as num).toInt(),
  //           open: double.parse(i['open'].toString()),
  //           high: double.parse(i['high'].toString()),
  //           low: double.parse(i['low'].toString()),
  //           close: double.parse(i['close'].toString()),
  //         );
  //         newCandles.add(candle);
  //       } catch (e) {
  //         print('⚠️ Error parsing candle: $e');
  //         continue;
  //       }
  //     }
  //     newCandles.sort((a, b) => a.epoch.compareTo(b.epoch));

  //     if (ohlcDataDeriv.isEmpty) {
  //       ohlcDataDeriv.assignAll(newCandles);
  //     } else {
  //       final lastEpoch = ohlcDataDeriv.last.epoch;
  //       final freshCandles =
  //           newCandles.where((c) => c.epoch > lastEpoch).toList();
  //       if (freshCandles.isNotEmpty) {
  //         ohlcDataDeriv.addAll(freshCandles);
  //       } else {
  //         final lastNewCandle = newCandles.last;
  //         if (lastNewCandle.epoch == lastEpoch) {
  //           ohlcDataDeriv[ohlcDataDeriv.length - 1] = lastNewCandle;
  //         }
  //       }
  //     }
  //     if (ohlcDataDeriv.length > 500) {
  //       ohlcDataDeriv.removeRange(0, ohlcDataDeriv.length - 500);
  //     }

  //     // Trigger immediate update dari WebSocket jika ada data
  //     if (_wsController != null && symbol != null) {
  //       final marketData = _wsController!.marketData[symbol];
  //       if (marketData != null && ohlcDataDeriv.isNotEmpty) {
  //         final lastCandle = ohlcDataDeriv.last;
  //         final updatedCandle = Candle(
  //           epoch: lastCandle.epoch,
  //           open: lastCandle.open,
  //           high:
  //               lastCandle.high > marketData.bid
  //                   ? lastCandle.high
  //                   : marketData.bid,
  //           low:
  //               lastCandle.low < marketData.bid
  //                   ? lastCandle.low
  //                   : marketData.bid,
  //           close: marketData.bid,
  //         );
  //         ohlcDataDeriv[ohlcDataDeriv.length - 1] = updatedCandle;
  //         print('📊 Initial WS update for $symbol - close: ${marketData.bid}');
  //       }
  //     }

  //     return true;
  //   } catch (e) {
  //     print('❌ Error in getMarketForDerivChartV4: $e');
  //     return false;
  //   }
  // }

  /// Get Market History for Deriv Chart with real-time updates
  // Future<bool> getMarketForDerivChart({
  //   String? market,
  //   String? timeframe,
  // }) async {
  //   try {
  //     market = market ?? "GOLDUD";
  //     timeframe = timeframe ?? "H1";

  //     final Map<String, dynamic> result = await authService.get(
  //       "market/price-history?symbol=$market&timeframe=$timeframe",
  //     );

  //     if (result['status'] != true) {
  //       return false;
  //     }

  //     final List<dynamic> json =
  //         result['response'].map((e) => e as Map<String, dynamic>).toList();
  //     List<Candle> newCandles = [];

  //     for (var i in json) {
  //       try {
  //         final candle = Candle(
  //           epoch: DateTime.parse(i['date']).millisecondsSinceEpoch ~/ 1000,
  //           open: double.parse(i['open'].toString()),
  //           high: double.parse(i['high'].toString()),
  //           low: double.parse(i['low'].toString()),
  //           close: double.parse(i['close'].toString()),
  //         );
  //         newCandles.add(candle);
  //       } catch (e) {
  //         continue;
  //       }
  //     }
  //     newCandles.sort((a, b) => a.epoch.compareTo(b.epoch));
  //     ohlcDataDeriv.clear();
  //     ohlcDataDeriv.addAll(newCandles);

  //     // print("Current number of candles: ${ohlcDataDeriv.length}");
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  /// Generate a list of sample ticks.
  // static List<Tick> generateTicks({int count = 100}) {
  //   final List<Tick> ticks = [];
  //   final baseTimestamp =
  //       DateTime.now()
  //           .subtract(Duration(minutes: count))
  //           .millisecondsSinceEpoch;
  //   double lastQuote = 100;

  //   for (int i = 0; i < count; i++) {
  //     final timestamp = baseTimestamp + i * 60000; // 1 minute intervals
  //     // Random walk with some volatility
  //     lastQuote += (_random.nextDouble() - 0.5) * 2.0;
  //     ticks.add(Tick(epoch: timestamp, quote: lastQuote));
  //   }
  //   return ticks;
  // }

  // Create Demo Trading API
  /// Fetch trading accounts (account/info) dengan caching.
  /// [forceRefresh] = true untuk bypass cache.
  Future<bool> getTradingAccount({bool forceRefresh = false}) async {
    // Return cached data jika masih fresh
    if (!forceRefresh &&
        tradingAccountModels.value != null &&
        _accountInfoFetchedAt != null &&
        DateTime.now().difference(_accountInfoFetchedAt!) < _accountInfoCacheTTL) {
      Get.log("✅ [TRADING] getTradingAccount() using cache (age: ${DateTime.now().difference(_accountInfoFetchedAt!).inSeconds}s)");
      return true;
    }

    // Deduplicate: jika fetch sedang berjalan, tunggu yang sudah ada
    if (_accountInfoFetchInProgress != null) {
      Get.log("⏳ [TRADING] getTradingAccount() already in progress, waiting...");
      return _accountInfoFetchInProgress!;
    }

    _accountInfoFetchInProgress = _doGetTradingAccount();
    try {
      return await _accountInfoFetchInProgress!;
    } finally {
      _accountInfoFetchInProgress = null;
    }
  }

  Future<bool> _doGetTradingAccount() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("account/info");
      isLoading(false);
      if (result['statusCode'] == 200) {
        tradingAccountModels(TradingAccountModels.fromJson(result['response']));
        allTradingAccounts.clear();
        if (result['response']['demo'].toList().isNotEmpty) {
          allTradingAccounts.add(result['response']['demo']);
        }
        if (result['response']['real'].toList().isNotEmpty) {
          allTradingAccounts.add(result['response']['real']);
        }
        _accountInfoFetchedAt = DateTime.now();
        return true;
      }
      responseMessage(result['message']);
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  /// Fetch trading account list (market/account/list) dengan caching.
  /// [forceRefresh] = true untuk bypass cache.
  Future<List<Map<String, dynamic>>> getTradingAccountV2({bool forceRefresh = false}) async {
    // Return cached data jika masih fresh
    if (!forceRefresh &&
        _cachedAccountList != null &&
        _accountListFetchedAt != null &&
        DateTime.now().difference(_accountListFetchedAt!) < _accountListCacheTTL) {
      Get.log("✅ [TRADING] getTradingAccountV2() using cache (age: ${DateTime.now().difference(_accountListFetchedAt!).inSeconds}s)");
      return _cachedAccountList!;
    }

    // Deduplicate: jika fetch sedang berjalan, tunggu yang sudah ada
    if (_accountListFetchInProgress != null) {
      Get.log("⏳ [TRADING] getTradingAccountV2() already in progress, waiting...");
      return _accountListFetchInProgress!;
    }

    _accountListFetchInProgress = _doGetTradingAccountV2();
    try {
      return await _accountListFetchInProgress!;
    } finally {
      _accountListFetchInProgress = null;
    }
  }

  Future<List<Map<String, dynamic>>> _doGetTradingAccountV2() async {
    try {
      Map<String, dynamic> result = await authService.get(
        "market/account/list",
      );
      if (result['status'] != true) {
        return [];
      }

      List<dynamic> rawList = result['response'];
      List<Map<String, dynamic>> json =
          rawList.map((e) => Map<String, dynamic>.from(e)).toList();
      _cachedAccountList = json;
      _accountListFetchedAt = DateTime.now();
      return json;
    } catch (e) {
      throw Exception("getTradingAccount error: $e");
    }
  }

  /// Invalidate semua trading account cache.
  /// Panggil setelah add/delete/connect account.
  void invalidateTradingAccountCache() {
    _accountInfoFetchedAt = null;
    _accountListFetchedAt = null;
    _cachedAccountList = null;
    Get.log("🗑️ [TRADING] Trading account cache invalidated");
  }

  // Create Demo Trading API
  Future<bool> createDemo() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post(
        "regol/createDemo",
        {},
      );
      (result);

      isLoading(false);
      if (result['status']) {
        return true;
      }
      responseMessage(result['message']);
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> addTradingAccount({
    required String accountId,
  }) async {
    try {
      Map<String, dynamic> result = await authService.post(
        "market/account/add",
        {'account_id': accountId},
      );
      invalidateTradingAccountCache();
      return result;
    } catch (e) {
      throw Exception("addTradingAccount error: $e");
    }
  }

  Future<Map<String, dynamic>> connectTradingAccount({
    required String accountId,
  }) async {
    isLoadingConnct(true);
    try {
      Map<String, dynamic> result = await authService.post(
        "market/account/connect",
        {'account_id': accountId},
      );
      isLoadingConnct(false);
      invalidateTradingAccountCache();
      return result;
    } catch (e) {
      throw Exception("addTradingAccount error: $e");
    }
  }

  Future<Map<String, dynamic>> inputPassword({
    required String accountId,
    required String password,
  }) async {
    try {
      Map<String, dynamic> result = await authService.post(
        "market/account/update",
        {'account_id': accountId, 'password': password},
      );
      return result;
    } catch (e) {
      throw Exception("addTradingAccount error: $e");
    }
  }

  Future<Map<String, dynamic>> deleteTradingAccount({
    required String accountId,
  }) async {
    try {
      Map<String, dynamic> result = await authService.post(
        'market/account/delete',
        {'trade_id': accountId},
      );
      invalidateTradingAccountCache();
      return result;
    } catch (e) {
      throw Exception("deleteTradingAccount error: $e");
    }
  }

  Future<Map<String, dynamic>> executionOrder({
    required String symbol,
    required String type,
    required String login,
    required String lot,
  }) async {
    print(login);
    print(symbol);
    print(type);
    print(lot);
    try {
      Map<String, dynamic> result = await authService.post(
        'market/execution/open',
        {
          'login': login.toString(),
          'symbol': symbol,
          'operation': type,
          'volume': lot,
          // 'price': price
        },
      );
      print(result);
      return result;
    } catch (e) {
      throw Exception("executionOrder error: $e");
    }
  }

  // API Daftar Transaksi Tertutup
  Future<Map<String, dynamic>> closedOrder({required String login}) async {
    try {
      Map<String, dynamic> result = await authService.get(
        'market/trade-history?login=$login',
      );
      tradingHistoryModel(ClosedOrderModel.fromJson(result));
      return result;
    } catch (e) {
      throw Exception("executionOrder error: $e");
    }
  }

  // API Daftar Transaksi Terbuka
  Future<Map<String, dynamic>> openOrder({required String login}) async {
    try {
      Map<String, dynamic> result = await authService.get(
        'market/opened-order?login=$login',
      );
      openOrderModel(OpenOrderModel.fromJson(result));
      print("INI RESULT OPEN ORDER => $result");
      return result;
    } catch (e) {
      throw Exception("executionOrder error: $e");
    }
  }

  Future<Map<String, dynamic>> closingOrder({
    required String loginID,
    required String? ticketID,
  }) async {
    try {
      // Get token (auto-fetch if missing)
      String? token = AccountCredentialsService.getTokenByLogin(loginID);
      if (token == null || token.isEmpty) {
        if (!AccountCredentialsService.hasCachedData()) {
          await AccountCredentialsService.fetchAndCache(forceRefresh: true);
        } else {
          token = await AccountCredentialsService.refreshTokenForLogin(loginID);
        }
        token ??= AccountCredentialsService.getTokenByLogin(loginID);
        if (token == null || token.isEmpty) {
          throw Exception('Gagal mendapatkan koneksi MT5 untuk login $loginID.');
        }
      }

      // First attempt
      var result = await _callOrderCloseSafe(token: token, ticket: ticketID ?? '');

      // Handle INVALID_TOKEN → refresh token and retry once
      if (result.containsKey('code') && result['code'] == 'INVALID_TOKEN') {
        Get.log('🔄 [CLOSE] INVALID_TOKEN → refreshing token for login $loginID...');
        final newToken = await AccountCredentialsService.refreshTokenForLogin(loginID);
        if (newToken == null || newToken.isEmpty) {
          throw Exception('Koneksi MT5 gagal. Silakan login ulang.');
        }
        result = await _callOrderCloseSafe(token: newToken, ticket: ticketID ?? '');
      }

      // Handle other error codes
      if (result.containsKey('code') && result['code'] != null) {
        final errorMsg = result['message'] ?? 'Close order gagal';
        throw Exception(errorMsg);
      }

      // Validate ticket in response
      final responseTicket = result['ticket'];
      if (responseTicket == null || responseTicket == 0) {
        final errorMsg = result['message'] ?? 'Close order gagal: tidak mendapat ticket.';
        throw Exception(errorMsg);
      }

      Get.log('✅ [CLOSE] Position closed successfully! Ticket: $responseTicket');

      // Signal the chart WebView to refresh (position was closed)
      chartRefreshTrigger.value++;

      return {
        'status': true,
        'message': 'Position berhasil ditutup',
        'data': result,
      };
    } catch (e) {
      isLoading(false);
      final errMsg = e.toString().replaceAll('Exception: ', '');
      throw Exception(errMsg);
    }
  }

  /// Internal: call OrderCloseSafe API
  Future<Map<String, dynamic>> _callOrderCloseSafe({
    required String token,
    required String ticket,
  }) async {
    final uri = Uri.parse(
      '$_mt5ApiBase/OrderClose'
      '?id=$token'
      '&ticket=$ticket'
      '&lots=0'
      '&price=0'
      '&slippage=0',
    );

    Get.log('📦 [CLOSE] Request URL: $uri');

    final response = await http.get(
      uri,
      headers: {'accept': 'text/json'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Close order timeout, coba lagi.'),
    );

    Get.log('📥 [CLOSE] Response status: ${response.statusCode}');
    Get.log('📥 [CLOSE] Response body: ${response.body}');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String get _mt5ApiBase => GlobalVariable.tradingApiBase;

  Future<Map<String, dynamic>> modifyPosition({
    required String login,
    required String ticket,
    required double stopLoss,
    required double takeProfit,
    bool isPending = false,
  }) async {
    try {
      // Get token (auto-fetch if missing)
      String? token = AccountCredentialsService.getTokenByLogin(login);
      if (token == null || token.isEmpty) {
        if (!AccountCredentialsService.hasCachedData()) {
          await AccountCredentialsService.fetchAndCache(forceRefresh: true);
        } else {
          token = await AccountCredentialsService.refreshTokenForLogin(login);
        }
        token ??= AccountCredentialsService.getTokenByLogin(login);
        if (token == null || token.isEmpty) {
          throw Exception('Gagal mendapatkan koneksi MT5 untuk login $login.');
        }
      }

      // First attempt
      var result = await _callOrderModifySafe(
        token: token,
        ticket: ticket,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
      );

      // Handle INVALID_TOKEN → refresh token and retry once
      if (result.containsKey('code') && result['code'] == 'INVALID_TOKEN') {
        Get.log('🔄 [MODIFY] INVALID_TOKEN → refreshing token for login $login...');
        final newToken = await AccountCredentialsService.refreshTokenForLogin(login);
        if (newToken == null || newToken.isEmpty) {
          throw Exception('Koneksi MT5 gagal. Silakan login ulang.');
        }
        result = await _callOrderModifySafe(
          token: newToken,
          ticket: ticket,
          stopLoss: stopLoss,
          takeProfit: takeProfit,
        );
      }

      // Handle other error codes
      if (result.containsKey('code') && result['code'] != null) {
        final errorMsg = result['message'] ?? 'Modify order gagal';
        throw Exception(errorMsg);
      }

      // Validate ticket in response
      final responseTicket = result['ticket'];
      if (responseTicket == null || responseTicket == 0) {
        final errorMsg = result['message'] ?? 'Modify order gagal: tidak mendapat ticket.';
        throw Exception(errorMsg);
      }

      Get.log('✅ [MODIFY] Position modified successfully! Ticket: $responseTicket');
      return {
        'status': true,
        'message': 'Position berhasil dimodifikasi',
        'response': result,
      };
    } catch (e) {
      isLoading(false);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Internal: call OrderModifySafe API
  Future<Map<String, dynamic>> _callOrderModifySafe({
    required String token,
    required String ticket,
    required double stopLoss,
    required double takeProfit,
  }) async {
    final uri = Uri.parse(
      '$_mt5ApiBase/OrderModify'
      '?id=$token'
      '&ticket=$ticket'
      '&stoploss=$stopLoss'
      '&takeprofit=$takeProfit'
      '&price=0'
      '&stoplimit=0',
    );

    Get.log('📦 [MODIFY] Request URL: $uri');

    final response = await http.get(
      uri,
      headers: {'accept': 'text/json'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Modify order timeout, coba lagi.'),
    );

    Get.log('📥 [MODIFY] Response status: ${response.statusCode}');
    Get.log('📥 [MODIFY] Response body: ${response.body}');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<bool> getAllTradingAccount({bool forceRefresh = false}) async {
    // Use getTradingAccount cache for the raw data, then convert format
    final success = await getTradingAccount(forceRefresh: forceRefresh);
    if (!success || tradingAccountModels.value == null) {
      return false;
    }

    try {
      final rawReal = tradingAccountModels.value!.response.real ?? [];
      final rawDemo = tradingAccountModels.value!.response.demo ?? [];

      // Convert Real/Demo objects to Map then to TradingAccountModelV2
      final allList = <TradingAccountModelV2>[];
      for (final r in rawReal) {
        allList.add(TradingAccountModelV2(
          id: r.id, login: r.login, type: r.type,
          namaTipeAkun: r.namaTipeAkun, rate: r.rate,
          marginFree: r.marginFree, balance: r.balance,
          leverage: r.leverage, pnl: r.pnl, currency: r.currency,
          minDeposit: r.minDeposit, minTopup: r.minTopup,
          minWithdrawal: r.minWithdrawal, maxWithdrawal: r.maxWithdrawal,
        ));
      }
      for (final d in rawDemo) {
        allList.add(TradingAccountModelV2(
          id: d.id, login: d.login, type: d.type,
          namaTipeAkun: d.namaTipeAkun, rate: d.rate,
          marginFree: d.marginFree, balance: d.balance,
          leverage: d.leverage, pnl: d.pnl, currency: d.currency,
          minDeposit: d.minDeposit, minTopup: d.minTopup,
          minWithdrawal: d.minWithdrawal, maxWithdrawal: d.maxWithdrawal,
        ));
      }

      allAccounts.assignAll(allList);
      responseMessage('Berhasil memuat akun trading');
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }
}
