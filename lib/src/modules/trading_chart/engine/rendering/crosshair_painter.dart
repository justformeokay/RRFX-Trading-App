import 'package:flutter/material.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';
import '../../data/models/candle_model.dart';

/// Painter for crosshair overlay
class CrosshairPainter extends CustomPainter {
  final CrosshairState crosshair;
  final ChartConfig config;
  final double chartWidth;
  final double chartHeight;
  final double priceScaleWidth;
  final int priceDecimals;
  
  late final Paint _linePaint;
  late final Paint _dotPaint;
  late final Paint _labelBackgroundPaint;
  late final TextPainter _textPainter;
  
  CrosshairPainter({
    required this.crosshair,
    required this.config,
    required this.chartWidth,
    required this.chartHeight,
    this.priceScaleWidth = 70,
    this.priceDecimals = 5,
  }) {
    _linePaint = Paint()
      ..color = config.crosshairColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    _dotPaint = Paint()
      ..color = config.crosshairColor
      ..style = PaintingStyle.fill;
    
    _labelBackgroundPaint = Paint()
      ..color = config.crosshairColor
      ..style = PaintingStyle.fill;
    
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (!crosshair.isActive) return;
    
    final x = crosshair.x.clamp(0.0, chartWidth);
    final y = crosshair.y.clamp(0.0, chartHeight);
    
    // Draw horizontal line
    _drawDashedLine(
      canvas,
      Offset(0, y),
      Offset(chartWidth + priceScaleWidth, y),
    );
    
    // Draw vertical line
    _drawDashedLine(
      canvas,
      Offset(x, 0),
      Offset(x, chartHeight),
    );
    
    // Draw center dot
    canvas.drawCircle(Offset(x, y), 4, _dotPaint);
    canvas.drawCircle(
      Offset(x, y),
      4,
      Paint()
        ..color = config.backgroundColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(Offset(x, y), 3, _dotPaint);
    
    // Draw price label on right side
    if (crosshair.price != null) {
      _drawPriceLabel(canvas, y, crosshair.price!);
    }
    
    // Draw time label at bottom
    if (crosshair.candle != null) {
      _drawTimeLabel(canvas, x, crosshair.candle!);
    }
  }
  
  void _drawDashedLine(Canvas canvas, Offset start, Offset end) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    
    final distance = (end - start).distance;
    if (distance == 0) return;
    
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
          _linePaint,
        );
      }
      
      drawn = segmentEnd;
      isDash = !isDash;
    }
  }
  
  void _drawPriceLabel(Canvas canvas, double y, double price) {
    final priceText = price.toStringAsFixed(priceDecimals);
    
    _textPainter.text = TextSpan(
      text: priceText,
      style: TextStyle(
        color: config.backgroundColor,
        fontSize: config.priceLabelFontSize,
        fontWeight: FontWeight.w500,
      ),
    );
    _textPainter.layout();
    
    final labelWidth = _textPainter.width + 12;
    final labelHeight = _textPainter.height + 6;
    final labelX = chartWidth;
    final labelY = y - labelHeight / 2;
    
    // Draw background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(labelRect, _labelBackgroundPaint);
    
    // Draw text
    _textPainter.paint(
      canvas,
      Offset(labelX + 6, labelY + 3),
    );
  }
  
  void _drawTimeLabel(Canvas canvas, double x, CandleModel candle) {
    final dateTime = candle.dateTime;
    final timeText = '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    _textPainter.text = TextSpan(
      text: timeText,
      style: TextStyle(
        color: config.backgroundColor,
        fontSize: config.timeLabelFontSize,
        fontWeight: FontWeight.w500,
      ),
    );
    _textPainter.layout();
    
    final labelWidth = _textPainter.width + 12;
    final labelHeight = _textPainter.height + 6;
    final labelX = (x - labelWidth / 2).clamp(0.0, chartWidth - labelWidth);
    final labelY = chartHeight;
    
    // Draw background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(labelRect, _labelBackgroundPaint);
    
    // Draw text
    _textPainter.paint(
      canvas,
      Offset(labelX + 6, labelY + 3),
    );
  }
  
  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {
    return oldDelegate.crosshair != crosshair;
  }
}
