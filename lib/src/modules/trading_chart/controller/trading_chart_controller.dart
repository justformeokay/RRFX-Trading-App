import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/candle_model.dart';
import '../data/models/chart_config.dart';
import '../data/models/indicator_model.dart';
import '../data/models/timeframe_model.dart';
import '../data/models/viewport_state.dart';
import '../data/providers/chart_data_provider.dart';
import '../engine/calculation/indicator_calculator.dart';
import '../engine/calculation/viewport_calculator.dart';

/// Main controller for the trading chart
/// Manages state, data, indicators, and coordinates all chart operations
class TradingChartController extends ChangeNotifier {
  // Configuration
  ChartConfig _config;
  ChartConfig get config => _config;
  
  // Data manager
  ChartDataManager? _dataManager;
  
  // Calculators
  late ViewportCalculator _viewportCalculator;
  
  // State
  ViewportState _viewport = const ViewportState();
  ViewportState get viewport => _viewport;
  
  CrosshairState _crosshair = const CrosshairState();
  CrosshairState get crosshair => _crosshair;
  
  // Candles
  List<CandleModel> _candles = [];
  List<CandleModel> get candles => List.unmodifiable(_candles);
  
  // Indicators
  final List<IndicatorModel> _indicators = [];
  List<IndicatorModel> get indicators => List.unmodifiable(_indicators);
  
  // Current state
  ChartTimeframe _timeframe = ChartTimeframe.h1;
  ChartTimeframe get timeframe => _timeframe;
  
  String _symbol = '';
  String get symbol => _symbol;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  
  // Chart dimensions (set by widget)
  double _chartWidth = 0;
  double _chartHeight = 0;
  
  // Subscriptions
  StreamSubscription? _realtimeSubscription;
  
  TradingChartController({
    ChartConfig? config,
  }) : _config = config ?? const ChartConfig() {
    _viewportCalculator = ViewportCalculator(_config);
  }
  
  /// Initialize the chart with a data provider
  Future<void> initialize({
    required ChartDataProvider dataProvider,
    int initialCandleCount = 200,
  }) async {
    _symbol = dataProvider.symbol;
    _timeframe = dataProvider.timeframe;
    
    _dataManager = ChartDataManager(dataProvider);
    _dataManager!.onCandlesLoaded = _onCandlesLoaded;
    _dataManager!.onCandleUpdate = _onCandleUpdate;
    _dataManager!.onLoadingStateChanged = _onLoadingStateChanged;
    _dataManager!.onError = _onError;
    
    _isLoading = true;
    notifyListeners();
    
    await _dataManager!.initialize(initialCount: initialCandleCount);
    
    _isInitialized = true;
  }
  
  /// Update chart configuration
  void updateConfig(ChartConfig newConfig) {
    _config = newConfig;
    _viewportCalculator = ViewportCalculator(_config);
    _recalculateViewport();
    notifyListeners();
  }
  
  /// Set chart dimensions (called by widget on layout)
  void setDimensions(double width, double height) {
    if (_chartWidth == width && _chartHeight == height) return;
    
    final wasUninitialized = _chartWidth == 0;
    _chartWidth = width;
    _chartHeight = height;
    
    if (wasUninitialized && _candles.isNotEmpty) {
      _viewport = _viewportCalculator.calculateInitialViewport(
        candles: _candles,
        chartWidth: _chartWidth,
        chartHeight: _chartHeight,
      );
    } else if (_candles.isNotEmpty) {
      _recalculateViewport();
    }
    
    notifyListeners();
  }
  
  /// Handle horizontal scroll
  void onScroll(double delta) {
    if (_candles.isEmpty || _chartWidth == 0) return;
    
    // Negate delta: dragging right (positive delta) should show newer candles (negative scroll)
    // Dragging left (negative delta) should show older candles (positive scroll)
    _viewport = _viewportCalculator.calculateScrolledViewport(
      currentViewport: _viewport,
      candles: _candles,
      scrollDelta: -delta,
      chartWidth: _chartWidth,
    );
    
    // Check if we should load more historical data
    if (_viewportCalculator.shouldLoadMore(_viewport)) {
      _loadMoreHistory();
    }
    
    // Deactivate crosshair on scroll
    if (_crosshair.isActive) {
      _crosshair = _crosshair.deactivate();
    }
    
    notifyListeners();
  }
  
  /// Handle zoom
  void onZoom(double scale, double focalX) {
    if (_candles.isEmpty || _chartWidth == 0) return;
    
    _viewport = _viewportCalculator.calculateZoomedViewport(
      currentViewport: _viewport,
      candles: _candles,
      scale: scale,
      focalX: focalX,
      chartWidth: _chartWidth,
    );
    
    // Deactivate crosshair on zoom
    if (_crosshair.isActive) {
      _crosshair = _crosshair.deactivate();
    }
    
    notifyListeners();
  }
  
  /// Handle crosshair activation
  void onCrosshairStart(Offset position) {
    if (_candles.isEmpty || _chartWidth == 0) return;
    
    _crosshair = _viewportCalculator.calculateCrosshairState(
      position: position,
      viewport: _viewport,
      candles: _candles,
      chartWidth: _chartWidth,
      chartHeight: _chartHeight,
    );
    
    notifyListeners();
  }
  
  /// Handle crosshair move
  void onCrosshairMove(Offset position) {
    if (!_crosshair.isActive) return;
    
    _crosshair = _viewportCalculator.calculateCrosshairState(
      position: position,
      viewport: _viewport,
      candles: _candles,
      chartWidth: _chartWidth,
      chartHeight: _chartHeight,
    );
    
    notifyListeners();
  }
  
  /// Handle crosshair end
  void onCrosshairEnd() {
    _crosshair = _crosshair.deactivate();
    notifyListeners();
  }
  
  /// Change timeframe
  Future<void> changeTimeframe(ChartTimeframe newTimeframe) async {
    if (newTimeframe == _timeframe || _dataManager == null) return;
    
    _timeframe = newTimeframe;
    _isLoading = true;
    _candles = [];
    _indicators.clear();
    _viewport = const ViewportState();
    notifyListeners();
    
    await _dataManager!.changeTimeframe(newTimeframe);
  }
  
  // ============ INDICATOR MANAGEMENT ============
  
  /// Add a moving average indicator
  void addMovingAverage({
    required MovingAverageType type,
    required int period,
    Color color = Colors.blue,
    double thickness = 1.5,
    MAPriceType priceType = MAPriceType.close,
  }) {
    final id = '${type.name}_$period\_${DateTime.now().millisecondsSinceEpoch}';
    
    final values = IndicatorCalculator.calculateMA(
      candles: _candles,
      type: type,
      period: period,
      priceType: priceType,
    );
    
    final indicator = MovingAverageIndicator(
      id: id,
      type: type,
      period: period,
      color: color,
      thickness: thickness,
      priceType: priceType,
      values: values,
    );
    
    _indicators.add(indicator);
    notifyListeners();
  }
  
  /// Add Bollinger Bands indicator
  void addBollingerBands({
    int period = 20,
    double deviation = 2.0,
    Color upperColor = Colors.grey,
    Color middleColor = Colors.blue,
    Color lowerColor = Colors.grey,
    double thickness = 1.0,
  }) {
    final id = 'bb_$period\_$deviation\_${DateTime.now().millisecondsSinceEpoch}';
    
    final bands = IndicatorCalculator.calculateBollingerBands(
      candles: _candles,
      period: period,
      deviation: deviation,
    );
    
    final indicator = BollingerBandsIndicator(
      id: id,
      period: period,
      deviation: deviation,
      upperBandColor: upperColor,
      middleBandColor: middleColor,
      lowerBandColor: lowerColor,
      thickness: thickness,
      upperValues: bands.upper,
      middleValues: bands.middle,
      lowerValues: bands.lower,
    );
    
    _indicators.add(indicator);
    notifyListeners();
  }
  
  /// Remove an indicator
  void removeIndicator(String id) {
    _indicators.removeWhere((i) => i.id == id);
    notifyListeners();
  }
  
  /// Toggle indicator visibility
  void toggleIndicatorVisibility(String id) {
    final index = _indicators.indexWhere((i) => i.id == id);
    if (index != -1) {
      final indicator = _indicators[index];
      _indicators[index] = indicator.copyWith(isVisible: !indicator.isVisible);
      notifyListeners();
    }
  }
  
  /// Clear all indicators
  void clearIndicators() {
    _indicators.clear();
    notifyListeners();
  }
  
  // ============ PRIVATE METHODS ============
  
  void _onCandlesLoaded(List<CandleModel> candles, bool isHistorical) {
    final previousCount = _candles.length;
    _candles = candles;
    
    if (_chartWidth > 0) {
      if (previousCount == 0) {
        _viewport = _viewportCalculator.calculateInitialViewport(
          candles: _candles,
          chartWidth: _chartWidth,
          chartHeight: _chartHeight,
        );
      } else {
        _viewport = _viewportCalculator.updateViewportWithNewCandles(
          currentViewport: _viewport,
          candles: _candles,
          previousCandleCount: previousCount,
          chartWidth: _chartWidth,
          isHistorical: isHistorical,
        );
      }
    }
    
    // Recalculate indicators
    _recalculateIndicators();
    
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
  
  void _onCandleUpdate(CandleModel candle) {
    // Update the last candle or add new one
    if (_candles.isNotEmpty && _candles.last.timestamp == candle.timestamp) {
      _candles[_candles.length - 1] = candle;
    } else if (_candles.isEmpty || candle.timestamp > _candles.last.timestamp) {
      _candles.add(candle);
      
      // Update viewport if at latest
      if (_viewport.isAtLatest && _chartWidth > 0) {
        _viewport = _viewportCalculator.updateViewportWithNewCandles(
          currentViewport: _viewport,
          candles: _candles,
          previousCandleCount: _candles.length - 1,
          chartWidth: _chartWidth,
          isHistorical: false,
        );
      }
    }
    
    // Update indicator values for the latest candle
    _updateIndicatorsForLatestCandle();
    
    notifyListeners();
  }
  
  void _onLoadingStateChanged(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }
  
  void _onError(String message, dynamic error) {
    debugPrint('TradingChart Error: $message - $error');
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
  
  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || _dataManager == null) return;
    
    _isLoadingMore = true;
    _viewport = _viewport.copyWith(isLoadingMore: true);
    notifyListeners();
    
    await _dataManager!.loadMoreHistory();
  }
  
  void _recalculateViewport() {
    if (_candles.isEmpty || _chartWidth == 0) return;
    
    _viewport = _viewportCalculator.calculateScrolledViewport(
      currentViewport: _viewport,
      candles: _candles,
      scrollDelta: 0,
      chartWidth: _chartWidth,
    );
  }
  
  void _recalculateIndicators() {
    for (int i = 0; i < _indicators.length; i++) {
      final indicator = _indicators[i];
      
      if (indicator is MovingAverageIndicator) {
        final values = IndicatorCalculator.calculateMA(
          candles: _candles,
          type: indicator.type,
          period: indicator.period,
          priceType: indicator.priceType,
        );
        _indicators[i] = indicator.copyWith(values: values);
      } else if (indicator is BollingerBandsIndicator) {
        final bands = IndicatorCalculator.calculateBollingerBands(
          candles: _candles,
          period: indicator.period,
          deviation: indicator.deviation,
        );
        _indicators[i] = indicator.copyWith(
          upperValues: bands.upper,
          middleValues: bands.middle,
          lowerValues: bands.lower,
        );
      }
    }
  }
  
  void _updateIndicatorsForLatestCandle() {
    // For efficiency, only update the last few values for indicators
    // This is called on each tick update
    for (int i = 0; i < _indicators.length; i++) {
      final indicator = _indicators[i];
      
      if (indicator is MovingAverageIndicator) {
        final values = List<double?>.from(indicator.values);
        
        // Calculate only the last value
        if (_candles.length >= indicator.period) {
          final newValues = IndicatorCalculator.calculateMA(
            candles: _candles,
            type: indicator.type,
            period: indicator.period,
            priceType: indicator.priceType,
          );
          
          // Update or add last value
          if (values.length < _candles.length) {
            values.add(newValues.last);
          } else if (values.isNotEmpty) {
            values[values.length - 1] = newValues.last;
          }
          
          _indicators[i] = indicator.copyWith(values: values);
        }
      }
    }
  }
  
  /// Scroll to latest candle
  void scrollToLatest() {
    if (_candles.isEmpty || _chartWidth == 0) return;
    
    _viewport = _viewportCalculator.calculateScrolledViewport(
      currentViewport: _viewport,
      candles: _candles,
      scrollDelta: -_viewport.scrollOffset,
      chartWidth: _chartWidth,
    );
    
    notifyListeners();
  }
  
  /// Get candle at specific index
  CandleModel? getCandleAt(int index) {
    if (index < 0 || index >= _candles.length) return null;
    return _candles[index];
  }
  
  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _dataManager?.dispose();
    super.dispose();
  }
}
