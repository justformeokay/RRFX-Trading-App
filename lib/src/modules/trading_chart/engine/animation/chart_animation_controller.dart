import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Animation controller for smooth chart scrolling and transitions
class ChartAnimationController {
  late Ticker _ticker;
  
  // Inertia scrolling
  double _velocity = 0;
  double _scrollOffset = 0;
  double _friction = 0.95;
  bool _isScrolling = false;
  
  // Transition animation
  bool _isTransitioning = false;
  double _transitionProgress = 0;
  double _transitionStart = 0;
  double _transitionEnd = 0;
  Duration _transitionDuration = const Duration(milliseconds: 300);
  DateTime? _transitionStartTime;
  
  // Callbacks
  void Function(double delta)? onScrollUpdate;
  void Function()? onScrollEnd;
  void Function(double progress)? onTransitionUpdate;
  void Function()? onTransitionEnd;
  
  ChartAnimationController(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
  }
  
  void _onTick(Duration elapsed) {
    if (_isScrolling) {
      _updateScroll();
    }
    
    if (_isTransitioning) {
      _updateTransition(elapsed);
    }
    
    if (!_isScrolling && !_isTransitioning) {
      _ticker.stop();
    }
  }
  
  void _updateScroll() {
    if (_velocity.abs() < 0.1) {
      _isScrolling = false;
      onScrollEnd?.call();
      return;
    }
    
    // Apply friction
    _velocity *= _friction;
    _scrollOffset += _velocity;
    
    onScrollUpdate?.call(_velocity);
  }
  
  void _updateTransition(Duration elapsed) {
    if (_transitionStartTime == null) return;
    
    final elapsedMs = DateTime.now().difference(_transitionStartTime!).inMilliseconds;
    final progress = (elapsedMs / _transitionDuration.inMilliseconds).clamp(0.0, 1.0);
    
    // Ease out cubic
    final easedProgress = 1 - ((1 - progress) * (1 - progress) * (1 - progress));
    _transitionProgress = easedProgress;
    
    final currentValue = _transitionStart + ((_transitionEnd - _transitionStart) * easedProgress);
    onTransitionUpdate?.call(currentValue);
    
    if (progress >= 1.0) {
      _isTransitioning = false;
      onTransitionEnd?.call();
    }
  }
  
  /// Start inertia scrolling
  void startInertiaScroll(double velocity, {double friction = 0.95}) {
    _velocity = velocity * 0.016; // Convert to per-frame
    _friction = friction;
    _isScrolling = true;
    
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }
  
  /// Stop inertia scrolling
  void stopScroll() {
    _isScrolling = false;
    _velocity = 0;
  }
  
  /// Start a smooth transition animation
  void startTransition({
    required double from,
    required double to,
    Duration duration = const Duration(milliseconds: 300),
    void Function(double value)? onUpdate,
    void Function()? onComplete,
  }) {
    _transitionStart = from;
    _transitionEnd = to;
    _transitionDuration = duration;
    _transitionStartTime = DateTime.now();
    _transitionProgress = 0;
    _isTransitioning = true;
    
    onTransitionUpdate = onUpdate;
    onTransitionEnd = onComplete;
    
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }
  
  /// Stop transition
  void stopTransition() {
    _isTransitioning = false;
    _transitionStartTime = null;
  }
  
  /// Check if any animation is active
  bool get isAnimating => _isScrolling || _isTransitioning;
  
  /// Get current scroll velocity
  double get currentVelocity => _velocity;
  
  /// Dispose resources
  void dispose() {
    _ticker.dispose();
  }
}

/// Specialized animation for candle transitions
class CandleAnimationController {
  final Map<int, double> _animationProgress = {};
  late Ticker _ticker;
  bool _isActive = false;
  
  void Function()? onUpdate;
  
  CandleAnimationController(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
  }
  
  void _onTick(Duration elapsed) {
    bool hasActiveAnimations = false;
    
    final toRemove = <int>[];
    
    _animationProgress.forEach((index, progress) {
      if (progress < 1.0) {
        _animationProgress[index] = (progress + 0.1).clamp(0.0, 1.0);
        hasActiveAnimations = true;
      } else {
        toRemove.add(index);
      }
    });
    
    for (final index in toRemove) {
      _animationProgress.remove(index);
    }
    
    if (hasActiveAnimations) {
      onUpdate?.call();
    } else {
      _isActive = false;
      _ticker.stop();
    }
  }
  
  /// Start animation for a new candle
  void animateCandle(int index) {
    _animationProgress[index] = 0.0;
    
    if (!_isActive) {
      _isActive = true;
      _ticker.start();
    }
  }
  
  /// Get animation progress for a candle (0.0 - 1.0)
  double getProgress(int index) {
    return _animationProgress[index] ?? 1.0;
  }
  
  /// Check if candle is animating
  bool isAnimating(int index) {
    return _animationProgress.containsKey(index) && _animationProgress[index]! < 1.0;
  }
  
  void dispose() {
    _ticker.dispose();
  }
}
