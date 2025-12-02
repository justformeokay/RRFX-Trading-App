class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory Candle.fromTick(Map<String, dynamic> data) {
    return Candle(
      time: DateTime.parse(data['created_at']),
      open: data['bid'].toDouble(),
      high: data['bid'].toDouble(),
      low: data['bid'].toDouble(),
      close: data['bid'].toDouble(),
    );
  }
}
