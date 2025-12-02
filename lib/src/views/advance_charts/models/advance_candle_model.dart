class AdvanceCandleModel {
  final int epoch;
  final double open;
  final double high;
  final double low;
  final double close;

  AdvanceCandleModel({
    required this.epoch,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory AdvanceCandleModel.fromJson(Map<String, dynamic> json) {
    return AdvanceCandleModel(
      epoch: json['time'], // already unix seconds
      open: json['open'].toDouble(),
      high: json['high'].toDouble(),
      low: json['low'].toDouble(),
      close: json['close'].toDouble(),
    );
  }
}
