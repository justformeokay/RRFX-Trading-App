import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WidgetService {
  static const String _widgetName = 'XAUUSDWidgetProvider';
  static const String _taskName = 'updateXAUUSDWidget';
  
  // Keys untuk data widget
  static const String keySymbol = 'widget_symbol';
  static const String keyPrice = 'widget_price';
  static const String keyChange = 'widget_change';
  static const String keyChangePercent = 'widget_change_percent';
  static const String keyLastUpdate = 'widget_last_update';
  static const String keyBid = 'widget_bid';
  static const String keyAsk = 'widget_ask';
  static const String keyHigh = 'widget_high';
  static const String keyLow = 'widget_low';

  /// Initialize widget service
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.rrfx.widget');
    await _registerBackgroundTask();
  }

  /// Register background task untuk update widget secara berkala
  static Future<void> _registerBackgroundTask() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Update setiap 15 menit (minimal interval yang direkomendasikan)
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  /// Update widget data
  static Future<bool> updateWidget({
    required String symbol,
    required double price,
    required double change,
    required double changePercent,
    double? bid,
    double? ask,
    double? high,
    double? low,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(keySymbol, symbol);
      await HomeWidget.saveWidgetData<String>(
        keyPrice,
        price.toStringAsFixed(2),
      );
      await HomeWidget.saveWidgetData<String>(
        keyChange,
        change.toStringAsFixed(2),
      );
      await HomeWidget.saveWidgetData<String>(
        keyChangePercent,
        changePercent.toStringAsFixed(2),
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastUpdate,
        DateTime.now().toIso8601String(),
      );
      
      if (bid != null) {
        await HomeWidget.saveWidgetData<String>(
          keyBid,
          bid.toStringAsFixed(2),
        );
      }
      if (ask != null) {
        await HomeWidget.saveWidgetData<String>(
          keyAsk,
          ask.toStringAsFixed(2),
        );
      }
      if (high != null) {
        await HomeWidget.saveWidgetData<String>(
          keyHigh,
          high.toStringAsFixed(2),
        );
      }
      if (low != null) {
        await HomeWidget.saveWidgetData<String>(
          keyLow,
          low.toStringAsFixed(2),
        );
      }

      // Update widget UI
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: 'XAUUSDWidget',
      );

      return true;
    } catch (e) {
      print('Error updating widget: $e');
      return false;
    }
  }

  /// Fetch XAUUSD data dari API
  static Future<Map<String, dynamic>?> fetchXAUUSDData() async {
    try {
      // Ganti dengan endpoint API Anda yang sesuai
      final response = await http.get(
        Uri.parse('${GlobalVariable.mainURL}/market/xauusd'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching XAUUSD data: $e');
      return null;
    }
  }

  /// Cancel background updates
  static Future<void> cancelBackgroundUpdates() async {
    await Workmanager().cancelByUniqueName(_taskName);
  }

  /// Manual update widget
  static Future<void> manualUpdate() async {
    final data = await fetchXAUUSDData();
    if (data != null) {
      await updateWidget(
        symbol: data['symbol'] ?? 'XAUUSD',
        price: double.tryParse(data['price']?.toString() ?? '0') ?? 0,
        change: double.tryParse(data['change']?.toString() ?? '0') ?? 0,
        changePercent:
            double.tryParse(data['changePercent']?.toString() ?? '0') ?? 0,
        bid: double.tryParse(data['bid']?.toString() ?? '0'),
        ask: double.tryParse(data['ask']?.toString() ?? '0'),
        high: double.tryParse(data['high']?.toString() ?? '0'),
        low: double.tryParse(data['low']?.toString() ?? '0'),
      );
    }
  }
}

/// Background callback untuk Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Fetch dan update widget data
      final data = await WidgetService.fetchXAUUSDData();
      if (data != null) {
        await WidgetService.updateWidget(
          symbol: data['symbol'] ?? 'XAUUSD',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0,
          change: double.tryParse(data['change']?.toString() ?? '0') ?? 0,
          changePercent:
              double.tryParse(data['changePercent']?.toString() ?? '0') ?? 0,
          bid: double.tryParse(data['bid']?.toString() ?? '0'),
          ask: double.tryParse(data['ask']?.toString() ?? '0'),
          high: double.tryParse(data['high']?.toString() ?? '0'),
          low: double.tryParse(data['low']?.toString() ?? '0'),
        );
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}
