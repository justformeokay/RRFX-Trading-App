import 'dart:convert';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

enum WebSocketStatus { connecting, connected, failed }

class TickModel {
  final String symbol;
  final double bid;
  final double ask;
  final DateTime datetime;

  TickModel({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.datetime,
  });

  factory TickModel.fromJson(Map<String, dynamic> json) {
    return TickModel(
      symbol: json['symbol'],
      bid: double.parse(json['bid'].toString()),
      ask: double.parse(json['ask'].toString()),
      datetime: DateTime.parse(json['timestamp']),
    );
  }
}


class MarketDataModel {
  final String symbol;
  final double bid;
  final double bidHigh;
  final double bidLow;
  final double ask;
  final double askHigh;
  final double askLow;
  final int datetime;
  final String direction;

  MarketDataModel({
    required this.symbol,
    required this.bid,
    required this.bidHigh,
    required this.bidLow,
    required this.ask,
    required this.askHigh,
    required this.askLow,
    required this.datetime,
    required this.direction,
  });

  factory MarketDataModel.fromJson(String symbol, Map<String, dynamic> json) {
    return MarketDataModel(
      symbol: symbol,
      bid: (json['bid'] ?? 0).toDouble(),
      bidHigh: (json['bid_high'] ?? 0).toDouble(),
      bidLow: (json['bid_low'] ?? 0).toDouble(),
      ask: (json['ask'] ?? 0).toDouble(),
      askHigh: (json['ask_high'] ?? 0).toDouble(),
      askLow: (json['ask_low'] ?? 0).toDouble(),
      datetime: json['datetime'] ?? 0,
      direction: json['direction'] ?? '',
    );
  }

  /// Spread in pips
  double get spreadPips {
    final spread = (ask - bid).abs();
    final upperSymbol = symbol.toUpperCase();

    if (upperSymbol.contains("JPY")) {
      return spread / 0.01;
    } else if (upperSymbol.contains("XAU")) {
      return spread / 0.1; // Atur sesuai broker Anda
    } else {
      return spread / 0.0001;
    }
  }

  /// Format display price
  String formatPrice(double value) {
    final upperSymbol = symbol.toUpperCase();
    if (upperSymbol.contains("JPY")) {
      return value.toStringAsFixed(3);
    } else {
      return value.toStringAsFixed(5);
    }
  }
}

class MarketWebSocketController extends GetxController {
  late IOWebSocketChannel channel;

  final Rx<WebSocketStatus> status = WebSocketStatus.connecting.obs;
  final RxMap<String, List<TickModel>> tickData = <String, List<TickModel>>{}.obs;
  final RxMap<String, MarketDataModel> marketData = <String, MarketDataModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      status.value = WebSocketStatus.connecting;
      channel = IOWebSocketChannel.connect('ws://207.148.119.106:9003'); // Ganti dengan URL Anda

      channel.stream.listen(
        (message) {
          try {
            final decoded = json.decode(message);
            if (decoded is Map<String, dynamic>) {
              decoded.forEach((symbol, item) {
                final data = MarketDataModel.fromJson(symbol, item);
                marketData[symbol] = data;
              });
              status.value = WebSocketStatus.connected;
            }
          } catch (_) {}
        },
        onError: (err) {
          status.value = WebSocketStatus.failed;
        },
        onDone: () {
          status.value = WebSocketStatus.failed;
        },
      );
    } catch (_) {
      status.value = WebSocketStatus.failed;
    }
  }

  List<Candle> generateOHLCFromTicks(String symbol, Duration interval) {
    final List<TickModel>? ticks = tickData[symbol];
    if (ticks == null || ticks.isEmpty) return [];

    final List<Candle> candles = [];
    ticks.sort((a, b) => a.datetime.compareTo(b.datetime));

    DateTime start = ticks.first.datetime;
    DateTime end = start.add(interval);

    double open = ticks.first.bid;
    double high = open;
    double low = open;
    double close = open;

    for (var tick in ticks) {
      if (tick.datetime.isBefore(end)) {
        high = tick.bid > high ? tick.bid : high;
        low = tick.bid < low ? tick.bid : low;
        close = tick.bid;
      } else {
        candles.add(Candle(
          epoch: start.millisecondsSinceEpoch ~/ 1000,
          open: open,
          high: high,
          low: low,
          close: close,
        ));

        // Mulai candle baru
        start = end;
        end = start.add(interval);
        open = tick.bid;
        high = tick.bid;
        low = tick.bid;
        close = tick.bid;
      }
    }

    // Tambah candle terakhir
    candles.add(Candle(
      epoch: start.millisecondsSinceEpoch ~/ 1000,
      open: open,
      high: high,
      low: low,
      close: close,
    ));

    return candles;
  }

  void reconnect() {
    try {
      channel.sink.close();
    } catch (_) {}
    _connectWebSocket();
  }

  @override
  void onClose() {
    try {
      channel.sink.close();
    } catch (_) {}
    super.onClose();
  }
}
