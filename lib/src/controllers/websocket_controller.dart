import 'dart:async';
// import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketStatus { connecting, connected, failed, disconnected }

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
  final int digits;
  final int spread;

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
    required this.digits,
    required this.spread,
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
      datetime: json['datetime_msc'] ?? json['datetime'] ?? 0,
      direction: json['direction'] ?? '',
      digits: json['digits'] ?? 5,
      spread: json['spread'] ?? 0,
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

class MarketWebSocketController extends GetxController
    with WidgetsBindingObserver {
  WebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final Rx<WebSocketStatus> status = WebSocketStatus.connecting.obs;
  final RxMap<String, List<TickModel>> tickData =
      <String, List<TickModel>>{}.obs;
  final RxMap<String, MarketDataModel> marketData =
      <String, MarketDataModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // _connectWebSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App kembali ke foreground, reconnect jika perlu
        if (status.value == WebSocketStatus.failed ||
            status.value == WebSocketStatus.disconnected) {
          _reconnectWebSocket();
        }
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // void _connectWebSocket() {
  //   try {
  //     status.value = WebSocketStatus.connecting;
  //     channel = IOWebSocketChannel.connect('ws://207.148.119.106:9003');

  //     channel!.stream.listen(
  //       (message) {
  //         try {
  //           _reconnectAttempts = 0; // Reset counter saat berhasil terima data
  //           // print('📥 WebSocket received message: $message');
  //           final decoded = json.decode(message);
  //           if (decoded is Map<String, dynamic>) {
  //             // Check apakah response adalah single market object
  //             if (decoded.containsKey('symbol')) {
  //               // Single market response: { "symbol": "XAUUSD.db", "bid": 4209.27, ... }
  //               final symbol = decoded['symbol'] as String;
  //               final bid = decoded['bid'];
  //               final ask = decoded['ask'];
  //               // print(
  //               //   '✅ Parsed single market - Symbol: $symbol, Bid: $bid, Ask: $ask',
  //               // );

  //               final data = MarketDataModel.fromJson(symbol, decoded);
  //               marketData[symbol] = data;
  //               // print(
  //               //   '💾 Stored in marketData[$symbol] = Bid: ${data.bid}, Ask: ${data.ask}',
  //               // );
  //               status.value = WebSocketStatus.connected;
  //             } else {
  //               // Multiple markets response: { "XAUUSD": {...}, "EURUSD": {...} }
  //               // print('📦 Parsing multiple markets...');
  //               decoded.forEach((symbol, item) {
  //                 final data = MarketDataModel.fromJson(symbol, item);
  //                 marketData[symbol] = data;
  //                 // print(
  //                 // //   '💾 Stored $symbol - Bid: ${data.bid}, Ask: ${data.ask}',
  //                 // );
  //               });
  //               status.value = WebSocketStatus.connected;
  //             }
  //           }
  //         } catch (e) {
  //           print('❌ WebSocket parse error: $e');
  //         }
  //       },
  //       onError: (err) {
  //         print('❌ WebSocket error: $err');
  //         status.value = WebSocketStatus.failed;
  //         if (!_isManuallyDisconnected) {
  //           _scheduleReconnect();
  //         }
  //       },
  //       onDone: () {
  //         print('⚠️ WebSocket connection closed');
  //         status.value = WebSocketStatus.disconnected;
  //         if (!_isManuallyDisconnected) {
  //           _scheduleReconnect();
  //         }
  //       },
  //       cancelOnError: false,
  //     );
  //   } catch (e) {
  //     print('WebSocket connection error: $e');
  //     status.value = WebSocketStatus.failed;
  //   }
  // }

  // List<Candle> generateOHLCFromTicks(String symbol, Duration interval) {
  //   final List<TickModel>? ticks = tickData[symbol];
  //   if (ticks == null || ticks.isEmpty) return [];

  //   // final List<Candle> candles = [];
  //   ticks.sort((a, b) => a.datetime.compareTo(b.datetime));

  //   DateTime start = ticks.first.datetime;
  //   DateTime end = start.add(interval);

  //   double open = ticks.first.bid;
  //   double high = open;
  //   double low = open;
  //   double close = open;

  //   for (var tick in ticks) {
  //     if (tick.datetime.isBefore(end)) {
  //       high = tick.bid > high ? tick.bid : high;
  //       low = tick.bid < low ? tick.bid : low;
  //       close = tick.bid;
  //     } else {
  //       // candles.add(
  //       //   Candle(
  //       //     epoch: start.millisecondsSinceEpoch ~/ 1000,
  //       //     open: open,
  //       //     high: high,
  //       //     low: low,
  //       //     close: close,
  //       //   ),
  //       // );

  //       // Mulai candle baru
  //       start = end;
  //       end = start.add(interval);
  //       open = tick.bid;
  //       high = tick.bid;
  //       low = tick.bid;
  //       close = tick.bid;
  //     }
  //   }

  //   // Tambah candle terakhir
  //   candles.add(
  //     Candle(
  //       epoch: start.millisecondsSinceEpoch ~/ 1000,
  //       open: open,
  //       high: high,
  //       low: low,
  //       close: close,
  //     ),
  //   );

  //   return candles;
  // }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }
    _reconnectAttempts++;
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isManuallyDisconnected) {
        _reconnectWebSocket();
      }
    });
  }

  void _reconnectWebSocket() {
    try {
      channel?.sink.close();
    } catch (e) {
      Get.log('⚠️ Error closing old channel: $e');
    }
    // _connectWebSocket();
  }

  void reconnect() {
    _reconnectAttempts = 0;
    _reconnectWebSocket();
  }

  void disconnect() {
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    try {
      channel?.sink.close();
    } catch (e) {
      Get.log('⚠️ Error closing channel: $e');
    }
    status.value = WebSocketStatus.disconnected;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    _isManuallyDisconnected = true;
    try {
      channel?.sink.close();
    } catch (e) {
      Get.log('⚠️ Error closing channel on dispose: $e');
    }
    super.onClose();
  }
}
