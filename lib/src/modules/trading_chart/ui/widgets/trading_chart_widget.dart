import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../controller/trading_chart_controller.dart';
import '../../data/models/chart_config.dart';
import '../../engine/gesture/chart_gesture_handler.dart';
import '../../engine/animation/chart_animation_controller.dart';
import 'chart_canvas.dart';
import 'time_scale_widget.dart';
import 'price_scale_widget.dart';
import '../overlays/crosshair_overlay.dart';
import '../overlays/loading_overlay.dart';

/// Main trading chart widget
/// This is the entry point for displaying the trading chart
class TradingChartWidget extends StatefulWidget {
  /// The chart controller that manages state
  final TradingChartController controller;
  
  /// Optional configuration override
  final ChartConfig? config;
  
  /// Whether to show the price scale (Y-axis)
  final bool showPriceScale;
  
  /// Whether to show the time scale (X-axis)
  final bool showTimeScale;
  
  /// Whether to enable gestures
  final bool enableGestures;
  
  /// Price scale width
  final double priceScaleWidth;
  
  /// Time scale height
  final double timeScaleHeight;
  
  /// Callback when candle is selected via crosshair
  final ValueChanged<int?>? onCandleSelected;
  
  const TradingChartWidget({
    super.key,
    required this.controller,
    this.config,
    this.showPriceScale = true,
    this.showTimeScale = true,
    this.enableGestures = true,
    this.priceScaleWidth = 80,
    this.timeScaleHeight = 30,
    this.onCandleSelected,
  });
  
  @override
  State<TradingChartWidget> createState() => _TradingChartWidgetState();
}

class _TradingChartWidgetState extends State<TradingChartWidget>
    with SingleTickerProviderStateMixin {
  late ChartGestureHandler _gestureHandler;
  late ChartAnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = ChartAnimationController(this);
    _animationController.onScrollUpdate = _onAnimationUpdate;
    _animationController.onScrollEnd = () {};
    
    _gestureHandler = ChartGestureHandler(
      config: _effectiveConfig,
      onHorizontalDrag: _handleScroll,
      onScale: _handleZoom,
      onLongPressStart: widget.controller.onCrosshairStart,
      onLongPressMove: widget.controller.onCrosshairMove,
      onLongPressEnd: widget.controller.onCrosshairEnd,
      onFling: _handleScrollEnd,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  ChartConfig get _effectiveConfig => widget.config ?? widget.controller.config;
  
  void _handleScroll(double delta) {
    _animationController.stopScroll();
    widget.controller.onScroll(delta);
  }
  
  void _handleScrollEnd(double velocity) {
    if (_effectiveConfig.enableInertiaScroll && velocity.abs() > 100) {
      _animationController.startInertiaScroll(
        velocity,
        friction: _effectiveConfig.inertiaFriction,
      );
    }
  }
  
  void _handleZoom(double scale, double focalX) {
    _animationController.stopScroll();
    widget.controller.onZoom(scale, focalX);
  }
  
  void _onAnimationUpdate(double delta) {
    widget.controller.onScroll(delta);
  }
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate chart area dimensions
            final chartWidth = constraints.maxWidth -
                (widget.showPriceScale ? widget.priceScaleWidth : 0);
            final chartHeight = constraints.maxHeight -
                (widget.showTimeScale ? widget.timeScaleHeight : 0);
            
            // Update controller with dimensions
            widget.controller.setDimensions(chartWidth, chartHeight);
            
            return Container(
              color: _effectiveConfig.backgroundColor,
              child: Column(
                children: [
                  // Main chart row
                  Expanded(
                    child: Row(
                      children: [
                        // Chart canvas
                        Expanded(
                          child: _buildChartArea(chartWidth, chartHeight),
                        ),
                        
                        // Price scale
                        if (widget.showPriceScale)
                          SizedBox(
                            width: widget.priceScaleWidth,
                            child: PriceScaleWidget(
                              controller: widget.controller,
                              config: _effectiveConfig,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Time scale
                  if (widget.showTimeScale)
                    SizedBox(
                      height: widget.timeScaleHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: TimeScaleWidget(
                              controller: widget.controller,
                              config: _effectiveConfig,
                            ),
                          ),
                          if (widget.showPriceScale)
                            SizedBox(width: widget.priceScaleWidth),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildChartArea(double width, double height) {
    Widget chart = Stack(
      children: [
        // Main chart canvas
        ChartCanvas(
          controller: widget.controller,
          config: _effectiveConfig,
          width: width,
          height: height,
        ),
        
        // Crosshair overlay
        if (widget.controller.crosshair.isActive)
          CrosshairOverlay(
            controller: widget.controller,
            config: _effectiveConfig,
            width: width,
            height: height,
          ),
        
        // Loading overlay
        if (widget.controller.isLoading)
          LoadingOverlay(config: _effectiveConfig),
        
        // Loading more indicator
        if (widget.controller.isLoadingMore)
          Positioned(
            left: 8,
            top: height / 2 - 12,
            child: _buildLoadingMoreIndicator(),
          ),
      ],
    );
    
    // Wrap with gesture detector if enabled
    if (widget.enableGestures) {
      chart = _buildGestureDetector(chart, width, height);
    }
    
    return ClipRect(child: chart);
  }
  
  Widget _buildGestureDetector(Widget child, double width, double height) {
    return Listener(
      onPointerSignal: (event) {
        // Handle mouse wheel zoom
        if (event is PointerScrollEvent) {
          final scale = event.scrollDelta.dy > 0 ? 0.95 : 1.05;
          _handleZoom(scale, event.localPosition.dx);
        }
      },
      child: RawGestureDetector(
        gestures: _gestureHandler.buildGestureRecognizers(),
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onDoubleTap: () {
            widget.controller.scrollToLatest();
          },
          behavior: HitTestBehavior.translucent,
          child: child,
        ),
      ),
    );
  }
  
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _effectiveConfig.backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _effectiveConfig.gridLineColor,
          width: 1,
        ),
      ),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _effectiveConfig.textColor,
          ),
        ),
      ),
    );
  }
}
