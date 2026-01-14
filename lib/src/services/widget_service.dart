import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

class WidgetService {
  static const String _widgetName = 'MarketAnalysisWidgetProvider';
  static const String _taskName = 'updateMarketAnalysisWidget';
  
  // Keys untuk data widget - untuk multiple markets
  static const String keyMarketsData = 'widget_markets_data';
  static const String keyLastUpdate = 'widget_last_update';
  static const String keyMarketsCount = 'widget_markets_count';
  
  // API Endpoint untuk multi-market analysis
  static const String _apiEndpoint = 'https://api-mt5.techcrm.net/v5-terminal-analis/analysis_main?timeframe=H1';

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

  /// Update widget data untuk multiple markets
  static Future<bool> updateWidget({
    required List<Map<String, dynamic>> marketsData,
  }) async {
    try {
      // Simpan data markets sebagai JSON string
      final marketsJson = json.encode(marketsData);
      await HomeWidget.saveWidgetData<String>(keyMarketsData, marketsJson);
      
      // Simpan jumlah markets
      await HomeWidget.saveWidgetData<String>(
        keyMarketsCount,
        marketsData.length.toString(),
      );
      
      // Simpan waktu last update
      await HomeWidget.saveWidgetData<String>(
        keyLastUpdate,
        DateTime.now().toIso8601String(),
      );

      // Update widget UI
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: 'MarketAnalysisWidget',
      );

      return true;
    } catch (e) {
      print('Error updating widget: $e');
      return false;
    }
  }

  /// Fetch market analysis data dari API untuk multiple markets
  static Future<List<Map<String, dynamic>>?> fetchMarketsData() async {
    try {
      final response = await http.get(
        Uri.parse(_apiEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'] as List?;
        
        if (message != null && message.isNotEmpty) {
          // Transform API response ke format widget
          return message.map((item) {
            final analysis = item['analysis'] ?? {};
            final currentPrice = analysis['current_price'] ?? {};
            final signals = analysis['signals'] ?? {};
            
            return {
              'symbol': item['symbol'] ?? 'N/A',
              'bid': currentPrice['bid']?.toString() ?? '0',
              'ask': currentPrice['ask']?.toString() ?? '0',
              'recommendation': analysis['recommendation'] ?? 'neutral',
              'rsi': analysis['indicators']?['rsi']?.toString() ?? '0',
              'ma_trend': signals['ma_trend'] ?? 'neutral',
              'last_update': analysis['last_update'] ?? '',
            };
          }).toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching markets data: $e');
      return null;
    }
  }

  /// Cancel background updates
  static Future<void> cancelBackgroundUpdates() async {
    await Workmanager().cancelByUniqueName(_taskName);
  }

  /// Manual update widget
  static Future<void> manualUpdate() async {
    final data = await fetchMarketsData();
    if (data != null && data.isNotEmpty) {
      await updateWidget(marketsData: data);
    }
  }
}

/// Background callback untuk Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Fetch dan update widget data untuk semua markets
      final data = await WidgetService.fetchMarketsData();
      if (data != null && data.isNotEmpty) {
        await WidgetService.updateWidget(marketsData: data);
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}
