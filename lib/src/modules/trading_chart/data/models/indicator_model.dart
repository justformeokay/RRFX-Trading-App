import 'package:flutter/material.dart';

/// Base class for all technical indicators
abstract class IndicatorModel {
  /// Unique identifier for this indicator instance
  final String id;
  
  /// Display name
  final String name;
  
  /// Whether the indicator is visible
  final bool isVisible;
  
  /// Whether this indicator is rendered as overlay on main chart
  /// or in a separate panel below
  final bool isOverlay;

  const IndicatorModel({
    required this.id,
    required this.name,
    this.isVisible = true,
    this.isOverlay = true,
  });

  /// Display name alias
  String get displayName => name;
  
  /// Primary color for this indicator (override in subclass)
  Color get color => Colors.blue;

  /// Creates a copy with new values
  IndicatorModel copyWith({bool? isVisible});
}

/// Moving Average indicator types
enum MovingAverageType {
  sma, // Simple Moving Average
  ema, // Exponential Moving Average
  wma, // Weighted Moving Average
  smma, // Smoothed Moving Average
}

/// Moving Average indicator configuration
class MovingAverageIndicator extends IndicatorModel {
  /// The type of moving average
  final MovingAverageType type;
  
  /// Period for calculation
  final int period;
  
  /// Line color
  final Color color;
  
  /// Line thickness
  final double thickness;
  
  /// Apply to price type
  final MAPriceType priceType;
  
  /// Calculated values (index corresponds to candle index)
  final List<double?> values;

  MovingAverageIndicator({
    required super.id,
    required this.type,
    required this.period,
    this.color = Colors.blue,
    this.thickness = 1.5,
    this.priceType = MAPriceType.close,
    this.values = const [],
    super.isVisible = true,
  }) : super(
    name: '${type.name.toUpperCase()}($period)',
    isOverlay: true,
  );

  @override
  MovingAverageIndicator copyWith({
    MovingAverageType? type,
    int? period,
    Color? color,
    double? thickness,
    MAPriceType? priceType,
    List<double?>? values,
    bool? isVisible,
  }) {
    return MovingAverageIndicator(
      id: id,
      type: type ?? this.type,
      period: period ?? this.period,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      priceType: priceType ?? this.priceType,
      values: values ?? this.values,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  String toString() => 'MA(${type.name}, $period)';
}

/// Price type for indicator calculation
enum MAPriceType {
  close,
  open,
  high,
  low,
  median,  // (H+L)/2
  typical, // (H+L+C)/3
  weighted, // (H+L+C+C)/4
}

/// Bollinger Bands indicator (for future extension)
class BollingerBandsIndicator extends IndicatorModel {
  final int period;
  final double deviation;
  final Color upperBandColor;
  final Color middleBandColor;
  final Color lowerBandColor;
  final double thickness;
  final List<double?> upperValues;
  final List<double?> middleValues;
  final List<double?> lowerValues;

  BollingerBandsIndicator({
    required super.id,
    this.period = 20,
    this.deviation = 2.0,
    this.upperBandColor = Colors.grey,
    this.middleBandColor = Colors.blue,
    this.lowerBandColor = Colors.grey,
    this.thickness = 1.0,
    this.upperValues = const [],
    this.middleValues = const [],
    this.lowerValues = const [],
    super.isVisible = true,
  }) : super(
    name: 'BB($period, $deviation)',
    isOverlay: true,
  );

  @override
  BollingerBandsIndicator copyWith({
    int? period,
    double? deviation,
    Color? upperBandColor,
    Color? middleBandColor,
    Color? lowerBandColor,
    double? thickness,
    List<double?>? upperValues,
    List<double?>? middleValues,
    List<double?>? lowerValues,
    bool? isVisible,
  }) {
    return BollingerBandsIndicator(
      id: id,
      period: period ?? this.period,
      deviation: deviation ?? this.deviation,
      upperBandColor: upperBandColor ?? this.upperBandColor,
      middleBandColor: middleBandColor ?? this.middleBandColor,
      lowerBandColor: lowerBandColor ?? this.lowerBandColor,
      thickness: thickness ?? this.thickness,
      upperValues: upperValues ?? this.upperValues,
      middleValues: middleValues ?? this.middleValues,
      lowerValues: lowerValues ?? this.lowerValues,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// RSI Indicator (for future extension)
class RSIIndicator extends IndicatorModel {
  final int period;
  final Color lineColor;
  final Color overboughtColor;
  final Color oversoldColor;
  final double overboughtLevel;
  final double oversoldLevel;
  final double thickness;
  final List<double?> values;

  RSIIndicator({
    required super.id,
    this.period = 14,
    this.lineColor = Colors.purple,
    this.overboughtColor = Colors.red,
    this.oversoldColor = Colors.green,
    this.overboughtLevel = 70,
    this.oversoldLevel = 30,
    this.thickness = 1.5,
    this.values = const [],
    super.isVisible = true,
  }) : super(
    name: 'RSI($period)',
    isOverlay: false, // RSI is shown in separate panel
  );

  @override
  RSIIndicator copyWith({
    int? period,
    Color? lineColor,
    Color? overboughtColor,
    Color? oversoldColor,
    double? overboughtLevel,
    double? oversoldLevel,
    double? thickness,
    List<double?>? values,
    bool? isVisible,
  }) {
    return RSIIndicator(
      id: id,
      period: period ?? this.period,
      lineColor: lineColor ?? this.lineColor,
      overboughtColor: overboughtColor ?? this.overboughtColor,
      oversoldColor: oversoldColor ?? this.oversoldColor,
      overboughtLevel: overboughtLevel ?? this.overboughtLevel,
      oversoldLevel: oversoldLevel ?? this.oversoldLevel,
      thickness: thickness ?? this.thickness,
      values: values ?? this.values,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// MACD Indicator (for future extension)
class MACDIndicator extends IndicatorModel {
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;
  final Color macdLineColor;
  final Color signalLineColor;
  final Color histogramPositiveColor;
  final Color histogramNegativeColor;
  final double thickness;
  final List<double?> macdValues;
  final List<double?> signalValues;
  final List<double?> histogramValues;

  MACDIndicator({
    required super.id,
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
    this.macdLineColor = Colors.blue,
    this.signalLineColor = Colors.orange,
    this.histogramPositiveColor = Colors.green,
    this.histogramNegativeColor = Colors.red,
    this.thickness = 1.5,
    this.macdValues = const [],
    this.signalValues = const [],
    this.histogramValues = const [],
    super.isVisible = true,
  }) : super(
    name: 'MACD($fastPeriod, $slowPeriod, $signalPeriod)',
    isOverlay: false,
  );

  @override
  MACDIndicator copyWith({
    int? fastPeriod,
    int? slowPeriod,
    int? signalPeriod,
    Color? macdLineColor,
    Color? signalLineColor,
    Color? histogramPositiveColor,
    Color? histogramNegativeColor,
    double? thickness,
    List<double?>? macdValues,
    List<double?>? signalValues,
    List<double?>? histogramValues,
    bool? isVisible,
  }) {
    return MACDIndicator(
      id: id,
      fastPeriod: fastPeriod ?? this.fastPeriod,
      slowPeriod: slowPeriod ?? this.slowPeriod,
      signalPeriod: signalPeriod ?? this.signalPeriod,
      macdLineColor: macdLineColor ?? this.macdLineColor,
      signalLineColor: signalLineColor ?? this.signalLineColor,
      histogramPositiveColor: histogramPositiveColor ?? this.histogramPositiveColor,
      histogramNegativeColor: histogramNegativeColor ?? this.histogramNegativeColor,
      thickness: thickness ?? this.thickness,
      macdValues: macdValues ?? this.macdValues,
      signalValues: signalValues ?? this.signalValues,
      histogramValues: histogramValues ?? this.histogramValues,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
