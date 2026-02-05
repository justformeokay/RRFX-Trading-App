import 'package:flutter/foundation.dart';

/// Represents a single candlestick data point with OHLC values
/// 
/// This is the core data model for the trading chart.
/// Each candle represents price action over a specific time period.
@immutable
class CandleModel {
  /// Unique timestamp for this candle (milliseconds since epoch)
  final int timestamp;
  
  /// Opening price
  final double open;
  
  /// Highest price during the period
  final double high;
  
  /// Lowest price during the period
  final double low;
  
  /// Closing price
  final double close;
  
  /// Trading volume (optional)
  final double? volume;
  
  /// Tick volume (optional, for forex)
  final int? tickVolume;

  const CandleModel({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
    this.tickVolume,
  });

  /// Returns true if this is a bullish (green) candle
  bool get isBullish => close >= open;

  /// Returns true if this is a bearish (red) candle
  bool get isBearish => close < open;

  /// Returns the body height (absolute difference between open and close)
  double get bodyHeight => (close - open).abs();

  /// Returns the upper wick height
  double get upperWickHeight => high - (isBullish ? close : open);

  /// Returns the lower wick height
  double get lowerWickHeight => (isBullish ? open : close) - low;

  /// Returns the total range (high - low)
  double get range => high - low;

  /// Returns the body top price
  double get bodyTop => isBullish ? close : open;

  /// Returns the body bottom price
  double get bodyBottom => isBullish ? open : close;

  /// Returns the midpoint price
  double get midPoint => (high + low) / 2;

  /// Returns the typical price (HLC/3)
  double get typicalPrice => (high + low + close) / 3;

  /// Returns DateTime from timestamp
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  /// Creates a copy with optional new values
  CandleModel copyWith({
    int? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
    int? tickVolume,
  }) {
    return CandleModel(
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      tickVolume: tickVolume ?? this.tickVolume,
    );
  }

  /// Creates from JSON map
  factory CandleModel.fromJson(Map<String, dynamic> json) {
    return CandleModel(
      timestamp: json['timestamp'] as int? ?? 
                 json['time'] as int? ?? 
                 DateTime.now().millisecondsSinceEpoch,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble(),
      tickVolume: json['tickVolume'] as int? ?? json['tick_volume'] as int?,
    );
  }

  /// Converts to JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      if (volume != null) 'volume': volume,
      if (tickVolume != null) 'tickVolume': tickVolume,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CandleModel &&
        other.timestamp == timestamp &&
        other.open == open &&
        other.high == high &&
        other.low == low &&
        other.close == close;
  }

  @override
  int get hashCode => Object.hash(timestamp, open, high, low, close);

  @override
  String toString() {
    return 'CandleModel(time: ${dateTime.toIso8601String()}, O: $open, H: $high, L: $low, C: $close)';
  }
}

/// Extension for list of candles
extension CandleListExtension on List<CandleModel> {
  /// Returns the highest high in the list
  double get highestHigh {
    if (isEmpty) return 0;
    return map((c) => c.high).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the lowest low in the list
  double get lowestLow {
    if (isEmpty) return 0;
    return map((c) => c.low).reduce((a, b) => a < b ? a : b);
  }

  /// Returns the price range
  double get priceRange => highestHigh - lowestLow;

  /// Returns candles within a time range
  List<CandleModel> inTimeRange(int startTime, int endTime) {
    return where((c) => c.timestamp >= startTime && c.timestamp <= endTime).toList();
  }

  /// Returns the latest candle
  CandleModel? get latest => isEmpty ? null : last;

  /// Returns the oldest candle
  CandleModel? get oldest => isEmpty ? null : first;
}
