import 'package:flutter/material.dart';
import '../../controller/trading_chart_controller.dart';
import '../../data/models/chart_config.dart';
import '../../engine/rendering/time_scale_painter.dart';

/// Widget for rendering the time scale (X-axis)
class TimeScaleWidget extends StatelessWidget {
  final TradingChartController controller;
  final ChartConfig config;
  
  const TimeScaleWidget({
    super.key,
    required this.controller,
    required this.config,
  });
  
  @override
  Widget build(BuildContext context) {
    if (controller.candles.isEmpty) {
      return Container(
        color: config.backgroundColor,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: config.gridLineColor, width: 1),
          ),
        ),
      );
    }
    
    final viewport = controller.viewport;
    final candles = controller.candles;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              color: config.backgroundColor,
              border: Border(
                top: BorderSide(color: config.gridLineColor, width: 1),
              ),
            ),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: TimeScalePainter(
                config: config,
                viewport: viewport,
                candles: candles,
                timeframe: controller.timeframe,
                chartWidth: constraints.maxWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}
