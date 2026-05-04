import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/account_credentials_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartExecutionController extends GetxController {
  String get _mt5ApiBase => GlobalVariable.tradingApiBase;

  // State
  final RxDouble lot = 0.1.obs;
  final RxBool isExecuting = false.obs;
  final RxString executionMessage = ''.obs;

  // Lot increment/decrement
  static const double lotStep = 0.1;
  static const double minLot = 0.1;
  static const double maxLot = 20.0;

  /// Increment lot
  void incrementLot() {
    if (lot.value < maxLot) {
      lot.value = double.parse((lot.value + lotStep).toStringAsFixed(1));
    }
  }

  /// Decrement lot
  void decrementLot() {
    if (lot.value > minLot) {
      lot.value = double.parse((lot.value - lotStep).toStringAsFixed(1));
    }
  }

  /// Get MT5 token for the given login.
  /// If token not found, auto-fetch credentials + reconnect MT5.
  Future<String> _getToken(String login) async {
    // 1. Cek token yang sudah ada di cache
    final existing = AccountCredentialsService.getTokenByLogin(login);
    if (existing != null && existing.isNotEmpty) return existing;

    if (kDebugMode) print('⚠️ Token belum ada untuk login $login, auto-fetching...');

    // 2. Jika credentials belum ada di cache, fetch dari API dulu
    if (!AccountCredentialsService.hasCachedData()) {
      if (kDebugMode) print('📡 Credentials belum ada, fetch dari market/account/list...');
      await AccountCredentialsService.fetchAndCache(forceRefresh: true);
    } else {
      // 3. Credentials ada tapi token belum → langsung refresh token saja
      if (kDebugMode) print('🔗 Credentials ada, fetch token via /Connect...');
      final newToken = await AccountCredentialsService.refreshTokenForLogin(login);
      if (newToken != null && newToken.isNotEmpty) return newToken;
    }

    // 4. Cek lagi setelah fetch
    final token = AccountCredentialsService.getTokenByLogin(login);
    if (token != null && token.isNotEmpty) return token;

    throw Exception('Gagal mendapatkan koneksi MT5 untuk login $login.');
  }

  /// Map operation string to API-friendly format
  String _mapOperation(String operation) {
    switch (operation.toLowerCase()) {
      case 'buy': return 'Buy';
      case 'sell': return 'Sell';
      case 'buylimit': return 'BuyLimit';
      case 'selllimit': return 'SellLimit';
      case 'buystop': return 'BuyStop';
      case 'sellstop': return 'SellStop';
      default: return operation;
    }
  }

  /// Unified order execution via MT5 OrderSendSafe API
  ///
  /// Used for all order types: Market (Buy/Sell) and Pending orders.
  /// Parameters:
  /// - [login]: Account login (used to lookup MT5 token)
  /// - [symbol]: Market symbol (e.g., "XAUUSD.db")
  /// - [operation]: "buy", "sell", "buylimit", "selllimit", "buystop", "sellstop"
  /// - [volume]: Lot size (default uses current lot.value)
  /// - [price]: Entry price (0 for market orders)
  /// - [sl]: Stop Loss price (0 or null = no SL)
  /// - [tp]: Take Profit price (0 or null = no TP)
  /// - [stopLimitPrice]: Stop Limit Price (default 0)
  /// - [slippage]: Slippage (default 0)
  /// - [maxRetries]: Max retries for transient errors
  Future<Map<String, dynamic>> executeOrder({
    required String login,
    required String symbol,
    required String operation,
    double? volume,
    double price = 0,
    double? sl,
    double? tp,
    double stopLimitPrice = 0,
    int slippage = 0,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    bool tokenRefreshed = false;

    String comment = _mt5ApiBase.contains('techcrm') ? 'techcrm' : (_mt5ApiBase.contains('gaintactics') ? 'gaintactics' : 'unknown');

    try {
      String token = await _getToken(login);
      final lotVolume = volume ?? lot.value;
      final apiOperation = _mapOperation(operation);
      if (kDebugMode) print("INI TOKEN YANG DIPAKAI EKSEKUSI ORDER: $token");

      while (retryCount <= maxRetries) {
        // print('📤 ===== EXECUTING ORDER ${retryCount > 0 ? "(Retry $retryCount)" : ""} =====');
        // print('   Operation: $apiOperation');
        // print('   Symbol: $symbol');
        // print('   Volume: $lotVolume lot');
        // print('   Price: $price');
        // print('   SL: ${sl ?? 0}');
        // print('   TP: ${tp ?? 0}');
        // print('   Token: ${token.substring(0, 8)}...');
        // print('   Comment: $comment'); // comment jika API Base nya adalah mt5-api-v3.techcrm.online = techcrm, jika mt5api.gaintactics.com = gaintactics, jika lainnya = unknown
        // print('==============================');

        final uri = Uri.parse(
          '$_mt5ApiBase/OrderSend'
          '?id=$token'
          '&symbol=$symbol'
          '&operation=$apiOperation'
          '&volume=$lotVolume'
          '&price=$price'
          '&slippage=$slippage'
          '&stoploss=${sl ?? 0}'
          '&takeprofit=${tp ?? 0}'
          '&comment=$comment'
          '&stopLimitPrice=$stopLimitPrice',
        );

        if (kDebugMode) print('📦 Request URL: $uri');

        final response = await http.get(
          uri,
          headers: {'accept': 'text/json'},
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Order timeout, coba lagi.'),
        );

        // print('📥 Response status: ${response.statusCode}');
        // print('📥 Response body: ${response.body}');

        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for INVALID_TOKEN — refresh token and retry once
        if (data.containsKey('code') && data['code'] == 'INVALID_TOKEN' && !tokenRefreshed) {
          // print('🔄 INVALID_TOKEN detected — refreshing token for login $login...');
          executionMessage.value = 'Token expired, reconnecting...';
          tokenRefreshed = true;

          final newToken = await AccountCredentialsService.refreshTokenForLogin(login);
          if (newToken != null && newToken.isNotEmpty) {
            token = newToken;
            // print('✅ Token refreshed successfully, retrying order...');
            continue; // Retry with new token (don't increment retryCount)
          } else {
            // print('❌ Token refresh failed');
            throw Exception('Koneksi MT5 gagal. Silakan login ulang.');
          }
        }

        // Check for other error codes
        if (data.containsKey('code') && data['code'] != null) {
          final errorMsg = data['message'] ?? 'Order gagal dieksekusi';
          executionMessage.value = errorMsg;
          // print('❌ Order failed (error code ${data['code']}): $errorMsg');
          throw Exception(errorMsg);
        }

        if (response.statusCode == 200) {
          // Validate ticket — null or 0 means order failed
          final ticket = data['ticket'];
          if (ticket == null || ticket == 0) {
            final errorMsg = data['message'] ?? 'Order gagal: tidak mendapat ticket.';
            executionMessage.value = errorMsg;
            // print('❌ Order failed: ticket is $ticket');
            throw Exception(errorMsg);
          }

          // Success — response has valid "ticket" field
          executionMessage.value = 'Order berhasil dieksekusi!';
          // print('✅ Order executed successfully! Ticket: ${data['ticket']}');

          return {
            'status': true,
            'message': 'Order berhasil dieksekusi',
            'response': data,
          };
        } else {
          final errorMsg = data['message'] ?? 'Order gagal (HTTP ${response.statusCode})';

          // Retry HANYA untuk "no prices" — kondisi transient MT5 saat quote belum tersedia.
          // Delay 500ms (cukup untuk 3-5 quote cycles). Error lain: fail fast tanpa retry.
          if (errorMsg.toString().toLowerCase().contains('no prices') && retryCount < maxRetries) {
            retryCount++;
            // print('⏳ "No prices" - retry $retryCount/$maxRetries dalam 500ms...');
            executionMessage.value = 'Menunggu harga... (percobaan $retryCount)';
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }

          // HTTP error lain (margin, symbol, market closed, dll) — fail fast, tidak retry.
          executionMessage.value = errorMsg;
          // print('❌ Order failed: $errorMsg');
          throw Exception(errorMsg);
        }
      }

      throw Exception('Order gagal setelah $maxRetries percobaan');
    } catch (e, stackTrace) {
      // print('❌ ===== ORDER EXECUTION ERROR =====');
      // print('   Error Type: ${e.runtimeType}');
      // print('   Error Message: $e');
      // print('   Stack Trace: $stackTrace');
      // print('====================================');
      rethrow;
    }
  }

  Future<String> getTokenForWSS() async {
    if (kDebugMode) print('🔐 Requesting token for WSS connection...');
    String username = GlobalVariable.wsUsername;
    String password = GlobalVariable.wsPassword;
    final body = jsonEncode({
      'username': username,
      'password': password,
    });
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final uri = Uri.parse('${GlobalVariable.mainURLForWSSTokenGetAPI}${GlobalVariable.loginTokenWSSEndpoint}');
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Token request timeout'),
      );
      if (kDebugMode) print('📥 Token response status: ${response.statusCode}');
      if (kDebugMode) print(response.body);
      if (response.statusCode == 200) {
        // Pastikan response body di-parse ke Map
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Ambil token
        final String? token = data['token'];

        if (token != null && token.isNotEmpty) {
          // Simpan ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('wsToken', token);
          
          GlobalVariable.tokenWSS = token;
          return token;
        } else {
          // Jika token null, cetak isi data untuk debug
          if (kDebugMode) print("Struktur data salah: $data");
          throw 'Field token tidak ditemukan atau kosong';
        }
      } else {
        throw 'HTTP Error: ${response.statusCode}';
      }
    } catch(e) {
      if (kDebugMode) print('❌ Error getting token for WSS: $e');
      throw Exception('Gagal mendapatkan token untuk koneksi WebSocket.');
    }
  }

  /// Execute BUY market order
  Future<Map<String, dynamic>> executeBuy({
    required String login,
    required String symbol,
    double? volume,
    double? sl,
    double? tp,
  }) async {
    return executeOrder(
      login: login,
      symbol: symbol,
      operation: 'buy',
      volume: volume,
      sl: sl,
      tp: tp,
    );
  }

  /// Execute SELL market order
  Future<Map<String, dynamic>> executeSell({
    required String login,
    required String symbol,
    double? volume,
    double? sl,
    double? tp,
  }) async {
    return executeOrder(
      login: login,
      symbol: symbol,
      operation: 'sell',
      volume: volume,
      sl: sl,
      tp: tp,
    );
  }

  /// Execute Pending Order (BuyLimit, SellLimit, BuyStop, SellStop)
  ///
  /// SL and TP are now in PRICE (not points).
  Future<Map<String, dynamic>> executePendingOrder({
    required String login,
    required String symbol,
    required String operation,
    required double price,
    double? volume,
    double? sl,
    double? tp,
    int maxRetries = 3,
  }) async {
    return executeOrder(
      login: login,
      symbol: symbol,
      operation: operation,
      volume: volume,
      price: price,
      sl: sl,
      tp: tp,
      maxRetries: maxRetries,
    );
  }

  /// Execute BUY LIMIT order
  Future<Map<String, dynamic>> executeBuyLimit({
    required String login,
    required String symbol,
    required double price,
    double? volume,
    double? sl,
    double? tp,
  }) async {
    return executePendingOrder(
      login: login,
      symbol: symbol,
      operation: 'buylimit',
      price: price,
      volume: volume,
      sl: sl,
      tp: tp,
    );
  }

  /// Execute SELL LIMIT order
  Future<Map<String, dynamic>> executeSellLimit({
    required String login,
    required String symbol,
    required double price,
    double? volume,
    double? sl,
    double? tp,
  }) async {
    return executePendingOrder(
      login: login,
      symbol: symbol,
      operation: 'selllimit',
      price: price,
      volume: volume,
      sl: sl,
      tp: tp,
    );
  }

  /// Execute BUY STOP order
  Future<Map<String, dynamic>> executeBuyStop({
    required String login,
    required String symbol,
    required double price,
    double? volume,
    double? sl,
    double? tp,
  }) async {
    return executePendingOrder(
      login: login,
      symbol: symbol,
      operation: 'buystop',
      price: price,
      volume: volume,
      sl: sl,
      tp: tp,
    );
  }

  /// Execute SELL STOP order
  Future<Map<String, dynamic>> executeSellStop({
    required String login,
    required String symbol,
    required double price,
    double? volume,
    double? sl,
    double? tp,
  }) async {
    return executePendingOrder(
      login: login,
      symbol: symbol,
      operation: 'sellstop',
      price: price,
      volume: volume,
      sl: sl,
      tp: tp,
    );
  }

  /// Reset lot to default
  void resetLot() {
    lot.value = minLot;
  }

  /// Set custom lot value
  void setLot(double value) {
    if (value >= minLot && value <= maxLot) {
      lot.value = double.parse(value.toStringAsFixed(1));
    }
  }
}
