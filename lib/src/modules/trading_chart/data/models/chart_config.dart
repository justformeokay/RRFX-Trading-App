import 'package:flutter/material.dart';

/// Configuration for the trading chart appearance and behavior
class ChartConfig {
  // ============ COLORS ============
  
  /// Background color of the chart
  final Color backgroundColor;
  
  /// Grid line color
  final Color gridColor;
  
  /// Text color for labels
  final Color textColor;
  
  /// Crosshair line color
  final Color crosshairColor;
  
  /// Bullish (green) candle color
  final Color bullishColor;
  
  /// Bearish (red) candle color
  final Color bearishColor;
  
  /// Wick color for bullish candles
  final Color bullishWickColor;
  
  /// Wick color for bearish candles
  final Color bearishWickColor;
  
  /// Current price line color
  final Color currentPriceLineColor;
  
  /// Bid line color
  final Color bidLineColor;
  
  /// Ask line color
  final Color askLineColor;
  
  /// Current price label background color
  final Color currentPriceLabelColor;
  
  // Getters for common aliases
  Color get gridLineColor => gridColor;
  
  /// Price padding percent for viewport (0.05 = 5% padding)
  double get pricePaddingPercent => 0.08;
  
  /// Enable inertia scroll
  bool get enableInertiaScroll => enableInertia;
  
  // ============ DIMENSIONS ============
  
  /// Minimum candle width in pixels
  final double minCandleWidth;
  
  /// Maximum candle width in pixels
  final double maxCandleWidth;
  
  /// Default candle width in pixels
  final double defaultCandleWidth;
  
  /// Space between candles as ratio of candle width (0.0 - 1.0)
  final double candleSpacing;
  
  /// Minimum wick width in pixels
  final double wickWidth;
  
  /// Price scale width in pixels
  final double priceScaleWidth;
  
  /// Time scale height in pixels
  final double timeScaleHeight;
  
  /// Padding inside the chart area
  final EdgeInsets chartPadding;
  
  // ============ GRID ============
  
  /// Number of horizontal grid lines
  final int horizontalGridLines;
  
  /// Grid line width
  final double gridLineWidth;
  
  /// Whether to show vertical grid lines
  final bool showVerticalGrid;
  
  /// Whether to show horizontal grid lines
  final bool showHorizontalGrid;
  
  // ============ TEXT ============
  
  /// Font size for price labels
  final double priceLabelFontSize;
  
  /// Font size for time labels
  final double timeLabelFontSize;
  
  /// Number of decimal places for price display
  final int priceDecimals;
  
  // ============ BEHAVIOR ============
  
  /// Minimum zoom level (candles visible)
  final int minVisibleCandles;
  
  /// Maximum zoom level (candles visible)
  final int maxVisibleCandles;
  
  /// Default number of visible candles
  final int defaultVisibleCandles;
  
  /// Number of candles to load per batch for pagination
  final int candlesPerPage;
  
  /// Threshold for triggering historical data load (candles from edge)
  final int loadMoreThreshold;
  
  /// Whether to enable inertia scrolling
  final bool enableInertia;
  
  /// Inertia friction factor (0.0 - 1.0, higher = more friction)
  final double inertiaFriction;
  
  /// Whether to show crosshair on long press
  final bool enableCrosshair;
  
  /// Whether to show current price line
  final bool showCurrentPriceLine;
  
  /// Whether to show bid/ask lines
  final bool showBidAskLines;
  
  /// Animation duration for transitions
  final Duration animationDuration;

  const ChartConfig({
    // Colors
    this.backgroundColor = const Color(0xFF1E222D),
    this.gridColor = const Color(0xFF2A2E39),
    this.textColor = const Color(0xFF787B86),
    this.crosshairColor = const Color(0xFF9598A1),
    this.bullishColor = const Color(0xFF26A69A),
    this.bearishColor = const Color(0xFFEF5350),
    this.bullishWickColor = const Color(0xFF26A69A),
    this.bearishWickColor = const Color(0xFFEF5350),
    this.currentPriceLineColor = const Color(0xFF2962FF),
    this.bidLineColor = const Color(0xFF26A69A),
    this.askLineColor = const Color(0xFFEF5350),
    this.currentPriceLabelColor = const Color(0xFF2962FF),
    
    // Dimensions
    this.minCandleWidth = 3.0,
    this.maxCandleWidth = 30.0,
    this.defaultCandleWidth = 8.0,
    this.candleSpacing = 0.2,
    this.wickWidth = 1.0,
    this.priceScaleWidth = 70.0,
    this.timeScaleHeight = 30.0,
    this.chartPadding = const EdgeInsets.only(top: 10, bottom: 10),
    
    // Grid
    this.horizontalGridLines = 5,
    this.gridLineWidth = 0.5,
    this.showVerticalGrid = true,
    this.showHorizontalGrid = true,
    
    // Text
    this.priceLabelFontSize = 11.0,
    this.timeLabelFontSize = 10.0,
    this.priceDecimals = 5,
    
    // Behavior
    this.minVisibleCandles = 10,
    this.maxVisibleCandles = 500,
    this.defaultVisibleCandles = 100,
    this.candlesPerPage = 50,
    this.loadMoreThreshold = 20,
    this.enableInertia = true,
    this.inertiaFriction = 0.95,
    this.enableCrosshair = true,
    this.showCurrentPriceLine = true,
    this.showBidAskLines = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Creates a copy with updated values
  ChartConfig copyWith({
    Color? backgroundColor,
    Color? gridColor,
    Color? textColor,
    Color? crosshairColor,
    Color? bullishColor,
    Color? bearishColor,
    Color? bullishWickColor,
    Color? bearishWickColor,
    Color? currentPriceLineColor,
    Color? bidLineColor,
    Color? askLineColor,
    double? minCandleWidth,
    double? maxCandleWidth,
    double? defaultCandleWidth,
    double? candleSpacing,
    double? wickWidth,
    double? priceScaleWidth,
    double? timeScaleHeight,
    EdgeInsets? chartPadding,
    int? horizontalGridLines,
    double? gridLineWidth,
    bool? showVerticalGrid,
    bool? showHorizontalGrid,
    double? priceLabelFontSize,
    double? timeLabelFontSize,
    int? priceDecimals,
    int? minVisibleCandles,
    int? maxVisibleCandles,
    int? defaultVisibleCandles,
    int? candlesPerPage,
    int? loadMoreThreshold,
    bool? enableInertia,
    double? inertiaFriction,
    bool? enableCrosshair,
    bool? showCurrentPriceLine,
    bool? showBidAskLines,
    Duration? animationDuration,
  }) {
    return ChartConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridColor: gridColor ?? this.gridColor,
      textColor: textColor ?? this.textColor,
      crosshairColor: crosshairColor ?? this.crosshairColor,
      bullishColor: bullishColor ?? this.bullishColor,
      bearishColor: bearishColor ?? this.bearishColor,
      bullishWickColor: bullishWickColor ?? this.bullishWickColor,
      bearishWickColor: bearishWickColor ?? this.bearishWickColor,
      currentPriceLineColor: currentPriceLineColor ?? this.currentPriceLineColor,
      bidLineColor: bidLineColor ?? this.bidLineColor,
      askLineColor: askLineColor ?? this.askLineColor,
      minCandleWidth: minCandleWidth ?? this.minCandleWidth,
      maxCandleWidth: maxCandleWidth ?? this.maxCandleWidth,
      defaultCandleWidth: defaultCandleWidth ?? this.defaultCandleWidth,
      candleSpacing: candleSpacing ?? this.candleSpacing,
      wickWidth: wickWidth ?? this.wickWidth,
      priceScaleWidth: priceScaleWidth ?? this.priceScaleWidth,
      timeScaleHeight: timeScaleHeight ?? this.timeScaleHeight,
      chartPadding: chartPadding ?? this.chartPadding,
      horizontalGridLines: horizontalGridLines ?? this.horizontalGridLines,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      showVerticalGrid: showVerticalGrid ?? this.showVerticalGrid,
      showHorizontalGrid: showHorizontalGrid ?? this.showHorizontalGrid,
      priceLabelFontSize: priceLabelFontSize ?? this.priceLabelFontSize,
      timeLabelFontSize: timeLabelFontSize ?? this.timeLabelFontSize,
      priceDecimals: priceDecimals ?? this.priceDecimals,
      minVisibleCandles: minVisibleCandles ?? this.minVisibleCandles,
      maxVisibleCandles: maxVisibleCandles ?? this.maxVisibleCandles,
      defaultVisibleCandles: defaultVisibleCandles ?? this.defaultVisibleCandles,
      candlesPerPage: candlesPerPage ?? this.candlesPerPage,
      loadMoreThreshold: loadMoreThreshold ?? this.loadMoreThreshold,
      enableInertia: enableInertia ?? this.enableInertia,
      inertiaFriction: inertiaFriction ?? this.inertiaFriction,
      enableCrosshair: enableCrosshair ?? this.enableCrosshair,
      showCurrentPriceLine: showCurrentPriceLine ?? this.showCurrentPriceLine,
      showBidAskLines: showBidAskLines ?? this.showBidAskLines,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Light theme configuration
  static ChartConfig get light => const ChartConfig(
    backgroundColor: Color(0xFFFFFFFF),
    gridColor: Color(0xFFE0E3EB),
    textColor: Color(0xFF131722),
    crosshairColor: Color(0xFF9598A1),
    bullishColor: Color(0xFF26A69A),
    bearishColor: Color(0xFFEF5350),
    bullishWickColor: Color(0xFF26A69A),
    bearishWickColor: Color(0xFFEF5350),
    currentPriceLineColor: Color(0xFF2962FF),
  );

  /// Dark theme configuration (default)
  static ChartConfig get dark => const ChartConfig();
}
