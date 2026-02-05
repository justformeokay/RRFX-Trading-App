import 'package:flutter/material.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';
import '../../data/models/candle_model.dart';
import '../../data/models/timeframe_model.dart';

/// Painter for time scale (X-axis)
class TimeScalePainter extends CustomPainter {
  final ViewportState viewport;
  final ChartConfig config;
  final double chartWidth;
  final List<CandleModel> candles;
  final ChartTimeframe timeframe;
  
  late final Paint _linePaint;
  late final TextPainter _textPainter;
  
  TimeScalePainter({
    required this.viewport,
    required this.config,
    required this.chartWidth,
    required this.candles,
    required this.timeframe,
  }) {
    _linePaint = Paint()
      ..color = config.gridColor
      ..strokeWidth = 1;
    
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    
    // Draw top border
    canvas.drawLine(
      Offset(0, 0),
      Offset(chartWidth, 0),
      _linePaint,
    );
    
    // Draw time labels
    _drawTimeLabels(canvas, size);
  }
  
  void _drawTimeLabels(Canvas canvas, Size size) {
    final totalCandleWidth = viewport.candleWidth * (1 + config.candleSpacing);
    
    // Calculate label interval based on candle width
    final minLabelSpacing = 80.0; // Minimum pixels between labels
    final candlesPerLabel = (minLabelSpacing / totalCandleWidth).ceil();
    final labelInterval = _calculateLabelInterval(candlesPerLabel);
    
    // Track last drawn date to show date separators
    DateTime? lastDate;
    
    for (int i = viewport.startIndex; i <= viewport.endIndex; i++) {
      if (i < 0 || i >= candles.length) continue;
      
      final candle = candles[i];
      final dateTime = candle.dateTime;
      
      // Check if we should draw a label at this position
      if (!_shouldDrawLabel(dateTime, labelInterval)) continue;
      
      final x = chartWidth - ((candles.length - i) * totalCandleWidth) + viewport.scrollOffset + (viewport.candleWidth / 2);
      
      if (x < 0 || x > chartWidth) continue;
      
      // Determine if we should show date
      final showDate = lastDate == null || 
                       dateTime.day != lastDate.day ||
                       dateTime.month != lastDate.month;
      
      final labelText = timeframe.formatForAxis(dateTime, showDate);
      
      _drawTimeLabel(canvas, x, size.height, labelText);
      
      lastDate = dateTime;
    }
  }
  
  int _calculateLabelInterval(int candlesPerLabel) {
    // Round up to nice intervals
    if (candlesPerLabel <= 1) return 1;
    if (candlesPerLabel <= 5) return 5;
    if (candlesPerLabel <= 10) return 10;
    if (candlesPerLabel <= 15) return 15;
    if (candlesPerLabel <= 30) return 30;
    if (candlesPerLabel <= 60) return 60;
    return ((candlesPerLabel / 60).ceil()) * 60;
  }
  
  bool _shouldDrawLabel(DateTime dateTime, int interval) {
    switch (timeframe) {
      case ChartTimeframe.m1:
        return dateTime.minute % interval == 0;
      case ChartTimeframe.m5:
        return (dateTime.minute ~/ 5) % (interval ~/ 5 + 1) == 0 && dateTime.minute % 5 == 0;
      case ChartTimeframe.m15:
        return dateTime.minute % 15 == 0 && (dateTime.hour * 4 + dateTime.minute ~/ 15) % ((interval ~/ 15).clamp(1, 24)) == 0;
      case ChartTimeframe.m30:
        return dateTime.minute % 30 == 0;
      case ChartTimeframe.h1:
        return dateTime.hour % (interval.clamp(1, 24)) == 0;
      case ChartTimeframe.h4:
        return dateTime.hour % 4 == 0 && (dateTime.hour ~/ 4) % ((interval ~/ 4).clamp(1, 6)) == 0;
      case ChartTimeframe.d1:
        return dateTime.weekday == 1 || dateTime.day == 1;
      case ChartTimeframe.w1:
        return dateTime.day <= 7;
      case ChartTimeframe.mn:
        return dateTime.month % 3 == 1;
    }
  }
  
  void _drawTimeLabel(Canvas canvas, double x, double height, String text) {
    _textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: config.textColor,
        fontSize: config.timeLabelFontSize,
        fontWeight: FontWeight.w400,
      ),
    );
    _textPainter.layout();
    
    final labelX = x - _textPainter.width / 2;
    final labelY = (height - _textPainter.height) / 2;
    
    _textPainter.paint(canvas, Offset(labelX, labelY));
  }
  
  @override
  bool shouldRepaint(covariant TimeScalePainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
           oldDelegate.candles.length != candles.length;
  }
}
