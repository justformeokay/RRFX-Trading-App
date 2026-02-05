import 'package:flutter/foundation.dart';
import 'candle_model.dart';

/// Represents the current viewport state of the chart
/// Manages which candles are visible and the zoom level
@immutable
class ViewportState {
  /// Index of the first visible candle (from the left)
  final int startIndex;
  
  /// Index of the last visible candle (from the right)
  final int endIndex;
  
  /// Current candle width in pixels
  final double candleWidth;
  
  /// Horizontal scroll offset in pixels
  final double scrollOffset;
  
  /// Minimum price visible in viewport
  final double minPrice;
  
  /// Maximum price visible in viewport
  final double maxPrice;
  
  /// Whether the chart is at the latest candle (right edge)
  final bool isAtLatest;
  
  /// Whether more historical data is being loaded
  final bool isLoadingMore;
  
  /// Total number of candles available
  final int totalCandles;

  const ViewportState({
    this.startIndex = 0,
    this.endIndex = 0,
    this.candleWidth = 8.0,
    this.scrollOffset = 0.0,
    this.minPrice = 0.0,
    this.maxPrice = 0.0,
    this.isAtLatest = true,
    this.isLoadingMore = false,
    this.totalCandles = 0,
  });

  /// Number of candles visible in the viewport
  int get visibleCandleCount => endIndex - startIndex + 1;

  /// Price range in the viewport
  double get priceRange => maxPrice - minPrice;

  /// Whether the viewport is at the oldest available data
  bool get isAtOldest => startIndex <= 0;

  /// Creates a copy with updated values
  ViewportState copyWith({
    int? startIndex,
    int? endIndex,
    double? candleWidth,
    double? scrollOffset,
    double? minPrice,
    double? maxPrice,
    bool? isAtLatest,
    bool? isLoadingMore,
    int? totalCandles,
  }) {
    return ViewportState(
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      candleWidth: candleWidth ?? this.candleWidth,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isAtLatest: isAtLatest ?? this.isAtLatest,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCandles: totalCandles ?? this.totalCandles,
    );
  }

  /// Calculates the X position for a candle at given index
  double candleXPosition(int index, double chartWidth, double spacing) {
    final totalCandleWidth = candleWidth + (candleWidth * spacing);
    return chartWidth - ((totalCandles - index) * totalCandleWidth) + scrollOffset;
  }

  /// Calculates the Y position for a price value
  double priceToY(double price, double chartHeight, double topPadding, double bottomPadding) {
    final availableHeight = chartHeight - topPadding - bottomPadding;
    if (priceRange == 0) return chartHeight / 2;
    return topPadding + ((maxPrice - price) / priceRange) * availableHeight;
  }

  /// Calculates the price for a Y position
  double yToPrice(double y, double chartHeight, double topPadding, double bottomPadding) {
    final availableHeight = chartHeight - topPadding - bottomPadding;
    final normalizedY = (y - topPadding) / availableHeight;
    return maxPrice - (normalizedY * priceRange);
  }

  /// Gets the candle index at a given X position
  int? xToIndex(double x, double chartWidth, double spacing, int totalCandles) {
    final totalCandleWidth = candleWidth + (candleWidth * spacing);
    final adjustedX = x - scrollOffset;
    final index = totalCandles - ((chartWidth - adjustedX) / totalCandleWidth).floor() - 1;
    if (index < 0 || index >= totalCandles) return null;
    return index;
  }

  /// Updates viewport based on visible candles
  ViewportState updateFromCandles(
    List<CandleModel> candles,
    double chartWidth,
    double spacing,
  ) {
    if (candles.isEmpty) return this;

    final totalCandleWidth = candleWidth + (candleWidth * spacing);
    final visibleCount = (chartWidth / totalCandleWidth).ceil();
    
    // Calculate visible range
    final adjustedScrollOffset = scrollOffset.clamp(
      -(candles.length - visibleCount) * totalCandleWidth,
      0.0,
    );
    
    final newEndIndex = (candles.length - 1 + (adjustedScrollOffset / totalCandleWidth)).round();
    final newStartIndex = (newEndIndex - visibleCount + 1).clamp(0, candles.length - 1);
    final clampedEndIndex = newEndIndex.clamp(0, candles.length - 1);

    // Calculate price range for visible candles
    final visibleCandles = candles.sublist(
      newStartIndex.clamp(0, candles.length - 1),
      (clampedEndIndex + 1).clamp(0, candles.length),
    );
    
    if (visibleCandles.isEmpty) return this;
    
    final minP = visibleCandles.lowestLow;
    final maxP = visibleCandles.highestHigh;
    final padding = (maxP - minP) * 0.1; // 10% padding

    return copyWith(
      startIndex: newStartIndex.clamp(0, candles.length - 1),
      endIndex: clampedEndIndex,
      scrollOffset: adjustedScrollOffset,
      minPrice: minP - padding,
      maxPrice: maxP + padding,
      isAtLatest: clampedEndIndex >= candles.length - 1,
      totalCandles: candles.length,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViewportState &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex &&
        other.candleWidth == candleWidth &&
        other.scrollOffset == scrollOffset &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice;
  }

  @override
  int get hashCode => Object.hash(
    startIndex, endIndex, candleWidth, scrollOffset, minPrice, maxPrice,
  );

  @override
  String toString() {
    return 'ViewportState(start: $startIndex, end: $endIndex, width: $candleWidth, '
           'scroll: $scrollOffset, price: $minPrice-$maxPrice)';
  }
}

/// Represents crosshair state
@immutable
class CrosshairState {
  /// Whether crosshair is active
  final bool isActive;
  
  /// X position in pixels
  final double x;
  
  /// Y position in pixels
  final double y;
  
  /// Candle index at crosshair position
  final int? candleIndex;
  
  /// Price at crosshair position
  final double? price;
  
  /// The candle at crosshair position
  final CandleModel? candle;

  const CrosshairState({
    this.isActive = false,
    this.x = 0,
    this.y = 0,
    this.candleIndex,
    this.price,
    this.candle,
  });

  CrosshairState copyWith({
    bool? isActive,
    double? x,
    double? y,
    int? candleIndex,
    double? price,
    CandleModel? candle,
  }) {
    return CrosshairState(
      isActive: isActive ?? this.isActive,
      x: x ?? this.x,
      y: y ?? this.y,
      candleIndex: candleIndex ?? this.candleIndex,
      price: price ?? this.price,
      candle: candle ?? this.candle,
    );
  }

  CrosshairState deactivate() {
    return const CrosshairState(isActive: false);
  }
}
