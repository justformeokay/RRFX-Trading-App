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

      print('📤 Executing $operation order: $symbol @ $lotVolume lot');

      final response = await _authService.post(
        'market/execution/open',
        {
          'login': login,
          'symbol': symbol,
          'operation': operation.toLowerCase(),
          'volume': lotVolume.toString(),
        },
      );

      if (response['status'] == true) {
        executionMessage.value = 'Order berhasil dieksekusi!';
        print('✅ Order executed successfully: ${response['message']}');
        return response;
      } else {
        final errorMsg = response['message'] ?? 'Order gagal dieksekusi';
        executionMessage.value = errorMsg;
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error executing order: $e');
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
