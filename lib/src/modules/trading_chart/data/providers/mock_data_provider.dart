import 'dart:async';
import 'dart:math';
import '../models/candle_model.dart';
import '../models/timeframe_model.dart';
import 'chart_data_provider.dart';

/// Mock data provider for testing and demonstration
/// Generates realistic-looking price data
class MockDataProvider implements ChartDataProvider {
  @override
  final String symbol;
  
  @override
  ChartTimeframe timeframe;
  
  final _realtimeController = StreamController<CandleModel>.broadcast();
  Timer? _realtimeTimer;
  
  double _lastPrice;
  final double _volatility;
  final Random _random = Random();
  
  // Cache for generated candles per timeframe
  final Map<ChartTimeframe, List<CandleModel>> _candleCache = {};
  
  MockDataProvider({
    this.symbol = 'EURUSD',
    this.timeframe = ChartTimeframe.h1,
    double initialPrice = 1.0850,
    double volatility = 0.0002,
  }) : _lastPrice = initialPrice,
       _volatility = volatility;

  @override
  Future<List<CandleModel>> loadInitialCandles({int count = 200}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final candles = _generateCandles(count, DateTime.now());
    _candleCache[timeframe] = List.from(candles);
    
    // Start real-time updates
    _startRealtimeUpdates();
    
    return candles;
  }

  @override
  Future<List<CandleModel>> loadMoreHistoricalCandles({
    required int beforeTimestamp,
    int count = 50,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    final beforeDate = DateTime.fromMillisecondsSinceEpoch(beforeTimestamp);
    final moreCandles = _generateCandles(count, beforeDate, goingBack: true);
    
    // Add to cache
    if (_candleCache.containsKey(timeframe)) {
      _candleCache[timeframe]!.insertAll(0, moreCandles);
    }
    
    return moreCandles;
  }

  @override
  void onNewRealtimeCandle(CandleModel candle) {
    _realtimeController.add(candle);
  }

  @override
  Stream<CandleModel> get realtimeUpdates => _realtimeController.stream;

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    _realtimeController.close();
  }
  
  /// Generate realistic candle data
  List<CandleModel> _generateCandles(int count, DateTime endTime, {bool goingBack = false}) {
    final candles = <CandleModel>[];
    final duration = timeframe.duration;
    
    DateTime currentTime = goingBack 
        ? endTime.subtract(duration) 
        : endTime.subtract(duration * count);
    
    double currentPrice = _lastPrice;
    
    // If going back, we need to calculate a reasonable starting price
    if (goingBack) {
      // Random walk backward
      for (int i = 0; i < count; i++) {
        currentPrice += (_random.nextDouble() - 0.5) * _volatility * 10;
      }
    }
    
    for (int i = 0; i < count; i++) {
      final candle = _generateSingleCandle(currentTime, currentPrice);
      candles.add(candle);
      
      currentPrice = candle.close;
      currentTime = currentTime.add(duration);
    }
    
    if (!goingBack) {
      _lastPrice = candles.last.close;
    }
    
    // Sort by timestamp (oldest first)
    candles.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return candles;
  }
  
  /// Generate a single candle with realistic OHLC
  CandleModel _generateSingleCandle(DateTime time, double basePrice) {
    // Generate random movement with some trend bias
    final trend = (_random.nextDouble() - 0.48) * _volatility * 5;
    
    // Open is close to previous close with small gap
    final open = basePrice + (_random.nextDouble() - 0.5) * _volatility;
    
    // Close with trend
    final close = open + trend + (_random.nextDouble() - 0.5) * _volatility * 2;
    
    // High and Low
    final isUp = close >= open;
    final wickMultiplier = 1 + _random.nextDouble() * 2;
    
    final high = (isUp ? close : open) + _random.nextDouble() * _volatility * wickMultiplier;
    final low = (isUp ? open : close) - _random.nextDouble() * _volatility * wickMultiplier;
    
    // Volume (random but realistic)
    final volume = 1000.0 + _random.nextDouble() * 9000;
    
    return CandleModel(
      timestamp: time.millisecondsSinceEpoch,
      open: _roundPrice(open),
      high: _roundPrice(high),
      low: _roundPrice(low),
      close: _roundPrice(close),
      volume: volume.round().toDouble(),
      tickVolume: (volume / 10).round(),
    );
  }
  
  double _roundPrice(double price) {
    return double.parse(price.toStringAsFixed(5));
  }
  
  /// Start generating real-time updates
  void _startRealtimeUpdates() {
    _realtimeTimer?.cancel();
    
    // Update frequency based on timeframe
    final updateInterval = switch (timeframe) {
      ChartTimeframe.m1 => const Duration(seconds: 1),
      ChartTimeframe.m5 => const Duration(seconds: 2),
      ChartTimeframe.m15 => const Duration(seconds: 3),
      ChartTimeframe.m30 => const Duration(seconds: 5),
      ChartTimeframe.h1 => const Duration(seconds: 10),
      ChartTimeframe.h4 => const Duration(seconds: 30),
      _ => const Duration(minutes: 1),
    };
    
    CandleModel? currentCandle;
    
    _realtimeTimer = Timer.periodic(updateInterval, (_) {
      final now = DateTime.now();
      final candleTime = _alignToTimeframe(now);
      
      if (currentCandle == null || currentCandle!.timestamp != candleTime.millisecondsSinceEpoch) {
        // New candle
        currentCandle = CandleModel(
          timestamp: candleTime.millisecondsSinceEpoch,
          open: _lastPrice,
          high: _lastPrice,
          low: _lastPrice,
          close: _lastPrice,
          volume: 0,
        );
      }
      
      // Update price with tick
      final tickChange = (_random.nextDouble() - 0.5) * _volatility;
      _lastPrice = _roundPrice(_lastPrice + tickChange);
      
      // Update candle
      currentCandle = currentCandle!.copyWith(
        high: max(currentCandle!.high, _lastPrice),
        low: min(currentCandle!.low, _lastPrice),
        close: _lastPrice,
        volume: (currentCandle!.volume ?? 0) + _random.nextDouble() * 100,
      );
      
      _realtimeController.add(currentCandle!);
    });
  }
  
  /// Align time to timeframe boundary
  DateTime _alignToTimeframe(DateTime time) {
    final minutes = timeframe.minutes;
    if (minutes < 60) {
      return DateTime(
        time.year,
        time.month,
        time.day,
        time.hour,
        (time.minute ~/ minutes) * minutes,
      );
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return DateTime(
        time.year,
        time.month,
        time.day,
        (time.hour ~/ hours) * hours,
      );
    } else {
      return DateTime(time.year, time.month, time.day);
    }
  }
}

/// Factory for creating mock data providers for different symbols
class MockDataProviderFactory {
  static final Map<String, Map<String, double>> _symbolConfigs = {
    'EURUSD': {'price': 1.0850, 'volatility': 0.0001},
    'GBPUSD': {'price': 1.2650, 'volatility': 0.00015},
    'USDJPY': {'price': 149.50, 'volatility': 0.05},
    'XAUUSD': {'price': 2025.50, 'volatility': 0.5},
    'BTCUSD': {'price': 43500.0, 'volatility': 50.0},
    'ETHUSD': {'price': 2280.0, 'volatility': 5.0},
    'US30': {'price': 38500.0, 'volatility': 10.0},
    'NAS100': {'price': 17200.0, 'volatility': 8.0},
  };
  
  static MockDataProvider create({
    required String symbol,
    ChartTimeframe timeframe = ChartTimeframe.h1,
    double? initialPrice,
    double? volatility,
  }) {
    final config = _symbolConfigs[symbol] ?? {'price': 1.0, 'volatility': 0.001};
    
    return MockDataProvider(
      symbol: symbol,
      timeframe: timeframe,
      initialPrice: initialPrice ?? config['price']!,
      volatility: volatility ?? config['volatility']!,
    );
  }
}
