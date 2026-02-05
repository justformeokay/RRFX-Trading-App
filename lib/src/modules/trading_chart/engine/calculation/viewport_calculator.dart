import 'dart:ui' show Offset;
import '../../data/models/candle_model.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';

/// Calculator for viewport calculations
/// Handles scroll, zoom, and position calculations
class ViewportCalculator {
  final ChartConfig config;
  
  ViewportCalculator(this.config);
  
  /// Calculate new viewport after scroll
  ViewportState calculateScrolledViewport({
    required ViewportState currentViewport,
    required List<CandleModel> candles,
    required double scrollDelta,
    required double chartWidth,
  }) {
    if (candles.isEmpty) return currentViewport;
    
    final totalCandleWidth = currentViewport.candleWidth * (1 + config.candleSpacing);
    
    // Calculate scroll bounds
    // maxScroll: can scroll right to see latest candles (positive direction)
    // minScroll: can scroll left to see historical candles (negative direction)
    final maxScroll = chartWidth * 0.5; // Allow some empty space on right
    final totalContentWidth = candles.length * totalCandleWidth;
    final minScroll = -(totalContentWidth - chartWidth * 0.5).clamp(0.0, double.infinity);
    
    final newScrollOffset = (currentViewport.scrollOffset + scrollDelta).clamp(minScroll, maxScroll);
    
    return _updateViewportFromScroll(
      currentViewport: currentViewport,
      candles: candles,
      scrollOffset: newScrollOffset,
      chartWidth: chartWidth,
    );
  }
  
  /// Calculate new viewport after zoom
  ViewportState calculateZoomedViewport({
    required ViewportState currentViewport,
    required List<CandleModel> candles,
    required double scale,
    required double focalX,
    required double chartWidth,
  }) {
    if (candles.isEmpty) return currentViewport;
    
    // Calculate new candle width
    final newCandleWidth = (currentViewport.candleWidth * scale).clamp(
      config.minCandleWidth,
      config.maxCandleWidth,
    );
    
    if (newCandleWidth == currentViewport.candleWidth) return currentViewport;
    
    // Calculate adjusted scroll to keep focal point stable
    final newTotalWidth = newCandleWidth * (1 + config.candleSpacing);
    
    // Find the candle index at focal point
    final focalIndex = _xToIndex(focalX, chartWidth, currentViewport, candles.length);
    
    // Calculate new scroll offset to keep focal point stable
    final newFocalXRaw = chartWidth - ((candles.length - focalIndex) * newTotalWidth);
    final newScrollOffset = focalX - newFocalXRaw;
    
    // Clamp scroll offset (same bounds as scroll)
    final maxScroll = chartWidth * 0.5;
    final totalContentWidth = candles.length * newTotalWidth;
    final minScroll = -(totalContentWidth - chartWidth * 0.5).clamp(0.0, double.infinity);
    final clampedScrollOffset = newScrollOffset.clamp(minScroll, maxScroll);
    
    return _updateViewportFromZoom(
      currentViewport: currentViewport,
      candles: candles,
      newCandleWidth: newCandleWidth,
      scrollOffset: clampedScrollOffset,
      chartWidth: chartWidth,
    );
  }
  
  /// Calculate viewport for initial display
  ViewportState calculateInitialViewport({
    required List<CandleModel> candles,
    required double chartWidth,
    required double chartHeight,
  }) {
    if (candles.isEmpty) {
      return ViewportState(candleWidth: config.defaultCandleWidth);
    }
    
    // Start at most recent (scroll offset 0)
    return _updateViewportFromScroll(
      currentViewport: ViewportState(
        candleWidth: config.defaultCandleWidth,
        scrollOffset: 0,
        totalCandles: candles.length,
      ),
      candles: candles,
      scrollOffset: 0,
      chartWidth: chartWidth,
    );
  }
  
  /// Update viewport when new candles are added
  ViewportState updateViewportWithNewCandles({
    required ViewportState currentViewport,
    required List<CandleModel> candles,
    required int previousCandleCount,
    required double chartWidth,
    required bool isHistorical,
  }) {
    if (candles.isEmpty) return currentViewport;
    
    if (isHistorical) {
      // Historical candles added at beginning
      // Adjust scroll offset to keep view position stable
      final addedCount = candles.length - previousCandleCount;
      final totalCandleWidth = currentViewport.candleWidth * (1 + config.candleSpacing);
      final scrollAdjustment = addedCount * totalCandleWidth;
      
      return _updateViewportFromScroll(
        currentViewport: currentViewport,
        candles: candles,
        scrollOffset: currentViewport.scrollOffset - scrollAdjustment,
        chartWidth: chartWidth,
      );
    } else {
      // New candle added at end
      if (currentViewport.isAtLatest) {
        // Keep view at latest
        return _updateViewportFromScroll(
          currentViewport: currentViewport,
          candles: candles,
          scrollOffset: 0,
          chartWidth: chartWidth,
        );
      } else {
        // Keep current position
        return _updateViewportFromScroll(
          currentViewport: currentViewport,
          candles: candles,
          scrollOffset: currentViewport.scrollOffset,
          chartWidth: chartWidth,
        );
      }
    }
  }
  
  /// Check if we should load more historical data
  bool shouldLoadMore(ViewportState viewport) {
    return !viewport.isLoadingMore && 
           viewport.startIndex <= config.loadMoreThreshold &&
           viewport.startIndex > 0;
  }
  
  /// Calculate crosshair position
  CrosshairState calculateCrosshairState({
    required Offset position,
    required ViewportState viewport,
    required List<CandleModel> candles,
    required double chartWidth,
    required double chartHeight,
  }) {
    if (candles.isEmpty) {
      return const CrosshairState(isActive: false);
    }
    
    final x = position.dx.clamp(0.0, chartWidth);
    final y = position.dy.clamp(0.0, chartHeight);
    
    // Find candle at position
    final index = _xToIndex(x, chartWidth, viewport, candles.length);
    final clampedIndex = index.clamp(0, candles.length - 1);
    final candle = candles[clampedIndex];
    
    // Calculate price at y position
    final price = _yToPrice(y, chartHeight, viewport);
    
    // Snap x to candle center
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    final snappedX = chartWidth - ((candles.length - clampedIndex) * totalCandleWidth) 
                   + viewport.scrollOffset + (viewport.candleWidth / 2);
    
    return CrosshairState(
      isActive: true,
      x: snappedX.clamp(0.0, chartWidth),
      y: y,
      candleIndex: clampedIndex,
      price: price,
      candle: candle,
    );
  }
  
  // Private helper methods
  
  ViewportState _updateViewportFromScroll({
    required ViewportState currentViewport,
    required List<CandleModel> candles,
    required double scrollOffset,
    required double chartWidth,
  }) {
    final totalCandleWidth = currentViewport.candleWidth * (1 + config.candleSpacing);
    final visibleCount = (chartWidth / totalCandleWidth).ceil() + 2;
    
    // Calculate visible range based on scroll offset
    // With scrollOffset = 0, we show the latest candles on the right
    // Negative scrollOffset means we're viewing older candles
    // Positive scrollOffset means we're past the latest candle (empty space on right)
    
    // The rightmost visible candle index
    final rightmostIndex = candles.length - 1 + (scrollOffset / totalCandleWidth).floor();
    // The leftmost visible candle index
    final leftmostIndex = rightmostIndex - visibleCount;
    
    final clampedStartIndex = leftmostIndex.clamp(0, candles.length - 1);
    final clampedEndIndex = (rightmostIndex + 1).clamp(0, candles.length);
    
    // Calculate price range for visible candles
    if (clampedStartIndex >= clampedEndIndex || clampedStartIndex >= candles.length) {
      return currentViewport.copyWith(
        scrollOffset: scrollOffset,
        totalCandles: candles.length,
      );
    }
    
    final visibleCandles = candles.sublist(clampedStartIndex, clampedEndIndex);
    
    if (visibleCandles.isEmpty) {
      return currentViewport.copyWith(
        scrollOffset: scrollOffset,
        totalCandles: candles.length,
      );
    }
    
    final minPrice = visibleCandles.lowestLow;
    final maxPrice = visibleCandles.highestHigh;
    final padding = (maxPrice - minPrice) * 0.1;
    
    return currentViewport.copyWith(
      startIndex: clampedStartIndex,
      endIndex: clampedEndIndex,
      scrollOffset: scrollOffset,
      minPrice: minPrice - padding,
      maxPrice: maxPrice + padding,
      isAtLatest: rightmostIndex >= candles.length - 1,
      totalCandles: candles.length,
    );
  }
  
  ViewportState _updateViewportFromZoom({
    required ViewportState currentViewport,
    required List<CandleModel> candles,
    required double newCandleWidth,
    required double scrollOffset,
    required double chartWidth,
  }) {
    final totalCandleWidth = newCandleWidth * (1 + config.candleSpacing);
    final visibleCount = (chartWidth / totalCandleWidth).ceil() + 2;
    
    // Calculate visible range based on scroll offset (same logic as scroll)
    final rightmostIndex = candles.length - 1 + (scrollOffset / totalCandleWidth).floor();
    final leftmostIndex = rightmostIndex - visibleCount;
    
    final clampedStartIndex = leftmostIndex.clamp(0, candles.length - 1);
    final clampedEndIndex = (rightmostIndex + 1).clamp(0, candles.length);
    
    if (clampedStartIndex >= clampedEndIndex || clampedStartIndex >= candles.length) {
      return currentViewport.copyWith(
        candleWidth: newCandleWidth,
        scrollOffset: scrollOffset,
        totalCandles: candles.length,
      );
    }
    
    final visibleCandles = candles.sublist(clampedStartIndex, clampedEndIndex);
    
    if (visibleCandles.isEmpty) {
      return currentViewport.copyWith(
        candleWidth: newCandleWidth,
        scrollOffset: scrollOffset,
        totalCandles: candles.length,
      );
    }
    
    final minPrice = visibleCandles.lowestLow;
    final maxPrice = visibleCandles.highestHigh;
    final padding = (maxPrice - minPrice) * 0.1;
    
    return currentViewport.copyWith(
      startIndex: clampedStartIndex,
      endIndex: clampedEndIndex,
      candleWidth: newCandleWidth,
      scrollOffset: scrollOffset,
      minPrice: minPrice - padding,
      maxPrice: maxPrice + padding,
      isAtLatest: rightmostIndex >= candles.length - 1,
      totalCandles: candles.length,
    );
  }
  
  int _xToIndex(double x, double chartWidth, ViewportState viewport, int totalCandles) {
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    final adjustedX = x - viewport.scrollOffset;
    return totalCandles - ((chartWidth - adjustedX) / totalCandleWidth).floor() - 1;
  }
  
  double _yToPrice(double y, double chartHeight, ViewportState viewport) {
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    final normalizedY = (y - config.chartPadding.top) / availableHeight;
    return viewport.maxPrice - (normalizedY * viewport.priceRange);
  }
}
