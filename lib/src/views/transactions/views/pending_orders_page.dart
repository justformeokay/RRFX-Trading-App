import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ─────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────

class PendingOrderItem {
  final dynamic ticket;
  final String symbol;
  final String orderType;
  final int typeInt;
  final double volume;
  final double priceOrder;
  final double priceCurrent;
  final double stopLoss;
  final double takeProfit;
  final DateTime? timeSetup;
  final DateTime? timeExpiration;
  final int digits;

  PendingOrderItem({
    required this.ticket,
    required this.symbol,
    required this.orderType,
    required this.typeInt,
    required this.volume,
    required this.priceOrder,
    required this.priceCurrent,
    required this.stopLoss,
    required this.takeProfit,
    required this.timeSetup,
    required this.timeExpiration,
    required this.digits,
  });

  factory PendingOrderItem.fromJson(Map<String, dynamic> json) {
    final int typeInt = (json['type'] as num?)?.toInt() ?? 0;
    String typeStr;
    switch (typeInt) {
      case 2:
        typeStr = 'Buy Limit';
        break;
      case 3:
        typeStr = 'Sell Limit';
        break;
      case 4:
        typeStr = 'Buy Stop';
        break;
      case 5:
        typeStr = 'Sell Stop';
        break;
      case 6:
        typeStr = 'Buy Stop Limit';
        break;
      case 7:
        typeStr = 'Sell Stop Limit';
        break;
      default:
        typeStr = 'Pending #$typeInt';
    }

    return PendingOrderItem(
      ticket: json['ticket'],
      symbol: json['symbol'] ?? '',
      orderType: typeStr,
      typeInt: typeInt,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      priceOrder: (json['price_order'] as num?)?.toDouble() ?? 0.0,
      priceCurrent: (json['price_current'] as num?)?.toDouble() ?? 0.0,
      stopLoss: (json['stop_loss'] as num?)?.toDouble() ?? 0.0,
      takeProfit: (json['take_profit'] as num?)?.toDouble() ?? 0.0,
      timeSetup: _parseTimestamp(json['time_setup']),
      timeExpiration: _parseTimestamp(json['time_expiration']),
      digits: (json['digits'] as num?)?.toInt() ?? 5,
    );
  }

  static DateTime? _parseTimestamp(dynamic ts) {
    if (ts == null) return null;
    if (ts is int) {
      if (ts == 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }
    return null;
  }

  bool get isBuyType => orderType.toLowerCase().contains('buy');

  /// Distance between order price and current price
  double get priceDistance => (priceCurrent - priceOrder).abs();

  bool get hasExpiration => timeExpiration != null;
}

// ─────────────────────────────────────────────────────────
// WebSocket Status
// ─────────────────────────────────────────────────────────

enum PendingWSStatus { connecting, connected, failed, disconnected }

// ─────────────────────────────────────────────────────────
// Page Widget
// ─────────────────────────────────────────────────────────

class PendingOrdersPage extends StatefulWidget {
  const PendingOrdersPage({super.key});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final AccountController _accountController;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const String _wsUrl = 'wss://ws-rrfx.techcrm.dev/openposition';

  /// Generation counter to invalidate stale WebSocket callbacks
  int _subscriptionGen = 0;

  final Rx<PendingWSStatus> status = PendingWSStatus.disconnected.obs;
  final RxList<PendingOrderItem> pendingOrders = <PendingOrderItem>[].obs;
  final RxBool isFirstLoad = true.obs;

  String? _currentLogin;
  String? _currentServerType;
  Worker? _accountListener;

  final AuthService _authService = AuthService();
  final RxBool _isCancelling = false.obs;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _accountController = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());

    // Listen for account changes
    _accountListener = ever(_accountController.selectedAccount, (account) {
      if (account != null) {
        final newLogin = account.login;
        final newType = account.type;
        if (_currentLogin != newLogin || _currentServerType != newType) {
          pendingOrders.clear();
          isFirstLoad.value = true;
          _subscribe(login: newLogin!, serverType: newType!);
        }
      }
    });

    // Initial subscription
    final account = _accountController.selectedAccount.value;
    if (account != null && account.login != null && account.type != null) {
      _subscribe(login: account.login!, serverType: account.type!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App kembali aktif — auto-reconnect jika WS tidak connected
      if (status.value != PendingWSStatus.connected &&
          _currentLogin != null &&
          _currentServerType != null) {
        debugPrint('📱 [PendingWS] App resumed, auto-reconnecting...');
        _reconnectAttempts = 0;
        _subscribe(login: _currentLogin!, serverType: _currentServerType!);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accountListener?.dispose();
    _audioPlayer.dispose();
    _disconnect();
    super.dispose();
  }

  // ─── WebSocket Management ─────────────────────────────

  void _subscribe({required String login, required String serverType}) {
    if (_currentLogin == login &&
        _currentServerType == serverType &&
        status.value == PendingWSStatus.connected) {
      return;
    }

    // Increment generation to invalidate stale callbacks from old channel
    _subscriptionGen++;

    // Cancel pending reconnect from old connection
    _reconnectTimer?.cancel();

    // Temporarily mark as manual disconnect so old onDone doesn't interfere
    _isManuallyDisconnected = true;

    // Close existing connection
    if (_channel != null) {
      try {
        _channel?.sink.close();
      } catch (_) {}
      _channel = null;
    }

    _currentLogin = login;
    _currentServerType = serverType;
    _isManuallyDisconnected = false;
    _reconnectAttempts = 0;

    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      status.value = PendingWSStatus.connecting;

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Capture current generation so stale callbacks are ignored
      final gen = _subscriptionGen;

      _channel!.stream.listen(
        (message) {
          if (gen != _subscriptionGen) return;
          try {
            _reconnectAttempts = 0;
            status.value = PendingWSStatus.connected;
            isFirstLoad.value = false;

            final decoded = json.decode(message);
            if (decoded is Map<String, dynamic>) {
              _handleData(decoded);
            }
          } catch (e) {
            debugPrint('❌ [PendingWS] Parse error: $e');
          }
        },
        onError: (err) {
          if (gen != _subscriptionGen) return;
          debugPrint('❌ [PendingWS] Error: $err');
          status.value = PendingWSStatus.failed;
          if (!_isManuallyDisconnected) _scheduleReconnect();
        },
        onDone: () {
          if (gen != _subscriptionGen) return;
          status.value = PendingWSStatus.disconnected;
          if (!_isManuallyDisconnected) _scheduleReconnect();
        },
        cancelOnError: false,
      );

      // Send subscribe message after brief delay for connection establishment
      if (_currentLogin != null && _currentServerType != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (gen != _subscriptionGen) return;
          _sendSubscribeMessage();
        });
      }
    } catch (e) {
      debugPrint('❌ [PendingWS] Connection error: $e');
      status.value = PendingWSStatus.failed;
      _scheduleReconnect();
    }
  }

  void _sendSubscribeMessage() {
    if (_channel == null || _currentLogin == null || _currentServerType == null) return;

    final loginInt = int.tryParse(_currentLogin!) ?? 0;
    final msg = json.encode({
      "action": "subscribe",
      "login": loginInt,
      "server": _currentServerType,
    });

    try {
      _channel!.sink.add(msg);
      debugPrint('📤 [PendingWS] Subscribed: login=$_currentLogin, server=$_currentServerType');
    } catch (e) {
      debugPrint('❌ [PendingWS] Failed to send subscribe: $e');
    }
  }

  void _handleData(Map<String, dynamic> data) {
    // Read from 'pending_orders' array in WebSocket response
    if (data['pending_orders'] != null && data['pending_orders'] is List) {
      final rawPending = data['pending_orders'] as List;

      final pending = rawPending
          .map((pos) => PendingOrderItem.fromJson(pos as Map<String, dynamic>))
          .toList();

      pendingOrders.value = pending;
    } else {
      // If no pending_orders key in this message, keep existing (don't clear)
      // Only clear if the key exists but is empty
      if (data.containsKey('pending_orders')) {
        pendingOrders.clear();
      }
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('⚠️ [PendingWS] Max reconnect attempts reached, waiting for manual retry or app resume');
      status.value = PendingWSStatus.failed;
      return;
    }

    _reconnectAttempts++;
    // Exponential backoff: 3s, 6s, 9s, ... capped at 15s
    final delay = Duration(seconds: (_reconnectDelay.inSeconds * _reconnectAttempts).clamp(3, 15));
    debugPrint('🔄 [PendingWS] Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      if (!_isManuallyDisconnected) {
        _subscriptionGen++;
        try {
          _channel?.sink.close();
        } catch (_) {}
        _connectWebSocket();
      }
    });
  }

  /// Manual reconnect — reset semua state dan coba ulang dari awal
  void _manualReconnect() {
    if (_currentLogin == null || _currentServerType == null) return;
    debugPrint('🔄 [PendingWS] Manual reconnect triggered');
    _reconnectAttempts = 0;
    _subscribe(login: _currentLogin!, serverType: _currentServerType!);
  }

  void _disconnect() {
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    status.value = PendingWSStatus.disconnected;
  }

  // ─── UI ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (!_accountController.hasAccounts) return noAccountDetected();

      return Scaffold(
        body: _buildBody(isDark),
      );
    });
  }

  Widget _buildBody(bool isDark) {
    return Obx(() {
      // Connection status banner
      final wsStatus = status.value;
      final orders = pendingOrders;

      return Column(
        children: [
          // Connection status indicator
          _buildConnectionBanner(wsStatus, isDark),

          // Content
          Expanded(
            child: isFirstLoad.value && wsStatus == PendingWSStatus.connecting
                ? _buildLoadingState(isDark)
                : orders.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildOrdersList(orders, isDark),
          ),
        ],
      );
    });
  }

  Widget _buildConnectionBanner(PendingWSStatus wsStatus, bool isDark) {
    if (wsStatus == PendingWSStatus.connected) return const SizedBox.shrink();

    Color bgColor;
    String text;
    IconData icon;
    bool isRetrying = false;

    switch (wsStatus) {
      case PendingWSStatus.connecting:
        bgColor = Colors.orange.shade600;
        text = _reconnectAttempts > 0
            ? 'Reconnecting ($_reconnectAttempts/$_maxReconnectAttempts)...'
            : 'Menghubungkan ke server...';
        icon = Icons.sync;
        isRetrying = true;
        break;
      case PendingWSStatus.failed:
        bgColor = Colors.red.shade600;
        text = _reconnectAttempts >= _maxReconnectAttempts
            ? 'Koneksi gagal. Tap Reconnect untuk coba lagi.'
            : 'Koneksi gagal. Mencoba ulang...';
        icon = Icons.error_outline;
        break;
      case PendingWSStatus.disconnected:
        bgColor = Colors.grey.shade600;
        text = 'Terputus dari server';
        icon = Icons.cloud_off;
        break;
      default:
        return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: bgColor,
      child: Row(
        children: [
          isRetrying
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (wsStatus == PendingWSStatus.failed ||
              wsStatus == PendingWSStatus.disconnected)
            GestureDetector(
              onTap: _manualReconnect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Reconnect',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: CustomColor.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat Pending Orders...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.clock_outline,
                size: 40,
                color: CustomColor.secondaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Pending Order',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada order pending yang aktif.\nBuat pending order dari chart untuk memulai.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    icon: Iconsax.chart_outline,
                    title: "Buat Pending Order",
                    description:
                        "Gunakan fitur pending order pada chart trading",
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Iconsax.refresh_outline,
                    title: "Update Real-time",
                    description:
                        "Pending orders akan muncul secara otomatis",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: CustomColor.secondaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color:
                      isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<PendingOrderItem> orders, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length + 1, // +1 for summary header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(orders, isDark);
        }
        final order = orders[index - 1];
        return _buildOrderCard(order, isDark, index - 1);
      },
    );
  }

  Widget _buildSummaryCard(List<PendingOrderItem> orders, bool isDark) {
    final buyCount = orders.where((o) => o.isBuyType).length;
    final sellCount = orders.length - buyCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF8F9FD), const Color(0xFFEEF1F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade800.withOpacity(0.5)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Orders',
              '${orders.length}',
              Iconsax.receipt_outline,
              CustomColor.secondaryColor,
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          Expanded(
            child: _buildSummaryItem(
              'Buy Orders',
              '$buyCount',
              Iconsax.arrow_up_3_outline,
              Colors.green,
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          Expanded(
            child: _buildSummaryItem(
              'Sell Orders',
              '$sellCount',
              Iconsax.arrow_down_outline,
              Colors.red,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(PendingOrderItem order, bool isDark, int index) {
    final isBuy = order.isBuyType;
    final typeColor = isBuy ? Colors.green : Colors.red;
    final priceFormat = NumberFormat('#,##0.${'0' * order.digits}', 'en_US');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Slidable(
        key: ValueKey(order.ticket),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) => _showEditPositionDialog(order),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Iconsax.edit_bold,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => _cancelPendingOrder(order),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Iconsax.close_circle_bold,
              label: 'Cancel',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.grey.shade800.withOpacity(0.5)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
          children: [
            // Header: Symbol + Type badge
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  // Symbol icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        order.symbol.isNotEmpty
                            ? order.symbol.substring(
                                0,
                                order.symbol.length >= 2 ? 2 : 1,
                              )
                            : '?',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.symbol,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '#${order.ticket}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${order.volume} lot',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: typeColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      order.orderType,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Divider
            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),

            // Details grid
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: [
                  // Row 1: Order Price, Current Price, Distance
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Order Price',
                          priceFormat.format(order.priceOrder),
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Current Price',
                          priceFormat.format(order.priceCurrent),
                          isDark,
                          valueColor: order.priceCurrent > order.priceOrder
                              ? Colors.green
                              : order.priceCurrent < order.priceOrder
                                  ? Colors.red
                                  : null,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Distance',
                          priceFormat.format(order.priceDistance),
                          isDark,
                          valueColor: CustomColor.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: SL, TP, Setup Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'SL',
                          order.stopLoss > 0
                              ? priceFormat.format(order.stopLoss)
                              : '—',
                          isDark,
                          valueColor: order.stopLoss > 0 ? Colors.red : null,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'TP',
                          order.takeProfit > 0
                              ? priceFormat.format(order.takeProfit)
                              : '—',
                          isDark,
                          valueColor:
                              order.takeProfit > 0 ? Colors.green : null,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Setup Time',
                          _formatDateTime(order.timeSetup),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  // Row 3: Expiration (only if set)
                  if (order.hasExpiration) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            'Expiration',
                            _formatDateTime(order.timeExpiration),
                            isDark,
                            valueColor: Colors.orange,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    try {
      // Subtract 7 hours for timezone offset to match Meta display
      final adjustedTime = dt.subtract(const Duration(hours: 7));
      // Format as Meta-style: YYYY.MM.DD HH:mm:ss
      return DateFormat('yyyy.MM.dd HH:mm:ss').format(adjustedTime);
    } catch (_) {
      return '—';
    }
  }

  /// Edit position - show bottom sheet dialog
  Future<void> _showEditPositionDialog(PendingOrderItem order) async {    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditPositionDialog(
          order: order,
          authService: _authService,
          currentLogin: _currentLogin,
        );
      },
    );
  }

  /// Cancel pending order via API
  Future<void> _cancelPendingOrder(PendingOrderItem order) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.info_circle_bold,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel Pending Order?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to cancel this pending order?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.3)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Symbol:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          order.symbol,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Get.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ticket:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '#${order.ticket}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Get.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Type:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          order.orderType,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: order.isBuyType ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'No, Keep It',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: CustomColor.secondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Cancelling order...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      _isCancelling.value = true;

      final requestBody = {
        'login': _currentLogin ?? '',
        'ticket': order.ticket.toString(),
        'is_pending': '1',  // Convert to string
      };

      debugPrint('📤 Cancelling pending order: $requestBody');

      final response = await _authService.post(
        'market/execution/close',
        requestBody,
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint('📥 Cancel response: $response');

      if (response['status'] == true) {
        // Play success sound with error handling
        try {
          debugPrint('🔊 [Cancel] Playing success sound...');
          await _audioPlayer.play(AssetSource('sounds/applepay.mp3'));
          debugPrint('✅ [Cancel] Sound played successfully');
        } catch (audioError) {
          debugPrint('❌ [Cancel] Audio error: $audioError');
        }
        
        AppSnackbar.success(
          response['message'] ?? 'Pending order cancelled successfully',
        );

        // Remove from local list immediately for better UX
        // WebSocket will sync the real state
        pendingOrders.removeWhere((item) => item.ticket == order.ticket);
      } else {
        final errorMessage = response['message'] ?? 'Failed to cancel pending order';
        AppSnackbar.error(errorMessage);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint('❌ Cancel pending order error: $e');
      AppSnackbar.error(
        'Failed to cancel pending order. Please try again.',
      );
    } finally {
      _isCancelling.value = false;
    }
  }
}

// ─────────────────────────────────────────────────────────
// Edit Position Dialog Widget
// ─────────────────────────────────────────────────────────

class _EditPositionDialog extends StatefulWidget {
  final PendingOrderItem order;
  final AuthService authService;
  final String? currentLogin;

  const _EditPositionDialog({
    required this.order,
    required this.authService,
    required this.currentLogin,
  });

  @override
  State<_EditPositionDialog> createState() => _EditPositionDialogState();
}

class _EditPositionDialogState extends State<_EditPositionDialog> {
  late TextEditingController tpController;
  late TextEditingController slController;
  late TextEditingController tpPriceController;
  late TextEditingController slPriceController;
  late TextEditingController volumeController;
  late TextEditingController priceController;

  bool _isSyncingSl = false;
  bool _isSyncingTp = false;

  final isSaving = RxBool(false);
  final tpError = RxString('');
  final slError = RxString('');
  final volumeError = RxString('');
  final priceError = RxString('');

  // Static audio player for success sound
  static final AudioPlayer _staticAudioPlayer = AudioPlayer();

  static Future<void> _playSuccessSound() async {
    try {
      debugPrint('🔊 [Edit] Playing success sound...');
      await _staticAudioPlayer.play(AssetSource('sounds/applepay.mp3'));
      debugPrint('✅ [Edit] Sound played successfully');
    } catch (e) {
      debugPrint('❌ [Edit] Audio play error: $e');
      // Try fallback path
      try {
        debugPrint('🔄 [Edit] Trying fallback path: assets/sounds/applepay.mp3');
        await _staticAudioPlayer.play(AssetSource('assets/sounds/applepay.mp3'));
        debugPrint('✅ [Edit] Fallback sound played successfully');
      } catch (fallbackError) {
        debugPrint('❌ [Edit] Fallback also failed: $fallbackError');
      }
    }
  }

  int _getDigitsForSymbol(String symbol) {
    final s = symbol.toUpperCase();
    if (s.contains('XAU') || s.contains('GOLD')) return 2;
    if (s.contains('XAG') || s.contains('SILVER')) return 3;
    if (s.contains('JPY')) return 3;
    if (s.contains('US30') || s.contains('NAS') || s.contains('SPX') ||
        s.contains('DAX') || s.contains('UK100')) return 2;
    return 5;
  }

  double _getPointValue(String symbol) {
    final digits = _getDigitsForSymbol(symbol);
    double v = 1.0;
    for (int i = 0; i < digits; i++) {
      v /= 10.0;
    }
    return v;
  }

  String _formatPrice(double price, String symbol) {
    return price.toStringAsFixed(_getDigitsForSymbol(symbol));
  }

  String _formatPriceWithLeadingZeros(double price, String symbol, {double? referencePrice}) {
    final digits = _getDigitsForSymbol(symbol);
    int intDigits = 4;
    if (referencePrice != null && referencePrice > 0) {
      intDigits = referencePrice.truncate().toString().length;
    }
    String formatted = price.toStringAsFixed(digits);
    List<String> parts = formatted.split('.');
    String intPart = parts[0].padLeft(intDigits, '0');
    String decPart = parts.length > 1 ? parts[1] : ''.padRight(digits, '0');
    return '$intPart.$decPart';
  }

  void _syncSlPriceFromPoints(String value) {
    if (_isSyncingSl) return;
    final points = double.tryParse(value);
    if (points == null || points <= 0) {
      _isSyncingSl = true;
      slPriceController.text = _formatPriceWithLeadingZeros(
        0.0, widget.order.symbol, referencePrice: widget.order.priceCurrent);
      _isSyncingSl = false;
      return;
    }
    final entryPrice = widget.order.priceOrder;
    if (entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.order.symbol);
    final isBuy = widget.order.orderType.toLowerCase().contains('buy');
    final slPrice = isBuy ? entryPrice - (points * pointValue) : entryPrice + (points * pointValue);
    _isSyncingSl = true;
    slPriceController.text = _formatPrice(slPrice, widget.order.symbol);
    _isSyncingSl = false;
  }

  void _syncSlPointsFromPrice(String value) {
    if (_isSyncingSl) return;
    final slPrice = double.tryParse(value.replaceAll(',', ''));
    if (slPrice == null || slPrice <= 0) {
      _isSyncingSl = true;
      slController.clear();
      _isSyncingSl = false;
      return;
    }
    final entryPrice = widget.order.priceOrder;
    if (entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.order.symbol);
    final isBuy = widget.order.orderType.toLowerCase().contains('buy');
    final points = isBuy ? (entryPrice - slPrice) / pointValue : (slPrice - entryPrice) / pointValue;
    if (points < 0) {
      _isSyncingSl = true;
      slController.clear();
      _isSyncingSl = false;
      return;
    }
    _isSyncingSl = true;
    slController.text = points.round().toString();
    _isSyncingSl = false;
  }

  void _syncTpPriceFromPoints(String value) {
    if (_isSyncingTp) return;
    final points = double.tryParse(value);
    if (points == null || points <= 0) {
      _isSyncingTp = true;
      tpPriceController.text = _formatPriceWithLeadingZeros(
        0.0, widget.order.symbol, referencePrice: widget.order.priceCurrent);
      _isSyncingTp = false;
      return;
    }
    final entryPrice = widget.order.priceOrder;
    if (entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.order.symbol);
    final isBuy = widget.order.orderType.toLowerCase().contains('buy');
    final tpPrice = isBuy ? entryPrice + (points * pointValue) : entryPrice - (points * pointValue);
    _isSyncingTp = true;
    tpPriceController.text = _formatPrice(tpPrice, widget.order.symbol);
    _isSyncingTp = false;
  }

  void _syncTpPointsFromPrice(String value) {
    if (_isSyncingTp) return;
    final tpPrice = double.tryParse(value.replaceAll(',', ''));
    if (tpPrice == null || tpPrice <= 0) {
      _isSyncingTp = true;
      tpController.clear();
      _isSyncingTp = false;
      return;
    }
    final entryPrice = widget.order.priceOrder;
    if (entryPrice <= 0) return;
    final pointValue = _getPointValue(widget.order.symbol);
    final isBuy = widget.order.orderType.toLowerCase().contains('buy');
    final points = isBuy ? (tpPrice - entryPrice) / pointValue : (entryPrice - tpPrice) / pointValue;
    if (points < 0) {
      _isSyncingTp = true;
      tpController.clear();
      _isSyncingTp = false;
      return;
    }
    _isSyncingTp = true;
    tpController.text = points.round().toString();
    _isSyncingTp = false;
  }

  @override
  void initState() {
    super.initState();
    tpController = TextEditingController(text: '');
    slController = TextEditingController(text: '');
    final zeroPrice = _formatPriceWithLeadingZeros(
      0.0, widget.order.symbol, referencePrice: widget.order.priceCurrent);
    tpPriceController = TextEditingController(text: zeroPrice);
    slPriceController = TextEditingController(text: zeroPrice);
    volumeController = TextEditingController(text: widget.order.volume.toString());
    priceController = TextEditingController(text: widget.order.priceOrder.toString());

    // Bidirectional sync listeners
    slController.addListener(() => _syncSlPriceFromPoints(slController.text));
    tpController.addListener(() => _syncTpPriceFromPoints(tpController.text));
    slPriceController.addListener(() => _syncSlPointsFromPrice(slPriceController.text));
    tpPriceController.addListener(() => _syncTpPointsFromPrice(tpPriceController.text));
  }

  @override
  void dispose() {
    tpController.dispose();
    slController.dispose();
    tpPriceController.dispose();
    slPriceController.dispose();
    volumeController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CustomColor.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.edit_bold,
                      color: CustomColor.secondaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Position',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.symbol} • Ticket #${order.ticket}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Iconsax.close_square_bold,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Order Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade900.withOpacity(0.5)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoBadge(
                      label: 'Order Price',
                      value: NumberFormat('#,##0.${'0' * order.digits}', 'en_US')
                          .format(order.priceOrder),
                      isDark: isDark,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    _buildInfoBadge(
                      label: 'Volume',
                      value: '${order.volume} lot',
                      isDark: isDark,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    _buildInfoBadge(
                      label: 'Current Price',
                      value: NumberFormat('#,##0.${'0' * order.digits}', 'en_US')
                          .format(order.priceCurrent),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Modify Position Title
              Text(
                'Modify Position',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 14),

              // Volume Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Volume (Lot)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => TextField(
                      controller: volumeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: false,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter volume',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        errorText:
                            volumeError.value.isEmpty ? null : volumeError.value,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: CustomColor.secondaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.grey.shade800.withOpacity(0.3)
                            : Colors.grey.shade50,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // // TP Field
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Row(
              //       children: [
              //         Text(
              //           'Take Profit (TP) - Points',
              //           style: GoogleFonts.inter(
              //             fontSize: 12,
              //             fontWeight: FontWeight.w600,
              //             color: isDark
              //                 ? Colors.grey.shade400
              //                 : Colors.grey.shade700,
              //           ),
              //         ),
              //         const Spacer(),
              //         Text(
              //           order.takeProfit > 0
              //               ? 'Current: ${order.takeProfit.toStringAsFixed(0)} pts'
              //               : 'Current: Not set',
              //           style: GoogleFonts.inter(
              //             fontSize: 10,
              //             color: order.takeProfit > 0
              //                 ? Colors.green
              //                 : isDark
              //                     ? Colors.grey.shade600
              //                     : Colors.grey.shade500,
              //           ),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(height: 6),
              //     Obx(
              //       () => TextField(
              //         controller: tpController,
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: false),
              //         enabled: !isSaving.value,
              //         style: GoogleFonts.inter(
              //           fontSize: 14,
              //           fontWeight: FontWeight.w600,
              //           color: isDark ? Colors.white : Colors.black87,
              //         ),
              //         decoration: InputDecoration(
              //           hintText: 'e.g., 6000 (integer points)',
              //           helperText: 'Leave empty to remove TP',
              //           counterText: '',
              //           helperStyle: GoogleFonts.inter(
              //             fontSize: 10,
              //             color: isDark
              //                 ? Colors.grey.shade600
              //                 : Colors.grey.shade500,
              //           ),
              //           hintStyle: GoogleFonts.inter(
              //             fontSize: 14,
              //             color: isDark
              //                 ? Colors.grey.shade600
              //                 : Colors.grey.shade400,
              //           ),
              //           errorText: tpError.value.isEmpty ? null : tpError.value,
              //           prefixIcon: Padding(
              //             padding: const EdgeInsets.only(left: 12, right: 8),
              //             child: Icon(
              //               Iconsax.arrow_up_bold,
              //               size: 18,
              //               color: Colors.green,
              //             ),
              //           ),
              //           contentPadding: const EdgeInsets.symmetric(
              //             horizontal: 14,
              //             vertical: 12,
              //           ),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: isDark
              //                   ? Colors.grey.shade700
              //                   : Colors.grey.shade300,
              //             ),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: CustomColor.secondaryColor,
              //               width: 2,
              //             ),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: isDark
              //                   ? Colors.grey.shade700
              //                   : Colors.grey.shade300,
              //             ),
              //           ),
              //           disabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: isDark
              //                   ? Colors.grey.shade800
              //                   : Colors.grey.shade200,
              //             ),
              //           ),
              //           filled: true,
              //           fillColor: isDark
              //               ? Colors.grey.shade800.withOpacity(0.3)
              //               : Colors.grey.shade50,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // const SizedBox(height: 16),

              // // SL Field
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Row(
              //       children: [
              //         Text(
              //           'Stop Loss (SL) - Points',
              //           style: GoogleFonts.inter(
              //             fontSize: 12,
              //             fontWeight: FontWeight.w600,
              //             color: isDark
              //                 ? Colors.grey.shade400
              //                 : Colors.grey.shade700,
              //           ),
              //         ),
              //         const Spacer(),
              //         Text(
              //           order.stopLoss > 0
              //               ? 'Current: ${order.stopLoss.toStringAsFixed(0)} pts'
              //               : 'Current: Not set',
              //           style: GoogleFonts.inter(
              //             fontSize: 10,
              //             color: order.stopLoss > 0
              //                 ? Colors.red
              //                 : isDark
              //                     ? Colors.grey.shade600
              //                     : Colors.grey.shade500,
              //           ),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(height: 6),
              //     Obx(
              //       () => TextField(
              //         controller: slController,
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: false),
              //         enabled: !isSaving.value,
              //         style: GoogleFonts.inter(
              //           fontSize: 14,
              //           fontWeight: FontWeight.w600,
              //           color: isDark ? Colors.white : Colors.black87,
              //         ),
              //         decoration: InputDecoration(
              //           hintText: 'e.g., 100 (integer points)',
              //           helperText: 'Leave empty to remove SL',
              //           counterText: '',
              //           helperStyle: GoogleFonts.inter(
              //             fontSize: 10,
              //             color: isDark
              //                 ? Colors.grey.shade600
              //                 : Colors.grey.shade500,
              //           ),
              //           hintStyle: GoogleFonts.inter(
              //             fontSize: 14,
              //             color: isDark
              //                 ? Colors.grey.shade600
              //                 : Colors.grey.shade400,
              //           ),
              //           errorText: slError.value.isEmpty ? null : slError.value,
              //           prefixIcon: Padding(
              //             padding: const EdgeInsets.only(left: 12, right: 8),
              //             child: Icon(
              //               Iconsax.arrow_down_bold,
              //               size: 18,
              //               color: Colors.red,
              //             ),
              //           ),
              //           contentPadding: const EdgeInsets.symmetric(
              //             horizontal: 14,
              //             vertical: 12,
              //           ),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: isDark
              //                   ? Colors.grey.shade700
              //                   : Colors.grey.shade300,
              //             ),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: CustomColor.secondaryColor,
              //               width: 2,
              //             ),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: isDark
              //                   ? Colors.grey.shade700
              //                   : Colors.grey.shade300,
              //             ),
              //           ),
              //           disabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: BorderSide(
              //               color: isDark
              //                   ? Colors.grey.shade800
              //                   : Colors.grey.shade200,
              //             ),
              //           ),
              //           filled: true,
              //           fillColor: isDark
              //               ? Colors.grey.shade800.withOpacity(0.3)
              //               : Colors.grey.shade50,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // const SizedBox(height: 12),

              // // "Atau" separator
              // Center(
              //   child: Text(
              //     'Atau',
              //     style: GoogleFonts.inter(
              //       fontSize: 13,
              //       fontWeight: FontWeight.w600,
              //       color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              //     ),
              //   ),
              // ),

              const SizedBox(height: 12),

              // SL/TP Prices Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stop Loss (Prices)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800.withOpacity(0.3)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: TextField(
                            controller: slPriceController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            enabled: !isSaving.value,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _PriceShiftInputFormatter(
                                decimalPlaces: _getDigitsForSymbol(order.symbol),
                                integerDigits: order.priceCurrent > 0
                                    ? order.priceCurrent.truncate().toString().length
                                    : 4,
                              ),
                            ],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                              prefixIcon: Icon(
                                Iconsax.shield_cross_bold,
                                size: 16,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Take Profit (Prices)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800.withOpacity(0.3)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: TextField(
                            controller: tpPriceController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            enabled: !isSaving.value,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _PriceShiftInputFormatter(
                                decimalPlaces: _getDigitsForSymbol(order.symbol),
                                integerDigits: order.priceCurrent > 0
                                    ? order.priceCurrent.truncate().toString().length
                                    : 4,
                              ),
                            ],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                              prefixIcon: Icon(
                                Iconsax.medal_star_bold,
                                size: 16,
                                color: Colors.green.shade400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => OutlinedButton(
                        onPressed: isSaving.value
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isSaving.value
                            ? null
                            : () => _submitEditPosition(
                                  order,
                                  tpController,
                                  slController,
                                  volumeController,
                                  isSaving,
                                  tpError,
                                  slError,
                                  volumeError,
                                  priceError,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          disabledBackgroundColor: CustomColor.secondaryColor
                              .withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving.value
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Update Position',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _submitEditPosition(
    PendingOrderItem order,
    TextEditingController tpController,
    TextEditingController slController,
    TextEditingController volumeController,
    RxBool isSaving,
    RxString tpError,
    RxString slError,
    RxString volumeError,
    RxString priceError,
  ) async {
    // Reset errors
    tpError.value = '';
    slError.value = '';
    volumeError.value = '';
    priceError.value = '';

    // Validate fields
    final tpStr = tpController.text.trim();
    final slStr = slController.text.trim();
    final volumeStr = volumeController.text.trim();

    bool hasError = false;

    // Validate volume
    if (volumeStr.isEmpty) {
      volumeError.value = 'Volume is required';
      hasError = true;
    } else {
      final volume = double.tryParse(volumeStr);
      if (volume == null || volume <= 0) {
        volumeError.value = 'Enter a valid volume';
        hasError = true;
      }
    }

    // Validate TP (must be integer)
    if (tpStr.isNotEmpty) {
      final tp = int.tryParse(tpStr);
      if (tp == null || tp <= 0) {
        tpError.value = 'Enter a valid integer points or leave empty';
        hasError = true;
      }
    }

    // Validate SL (must be integer)
    if (slStr.isNotEmpty) {
      final sl = int.tryParse(slStr);
      if (sl == null || sl <= 0) {
        slError.value = 'Enter a valid integer points or leave empty';
        hasError = true;
      }
    }

    if (hasError) return;

    isSaving.value = true;

    try {
      final requestBody = {
        'login': widget.currentLogin ?? '',
        'ticket': order.ticket.toString(),
        'is_pending': '1',  // Convert to string
        'tp': tpStr.isEmpty ? '0' : tpStr,
        'sl': slStr.isEmpty ? '0' : slStr,
        'volume': volumeStr,
      };

      debugPrint('📤 Modifying position: $requestBody');

      final response = await widget.authService.post(
        'market/execution/modify',
        requestBody,
      );

      debugPrint('📥 Modify response: $response (type: ${response.runtimeType})');

      // Handle response from API
      bool isSuccess = false;
      String message = 'Position updated successfully';

      try {
        // Response is a Map from authService.post()
        // Check for status field
        if (response.containsKey('status')) {
          isSuccess = response['status'] == true || response['status'] == 1;
          message = response['message']?.toString() ?? 'Position updated successfully';
          debugPrint('✅ Map response - isSuccess: $isSuccess, message: $message');
        } else if (response.containsKey('0') && response.containsKey('1')) {
          // Weird case where response has numeric keys like a list
          isSuccess = response['0'] == 1 || response['0'] == true;
          message = response['1']?.toString() ?? 'Position updated successfully';
          debugPrint('✅ Numeric keys response - isSuccess: $isSuccess, message: $message');
        } else {
          debugPrint('⚠️ Unknown response format. Keys: ${response.keys}');
          // Treat as success by default if response exists
          isSuccess = true;
          message = 'Position updated successfully';
        }
      } catch (parseErr) {
        debugPrint('❌ Response parse error: $parseErr');
        message = 'Error: ${parseErr.toString()}';
        isSuccess = false;
      }

      if (isSuccess) {
        Navigator.pop(context); // Close bottom sheet
        // Play success sound
        _EditPositionDialogState._playSuccessSound();
        AppSnackbar.success(message);
      } else {
        AppSnackbar.error(message);
      }
    } catch (e) {
      debugPrint('❌ Modify position error: $e');
      AppSnackbar.error(
        'Failed to update position. Please try again.',
      );
    } finally {
      isSaving.value = false;
    }
  }
}

/// ATM-style input formatter for price fields in pending order edit dialog
class _PriceShiftInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final int integerDigits;

  _PriceShiftInputFormatter({
    required this.decimalPlaces,
    this.integerDigits = 4,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      final zero = _formatNumber(0);
      return TextEditingValue(
        text: zero,
        selection: TextSelection.collapsed(offset: zero.length),
      );
    }

    int value = int.tryParse(digits) ?? 0;
    String formatted = _formatNumber(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int value) {
    double divisor = 1.0;
    for (int i = 0; i < decimalPlaces; i++) {
      divisor *= 10;
    }
    double result = value / divisor;

    String formatted = result.toStringAsFixed(decimalPlaces);
    List<String> parts = formatted.split('.');
    String intPart = parts[0].padLeft(integerDigits, '0');
    String decPart = parts.length > 1 ? parts[1] : ''.padRight(decimalPlaces, '0');

    return '$intPart.$decPart';
  }
}
