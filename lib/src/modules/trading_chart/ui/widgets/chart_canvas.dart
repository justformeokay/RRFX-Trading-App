import 'package:flutter/material.dart';
import '../../controller/trading_chart_controller.dart';
import '../../data/models/chart_config.dart';
import '../../engine/rendering/candle_painter.dart';
import '../../engine/rendering/grid_painter.dart';
import '../../engine/rendering/indicator_painter.dart';

/// The main chart canvas that renders candles, grid, and indicators
class ChartCanvas extends StatelessWidget {
  final TradingChartController controller;
  final ChartConfig config;
  final double width;
  final double height;
  
  const ChartCanvas({
    super.key,
    required this.controller,
    required this.config,
    required this.width,
    required this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    if (controller.candles.isEmpty) {
      return _buildEmptyState();
    }
    
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: _ChartCompositePainter(
          controller: controller,
          config: config,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No data',
        style: TextStyle(
          color: config.textColor.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Composite painter that renders all chart layers in order
class _ChartCompositePainter extends CustomPainter {
  final TradingChartController controller;
  final ChartConfig config;
  
  _ChartCompositePainter({
    required this.controller,
    required this.config,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final viewport = controller.viewport;
    final candles = controller.candles;
    
    if (candles.isEmpty) return;
    
    // Get visible candles
    final startIndex = viewport.startIndex.clamp(0, candles.length - 1);
    final endIndex = viewport.endIndex.clamp(0, candles.length);
    final visibleCandles = candles.sublist(startIndex, endIndex);
    
    if (visibleCandles.isEmpty) return;
    
    // Create child painters
    final gridPainter = GridPainter(
      config: config,
      viewport: viewport,
      candles: candles,
      timeframe: controller.timeframe,
      chartWidth: size.width,
      chartHeight: size.height,
    );
    
    final candlePainter = CandlePainter(
      config: config,
      viewport: viewport,
      candles: candles,
      chartWidth: size.width,
      chartHeight: size.height,
    );
    
    final indicatorPainter = IndicatorPainter(
      config: config,
      viewport: viewport,
      indicators: controller.indicators,
      totalCandles: candles.length,
      chartWidth: size.width,
      chartHeight: size.height,
    );
    
    // Paint in order: grid -> indicators -> candles
    gridPainter.paint(canvas, size);
    indicatorPainter.paint(canvas, size);
    candlePainter.paint(canvas, size);
  }
  
  @override
  bool shouldRepaint(covariant _ChartCompositePainter oldDelegate) {
    return oldDelegate.controller.viewport != controller.viewport ||
           oldDelegate.controller.candles != controller.candles ||
           oldDelegate.controller.indicators != controller.indicators ||
           oldDelegate.config != config;
  }
}
