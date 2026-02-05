import 'package:flutter/material.dart';
import '../../controller/trading_chart_controller.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/candle_model.dart';
import '../../engine/rendering/crosshair_painter.dart';

/// Overlay widget for displaying crosshair and OHLC info
class CrosshairOverlay extends StatelessWidget {
  final TradingChartController controller;
  final ChartConfig config;
  final double width;
  final double height;
  
  const CrosshairOverlay({
    super.key,
    required this.controller,
    required this.config,
    required this.width,
    required this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    final crosshair = controller.crosshair;
    if (!crosshair.isActive) return const SizedBox.shrink();
    
    final candle = crosshair.candleIndex != null 
        ? controller.getCandleAt(crosshair.candleIndex!) 
        : null;
    
    return Stack(
      children: [
        // Crosshair lines
        CustomPaint(
          size: Size(width, height),
          painter: CrosshairPainter(
            config: config,
            crosshair: crosshair,
            chartWidth: width,
            chartHeight: height,
          ),
        ),
        
        // OHLC info panel
        if (candle != null)
          Positioned(
            top: 8,
            left: 8,
            child: _buildOHLCPanel(candle),
          ),
      ],
    );
  }
  
  Widget _buildOHLCPanel(CandleModel candle) {
    final isBullish = candle.isBullish;
    final color = isBullish ? config.bullishColor : config.bearishColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config.backgroundColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: config.gridLineColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriceItem('O', candle.open, color),
          const SizedBox(width: 16),
          _buildPriceItem('H', candle.high, config.bullishColor),
          const SizedBox(width: 16),
          _buildPriceItem('L', candle.low, config.bearishColor),
          const SizedBox(width: 16),
          _buildPriceItem('C', candle.close, color),
          if (candle.volume != null) ...[
            const SizedBox(width: 16),
            _buildVolumeItem(candle.volume!),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPriceItem(String label, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: config.textColor.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _formatPrice(value),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
  
  Widget _buildVolumeItem(double volume) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'V',
          style: TextStyle(
            color: config.textColor.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _formatVolume(volume),
          style: TextStyle(
            color: config.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
  
  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(5);
    }
  }
  
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    }
    return volume.toStringAsFixed(0);
  }
}
