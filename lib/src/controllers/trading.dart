import 'package:get/get.dart';
import 'package:rrfx/src/controllers/two_factory_auth.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/models/trades/candle_model.dart';
import 'package:rrfx/src/models/trades/ohlc_models.dart';
import 'package:rrfx/src/models/trades/open_order_model.dart';
import 'package:rrfx/src/models/trades/symbol_model.dart';
import 'package:rrfx/src/models/trades/trading_account_model_v2.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';
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
  Future<bool> getTradingAccount() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("account/info");
      isLoading(false);
      if (result['statusCode'] == 200) {
        tradingAccountModels(TradingAccountModels.fromJson(result['response']));
        if (result['response']['demo'].toList().isNotEmpty) {
          allTradingAccounts.add(result['response']['demo']);
        }
        if (result['response']['real'].toList().isNotEmpty) {
          allTradingAccounts.add(result['response']['real']);
        }
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

  Future<List<Map<String, dynamic>>> getTradingAccountV2() async {
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
      return json;
    } catch (e) {
      throw Exception("getTradingAccount error: $e");
    }
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
      Map<String, dynamic> result = await authService.post(
        'market/execution/close',
        {'login': loginID, 'ticket': ticketID},
      );
      return result;
    } catch (e) {
      isLoading(false);
      throw Exception("executionOrder error: $e");
    }
  }

  Future<Map<String, dynamic>> modifyPosition({
    required String login,
    required String ticket,
    required double stopLoss,
    required double takeProfit,
    bool isPending = false,
  }) async {
    try {
      Map<String, dynamic> result = await authService.post(
        'market/execution/modify',
        {
          'login': login,
          'ticket': ticket,
          'tp': takeProfit.toString(),
          'sl': stopLoss.toString(),
          'is_pending': isPending ? '1' : '0',
        },
      );
      Get.log("INI RESULT MODIFY POSITION => $result");
      return result;
    } catch (e) {
      isLoading(false);
      throw Exception("modifyPosition error: $e");
    }
  }

  Future<bool> getAllTradingAccount() async {
    try {
      isLoading(true);
      final result = await authService.get("account/info");
      isLoading(false);

      if (result['status'] == true && result['response'] != null) {
        final response = result['response'] ?? {};

        // Bisa kosong
        final List<dynamic> realList = response['real'] ?? [];
        final List<dynamic> demoList = response['demo'] ?? [];

        // Gabungkan & konversi ke model
        final allList = [
          ...realList.map(
            (e) => TradingAccountModelV2.fromJson(Map<String, dynamic>.from(e)),
          ),
          ...demoList.map(
            (e) => TradingAccountModelV2.fromJson(Map<String, dynamic>.from(e)),
          ),
        ];

        allAccounts.assignAll(allList);

        responseMessage('Berhasil memuat akun trading');
        return true;
      }

      responseMessage(result['message'] ?? 'Gagal memuat data');
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }
}
