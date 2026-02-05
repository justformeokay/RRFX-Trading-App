import 'package:flutter/material.dart';
import '../trading_chart.dart';

/// Example screen demonstrating the Trading Chart module usage
class TradingChartExample extends StatefulWidget {
  const TradingChartExample({super.key});
  
  @override
  State<TradingChartExample> createState() => _TradingChartExampleState();
}

class _TradingChartExampleState extends State<TradingChartExample> {
  late TradingChartController _controller;
  ChartTimeframe _selectedTimeframe = ChartTimeframe.h1;
  
  @override
  void initState() {
    super.initState();
    _initializeChart();
  }
  
  Future<void> _initializeChart() async {
    // Create the controller with custom config
    _controller = TradingChartController(
      config: const ChartConfig(
        bullishColor: Color(0xFF26A69A),
        bearishColor: Color(0xFFEF5350),
        backgroundColor: Color(0xFF131722),
        gridColor: Color(0xFF2A2E39),
        textColor: Color(0xFFD1D4DC),
        currentPriceLabelColor: Color(0xFF2962FF),
      ),
    );
    
    // Create mock data provider
    final dataProvider = MockDataProviderFactory.create(
      symbol: 'EURUSD',
      timeframe: _selectedTimeframe,
      initialPrice: 1.0850,
    );
    
    // Initialize with data
    await _controller.initialize(
      dataProvider: dataProvider,
      initialCandleCount: 200,
    );
    
    // Add default indicators
    _controller.addMovingAverage(
      type: MovingAverageType.sma,
      period: 20,
      color: const Color(0xFFFFD700),
    );
    
    _controller.addMovingAverage(
      type: MovingAverageType.ema,
      period: 50,
      color: const Color(0xFF2196F3),
    );
    
    if (mounted) setState(() {});
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTimeframeChanged(ChartTimeframe timeframe) {
    if (timeframe == _selectedTimeframe) return;
    
    setState(() => _selectedTimeframe = timeframe);
    _controller.changeTimeframe(timeframe);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222D),
        title: Row(
          children: [
            const Text(
              'EURUSD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedTimeframe.displayName,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          CompactTimeframeSelector(
            currentTimeframe: _selectedTimeframe,
            onTimeframeChanged: _onTimeframeChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Indicator panel
          IndicatorPanel(
            controller: _controller,
          ),
          
          // Main chart
          Expanded(
            child: TradingChartWidget(
              controller: _controller,
              showPriceScale: true,
              showTimeScale: true,
              priceScaleWidth: 72,
              timeScaleHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative minimal example for quick integration
class MinimalChartExample extends StatelessWidget {
  const MinimalChartExample({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TradingChartController>(
      future: _createController(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return TradingChartWidget(
          controller: snapshot.data!,
        );
      },
    );
  }
  
  Future<TradingChartController> _createController() async {
    final controller = TradingChartController();
    
    final dataProvider = MockDataProviderFactory.create(
      symbol: 'BTCUSD',
      timeframe: ChartTimeframe.h1,
      initialPrice: 45000.0,
    );
    
    await controller.initialize(dataProvider: dataProvider);
    
    return controller;
  }
}
