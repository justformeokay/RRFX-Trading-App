import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
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
    with AutomaticKeepAliveClientMixin {
  late final AccountController _accountController;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const String _wsUrl = 'wss://ws-rrfx.techcrm.dev/openposition';

  final Rx<PendingWSStatus> status = PendingWSStatus.disconnected.obs;
  final RxList<PendingOrderItem> pendingOrders = <PendingOrderItem>[].obs;
  final RxBool isFirstLoad = true.obs;

  String? _currentLogin;
  String? _currentServerType;
  Worker? _accountListener;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

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
  void dispose() {
    _accountListener?.dispose();
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

      _channel!.stream.listen(
        (message) {
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
          debugPrint('❌ [PendingWS] Error: $err');
          status.value = PendingWSStatus.failed;
          if (!_isManuallyDisconnected) _scheduleReconnect();
        },
        onDone: () {
          status.value = PendingWSStatus.disconnected;
          if (!_isManuallyDisconnected) _scheduleReconnect();
        },
        cancelOnError: false,
      );

      // Send subscribe message after brief delay for connection establishment
      if (_currentLogin != null && _currentServerType != null) {
        Future.delayed(const Duration(milliseconds: 500), _sendSubscribeMessage);
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
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectAttempts++;
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isManuallyDisconnected) {
        try {
          _channel?.sink.close();
        } catch (_) {}
        _connectWebSocket();
      }
    });
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

    switch (wsStatus) {
      case PendingWSStatus.connecting:
        bgColor = Colors.orange.shade600;
        text = 'Menghubungkan ke server...';
        icon = Icons.sync;
        break;
      case PendingWSStatus.failed:
        bgColor = Colors.red.shade600;
        text = 'Koneksi gagal. Mencoba ulang...';
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
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (wsStatus == PendingWSStatus.failed ||
              wsStatus == PendingWSStatus.disconnected)
            GestureDetector(
              onTap: () {
                if (_currentLogin != null && _currentServerType != null) {
                  _reconnectAttempts = 0;
                  _subscribe(
                    login: _currentLogin!,
                    serverType: _currentServerType!,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
            fontSize: 12,
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
      return DateFormat('dd/MM/yy HH:mm').format(dt);
    } catch (_) {
      return '—';
    }
  }
}
