// models/chart_model.dart
import 'package:deriv_chart/deriv_chart.dart';

class OhlcData {
  final int time;
  final double open;
  final double high;
  final double low;
  final double close;

  OhlcData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory OhlcData.fromJson(Map<String, dynamic> json) {
    return OhlcData(
      time: json['time'] as int,
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
    );
  }

  // Konversi ke model Candle untuk deriv_chart
  Candle toCandle() {
    return Candle(
      // Epoch harus dalam detik
      epoch: time,
      open: open,
      high: high,
      low: low,
      close: close,
    );
  }
}

class ChartResponse {
  final List<OhlcData> chartData;
  ChartResponse({required this.chartData});
  factory ChartResponse.fromJson(Map<String, dynamic> json) {
    return ChartResponse(
      chartData: (json['chart_data'] as List)
          .map((i) => OhlcData.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}