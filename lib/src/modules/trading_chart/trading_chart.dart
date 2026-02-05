/// RRFX Trading Chart Module
/// 
/// A production-grade candlestick chart engine built from scratch
/// with high performance rendering, smooth animations, and professional trading UX.
/// 
/// Features:
/// - Custom candlestick rendering with OHLC data
/// - Real-time updates with smooth animations
/// - Multiple timeframe support (M1, M5, M15, M30, H1, H4, D1, W1, MN)
/// - Technical indicators (SMA, EMA, and extensible for more)
/// - Gesture handling (pan, zoom, crosshair)
/// - Historical data pagination
/// - 60 FPS performance optimized
/// 
/// Architecture:
/// - Data Layer: Models and data providers
/// - Engine Layer: Rendering, gestures, animations
/// - UI Layer: Widgets and overlays
/// 
/// Usage:
/// ```dart
/// TradingChartWidget(
///   controller: TradingChartController(),
///   dataProvider: MyDataProvider(),
///   config: ChartConfig(),
/// )
/// ```

library trading_chart;

// Data Layer - Models
export 'data/models/candle_model.dart';
export 'data/models/indicator_model.dart';
export 'data/models/timeframe_model.dart';
export 'data/models/chart_config.dart';
export 'data/models/viewport_state.dart';

// Data Layer - Providers
export 'data/providers/chart_data_provider.dart';
export 'data/providers/mock_data_provider.dart';

// Engine Layer
export 'engine/rendering/candle_painter.dart';
export 'engine/rendering/indicator_painter.dart';
export 'engine/rendering/grid_painter.dart';
export 'engine/rendering/crosshair_painter.dart';
export 'engine/rendering/price_scale_painter.dart';
export 'engine/rendering/time_scale_painter.dart';

export 'engine/gesture/chart_gesture_handler.dart';
export 'engine/animation/chart_animation_controller.dart';
export 'engine/calculation/indicator_calculator.dart';
export 'engine/calculation/viewport_calculator.dart';

// Controller
export 'controller/trading_chart_controller.dart';

// UI Layer - Widgets
export 'ui/widgets/trading_chart_widget.dart';
export 'ui/widgets/chart_canvas.dart';
export 'ui/widgets/price_scale_widget.dart';
export 'ui/widgets/time_scale_widget.dart';
export 'ui/widgets/timeframe_selector.dart';
export 'ui/widgets/indicator_panel.dart';

// UI Layer - Overlays
export 'ui/overlays/crosshair_overlay.dart';
export 'ui/overlays/loading_overlay.dart';
