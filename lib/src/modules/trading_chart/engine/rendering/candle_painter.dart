import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/candle_model.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';

/// High-performance candlestick painter using CustomPainter
/// Optimized for 60 FPS rendering with 1000+ candles
class CandlePainter extends CustomPainter {
  final List<CandleModel> candles;
  final ViewportState viewport;
  final ChartConfig config;
  final double chartHeight;
  final double chartWidth;
  
  // Cached paints for performance
  late final Paint _bullishBodyPaint;
  late final Paint _bearishBodyPaint;
  late final Paint _bullishWickPaint;
  late final Paint _bearishWickPaint;
  
  // Pre-calculated values
  late final double _totalCandleWidth;
  late final double _bodyWidth;
  late final double _availableHeight;
  
  CandlePainter({
    required this.candles,
    required this.viewport,
    required this.config,
    required this.chartHeight,
    required this.chartWidth,
  }) {
    _initPaints();
    _calculateDimensions();
  }
  
  void _initPaints() {
    _bullishBodyPaint = Paint()
      ..color = config.bullishColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    
    _bearishBodyPaint = Paint()
      ..color = config.bearishColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    
    _bullishWickPaint = Paint()
      ..color = config.bullishWickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.wickWidth
      ..isAntiAlias = true;
    
    _bearishWickPaint = Paint()
      ..color = config.bearishWickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.wickWidth
      ..isAntiAlias = true;
  }
  
  void _calculateDimensions() {
    _totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    _bodyWidth = viewport.candleWidth;
    _availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || viewport.priceRange == 0) return;
    
    // Clip to chart area
    canvas.clipRect(Rect.fromLTWH(0, 0, chartWidth, chartHeight));
    
    // Calculate visible range with buffer for smooth scrolling
    // Note: viewport.endIndex is exclusive, so we use endIndex - 1 for the last visible
    final visibleStart = (viewport.startIndex - 2).clamp(0, candles.length - 1);
    final visibleEnd = (viewport.endIndex + 1).clamp(0, candles.length - 1);
    
    // Batch draw candles for performance
    final bullishBodies = <Rect>[];
    final bearishBodies = <Rect>[];
    final bullishWicks = <Offset>[];
    final bearishWicks = <Offset>[];
    
    for (int i = visibleStart; i <= visibleEnd; i++) {
      final candle = candles[i];
      final x = _calculateX(i);
      
      // Skip if out of visible area
      if (x + _bodyWidth < 0 || x - _bodyWidth > chartWidth) continue;
      
      final centerX = x + _bodyWidth / 2;
      
      // Calculate Y positions
      final highY = _priceToY(candle.high);
      final lowY = _priceToY(candle.low);
      final openY = _priceToY(candle.open);
      final closeY = _priceToY(candle.close);
      
      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs().clamp(1.0, double.infinity);
      
      // Add to appropriate batch
      if (candle.isBullish) {
        // Wick
        bullishWicks.add(Offset(centerX, highY));
        bullishWicks.add(Offset(centerX, lowY));
        
        // Body
        bullishBodies.add(Rect.fromLTWH(x, bodyTop, _bodyWidth, bodyHeight));
      } else {
        // Wick
        bearishWicks.add(Offset(centerX, highY));
        bearishWicks.add(Offset(centerX, lowY));
        
        // Body
        bearishBodies.add(Rect.fromLTWH(x, bodyTop, _bodyWidth, bodyHeight));
      }
    }
    
    // Draw wicks first (they go behind bodies)
    _drawWicks(canvas, bullishWicks, _bullishWickPaint);
    _drawWicks(canvas, bearishWicks, _bearishWickPaint);
    
    // Draw bodies
    _drawBodies(canvas, bullishBodies, _bullishBodyPaint);
    _drawBodies(canvas, bearishBodies, _bearishBodyPaint);
  }
  
  /// Draw wicks efficiently using drawLines
  void _drawWicks(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;
    
    // Draw lines in pairs (start, end)
    for (int i = 0; i < points.length - 1; i += 2) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }
  
  /// Draw bodies efficiently using drawRect
  void _drawBodies(Canvas canvas, List<Rect> rects, Paint paint) {
    for (final rect in rects) {
      canvas.drawRect(rect, paint);
    }
  }
  
  /// Calculate X position for candle at index
  double _calculateX(int index) {
    // Right-aligned: newest candle at right edge
    return chartWidth - ((candles.length - index) * _totalCandleWidth) + viewport.scrollOffset;
  }
  
  /// Convert price to Y coordinate
  double _priceToY(double price) {
    final topPadding = config.chartPadding.top;
    return topPadding + ((viewport.maxPrice - price) / viewport.priceRange) * _availableHeight;
  }
  
  @override
  bool shouldRepaint(covariant CandlePainter oldDelegate) {
    // Repaint if any relevant property changed
    return oldDelegate.viewport != viewport ||
           oldDelegate.candles.length != candles.length ||
           (candles.isNotEmpty && oldDelegate.candles.isNotEmpty &&
            oldDelegate.candles.last != candles.last);
  }
}

/// Optimized candle painter using drawVertices for maximum performance
/// Use this for very large datasets (5000+ candles)
class OptimizedCandlePainter extends CustomPainter {
  final List<CandleModel> candles;
  final ViewportState viewport;
  final ChartConfig config;
  final double chartHeight;
  final double chartWidth;
  
  // Cached vertex data
  ui.Vertices? _bullishVertices;
  ui.Vertices? _bearishVertices;
  
  OptimizedCandlePainter({
    required this.candles,
    required this.viewport,
    required this.config,
    required this.chartHeight,
    required this.chartWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || viewport.priceRange == 0) return;
    
    canvas.clipRect(Rect.fromLTWH(0, 0, chartWidth, chartHeight));
    
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    final bodyWidth = viewport.candleWidth;
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    final topPadding = config.chartPadding.top;
    
    // Prepare vertex lists
    final bullishPositions = <Offset>[];
    final bullishColors = <Color>[];
    final bearishPositions = <Offset>[];
    final bearishColors = <Color>[];
    
    final wickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.wickWidth;
    
    // Note: viewport.endIndex is exclusive
    final visibleStart = (viewport.startIndex - 1).clamp(0, candles.length - 1);
    final visibleEnd = (viewport.endIndex + 1).clamp(0, candles.length - 1);
    
    for (int i = visibleStart; i <= visibleEnd; i++) {
      final candle = candles[i];
      final x = chartWidth - ((candles.length - i) * totalCandleWidth) + viewport.scrollOffset;
      
      if (x + bodyWidth < -totalCandleWidth || x > chartWidth + totalCandleWidth) continue;
      
      final centerX = x + bodyWidth / 2;
      
      double priceToY(double price) {
        return topPadding + ((viewport.maxPrice - price) / viewport.priceRange) * availableHeight;
      }
      
      final highY = priceToY(candle.high);
      final lowY = priceToY(candle.low);
      final openY = priceToY(candle.open);
      final closeY = priceToY(candle.close);
      
      // Draw wick
      wickPaint.color = candle.isBullish ? config.bullishWickColor : config.bearishWickColor;
      canvas.drawLine(Offset(centerX, highY), Offset(centerX, lowY), wickPaint);
      
      // Add body vertices (two triangles per candle)
      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs().clamp(1.0, double.infinity);
      
      final color = candle.isBullish ? config.bullishColor : config.bearishColor;
      final positions = candle.isBullish ? bullishPositions : bearishPositions;
      final colors = candle.isBullish ? bullishColors : bearishColors;
      
      // Triangle 1
      positions.add(Offset(x, bodyTop));
      positions.add(Offset(x + bodyWidth, bodyTop));
      positions.add(Offset(x, bodyTop + bodyHeight));
      
      // Triangle 2
      positions.add(Offset(x + bodyWidth, bodyTop));
      positions.add(Offset(x + bodyWidth, bodyTop + bodyHeight));
      positions.add(Offset(x, bodyTop + bodyHeight));
      
      // Colors for all 6 vertices
      for (int j = 0; j < 6; j++) {
        colors.add(color);
      }
    }
    
    // Draw using vertices for maximum performance
    if (bullishPositions.isNotEmpty) {
      _bullishVertices = ui.Vertices(
        ui.VertexMode.triangles,
        bullishPositions,
        colors: bullishColors,
      );
      canvas.drawVertices(_bullishVertices!, BlendMode.srcOver, Paint());
    }
    
    if (bearishPositions.isNotEmpty) {
      _bearishVertices = ui.Vertices(
        ui.VertexMode.triangles,
        bearishPositions,
        colors: bearishColors,
      );
      canvas.drawVertices(_bearishVertices!, BlendMode.srcOver, Paint());
    }
  }
  
  @override
  bool shouldRepaint(covariant OptimizedCandlePainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
           oldDelegate.candles.length != candles.length ||
           (candles.isNotEmpty && oldDelegate.candles.isNotEmpty &&
            oldDelegate.candles.last != candles.last);
  }
}
