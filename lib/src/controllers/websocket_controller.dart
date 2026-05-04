import 'dart:async';
import 'dart:convert';
// import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
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


class TickModelWSS {
  final double ask;
  final double bid;
  final String symbol;
  final int digits;
  final int spread;

  TickModelWSS({
    required this.ask,
    required this.bid,
    required this.symbol,
    required this.digits,
    required this.spread,
  });

  factory TickModelWSS.fromJson(Map<String, dynamic> json) {
    return TickModelWSS(
      ask: (json['ask'] ?? 0.0).toDouble(),
      bid: (json['bid'] ?? 0.0).toDouble(),
      symbol: json['symbol'] ?? "",
      digits: json['digits'] ?? 0,
      spread: json['spread'] ?? 0,
    );
  }
}


class TickWSSController extends GetxController {
  WebSocketChannel? _channel;
  String? _connectedUrl; // URL terakhir yang berhasil connect — guard duplikat
  
  var ticks = <String, TickModelWSS>{}.obs;
  // Map untuk menyimpan warna masing-masing simbol
  var tickColors = <String, Color>{}.obs;
  var isConnected = false.obs;

  void connectToSocket({
    required String login,
    required String token,
    required String server,
  }) {
    final url = '${GlobalVariable.mainURLForWebSocketTick}${GlobalVariable.endpointWssTick}?token=$token&server=$server&login=$login';

    // Skip jika sudah terhubung dengan URL yang sama
    if (isConnected.value && _connectedUrl == url) return;

    // Tutup channel lama sebelum membuka yang baru untuk mencegah orphan connection
    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (_) {}
      _channel = null;
      isConnected.value = false;
      _connectedUrl = null;
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _connectedUrl = url;
      isConnected.value = true;

      _channel!.stream.listen(
        (data) {
          final decoded = jsonDecode(data);
          final newTick = TickModelWSS.fromJson(decoded);
          
          final String sym = newTick.symbol;

          // LOGIKA PERUBAHAN WARNA
          if (ticks.containsKey(sym)) {
            double oldBid = ticks[sym]!.bid;
            double newBid = newTick.bid;

            if (newBid > oldBid) {
              tickColors[sym] = Colors.blue; // Harga Naik
            } else if (newBid < oldBid) {
              tickColors[sym] = Colors.red;  // Harga Turun
            } else {
              tickColors[sym] = Colors.grey; // Harga Sama
            }
          } else {
            tickColors[sym] = Colors.grey; // Default warna pertama kali data masuk
          }

          // Simpan data terbaru
          ticks[sym] = newTick;
        },
        onError: (error) {
          isConnected.value = false;
          _connectedUrl = null;
        },
        onDone: () {
          isConnected.value = false;
          _connectedUrl = null;
        },
      );
    } catch (e) {
      isConnected.value = false;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _connectedUrl = null;
    isConnected.value = false;
  }
}