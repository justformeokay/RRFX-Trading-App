// models/ticker_model.dart

class Ticker {
  final String symbol;
  final double bid;
  final double ask;
  final int digits;
  final int spread;

  Ticker({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.spread,
    required this.digits,
  });

  factory Ticker.fromJson(Map<String, dynamic> json) {
    return Ticker(
      symbol: json['symbol'] as String,
      bid: (json['bid'] as num).toDouble(),
      ask: (json['ask'] as num).toDouble(),
      digits: (json['digits'] as num).toInt(),
      spread: (json['spread'] as num).toInt(), 
    );
  }
}