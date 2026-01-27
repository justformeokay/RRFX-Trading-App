class MarketMt5Model {
  // Data dari WebSocket
  final String symbol;
  final int datetimeMsc;
  final double bid;
  final double ask;
  final double spread;
  final double bidHigh;
  final double bidLow;
  final double askHigh;
  final double askLow;
  final int digits;

  // Data tambahan untuk logika warna
  double previousBid;
  double previousAsk;

  MarketMt5Model({
    required this.symbol,
    required this.datetimeMsc,
    required this.bid,
    required this.ask,
    required this.spread,
    required this.bidHigh,
    required this.bidLow,
    required this.askHigh,
    required this.askLow,
    required this.digits,
    // Saat inisialisasi, previous price sama dengan current price
    // agar warna awal netral/tidak diwarnai
    double? initialPreviousBid,
    double? initialPreviousAsk,
  })  : previousBid = initialPreviousBid ?? bid,
        previousAsk = initialPreviousAsk ?? ask;

  // Factory untuk membuat objek dari JSON WebSocket
  factory MarketMt5Model.fromJson(Map<String, dynamic> json) {
    return MarketMt5Model(
      symbol: json['symbol'] as String,
      datetimeMsc: json['datetime_msc'] as int,
      bid: (json['bid'] as num).toDouble(),
      ask: (json['ask'] as num).toDouble(),
      spread: (json['spread'] as num).toDouble(),
      bidHigh: (json['bid_high'] as num).toDouble(),
      bidLow: (json['bid_low'] as num).toDouble(),
      askHigh: (json['ask_high'] as num).toDouble(),
      askLow: (json['ask_low'] as num).toDouble(),
      digits: json['digits'] as int,
    );
  }

  // Fungsi untuk mengupdate model dengan data baru sambil menyimpan data lama
  MarketMt5Model updateWithNewData(MarketMt5Model newData) {
    // Simpan harga bid/ask saat ini ke previous sebelum mengganti
    previousBid = bid;
    previousAsk = ask;

    return MarketMt5Model(
      symbol: newData.symbol,
      datetimeMsc: newData.datetimeMsc,
      bid: newData.bid,
      ask: newData.ask,
      spread: newData.spread,
      bidHigh: newData.bidHigh,
      bidLow: newData.bidLow,
      askHigh: newData.askHigh,
      askLow: newData.askLow,
      // Pertahankan harga previous yang baru disimpan
      initialPreviousBid: previousBid,
      initialPreviousAsk: previousAsk,
      digits: newData.digits,
    );
  }

  // Method untuk convert ke JSON (untuk caching)
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'datetime_msc': datetimeMsc,
      'bid': bid,
      'ask': ask,
      'spread': spread,
      'bid_high': bidHigh,
      'bid_low': bidLow,
      'ask_high': askHigh,
      'ask_low': askLow,
      'digits': digits,
    };
  }
}