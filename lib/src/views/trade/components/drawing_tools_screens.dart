import 'dart:collection';
import 'dart:math';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TickProviders extends GetxController{
  static final Random _random = Random(42); // Fixed seed for reproducible data

  /// Generate a list of sample ticks.
  static List<Tick> generateTicks({int count = 100}) {
    final List<Tick> ticks = [];
    final baseTimestamp = DateTime.now().subtract(Duration(minutes: count)).millisecondsSinceEpoch;
    double lastQuote = 100;

    for (int i = 0; i < count; i++) {
      final timestamp = baseTimestamp + i * 60000; // 1 minute intervals
      lastQuote += (_random.nextDouble() - 0.5) * 2.0;
      ticks.add(Tick(
        epoch: timestamp,
        quote: lastQuote,
      ));
    }

    return ticks;
  }

  /// Generate a list of sample candles.
  static List<Candle> generateCandles({int count = 100}) {
    final List<Candle> candles = [];
    final baseTimestamp =
        DateTime.now().subtract(Duration(hours: count)).millisecondsSinceEpoch;
    double lastClose = 100;

    for (int i = 0; i < count; i++) {
      final timestamp = baseTimestamp + i * 3600000; // 1 hour intervals

      // Generate realistic OHLC data with random walk
      final change = (_random.nextDouble() - 0.5) * 5.0;
      final open = lastClose;
      final close = open + change;
      final high = max(open, close) + _random.nextDouble() * 2.0;
      final low = min(open, close) - _random.nextDouble() * 2.0;

      lastClose = close;

      candles.add(Candle(
        epoch: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        currentEpoch: timestamp,
      ));
    }

    return candles;
  }

  /// Generate sample barriers.
  static List<ChartAnnotation<ChartObject>> generateBarriers(
    List<Tick> ticks, {ChartTheme? theme}) {
      if (ticks.isEmpty) {
        return [];
      }

    final lastTick = ticks.last;
    final quotes = ticks.map((tick) => tick.quote).toList();
    final minQuote = quotes.reduce(min);
    final maxQuote = quotes.reduce(max);
    final midQuote = (minQuote + maxQuote) / 2;

    return [
      // Horizontal barrier at the middle price
      HorizontalBarrier(
        midQuote,
        title: 'Middle',
        style: const HorizontalBarrierStyle(isDashed: false),
        visibility: HorizontalBarrierVisibility.normal,
      ),

      // Vertical barrier at a random tick
      VerticalBarrier.onTick(
        ticks[ticks.length ~/ 2],
        title: 'Mid-point',
        style: const VerticalBarrierStyle(color: BrandColors.orange),
      ),

      // Tick indicator at the last tick
      TickIndicator(
        lastTick,
        style: theme?.currentSpotStyle.copyWith(color: BrandColors.orange),
        visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
      ),
    ];
  }

  /// Generate sample markers.
  static MarkerSeries generateMarkers(List<Tick> ticks) {
    if (ticks.isEmpty) {
      return MarkerSeries(SplayTreeSet<Marker>(), markerIconPainter: MultipliersMarkerIconPainter());
    }

    final markers = SplayTreeSet<Marker>();

    // Add some up and down markers at strategic points
    for (int i = 10; i < ticks.length; i += 20) {
      final direction =
      i % 40 == 10 ? MarkerDirection.up : MarkerDirection.down;
      markers.add(Marker(
        direction: direction,
        epoch: ticks[i].epoch,
        quote: ticks[i].quote,
        onTap: () {},
      ));
    }

    return MarkerSeries(markers, markerIconPainter: MultipliersMarkerIconPainter());
  }
}

/// Base class for all chart example screens.
abstract class BaseChartScreen extends StatefulWidget {
  /// Initialize the base chart screen.
  const BaseChartScreen({super.key});
}

/// Base state class for all chart example screens.
abstract class BaseChartScreenState<T extends BaseChartScreen>
    extends State<T> {
  /// The chart controller.
  final ChartController controller = ChartController();

  /// The chart data.
  late List<Tick> ticks;

  /// The chart candles.
  late List<Candle> candles;

  @override
  void initState() {
    super.initState();
    ticks = TickProviders.generateTicks();
    candles = TickProviders.generateCandles();
  }

  /// Build the chart widget.
  Widget buildChart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: buildChart(),
          ),
          buildControls(),
        ],
      ),
    );
  }

  /// Get the title of the chart screen.
  String getTitle();

  /// Build the controls for the chart.
  Widget buildControls() {
    return const SizedBox(height: 50);
  }
}

/// Screen that displays information about drawing tools.
class DrawingToolsScreen extends BaseChartScreen {
  /// Initialize the drawing tools screen.
  const DrawingToolsScreen({super.key});

  @override
  State<DrawingToolsScreen> createState() => _DrawingToolsScreenState();
}

class _DrawingToolsScreenState extends BaseChartScreenState<DrawingToolsScreen> {
  final DrawingTools _drawingTools = DrawingTools();
  late final Repository<DrawingToolConfig> _drawingToolsRepo;
  DrawingToolConfig? _selectedDrawingTool;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize in the next frame to ensure all dependencies are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDrawingTools();
    });
  }

  void _initializeDrawingTools() {
    if (_isInitialized) {
      return;
    }

    setState(() {
      _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
        createAddOn: (Map<String, dynamic> map) =>
            DrawingToolConfig.fromJson(map),
        sharedPrefKey: 'drawing_tools_screen',
      );

      _drawingTools.drawingToolsRepo = _drawingToolsRepo;
      _isInitialized = true;
    });
  }

  @override
  String getTitle() => 'Drawing Tools';

  @override
  Widget buildChart() {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return DerivChart(
      key: const Key('drawing_tools_chart'),
      mainSeries: LineSeries(ticks, style: const LineStyle(hasArea: true)),
      controller: controller,
      pipSize: 2,
      granularity: 60000, // 1 minute
      activeSymbol: 'DRAWING_TOOLS_CHART',
      drawingTools: _drawingTools,
      drawingToolsRepo: _drawingToolsRepo,
      theme: ChartDefaultDarkTheme(),
    );
  }

  void _showDrawingToolsDialog() {
    if (!_isInitialized) {
      return;
    }

    _drawingTools.init();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: DrawingToolsDialog(
          drawingTools: _drawingTools,
        ),
      ),
    );
  }

  void _addDrawingTool() {
    if (!_isInitialized || _selectedDrawingTool == null) {
      return;
    }

    _drawingTools.onDrawingToolSelection(_selectedDrawingTool!);
    _drawingToolsRepo.update();
    setState(() {
      _selectedDrawingTool = null;
    });
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Drawing Tools',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          if (!_isInitialized)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing drawing tools...'),
                ],
              ),
            )
          else
            Column(
              children: [
                // Drawing tool selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<DrawingToolConfig>(
                      value: _selectedDrawingTool,
                      hint: const Text('Select a drawing tool'),
                      items: const <DropdownMenuItem<DrawingToolConfig>>[
                        DropdownMenuItem<DrawingToolConfig>(
                          value: LineDrawingToolConfig(),
                          child: Text('Line'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: HorizontalDrawingToolConfig(),
                          child: Text('Horizontal'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: VerticalDrawingToolConfig(),
                          child: Text('Vertical'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: RayDrawingToolConfig(),
                          child: Text('Ray'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: TrendDrawingToolConfig(),
                          child: Text('Trend'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: RectangleDrawingToolConfig(),
                          child: Text('Rectangle'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: ChannelDrawingToolConfig(),
                          child: Text('Channel'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: FibfanDrawingToolConfig(),
                          child: Text('Fibonacci Fan'),
                        ),
                      ],
                      onChanged: (DrawingToolConfig? config) {
                        setState(() {
                          _selectedDrawingTool = config;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed:
                      _selectedDrawingTool != null ? _addDrawingTool : null,
                      child: const Text('Add'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Manage drawings button
                ElevatedButton.icon(
                  onPressed: _showDrawingToolsDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Manage Drawings'),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Instructions
          const Text(
            'Select a drawing tool from the dropdown and click "Add" to start drawing on the chart. '
                'Tap on the chart to place points for your drawing. '
                'Click "Manage Drawings" to edit or delete existing drawings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 16),

          // Available tools
          const Text(
            'Available Drawing Tools:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildToolChip('Line', Icons.show_chart),
              _buildToolChip('Horizontal', Icons.horizontal_rule),
              _buildToolChip('Vertical', Icons.vertical_align_center),
              _buildToolChip('Ray', Icons.trending_up),
              _buildToolChip('Trend', Icons.timeline),
              _buildToolChip('Rectangle', Icons.crop_square),
              _buildToolChip('Channel', Icons.view_stream),
              _buildToolChip('Fibonacci Fan', Icons.filter_tilt_shift),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}