class CandleData {
  final int epoch;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.epoch,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      epoch: DateTime.parse(json['time']).millisecondsSinceEpoch ~/ 1000,
      open: (json['open'] ?? 0).toDouble(),
      high: (json['high'] ?? 0).toDouble(),
      low: (json['low'] ?? 0).toDouble(),
      close: (json['close'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'epoch': epoch,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
      };
}
