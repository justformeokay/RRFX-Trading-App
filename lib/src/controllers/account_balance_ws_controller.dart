import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/models/trades/open_order_model.dart';

enum AccountWSStatus { connecting, connected, failed, disconnected }

class AccountBalanceWSController extends GetxController
    with WidgetsBindingObserver {
  IOWebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final Rx<AccountWSStatus> status = AccountWSStatus.connecting.obs;
  String? _currentLogin;
  String? _currentServerType;

  // Observable untuk profit dari WebSocket (tidak ada di API model)
  final RxDouble profit = 0.0.obs;
  final RxDouble floating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print('🔄 [AccountWS] App lifecycle changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        if (status.value == AccountWSStatus.failed ||
            status.value == AccountWSStatus.disconnected) {
          // print('📱 [AccountWS] App resumed, reconnecting...');
          _reconnectWebSocket();
        }
        break;
      case AppLifecycleState.paused:
        // print('📱 [AccountWS] App paused, keeping connection alive...');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void subscribe({required String login, required String serverType}) {
    _currentLogin = login;
    _currentServerType = serverType;

    // Connect dulu, subscribe message akan dikirim otomatis setelah connected
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      status.value = AccountWSStatus.connecting;
      // print('🔌 [AccountWS] Connecting to ws://207.148.119.106:9006');

      channel = IOWebSocketChannel.connect('ws://207.148.119.106:9006');

      channel!.stream.listen(
        (message) {
          try {
            _reconnectAttempts = 0;
            status.value = AccountWSStatus.connected;
            // print('📥 [AccountWS] Received: $message');

            final decoded = json.decode(message);
            if (decoded is Map<String, dynamic>) {
              _handleAccountUpdate(decoded);
            }
          } catch (e) {
            // print('❌ [AccountWS] Parse error: $e');
          }
        },
        onError: (err) {
          // print('❌ [AccountWS] Error: $err');
          status.value = AccountWSStatus.failed;
          if (!_isManuallyDisconnected) {
            _scheduleReconnect();
          }
        },
        onDone: () {
          // print('⚠️ [AccountWS] Connection closed');
          status.value = AccountWSStatus.disconnected;
          if (!_isManuallyDisconnected) {
            _scheduleReconnect();
          }
        },
        cancelOnError: false,
      );

      // Kirim subscribe message SEKALI setelah connect
      if (_currentLogin != null && _currentServerType != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendSubscribeMessage();
        });
      } else {
        status.value = AccountWSStatus.connected;
      }
    } catch (e) {
      // print('❌ [AccountWS] Connection error: $e');
      status.value = AccountWSStatus.failed;
      _scheduleReconnect();
    }
  }

  void _sendSubscribeMessage() {
    if (channel == null ||
        _currentLogin == null ||
        _currentServerType == null) {
      return;
    }

    // Convert login string to integer
    final loginInt = int.tryParse(_currentLogin!) ?? 0;

    final subscribeMessage = json.encode({
      "action": "subscribe",
      "login": loginInt, // ← Harus integer, bukan string!
      "server": _currentServerType,
    });

    try {
      channel!.sink.add(subscribeMessage);
      // print('📤 [AccountWS] Sent subscribe: $subscribeMessage');
      // print('📤 [AccountWS] Waiting for response from server...');
    } catch (e) {
      // print('❌ [AccountWS] Failed to send subscribe: $e');
    }
  }

  void _handleAccountUpdate(Map<String, dynamic> data) {
    try {
      final accountController = Get.find<AccountController>();
      final tradingController = Get.find<TradingController>();

      // print('🔄 [AccountWS] Handling account update: $data');
      // print(
      //   '🔄 [AccountWS] Current selected account: ${accountController.selectedAccount.value?.login}',
      // );

      // Update balance, equity, margin, dll
      if (accountController.selectedAccount.value != null) {
        final currentAccount = accountController.selectedAccount.value!;

        // Update account data
        currentAccount.balance =
            data['balance']?.toString() ?? currentAccount.balance;
        currentAccount.equity =
            data['equity']?.toString() ?? currentAccount.equity;
        currentAccount.margin = data['margin']?.toString() ?? "0";
        currentAccount.marginFree =
            data['free_margin']?.toString() ?? currentAccount.marginFree;
        currentAccount.marginFreePercent =
            (data['margin_level'] as num?)?.toDouble() ??
            currentAccount.marginFreePercent;

        // Update profit dan floating dari WebSocket (tidak ada di model)
        profit.value = (data['profit'] as num?)?.toDouble() ?? 0.0;
        floating.value = (data['floating'] as num?)?.toDouble() ?? 0.0;

        // Trigger update
        accountController.selectedAccount.refresh();

        // print(
        //   '💰 [AccountWS] Updated account: Balance=${data['balance']}, Equity=${data['equity']}',
        // );
      }

      // Update open positions
      if (data['open_positions'] != null && data['open_positions'] is List) {
        final openPositions = data['open_positions'] as List;

        // Convert WebSocket format to Response objects
        final updatedPositions =
            openPositions.map((pos) {
              return {
                'ticket': pos['ticket'],
                'symbol': pos['symbol'],
                'orderType': pos['type'] == 0 ? 'buy' : 'sell',
                'lot': pos['volume'],
                'openPrice': pos['open_price'],
                'currentPrice': pos['current_price'],
                'stopLoss': pos['stop_loss'],
                'takeProfit': pos['take_profit'],
                'profit': pos['profit'],
                'swap': pos['swap'],
                'openTime':
                    DateTime.fromMillisecondsSinceEpoch(
                      (pos['open_time'] as int) * 1000,
                    ).toString(),
                'digits': pos['digits'] ?? 5,
              };
            }).toList();

        // Create new OpenOrderModel with updated data
        final newModel = {'response': updatedPositions};

        tradingController.openOrderModel.value =
            tradingController.openOrderModel.value != null
                ? OpenOrderModel.fromJson(newModel)
                : OpenOrderModel.fromJson(newModel);

        // print('📊 [AccountWS] Updated ${openPositions.length} open positions');
      }
    } catch (e) {
      // print('❌ [AccountWS] Error handling update: $e');
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      // print('❌ [AccountWS] Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    // print(
    //   '🔄 [AccountWS] Scheduling reconnect $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds}s',
    // );

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isManuallyDisconnected) {
        _reconnectWebSocket();
      }
    });
  }

  void _reconnectWebSocket() {
    // print('🔄 [AccountWS] Attempting to reconnect...');
    try {
      channel?.sink.close();
    } catch (e) {
      //  print('⚠️ [AccountWS] Error closing old channel: $e');
    }
    _connectWebSocket();
  }

  void reconnect() {
    _reconnectAttempts = 0;
    _reconnectWebSocket();
  }

  void disconnect() {
    // print('🛑 [AccountWS] Manually disconnecting');
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    try {
      channel?.sink.close();
    } catch (e) {
      print('⚠️ [AccountWS] Error closing channel: $e');
    }
    status.value = AccountWSStatus.disconnected;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    _isManuallyDisconnected = true;
    try {
      channel?.sink.close();
    } catch (e) {
      // print('⚠️ [AccountWS] Error closing channel on dispose: $e');
    }
    super.onClose();
  }
}
