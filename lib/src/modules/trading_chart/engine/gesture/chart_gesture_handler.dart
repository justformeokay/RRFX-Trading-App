import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import '../../data/models/chart_config.dart';

/// Handles all gesture interactions for the trading chart
/// Supports pan, zoom, and long press for crosshair
class ChartGestureHandler {
  final ChartConfig config;
  
  // Callbacks
  final void Function(double delta) onHorizontalDrag;
  final void Function(double scale, double focalX)? onScale;
  final void Function(Offset position)? onLongPressStart;
  final void Function(Offset position)? onLongPressMove;
  final void Function()? onLongPressEnd;
  final void Function()? onTap;
  final void Function(double velocity)? onFling;
  final void Function()? onLoadMore;
  
  // State
  double _lastFocalX = 0;
  double _lastScale = 1.0;
  bool _isScaling = false;
  Offset _panStartPosition = Offset.zero;
  DateTime _panStartTime = DateTime.now();
  
  ChartGestureHandler({
    required this.config,
    required this.onHorizontalDrag,
    this.onScale,
    this.onLongPressStart,
    this.onLongPressMove,
    this.onLongPressEnd,
    this.onTap,
    this.onFling,
    this.onLoadMore,
  });
  
  /// Create gesture recognizers for the chart
  Map<Type, GestureRecognizerFactory> buildGestureRecognizers() {
    return <Type, GestureRecognizerFactory>{
      // Scale gesture for zoom
      ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(),
        (ScaleGestureRecognizer instance) {
          instance
            ..onStart = _onScaleStart
            ..onUpdate = _onScaleUpdate
            ..onEnd = _onScaleEnd;
        },
      ),
      
      // Long press for crosshair
      LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 300)),
        (LongPressGestureRecognizer instance) {
          instance
            ..onLongPressStart = _onLongPressStart
            ..onLongPressMoveUpdate = _onLongPressMoveUpdate
            ..onLongPressEnd = _onLongPressEnd;
        },
      ),
      
      // Tap gesture
      TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer instance) {
          instance.onTap = _onTap;
        },
      ),
    };
  }
  
  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalX = details.focalPoint.dx;
    _lastScale = 1.0;
    _isScaling = details.pointerCount > 1;
    _panStartPosition = details.focalPoint;
    _panStartTime = DateTime.now();
  }
  
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isScaling || details.pointerCount > 1) {
      // Zoom
      _isScaling = true;
      final scale = details.scale / _lastScale;
      _lastScale = details.scale;
      onScale?.call(scale, details.focalPoint.dx);
    } else {
      // Pan
      final delta = details.focalPoint.dx - _lastFocalX;
      _lastFocalX = details.focalPoint.dx;
      onHorizontalDrag(delta);
    }
  }
  
  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isScaling && config.enableInertia) {
      // Calculate fling velocity for inertia
      final velocity = details.velocity.pixelsPerSecond.dx;
      if (velocity.abs() > 100) {
        onFling?.call(velocity);
      }
    }
    _isScaling = false;
  }
  
  void _onLongPressStart(LongPressStartDetails details) {
    if (config.enableCrosshair) {
      onLongPressStart?.call(details.localPosition);
    }
  }
  
  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (config.enableCrosshair) {
      onLongPressMove?.call(details.localPosition);
    }
  }
  
  void _onLongPressEnd(LongPressEndDetails details) {
    if (config.enableCrosshair) {
      onLongPressEnd?.call();
    }
  }
  
  void _onTap() {
    onTap?.call();
  }
}

/// Physics simulation for inertia scrolling
class ChartScrollPhysics {
  final double friction;
  
  FrictionSimulation? _simulation;
  double _lastPosition = 0;
  
  ChartScrollPhysics({
    this.friction = 0.015,
  });
  
  /// Start inertia scrolling with initial velocity
  void startFling(double velocity, double currentPosition) {
    _lastPosition = currentPosition;
    _simulation = FrictionSimulation(
      friction,
      currentPosition,
      velocity,
    );
  }
  
  /// Get the scroll position at given time
  /// Returns null when simulation is complete
  double? getPositionAt(double time) {
    if (_simulation == null) return null;
    
    if (_simulation!.isDone(time)) {
      _simulation = null;
      return null;
    }
    
    final position = _simulation!.x(time);
    final delta = position - _lastPosition;
    _lastPosition = position;
    
    return delta;
  }
  
  /// Stop any ongoing animation
  void stop() {
    _simulation = null;
  }
  
  /// Check if animation is active
  bool get isAnimating => _simulation != null;
}
