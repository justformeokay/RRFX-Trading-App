import '../models/candle_model.dart';
import '../models/timeframe_model.dart';

/// Abstract interface for chart data providers
/// Implement this to connect the chart to any data source
abstract class ChartDataProvider {
  /// Symbol being displayed
  String get symbol;
  
  /// Current timeframe
  ChartTimeframe get timeframe;
  
  /// Set the current timeframe
  set timeframe(ChartTimeframe value);
  
  /// Load initial candles for the chart
  /// Returns list of candles, newest last
  Future<List<CandleModel>> loadInitialCandles({
    int count = 200,
  });
  
  /// Load more historical candles (older data)
  /// [beforeTimestamp] - Load candles before this timestamp
  /// [count] - Number of candles to load
  /// Returns list of candles, newest last
  Future<List<CandleModel>> loadMoreHistoricalCandles({
    required int beforeTimestamp,
    int count = 50,
  });
  
  /// Called when a new real-time candle update arrives
  /// This should be called by the data source when new tick data comes in
  void onNewRealtimeCandle(CandleModel candle);
  
  /// Subscribe to real-time updates
  /// Returns a stream of candle updates
  Stream<CandleModel> get realtimeUpdates;
  
  /// Dispose resources
  void dispose();
}

/// Callback types for data events
typedef OnCandlesLoaded = void Function(List<CandleModel> candles, bool isHistorical);
typedef OnCandleUpdate = void Function(CandleModel candle);
typedef OnLoadingStateChanged = void Function(bool isLoading);
typedef OnError = void Function(String message, dynamic error);

/// Data provider wrapper that adds caching and event handling
class ChartDataManager {
  final ChartDataProvider _provider;
  
  /// All loaded candles, sorted by timestamp (oldest first)
  final List<CandleModel> _candles = [];
  
  /// Whether initial data has been loaded
  bool _isInitialized = false;
  
  /// Whether more historical data is being loaded
  bool _isLoadingMore = false;
  
  /// Callbacks
  OnCandlesLoaded? onCandlesLoaded;
  OnCandleUpdate? onCandleUpdate;
  OnLoadingStateChanged? onLoadingStateChanged;
  OnError? onError;
  
  ChartDataManager(this._provider);
  
  /// Get current symbol
  String get symbol => _provider.symbol;
  
  /// Get current timeframe
  ChartTimeframe get timeframe => _provider.timeframe;
  
  /// Get all loaded candles
  List<CandleModel> get candles => List.unmodifiable(_candles);
  
  /// Whether data is initialized
  bool get isInitialized => _isInitialized;
  
  /// Whether more data is loading
  bool get isLoadingMore => _isLoadingMore;
  
  /// Initialize and load initial candles
  Future<void> initialize({int initialCount = 200}) async {
    try {
      onLoadingStateChanged?.call(true);
      
      final candles = await _provider.loadInitialCandles(count: initialCount);
      
      _candles.clear();
      _candles.addAll(candles);
      _sortCandles();
      
      _isInitialized = true;
      onCandlesLoaded?.call(_candles, false);
      
      // Subscribe to real-time updates
      _provider.realtimeUpdates.listen(_handleRealtimeUpdate);
      
    } catch (e) {
      onError?.call('Failed to load initial candles', e);
    } finally {
      onLoadingStateChanged?.call(false);
    }
  }
  
  /// Load more historical data
  Future<void> loadMoreHistory() async {
    if (_isLoadingMore || _candles.isEmpty) return;
    
    try {
      _isLoadingMore = true;
      onLoadingStateChanged?.call(true);
      
      final oldestTimestamp = _candles.first.timestamp;
      final moreCandles = await _provider.loadMoreHistoricalCandles(
        beforeTimestamp: oldestTimestamp,
      );
      
      if (moreCandles.isNotEmpty) {
        // Insert at beginning (older data)
        _candles.insertAll(0, moreCandles);
        _sortCandles();
        onCandlesLoaded?.call(_candles, true);
      }
      
    } catch (e) {
      onError?.call('Failed to load more history', e);
    } finally {
      _isLoadingMore = false;
      onLoadingStateChanged?.call(false);
    }
  }
  
  /// Change timeframe
  Future<void> changeTimeframe(ChartTimeframe newTimeframe) async {
    if (newTimeframe == _provider.timeframe) return;
    
    _provider.timeframe = newTimeframe;
    _isInitialized = false;
    _candles.clear();
    
    await initialize();
  }
  
  /// Handle real-time candle update
  void _handleRealtimeUpdate(CandleModel candle) {
    if (_candles.isEmpty) return;
    
    final lastCandle = _candles.last;
    
    // Check if this is an update to the current candle or a new candle
    if (candle.timestamp == lastCandle.timestamp) {
      // Update existing candle
      _candles[_candles.length - 1] = candle;
    } else if (candle.timestamp > lastCandle.timestamp) {
      // New candle
      _candles.add(candle);
    }
    
    onCandleUpdate?.call(candle);
  }
  
  /// Sort candles by timestamp
  void _sortCandles() {
    _candles.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  /// Get candle at index
  CandleModel? getCandleAt(int index) {
    if (index < 0 || index >= _candles.length) return null;
    return _candles[index];
  }
  
  /// Get candles in range
  List<CandleModel> getCandlesInRange(int startIndex, int endIndex) {
    final start = startIndex.clamp(0, _candles.length - 1);
    final end = (endIndex + 1).clamp(0, _candles.length);
    return _candles.sublist(start, end);
  }
  
  /// Dispose resources
  void dispose() {
    _provider.dispose();
    _candles.clear();
  }
}
