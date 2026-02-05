import 'package:flutter/material.dart';
import '../../data/models/indicator_model.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';

/// Painter for technical indicators overlay
class IndicatorPainter extends CustomPainter {
  final List<IndicatorModel> indicators;
  final ViewportState viewport;
  final ChartConfig config;
  final double chartWidth;
  final double chartHeight;
  final int totalCandles;
  
  IndicatorPainter({
    required this.indicators,
    required this.viewport,
    required this.config,
    required this.chartWidth,
    required this.chartHeight,
    required this.totalCandles,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (indicators.isEmpty || viewport.priceRange == 0) return;
    
    canvas.clipRect(Rect.fromLTWH(0, 0, chartWidth, chartHeight));
    
    for (final indicator in indicators) {
      if (!indicator.isVisible || !indicator.isOverlay) continue;
      
      if (indicator is MovingAverageIndicator) {
        _paintMovingAverage(canvas, indicator);
      } else if (indicator is BollingerBandsIndicator) {
        _paintBollingerBands(canvas, indicator);
      }
    }
  }
  
  void _paintMovingAverage(Canvas canvas, MovingAverageIndicator indicator) {
    if (indicator.values.isEmpty) return;
    
    final paint = Paint()
      ..color = indicator.color
      ..strokeWidth = indicator.thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    
    final path = Path();
    bool pathStarted = false;
    
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    final topPadding = config.chartPadding.top;
    
    // Draw only visible portion with small buffer
    final startIdx = (viewport.startIndex - 2).clamp(0, indicator.values.length - 1);
    final endIdx = (viewport.endIndex + 2).clamp(0, indicator.values.length - 1);
    
    for (int i = startIdx; i <= endIdx; i++) {
      final value = indicator.values[i];
      if (value == null) continue;
      
      final x = chartWidth - ((totalCandles - i) * totalCandleWidth) + viewport.scrollOffset + (viewport.candleWidth / 2);
      final y = topPadding + ((viewport.maxPrice - value) / viewport.priceRange) * availableHeight;
      
      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }
    
    if (pathStarted) {
      canvas.drawPath(path, paint);
    }
  }
  
  void _paintBollingerBands(Canvas canvas, BollingerBandsIndicator indicator) {
    if (indicator.middleValues.isEmpty) return;
    
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    final topPadding = config.chartPadding.top;
    
    // Draw filled area between bands
    final fillPath = Path();
    final upperPath = Path();
    final middlePath = Path();
    final lowerPath = Path();
    
    bool fillStarted = false;
    final upperPoints = <Offset>[];
    final lowerPoints = <Offset>[];
    
    final startIdx = (viewport.startIndex - 2).clamp(0, indicator.middleValues.length - 1);
    final endIdx = (viewport.endIndex + 2).clamp(0, indicator.middleValues.length - 1);
    
    for (int i = startIdx; i <= endIdx; i++) {
      final upper = indicator.upperValues.length > i ? indicator.upperValues[i] : null;
      final middle = indicator.middleValues.length > i ? indicator.middleValues[i] : null;
      final lower = indicator.lowerValues.length > i ? indicator.lowerValues[i] : null;
      
      if (upper == null || middle == null || lower == null) continue;
      
      final x = chartWidth - ((totalCandles - i) * totalCandleWidth) + viewport.scrollOffset + (viewport.candleWidth / 2);
      
      final upperY = topPadding + ((viewport.maxPrice - upper) / viewport.priceRange) * availableHeight;
      final middleY = topPadding + ((viewport.maxPrice - middle) / viewport.priceRange) * availableHeight;
      final lowerY = topPadding + ((viewport.maxPrice - lower) / viewport.priceRange) * availableHeight;
      
      upperPoints.add(Offset(x, upperY));
      lowerPoints.add(Offset(x, lowerY));
      
      if (!fillStarted) {
        upperPath.moveTo(x, upperY);
        middlePath.moveTo(x, middleY);
        lowerPath.moveTo(x, lowerY);
        fillStarted = true;
      } else {
        upperPath.lineTo(x, upperY);
        middlePath.lineTo(x, middleY);
        lowerPath.lineTo(x, lowerY);
      }
    }
    
    // Draw filled area
    if (upperPoints.isNotEmpty && lowerPoints.isNotEmpty) {
      fillPath.addPath(upperPath, Offset.zero);
      for (int i = lowerPoints.length - 1; i >= 0; i--) {
        if (i == lowerPoints.length - 1) {
          fillPath.lineTo(lowerPoints[i].dx, lowerPoints[i].dy);
        } else {
          fillPath.lineTo(lowerPoints[i].dx, lowerPoints[i].dy);
        }
      }
      fillPath.close();
      
      final fillPaint = Paint()
        ..color = indicator.middleBandColor.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }
    
    // Draw lines
    final upperPaint = Paint()
      ..color = indicator.upperBandColor
      ..strokeWidth = indicator.thickness
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    
    final middlePaint = Paint()
      ..color = indicator.middleBandColor
      ..strokeWidth = indicator.thickness
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    
    final lowerPaint = Paint()
      ..color = indicator.lowerBandColor
      ..strokeWidth = indicator.thickness
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    
    if (fillStarted) {
      canvas.drawPath(upperPath, upperPaint);
      canvas.drawPath(middlePath, middlePaint);
      canvas.drawPath(lowerPath, lowerPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant IndicatorPainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
           oldDelegate.indicators != indicators ||
           oldDelegate.totalCandles != totalCandles;
  }
}
