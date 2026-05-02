import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/account_credentials_service.dart';
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
  String get _mt5ApiBase => GlobalVariable.tradingApiBase;

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
      if (!_accountController.hasAccounts && _accountController.isInitialLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: CustomColor.secondaryColor),
          ),
        );
      }
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
        return EditPositionDialog(
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
                          color: Get.isDarkMode ? Colors.white : Colors.black87,
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
              DefaultTextStyle(
                style: GoogleFonts.inter(
                  color: Get.isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text(
                  'Cancelling order...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      closingOrder(loginID: _currentLogin ?? '', ticketID: order.ticket.toString())
          .then((result) {
        if (Get.isDialogOpen ?? false) Get.back();
        if (result['status'] == true) {
          AppSnackbar.success(
            result['message'] ?? 'Pending order cancelled successfully',
          );
          // Optimistically remove from list; WebSocket will sync real state
          pendingOrders.removeWhere((item) => item.ticket == order.ticket);
        } else {
          final errorMessage = result['message'] ?? 'Failed to cancel pending order';
          AppSnackbar.error(errorMessage);
        }
      }).catchError((e) {
        if (Get.isDialogOpen ?? false) Get.back();
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        AppSnackbar.error(errorMsg);
      });
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(
        'Failed to cancel pending order. Please try again.',
      );
    } finally {
      _isCancelling.value = false;
    }
  }


  Future<Map<String, dynamic>> closingOrder({
    required String loginID,
    required String? ticketID,
  }) async {
    try {
      // Get token (auto-fetch if missing)
      String? token = AccountCredentialsService.getTokenByLogin(loginID);
      if (token == null || token.isEmpty) {
        if (!AccountCredentialsService.hasCachedData()) {
          await AccountCredentialsService.fetchAndCache(forceRefresh: true);
        } else {
          token = await AccountCredentialsService.refreshTokenForLogin(loginID);
        }
        token ??= AccountCredentialsService.getTokenByLogin(loginID);
        if (token == null || token.isEmpty) {
          throw Exception('Gagal mendapatkan koneksi MT5 untuk login $loginID.');
        }
      }

      // First attempt
      var result = await _callOrderCloseSafe(token: token, ticket: ticketID ?? '');

      // Handle INVALID_TOKEN → refresh token and retry once
      if (result.containsKey('code') && result['code'] == 'INVALID_TOKEN') {
        // Get.log('🔄 [CLOSE] INVALID_TOKEN → refreshing token for login $loginID...');
        final newToken = await AccountCredentialsService.refreshTokenForLogin(loginID);
        if (newToken == null || newToken.isEmpty) {
          throw Exception('Koneksi MT5 gagal. Silakan login ulang.');
        }
        result = await _callOrderCloseSafe(token: newToken, ticket: ticketID ?? '');
      }

      // Handle other error codes
      if (result.containsKey('code') && result['code'] != null) {
        final errorMsg = result['message'] ?? 'Close order gagal';
        throw Exception(errorMsg);
      }

      // Validate ticket in response
      final responseTicket = result['ticket'];
      if (responseTicket == null || responseTicket == 0) {
        final errorMsg = result['message'] ?? 'Close order gagal: tidak mendapat ticket.';
        throw Exception(errorMsg);
      }

      // Get.log('✅ [CLOSE] Position closed successfully! Ticket: $responseTicket');

      // Signal the chart WebView to refresh (position was closed)

      return {
        'status': true,
        'message': 'Position berhasil ditutup',
        'data': result,
      };
    } catch (e) {
      final errMsg = e.toString().replaceAll('Exception: ', '');
      throw Exception(errMsg);
    }
  }

  /// Internal: call OrderCloseSafe API
  Future<Map<String, dynamic>> _callOrderCloseSafe({
    required String token,
    required String ticket,
  }) async {
    final uri = Uri.parse(
      '$_mt5ApiBase/OrderClose'
      '?id=$token'
      '&ticket=$ticket'
      '&lots=0'
      '&price=0'
      '&slippage=0',
    );

    Get.log('📦 [CLOSE] Request URL: $uri');

    final response = await http.get(
      uri,
      headers: {'accept': 'text/json'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Close order timeout, coba lagi.'),
    );

    Get.log('📥 [CLOSE] Response status: ${response.statusCode}');
    Get.log('📥 [CLOSE] Response body: ${response.body}');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class EditPositionDialog extends StatefulWidget {
  final PendingOrderItem order;
  final AuthService authService;
  final String? currentLogin;

  const EditPositionDialog({super.key, 

    required this.order,
    required this.authService,
    required this.currentLogin,
  });

  @override
  State<EditPositionDialog> createState() => _EditPositionDialogState();
}

class _EditPositionDialogState extends State<EditPositionDialog> {
  late TextEditingController priceController;
  late TextEditingController volumeController;
  late TextEditingController slController;
  late TextEditingController tpController;
  String get _mt5ApiBase => GlobalVariable.tradingApiBase;

  final isSaving = RxBool(false);

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan data awal dari order
    priceController = TextEditingController(text: widget.order.priceOrder.toString());
    volumeController = TextEditingController(text: widget.order.volume.toString());
    // Change .sl to .stopLoss and .tp to .takeProfit
    slController = TextEditingController(
      text: widget.order.stopLoss != 0 ? widget.order.stopLoss.toString() : ''
    );
    tpController = TextEditingController(
      text: widget.order.takeProfit != 0 ? widget.order.takeProfit.toString() : ''
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    volumeController.dispose();
    slController.dispose();
    tpController.dispose();
    super.dispose();
  }

  // --- LOGIKA VALIDASI PENDING ORDER ---
  String? _validatePendingOrder(double entry, double current, String type) {
    final t = type.toLowerCase();
    if (t.contains('buy limit') && entry >= current) return "Buy Limit: Price must be BELOW current price";
    if (t.contains('sell limit') && entry <= current) return "Sell Limit: Price must be ABOVE current price";
    if (t.contains('buy stop') && entry <= current) return "Buy Stop: Price must be ABOVE current price";
    if (t.contains('sell stop') && entry >= current) return "Sell Stop: Price must be BELOW current price";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Edit ${widget.order.symbol}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Input Price & Volume
          Row(
            children: [
              Expanded(child: _buildSimpleField("Entry Price", priceController)),
              const SizedBox(width: 10),
              Expanded(child: _buildSimpleField("Volume", volumeController, disabled: true)),
            ],
          ),
          const SizedBox(height: 15),
          
          // Input SL & TP
          Row(
            children: [
              Expanded(child: _buildSimpleField("Stop Loss", slController)),
              const SizedBox(width: 10),
              Expanded(child: _buildSimpleField("Take Profit", tpController)),
            ],
          ),
          const SizedBox(height: 25),
          
          // Action Button
          Obx(() => ElevatedButton(
            onPressed: isSaving.value ? null : _handleUpdate,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: CustomColor.secondaryColor,
            ),
            child: isSaving.value 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text("UPDATE POSITION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildSimpleField(String label, TextEditingController controller, {bool? disabled}) {
  final bool isReadOnly = disabled ?? false;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ),
      TextField(
        enabled: !isReadOnly,
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          filled: true,
          fillColor: isReadOnly ? Colors.grey[100] : Colors.blueGrey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Border saat kondisi normal
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          // Border saat diklik (Focus)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          // Border saat disabled
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          hintText: 'Ketik di sini...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    ],
  );
}

  Future<void> _handleUpdate() async {
    final entry = double.tryParse(priceController.text) ?? 0;
    final current = widget.order.priceCurrent;
    final type = widget.order.orderType;

    // 1. Validasi Harga vs Market (Pending Order Rules)
    final error = _validatePendingOrder(entry, current, type);
    if (error != null) {
      AppSnackbar.error(error);
      return;
    }

    isSaving.value = true;
    try {
      // Memastikan jika input kosong, maka dikirim sebagai "0"
      final String finalPrice = priceController.text.isEmpty ? "0" : priceController.text;
      final String finalSL = slController.text.isEmpty ? "0" : slController.text;
      final String finalTP = tpController.text.isEmpty ? "0" : tpController.text;

      print("🔄 Updating pending order with Entry: $finalPrice, SL: $finalSL, TP: $finalTP");

      final result = await modifyPendingOrder(
        loginID: widget.currentLogin ?? '',
        ticketID: widget.order.ticket.toString(),
        price: finalPrice,
        stoploss: finalSL,
        takeprofit: finalTP,
      );

      if (result['status'] == true) {
        Get.back(); // Tutup bottom sheet
        AppSnackbar.success(result['message']);
      } else {
        AppSnackbar.error(result['message']);
      }
    } catch (e) {
      AppSnackbar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  Future<Map<String, dynamic>> modifyPendingOrder({
    required String loginID,
    required String ticketID,
    required String price,
    required String stoploss,
    required String takeprofit,
  }) async {
    try {
      String? token = AccountCredentialsService.getTokenByLogin(loginID);
      if (token == null || token.isEmpty) {
        await AccountCredentialsService.fetchAndCache(forceRefresh: true);
        token = AccountCredentialsService.getTokenByLogin(loginID);
      }

      if (token == null) throw Exception('Gagal mendapatkan token MT5');

      // Memanggil internal helper dengan parameter lengkap
      var result = await _callOrderModifySafe(
        token: token,
        ticket: ticketID,
        price: price,
        stoploss: stoploss,
        takeprofit: takeprofit,
      );

      // Logika Refresh Token jika INVALID_TOKEN
      if (result['code'] == 'INVALID_TOKEN') {
        final newToken = await AccountCredentialsService.refreshTokenForLogin(loginID);
        result = await _callOrderModifySafe(
          token: newToken!,
          ticket: ticketID,
          price: price,
          stoploss: stoploss,
          takeprofit: takeprofit,
        );
      }

      if (result.containsKey('code') && result['code'] != null) {
        throw Exception(result['message'] ?? 'Gagal mengubah order');
      }

      return {
        'status': true,
        'message': 'Order berhasil diperbarui',
        'data': result,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Internal: call OrderModifySafe API
  Future<Map<String, dynamic>> _callOrderModifySafe({
    required String token,
    required String ticket,
    String? stoploss,
    String? takeprofit,
    String? price,
  }) async {
    final uri = Uri.parse(
      '$_mt5ApiBase/OrderModifySafe'
      '?id=$token'
      '&ticket=$ticket'
      '&stoploss=$stoploss'
      '&takeprofit=$takeprofit'
      '&price=$price',
    );

    Get.log('📦 [MODIFY] Request URL: $uri');

    final response = await http.get(
      uri,
      headers: {'accept': 'text/json'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Close order timeout, coba lagi.'),
    );

    Get.log('📥 [CLOSE] Response status: ${response.statusCode}');
    Get.log('📥 [CLOSE] Response body: ${response.body}');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}