import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/modules/trading_chart/trading_chart.dart';

/// Sample page for testing the Trading Chart module
class TradingChartSamplePage extends StatefulWidget {
  const TradingChartSamplePage({super.key});

  @override
  State<TradingChartSamplePage> createState() => _TradingChartSamplePageState();
}

class _TradingChartSamplePageState extends State<TradingChartSamplePage> {
  late TradingChartController _chartController;
  ChartTimeframe _selectedTimeframe = ChartTimeframe.h1;
  String _selectedSymbol = 'EURUSD';
  bool _isInitialized = false;
  bool _hasInitialized = false;
  String? _errorMessage;

  final List<String> _availableSymbols = [
    'EURUSD',
    'GBPUSD',
    'USDJPY',
    'XAUUSD',
    'BTCUSD',
    'ETHUSD',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initializeChart();
    }
  }

  Future<void> _initializeChart() async {
    try {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _errorMessage = null;
        });
      }

      // Create controller with theme config
      _chartController = TradingChartController(
        config: ChartConfig(
          bullishColor: const Color(0xFF26A69A),
          bearishColor: const Color(0xFFEF5350),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E222D)
              : const Color(0xFFFFFFFF),
          gridColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2E39)
              : const Color(0xFFE0E3EB),
          textColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFD1D4DC)
              : const Color(0xFF131722),
          currentPriceLabelColor: CustomColor.secondaryColor,
          crosshairColor: const Color(0xFF9598A1),
        ),
      );

      // Create mock data provider
      final dataProvider = MockDataProviderFactory.create(
        symbol: _selectedSymbol,
        timeframe: _selectedTimeframe,
      );

      // Initialize with data
      await _chartController.initialize(
        dataProvider: dataProvider,
        initialCandleCount: 200,
      );

      // Add default indicators
      _chartController.addMovingAverage(
        type: MovingAverageType.sma,
        period: 20,
        color: const Color(0xFFFFD700),
      );

      _chartController.addMovingAverage(
        type: MovingAverageType.ema,
        period: 50,
        color: CustomColor.secondaryColor,
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize chart: $e';
          _isInitialized = false;
        });
      }
    }
  }

  void _onTimeframeChanged(ChartTimeframe timeframe) {
    if (timeframe == _selectedTimeframe) return;
    setState(() => _selectedTimeframe = timeframe);
    _chartController.changeTimeframe(timeframe);
  }

  void _onSymbolChanged(String? symbol) {
    if (symbol == null || symbol == _selectedSymbol) return;
    setState(() {
      _selectedSymbol = symbol;
      _hasInitialized = false;
    });
    _initializeChart();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _chartController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Trading Chart Sample",
        actions: [
          // Symbol selector
          PopupMenuButton<String>(
            initialValue: _selectedSymbol,
            onSelected: _onSymbolChanged,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedSymbol,
                  style: TextStyle(
                    color: CustomColor.secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: CustomColor.secondaryColor,
                ),
              ],
            ),
            itemBuilder: (context) => _availableSymbols
                .map((symbol) => PopupMenuItem(
                      value: symbol,
                      child: Text(symbol),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timeframe selector
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222D) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE0E3EB),
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ChartTimeframe.values.length,
              itemBuilder: (context, index) {
                final timeframe = ChartTimeframe.values[index];
                final isSelected = timeframe == _selectedTimeframe;

                return GestureDetector(
                  onTap: () => _onTimeframeChanged(timeframe),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CustomColor.secondaryColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? CustomColor.secondaryColor
                            : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      timeframe.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? CustomColor.secondaryColor
                            : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicator panel
          if (_isInitialized)
            IndicatorPanel(
              controller: _chartController,
              config: _chartController.config,
            ),

          // Chart area
          Expanded(
            child: _buildChartArea(),
          ),

          // Info panel
          _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildChartArea() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.warning_2_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeChart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: CustomColor.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading chart data...',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return TradingChartWidget(
      controller: _chartController,
      showPriceScale: true,
      showTimeScale: true,
      priceScaleWidth: 72,
      timeScaleHeight: 28,
    );
  }

  Widget _buildInfoPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE0E3EB),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle_outline,
                size: 16,
                color: CustomColor.secondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Trading Chart Module Test',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Swipe left/right to scroll through history\n'
            '• Pinch to zoom in/out\n'
            '• Long press for crosshair & OHLC info\n'
            '• Double tap to jump to latest candle\n'
            '• This uses mock data for demonstration',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
