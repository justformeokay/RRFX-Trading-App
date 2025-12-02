class TickData {
  final String symbol;
  final double bid;
  final double ask;
  final double bidHigh;
  final double bidLow;
  final double askHigh;
  final double askLow;
  final double spread;

  TickData({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.bidHigh,
    required this.bidLow,
    required this.askHigh,
    required this.askLow,
    required this.spread,
  });

  factory TickData.fromJson(Map<String, dynamic> json) {
    return TickData(
      symbol: json['symbol'],
      bid: (json['bid'] ?? 0).toDouble(),
      ask: (json['ask'] ?? 0).toDouble(),
      bidHigh: (json['bid_high'] ?? 0).toDouble(),
      bidLow: (json['bid_low'] ?? 0).toDouble(),
      askHigh: (json['ask_high'] ?? 0).toDouble(),
      askLow: (json['ask_low'] ?? 0).toDouble(),
      spread: (json['spread'] ?? 0).toDouble()
    );
  }
}
