import 'package:flutter/material.dart';
import '../../controller/trading_chart_controller.dart';
import '../../data/models/chart_config.dart';
import '../../engine/rendering/price_scale_painter.dart';

/// Widget for rendering the price scale (Y-axis)
class PriceScaleWidget extends StatelessWidget {
  final TradingChartController controller;
  final ChartConfig config;
  
  const PriceScaleWidget({
    super.key,
    required this.controller,
    required this.config,
  });
  
  @override
  Widget build(BuildContext context) {
    if (controller.candles.isEmpty) {
      return Container(
        color: config.backgroundColor,
        child: const SizedBox.expand(),
      );
    }
    
    final viewport = controller.viewport;
    final candles = controller.candles;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: PriceScalePainter(
              config: config,
              viewport: viewport,
              chartHeight: constraints.maxHeight,
              latestCandle: candles.isNotEmpty ? candles.last : null,
            ),
          ),
        );
      },
    );
  }
}
