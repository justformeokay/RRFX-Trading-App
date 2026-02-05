import 'package:flutter/material.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/viewport_state.dart';
import '../../data/models/candle_model.dart';

/// Painter for price scale (Y-axis)
class PriceScalePainter extends CustomPainter {
  final ViewportState viewport;
  final ChartConfig config;
  final double chartHeight;
  final CandleModel? latestCandle;
  final double? bidPrice;
  final double? askPrice;
  
  late final Paint _textBackgroundPaint;
  late final Paint _currentPriceBackgroundPaint;
  late final Paint _bidBackgroundPaint;
  late final Paint _askBackgroundPaint;
  late final TextPainter _textPainter;
  
  PriceScalePainter({
    required this.viewport,
    required this.config,
    required this.chartHeight,
    this.latestCandle,
    this.bidPrice,
    this.askPrice,
  }) {
    _textBackgroundPaint = Paint()
      ..color = config.backgroundColor
      ..style = PaintingStyle.fill;
    
    _currentPriceBackgroundPaint = Paint()
      ..color = config.currentPriceLineColor
      ..style = PaintingStyle.fill;
    
    _bidBackgroundPaint = Paint()
      ..color = config.bidLineColor
      ..style = PaintingStyle.fill;
    
    _askBackgroundPaint = Paint()
      ..color = config.askLineColor
      ..style = PaintingStyle.fill;
    
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (viewport.priceRange == 0) return;
    
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, chartHeight),
      _textBackgroundPaint,
    );
    
    // Draw separator line
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, chartHeight),
      Paint()
        ..color = config.gridColor
        ..strokeWidth = 1,
    );
    
    // Draw price labels
    _drawPriceLabels(canvas, size);
    
    // Draw current price label
    if (latestCandle != null && config.showCurrentPriceLine) {
      _drawCurrentPriceLabel(canvas, size, latestCandle!.close);
    }
    
    // Draw bid/ask labels
    if (config.showBidAskLines) {
      if (bidPrice != null) {
        _drawBidAskLabel(canvas, size, bidPrice!, true);
      }
      if (askPrice != null) {
        _drawBidAskLabel(canvas, size, askPrice!, false);
      }
    }
  }
  
  void _drawPriceLabels(Canvas canvas, Size size) {
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    final gridCount = config.horizontalGridLines;
    final priceStep = viewport.priceRange / (gridCount + 1);
    
    for (int i = 0; i <= gridCount + 1; i++) {
      final price = viewport.maxPrice - (i * priceStep);
      final y = config.chartPadding.top + (i * availableHeight / (gridCount + 1));
      
      _drawPriceLabel(canvas, size, price, y, config.textColor);
    }
  }
  
  void _drawPriceLabel(Canvas canvas, Size size, double price, double y, Color color) {
    final priceText = _formatPrice(price);
    
    _textPainter.text = TextSpan(
      text: priceText,
      style: TextStyle(
        color: color,
        fontSize: config.priceLabelFontSize,
        fontWeight: FontWeight.w400,
      ),
    );
    _textPainter.layout(maxWidth: size.width - 8);
    
    _textPainter.paint(
      canvas,
      Offset(4, y - _textPainter.height / 2),
    );
  }
  
  void _drawCurrentPriceLabel(Canvas canvas, Size size, double price) {
    final y = _priceToY(price);
    if (y < 0 || y > chartHeight) return;
    
    final priceText = _formatPrice(price);
    
    _textPainter.text = TextSpan(
      text: priceText,
      style: TextStyle(
        color: Colors.white,
        fontSize: config.priceLabelFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
    _textPainter.layout(maxWidth: size.width - 8);
    
    final labelHeight = _textPainter.height + 6;
    final labelY = y - labelHeight / 2;
    
    // Draw background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, labelY, size.width - 4, labelHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(labelRect, _currentPriceBackgroundPaint);
    
    // Draw text
    _textPainter.paint(
      canvas,
      Offset(4, labelY + 3),
    );
  }
  
  void _drawBidAskLabel(Canvas canvas, Size size, double price, bool isBid) {
    final y = _priceToY(price);
    if (y < 0 || y > chartHeight) return;
    
    final priceText = _formatPrice(price);
    
    _textPainter.text = TextSpan(
      text: priceText,
      style: TextStyle(
        color: Colors.white,
        fontSize: config.priceLabelFontSize - 1,
        fontWeight: FontWeight.w500,
      ),
    );
    _textPainter.layout(maxWidth: size.width - 8);
    
    final labelHeight = _textPainter.height + 4;
    final labelY = y - labelHeight / 2;
    
    // Draw background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, labelY, size.width - 4, labelHeight),
      const Radius.circular(2),
    );
    canvas.drawRRect(labelRect, isBid ? _bidBackgroundPaint : _askBackgroundPaint);
    
    // Draw text
    _textPainter.paint(
      canvas,
      Offset(4, labelY + 2),
    );
  }
  
  double _priceToY(double price) {
    final availableHeight = chartHeight - config.chartPadding.top - config.chartPadding.bottom;
    return config.chartPadding.top + ((viewport.maxPrice - price) / viewport.priceRange) * availableHeight;
  }
  
  String _formatPrice(double price) {
    return price.toStringAsFixed(config.priceDecimals);
  }
  
  @override
  bool shouldRepaint(covariant PriceScalePainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
           oldDelegate.latestCandle != latestCandle ||
           oldDelegate.bidPrice != bidPrice ||
           oldDelegate.askPrice != askPrice;
  }
}
