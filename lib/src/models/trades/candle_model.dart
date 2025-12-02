class CandleModel {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  CandleModel({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandleModel.fromJson(Map<String, dynamic> json) {
    return CandleModel(
      time: DateTime.parse(json['time']),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: json['tickVolume'] as int,
    );
  }
}
