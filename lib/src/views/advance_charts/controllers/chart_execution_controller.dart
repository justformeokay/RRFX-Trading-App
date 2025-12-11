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
  /// 
  /// Returns API response Map or throws exception on error
  Future<Map<String, dynamic>> executeOrder({
    required String login,
    required String symbol,
    required String operation, // "buy" or "sell"
    double? volume,
  }) async {
    if (isExecuting.value) {
      throw Exception('Order sedang diproses');
    }

    try {
      isExecuting.value = true;
      executionMessage.value = 'Memproses order...';

      final lotVolume = volume ?? lot.value;

      print('📤 ===== EXECUTING ORDER =====');
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
        executionMessage.value = errorMsg;
        print('❌ Order failed: $errorMsg');
        throw Exception(errorMsg);
      }
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
