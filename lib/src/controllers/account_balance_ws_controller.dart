import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/models/trades/open_order_model.dart';

enum AccountWSStatus { connecting, connected, failed, disconnected }

class AccountBalanceWSController extends GetxController
    with WidgetsBindingObserver {
  WebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  /// Generation counter to invalidate stale WebSocket callbacks
  /// (prevents old channel's onDone from triggering reconnect after subscribe)
  int _subscriptionGen = 0;

  final Rx<AccountWSStatus> status = AccountWSStatus.connecting.obs;
  String? _currentLogin;
  String? _currentServerType;

  // Observable untuk profit dari WebSocket (tidak ada di API model)
  final RxDouble profit = 0.0.obs;
  final RxDouble floating = 0.0.obs;

  // Individual observables untuk setiap baris header — hanya field yg berubah
  // yang memicu rebuild Obx-nya masing-masing, bukan semua sekaligus.
  final RxString loginObs = ''.obs;
  final RxString balanceObs = 'N/A'.obs;
  final RxString equityObs = 'N/A'.obs;
  final RxString marginObs = 'N/A'.obs;
  final RxString marginFreeObs = 'N/A'.obs;
  final RxString marginLevelObs = 'N/A'.obs;

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
    // Skip if already subscribed to same account
    if (_currentLogin == login && _currentServerType == serverType && 
        status.value == AccountWSStatus.connected) {
      // print('✅ [AccountWS] Already subscribed to $login');
      return;
    }

    // Increment generation to invalidate any pending callbacks from old channel
    _subscriptionGen++;

    // Cancel any pending reconnect from old connection
    _reconnectTimer?.cancel();

    // Temporarily mark as manual disconnect so old onDone doesn't interfere
    _isManuallyDisconnected = true;

    // Close old connection before creating new one
    if (channel != null) {
      // print('🔄 [AccountWS] Closing old connection for $_currentLogin');
      try {
        channel?.sink.close();
      } catch (e) {
        // print('⚠️ [AccountWS] Error closing old channel: $e');
      }
      channel = null;
    }

    _currentLogin = login;
    _currentServerType = serverType;
    _isManuallyDisconnected = false;
    _reconnectAttempts = 0;

    // Sync individual observables from current account snapshot
    // so the header shows correct values immediately on account switch
    final acc = Get.find<AccountController>().selectedAccount.value;
    if (acc != null) {
      loginObs.value = acc.login ?? '';
      balanceObs.value = acc.balance ?? 'N/A';
      equityObs.value = acc.equity ?? 'N/A';
      marginObs.value = acc.margin ?? 'N/A';
      marginFreeObs.value = acc.marginFree ?? 'N/A';
      marginLevelObs.value = acc.marginFreePercent?.toString() ?? 'N/A';
    }

    // Connect to new account
    // print('🔌 [AccountWS] Subscribing to new account: $login');
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      status.value = AccountWSStatus.connecting;
      // print('🔌 [AccountWS] Connecting to ws://207.148.119.106:9006');

      channel = WebSocketChannel.connect(Uri.parse(GlobalVariable.wsAccountURL));

      // Capture current generation so stale callbacks are ignored
      final gen = _subscriptionGen;

      channel!.stream.listen(
        (message) {
          // Ignore if this listener belongs to an old subscription
          if (gen != _subscriptionGen) return;
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
          if (gen != _subscriptionGen) return;
          // print('❌ [AccountWS] Error: $err');
          status.value = AccountWSStatus.failed;
          if (!_isManuallyDisconnected) {
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (gen != _subscriptionGen) return;
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
        Future.delayed(const Duration(milliseconds: 100), () {
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

      // Validate if data belongs to current account (prevent processing wrong account data)
      final dataLogin = data['login']?.toString();
      if (dataLogin != null && dataLogin != _currentLogin) {
        // print('⚠️ [AccountWS] Ignoring data for different account: $dataLogin (current: $_currentLogin)');
        return;
      }

      // Update balance, equity, margin, dll
      if (accountController.selectedAccount.value != null) {
        final currentAccount = accountController.selectedAccount.value!;

        // Only update if values actually changed (reduce unnecessary UI rebuilds)
        bool hasChanges = false;
        
        final newBalance = data['balance']?.toString();
        if (newBalance != null && newBalance != currentAccount.balance) {
          currentAccount.balance = newBalance;
          balanceObs.value = newBalance;
          hasChanges = true;
        }
        
        final newEquity = data['equity']?.toString();
        if (newEquity != null && newEquity != currentAccount.equity) {
          currentAccount.equity = newEquity;
          equityObs.value = newEquity;
          hasChanges = true;
        }
        
        if (data.containsKey('margin') && data['margin'] != null) {
          final newMargin = data['margin'].toString();
          if (newMargin != currentAccount.margin) {
            currentAccount.margin = newMargin;
            marginObs.value = newMargin;
            hasChanges = true;
          }
        }
        
        final newMarginFree = data['free_margin']?.toString();
        if (newMarginFree != null && newMarginFree != currentAccount.marginFree) {
          currentAccount.marginFree = newMarginFree;
          marginFreeObs.value = newMarginFree;
          hasChanges = true;
        }
        
        final newMarginLevel = (data['margin_level'] as num?)?.toDouble();
        if (newMarginLevel != null && newMarginLevel != currentAccount.marginFreePercent) {
          currentAccount.marginFreePercent = newMarginLevel;
          marginLevelObs.value = newMarginLevel.toString();
          hasChanges = true;
        }

        // Update profit dan floating — only if server actually sends these fields
        if (data.containsKey('profit') && data['profit'] != null) {
          final newProfit = (data['profit'] as num).toDouble();
          if ((newProfit - profit.value).abs() > 0.001) {
            profit.value = newProfit;
            hasChanges = true;
          }
        }

        if (data.containsKey('floating') && data['floating'] != null) {
          final newFloating = (data['floating'] as num).toDouble();
          if ((newFloating - floating.value).abs() > 0.001) {
            floating.value = newFloating;
            hasChanges = true;
          }
        }

        // Trigger update only if there are actual changes
        if (hasChanges) {
          accountController.selectedAccount.refresh();
        }
      }

      // Update open positions (only if there are positions in the data)
      if (data['open_positions'] != null && data['open_positions'] is List) {
        final openPositions = data['open_positions'] as List;

        // Skip if positions data is empty and we already have empty model
        if (openPositions.isEmpty &&
            (tradingController.openOrderModel.value?.response?.isEmpty ?? true)) {
          return;
        }

        final existingPositions = tradingController.openOrderModel.value?.response;
        bool needsFullReplace = existingPositions == null ||
            existingPositions.length != openPositions.length;

        if (!needsFullReplace) {
          // Build O(1) lookup by ticket to avoid nested loops
          final existingByTicket = {
            for (final p in existingPositions) '${p.ticket}': p
          };

          bool positionChanged = false;

          for (final pos in openPositions) {
            final ticket = '${pos['ticket']}';
            final existing = existingByTicket[ticket];
            if (existing == null) {
              // Unknown ticket — structure changed, fall through to full replace
              needsFullReplace = true;
              break;
            }

            // currentPrice changes on every tick — update in-place
            final newCurrentPrice = pos['current_price'];
            if (newCurrentPrice != null &&
                '$newCurrentPrice' != '${existing.currentPrice}') {
              existing.currentPrice = newCurrentPrice;
              positionChanged = true;
            }

            // profit changes frequently
            final newProfit = pos['profit'];
            if (newProfit != null) {
              final oldVal = double.tryParse('${existing.profit}') ?? 0.0;
              final newVal = (newProfit as num).toDouble();
              if ((newVal - oldVal).abs() > 0.00001) {
                existing.profit = newProfit;
                positionChanged = true;
              }
            }

            // swap changes daily, but check anyway
            final newSwap = pos['swap'];
            if (newSwap != null) {
              final oldVal = double.tryParse('${existing.swap}') ?? 0.0;
              final newVal = (newSwap as num).toDouble();
              if ((newVal - oldVal).abs() > 0.00001) {
                existing.swap = newSwap;
                positionChanged = true;
              }
            }

            // SL/TP can change after modify order
            final newSL = pos['stop_loss'];
            if (newSL != null && '$newSL' != '${existing.stopLoss}') {
              existing.stopLoss = newSL;
              positionChanged = true;
            }

            final newTP = pos['take_profit'];
            if (newTP != null && '$newTP' != '${existing.takeProfit}') {
              existing.takeProfit = newTP;
              positionChanged = true;
            }
          }

          // In-place update: notify without creating new objects
          if (positionChanged && !needsFullReplace) {
            tradingController.openOrderModel.refresh();
            return;
          } else if (!needsFullReplace) {
            // Nothing changed at all — skip rebuild entirely
            return;
          }
        }

        // Position count changed (opened/closed) — full replace required
        final updatedPositions = openPositions.map((pos) {
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
            'openTime': DateTime.fromMillisecondsSinceEpoch(
              (pos['open_time'] as int) * 1000,
            ).toString(),
            'digits': pos['digits'] ?? 5,
          };
        }).toList();

        tradingController.openOrderModel.value =
            OpenOrderModel.fromJson({'response': updatedPositions});
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
