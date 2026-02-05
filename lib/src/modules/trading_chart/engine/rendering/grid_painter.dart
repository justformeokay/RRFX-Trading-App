import 'package:flutter/material.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';
import '../../data/models/candle_model.dart';
import '../../data/models/timeframe_model.dart';

/// Painter for chart grid lines
class GridPainter extends CustomPainter {
  final ViewportState viewport;
  final ChartConfig config;
  final double chartWidth;
  final double chartHeight;
  final List<CandleModel> candles;
  final ChartTimeframe timeframe;
  
  late final Paint _gridPaint;
  late final TextPainter _textPainter;
  
  GridPainter({
    required this.viewport,
    required this.config,
    required this.chartWidth,
    required this.chartHeight,
    required this.candles,
    required this.timeframe,
  }) {
    _gridPaint = Paint()
      ..color = config.gridColor
      ..strokeWidth = config.gridLineWidth
      ..style = PaintingStyle.stroke;
    
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (config.showHorizontalGrid) {
      _drawHorizontalGridLines(canvas);
    }
    
    if (config.showVerticalGrid) {
      _drawVerticalGridLines(canvas);
    }
  }
  
  void _drawHorizontalGridLines(Canvas canvas) {
    if (viewport.priceRange == 0) return;
    
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    final gridCount = config.horizontalGridLines;
    final gridSpacing = availableHeight / (gridCount + 1);
    
    for (int i = 1; i <= gridCount; i++) {
      final y = config.chartPadding.top + (i * gridSpacing);
      
      // Draw dashed line
      _drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(chartWidth, y),
        _gridPaint,
      );
    }
  }
  
  void _drawVerticalGridLines(Canvas canvas) {
    if (candles.isEmpty) return;
    
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    final gridInterval = timeframe.gridIntervalCandles;
    
    // Find the first candle that aligns with grid interval
    int startIndex = viewport.startIndex;
    for (int i = viewport.startIndex; i <= viewport.endIndex; i++) {
      if (i >= 0 && i < candles.length) {
        final candle = candles[i];
        final dt = candle.dateTime;
        
        // Check if this candle aligns with grid interval
        bool isGridLine = false;
        switch (timeframe) {
          case ChartTimeframe.m1:
          case ChartTimeframe.m5:
          case ChartTimeframe.m15:
          case ChartTimeframe.m30:
            isGridLine = dt.minute == 0;
            break;
          case ChartTimeframe.h1:
          case ChartTimeframe.h4:
            isGridLine = dt.hour == 0;
            break;
          case ChartTimeframe.d1:
            isGridLine = dt.weekday == 1; // Monday
            break;
          case ChartTimeframe.w1:
            isGridLine = dt.day <= 7;
            break;
          case ChartTimeframe.mn:
            isGridLine = dt.month == 1;
            break;
        }
        
        if (isGridLine) {
          final x = chartWidth - ((candles.length - i) * totalCandleWidth) + viewport.scrollOffset;
          
          if (x >= 0 && x <= chartWidth) {
            _drawDashedLine(
              canvas,
              Offset(x, 0),
              Offset(x, chartHeight),
              _gridPaint,
            );
          }
        }
      }
    }
  }
  
  /// Draw a dashed line
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    
    double drawn = 0;
    bool isDash = true;
    
    while (drawn < distance) {
      final length = isDash ? dashWidth : dashSpace;
      final segmentEnd = drawn + length > distance ? distance : drawn + length;
      
      if (isDash) {
        canvas.drawLine(
          start + direction * drawn,
          start + direction * segmentEnd,
          paint,
        );
      }
      
      drawn = segmentEnd;
      isDash = !isDash;
    }
  }
  
  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
           oldDelegate.chartWidth != chartWidth ||
           oldDelegate.chartHeight != chartHeight;
  }
}
