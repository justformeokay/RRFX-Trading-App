import 'package:get/get.dart';
import 'package:rrfx/src/service/auth_service.dart';

class ChartExecutionController extends GetxController {
  final AuthService _authService = AuthService();

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

  /// Execute buy or sell order
  /// 
  /// Parameters:
  /// - [login]: Account login number
  /// - [symbol]: Market symbol (e.g., "AUDCAD.db")
  /// - [operation]: "buy" or "sell"
  /// - [volume]: Lot size (default uses current lot.value)
  /// - [maxRetries]: Maximum retry attempts for "No prices" error (default: 3)
  /// 
  /// Returns API response Map or throws exception on error
  Future<Map<String, dynamic>> executeOrder({
    required String login,
    required String symbol,
    required String operation, // "buy" or "sell"
    double? volume,
    int maxRetries = 3,
  }) async {
    if (isExecuting.value) {
      throw Exception('Order sedang diproses');
    }

    int retryCount = 0;
    
    try {
      isExecuting.value = true;
      executionMessage.value = 'Memproses order...';

      final lotVolume = volume ?? lot.value;

      while (retryCount <= maxRetries) {
        print('📤 ===== EXECUTING ORDER ${retryCount > 0 ? "(Retry $retryCount)" : ""} =====');
        print('   Operation: ${operation.toUpperCase()}');
        print('   Symbol: $symbol');
        print('   Volume: $lotVolume lot');
        print('   Login: $login');
        print('==============================');

        final requestBody = {
          'login': login,
          'symbol': symbol,
          'operation': operation.toLowerCase(),
          'volume': lotVolume.toString(),
        };

        print('📦 Request Body: $requestBody');

        final response = await _authService.post(
          'market/execution/open',
          requestBody,
        );

        print('📥 Response received:');
        print('   Status: ${response['status']}');
        print('   Status Code: ${response['statusCode']}');
        print('   Message: ${response['message']}');
        print('   Response Data: ${response['response']}');

        if (response['status'] == true) {
          executionMessage.value = 'Order berhasil dieksekusi!';
          print('✅ Order executed successfully!');
          return response;
        } else {
          final errorMsg = response['message'] ?? 'Order gagal dieksekusi';
          
          // Check if "No prices" error and still have retries left
          if (errorMsg.toString().toLowerCase().contains('no prices') && retryCount < maxRetries) {
            retryCount++;
            print('⏳ "No prices" error - waiting 1.5s before retry ($retryCount/$maxRetries)...');
            executionMessage.value = 'Menunggu harga... (percobaan $retryCount)';
            await Future.delayed(const Duration(milliseconds: 1500));
            continue; // Retry the loop
          }
          
          executionMessage.value = errorMsg;
          print('❌ Order failed: $errorMsg');
          throw Exception(errorMsg);
        }
      }
      
      // If we exit the loop without returning, throw error
      throw Exception('Order gagal setelah $maxRetries percobaan');
    } catch (e, stackTrace) {
      print('❌ ===== ORDER EXECUTION ERROR =====');
      print('   Error Type: ${e.runtimeType}');
      print('   Error Message: $e');
      print('   Stack Trace: $stackTrace');
      print('====================================');
      executionMessage.value = 'Error: $e';
      rethrow;
    } finally {
      isExecuting.value = false;
    }
  }

  /// Execute BUY order
  Future<Map<String, dynamic>> executeBuy({
    required String login,
    required String symbol,
    double? volume,
  }) async {
    return executeOrder(
      login: login,
      symbol: symbol,
      operation: 'buy',
      volume: volume,
    );
  }

  /// Execute SELL order
  Future<Map<String, dynamic>> executeSell({
    required String login,
    required String symbol,
    double? volume,
  }) async {
    return executeOrder(
      login: login,
      symbol: symbol,
      operation: 'sell',
      volume: volume,
    );
  }

  /// Execute Pending Order (Buy Limit, Sell Limit, Buy Stop, Sell Stop)
  /// 
  /// Parameters:
  /// - [login]: Account login number
  /// - [symbol]: Market symbol (e.g., "EURJPY.db")
  /// - [operation]: "buylimit", "selllimit", "buystop", "sellstop"
  /// - [volume]: Lot size (default uses current lot.value)
  /// - [price]: Entry price (required)
  /// - [sl]: Stop Loss (optional)
  /// - [tp]: Take Profit (optional)
  /// - [maxRetries]: Maximum retry attempts for "No prices" error (default: 3)
  /// 
  /// Returns API response Map or throws exception on error
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
    if (isExecuting.value) {
      throw Exception('Order sedang diproses');
    }

    int retryCount = 0;

    try {
      isExecuting.value = true;
      executionMessage.value = 'Memproses pending order...';

      final lotVolume = volume ?? lot.value;

      while (retryCount <= maxRetries) {
        print('📤 ===== EXECUTING PENDING ORDER ${retryCount > 0 ? "(Retry $retryCount)" : ""} =====');
        print('   Operation: ${operation.toUpperCase()}');
        print('   Symbol: $symbol');
        print('   Volume: $lotVolume lot');
        print('   Price: $price');
        print('   SL: ${sl ?? "Not set"}');
        print('   TP: ${tp ?? "Not set"}');
        print('   Login: $login');
        print('======================================');


        final Map<String, String> requestBody = {
          'login': login,
          'symbol': symbol,
          'operation': operation.toLowerCase(),
          'volume': lotVolume.toString(),
          'price': price.toString(),
        };

        print("INI REQUEST BODY: $requestBody");

        // Add optional SL/TP if provided
        if (sl != null && sl > 0) {
          requestBody['sl'] = sl.toString();
        }
        if (tp != null && tp > 0) {
          requestBody['tp'] = tp.toString();
        }

        print('📦 Request Body: $requestBody');

        final response = await _authService.post(
          'market/execution/open',
          requestBody,
        );

        print('📥 Response received:');
        print('   Status: ${response['status']}');
        print('   Status Code: ${response['statusCode']}');
        print('   Message: ${response['message']}');
        print('   Response Data: ${response['response']}');

        if (response['status'] == true) {
          executionMessage.value = 'Pending order berhasil dibuat!';
          print('✅ Pending order created successfully!');
          return response;
        } else {
          final errorMsg = response['message'] ?? 'Pending order gagal dibuat';
          
          // Check if "No prices" error and still have retries left
          if (errorMsg.toString().toLowerCase().contains('no prices') && retryCount < maxRetries) {
            retryCount++;
            print('⏳ "No prices" error - waiting 1.5s before retry ($retryCount/$maxRetries)...');
            executionMessage.value = 'Menunggu harga... (percobaan $retryCount)';
            await Future.delayed(const Duration(milliseconds: 1500));
            continue; // Retry the loop
          }
          
          executionMessage.value = errorMsg;
          print('❌ Pending order failed: $errorMsg');
          throw Exception(errorMsg);
        }
      }
      
      // If we exit the loop without returning, throw error
      throw Exception('Pending order gagal setelah $maxRetries percobaan');
    } catch (e, stackTrace) {
      print('❌ ===== PENDING ORDER ERROR =====');
      print('   Error Type: ${e.runtimeType}');
      print('   Error Message: $e');
      print('   Stack Trace: $stackTrace');
      print('==================================');
      executionMessage.value = 'Error: $e';
      rethrow;
    } finally {
      isExecuting.value = false;
    }
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
