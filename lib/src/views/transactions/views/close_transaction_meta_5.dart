import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/trading.dart';

class CloseTransactionMeta5 extends StatefulWidget {
  const CloseTransactionMeta5({super.key});

  @override
  State<CloseTransactionMeta5> createState() => _CloseTransactionMeta5State();
}

class _CloseTransactionMeta5State extends State<CloseTransactionMeta5> {
  final TradingController tradingController = Get.put(TradingController());
  final AccountController controller = Get.put(AccountController());

  // Filter & Sort state
  String selectedSymbol = 'All';
  String sortBy = 'closeTime';
  bool sortAscending = false;
  String filterPeriod = 'All';
  DateTime? customStartDate;
  DateTime? customEndDate;

  // Cache to avoid recomputation every frame
  List<String> _cachedSymbols = const ['All'];
  List<dynamic>? _lastRawOrders;

  @override
  void initState() {
    super.initState();
    _loadClosedOrders();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadClosedOrders() async {
    if (!controller.hasAccounts) return;

    final loginID = controller.selectedAccount.value?.login;
    if (loginID != null) {
      await tradingController.closedOrder(login: loginID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasAccounts) return noAccountDetected();

      final closed = tradingController.tradingHistoryModel.value?.response;

      // Compute ONCE, reuse everywhere (sebelumnya dihitung 3-5x per frame)
      final filteredOrders =
          closed != null && closed.isNotEmpty
              ? _getFilteredAndSortedOrders(closed)
              : <dynamic>[];
      final totals = _calculateTotals(filteredOrders);

      // Cache unique symbols hanya saat raw data berubah
      if (closed != null && !identical(closed, _lastRawOrders)) {
        _lastRawOrders = closed;
        _cachedSymbols = _getUniqueSymbols(closed);
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            if (closed != null)
              SliverToBoxAdapter(child: _buildFilterBar(context)),

            SliverPersistentHeader(
              pinned: true,
              delegate: _BalanceHeaderDelegate(
                totalSwap: totals['swap']!,
                totalCommission: totals['commission']!,
                totalProfit: totals['profit']!,
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Text(
                  "Closed Positions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Show loading indicator or positions list
            if (closed == null)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                ),
              )
            else if (closed.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with gradient background
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CustomColor.secondaryColor.withValues(
                                  alpha: 0.15,
                                ),
                                Colors.orange.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Iconsax.folder_open_outline,
                              size: 60,
                              color: CustomColor.secondaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          "No Trading History",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          "You haven't closed any trading positions yet. Your trading history will appear here.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Info cards
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                context,
                                icon: Iconsax.clock_outline,
                                title: "Automatic Recording",
                                description:
                                    "All closed positions are automatically saved here",
                              ),
                              const SizedBox(height: 16),
                              Divider(
                                height: 1,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                context,
                                icon: Iconsax.document_text_outline,
                                title: "Detailed Reports",
                                description:
                                    "View profit/loss, open/close prices, and more",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final order = filteredOrders[index];
                  return _PositionTile(
                    positionId: "${order.ticket}",
                    swap: "${order.swap}",
                    stopLoss: "${order.stopLoss}",
                    openTime: _formatTime("${order.openTime}"),
                    closeTime: _formatTime("${order.closeTime}"),
                    takeProfit: "${order.takeProfit}",
                    profit: order.profit != null ? "${order.profit}" : "0.00",
                    symbol: "${order.symbol}",
                    direction: "${order.orderType}",
                    volume: _formatLot(order.lot),
                    openPrice: "${order.openPrice}",
                    closePrice: "${order.closePrice}",
                    commission: "${order.commission}",
                  );
                }, childCount: filteredOrders.length),
              ),
          ],
        ),
      );
    });
  }

  // Filter dan Sort Logic
  List<dynamic> _getFilteredAndSortedOrders(List<dynamic> orders) {
    if (orders.isEmpty) return [];

    var filtered =
        orders.where((order) {
          // Filter by symbol
          if (selectedSymbol != 'All' && order.symbol != selectedSymbol) {
            return false;
          }

          // Filter by period
          if (filterPeriod != 'All') {
            final closeTime = _parseDateTime(order.closeTime);
            if (closeTime == null) return false;

            final now = DateTime.now();
            DateTime startDate;

            switch (filterPeriod) {
              case 'Today':
                startDate = DateTime(now.year, now.month, now.day);
                break;
              case 'Last Week':
                startDate = now.subtract(const Duration(days: 7));
                break;
              case 'Last Month':
                startDate = now.subtract(const Duration(days: 30));
                break;
              case 'Last 3 Months':
                startDate = now.subtract(const Duration(days: 90));
                break;
              case 'Custom':
                if (customStartDate != null && customEndDate != null) {
                  if (closeTime.isBefore(customStartDate!) ||
                      closeTime.isAfter(customEndDate!)) {
                    return false;
                  }
                }
                return true;
              default:
                return true;
            }

            if (closeTime.isBefore(startDate)) {
              return false;
            }
          }

          return true;
        }).toList();

    // Sort
    filtered.sort((a, b) {
      int result = 0;

      switch (sortBy) {
        case 'ticket':
          result = (a.ticket ?? 0).compareTo(b.ticket ?? 0);
          break;
        case 'type':
          result = (a.orderType ?? '').compareTo(b.orderType ?? '');
          break;
        case 'volume':
          final aVol = double.tryParse(a.lot?.toString() ?? '0') ?? 0;
          final bVol = double.tryParse(b.lot?.toString() ?? '0') ?? 0;
          result = aVol.compareTo(bVol);
          break;
        case 'openTime':
          final aTime = _parseDateTime(a.openTime);
          final bTime = _parseDateTime(b.openTime);
          if (aTime != null && bTime != null) {
            result = aTime.compareTo(bTime);
          }
          break;
        case 'closeTime':
          final aTime = _parseDateTime(a.closeTime);
          final bTime = _parseDateTime(b.closeTime);
          if (aTime != null && bTime != null) {
            result = aTime.compareTo(bTime);
          }
          break;
        case 'profit':
          final aProfit = double.tryParse(a.profit?.toString() ?? '0') ?? 0;
          final bProfit = double.tryParse(b.profit?.toString() ?? '0') ?? 0;
          result = aProfit.compareTo(bProfit);
          break;
      }

      return sortAscending ? result : -result;
    });

    return filtered;
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return null;
    }
  }

  List<String> _getUniqueSymbols(List<dynamic> orders) {
    final symbols =
        orders
            .map((o) => o.symbol?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    symbols.sort();
    return ['All', ...symbols];
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final symbols = _cachedSymbols;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.filter_outline,
                  size: 20,
                  color: CustomColor.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Filter & Sort',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              if (selectedSymbol != 'All' ||
                  sortBy != 'closeTime' ||
                  filterPeriod != 'All')
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedSymbol = 'All';
                      sortBy = 'closeTime';
                      sortAscending = false;
                      filterPeriod = 'All';
                      customStartDate = null;
                      customEndDate = null;
                    });
                  },
                  icon: const Icon(Iconsax.refresh_outline, size: 16),
                  label: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: CustomColor.secondaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Icon Dropdown Row
          Row(
            children: [
              // Symbol Dropdown (Icon Only)
              Expanded(
                child: _buildIconDropdown(
                  context: context,
                  icon: Iconsax.chart_outline,
                  tooltip: 'Symbol',
                  value: selectedSymbol,
                  items: symbols,
                  onChanged: (value) {
                    setState(() {
                      selectedSymbol = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Sort By Dropdown (Icon Only)
              Expanded(
                child: _buildIconDropdown(
                  context: context,
                  icon: Iconsax.sort_outline,
                  tooltip: 'Sort By',
                  value: sortBy,
                  items: const [
                    'ticket',
                    'type',
                    'volume',
                    'openTime',
                    'closeTime',
                    'profit',
                  ],
                  itemLabels: const {
                    'ticket': 'Ticket',
                    'type': 'Type',
                    'volume': 'Volume',
                    'openTime': 'Open Time',
                    'closeTime': 'Close Time',
                    'profit': 'Profit',
                  },
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      sortAscending
                          ? Iconsax.arrow_up_3_outline
                          : Iconsax.arrow_down_outline,
                      size: 16,
                      color: CustomColor.secondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        sortAscending = !sortAscending;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Period Dropdown (Icon Only)
              Expanded(
                child: _buildIconDropdown(
                  context: context,
                  icon: Iconsax.calendar_outline,
                  tooltip: 'Period',
                  value: filterPeriod,
                  items: const [
                    'All',
                    'Today',
                    'Last Week',
                    'Last Month',
                    'Last 3 Months',
                    'Custom',
                  ],
                  onChanged: (value) {
                    setState(() {
                      filterPeriod = value!;
                      if (value != 'Custom') {
                        customStartDate = null;
                        customEndDate = null;
                      }
                    });
                  },
                ),
              ),
            ],
          ),

          // Custom Date Range
          if (filterPeriod == 'Custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    context,
                    customStartDate != null
                        ? DateFormat('dd/MM/yy').format(customStartDate!)
                        : 'Start Date',
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: customStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          customStartDate = date;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateButton(
                    context,
                    customEndDate != null
                        ? DateFormat('dd/MM/yy').format(customEndDate!)
                        : 'End Date',
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: customEndDate ?? DateTime.now(),
                        firstDate: customStartDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          customEndDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconDropdown({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (suffixIcon != null) suffixIcon,
                Icon(
                  Iconsax.arrow_down_1_outline,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ],
            ),
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((String item) {
                return Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: CustomColor.secondaryColor,
                  ),
                );
              }).toList();
            },
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            items:
                items.map((String item) {
                  final displayLabel = itemLabels?[item] ?? item;
                  final isSelected = value == item;

                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color:
                              isSelected
                                  ? CustomColor.secondaryColor
                                  : theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayLabel,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? CustomColor.secondaryColor
                                      : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Iconsax.tick_circle_bold,
                            size: 18,
                            color: CustomColor.secondaryColor,
                          ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.calendar_1_outline,
              size: 16,
              color: CustomColor.secondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLot(dynamic lot) {
    if (lot == null) return "0.00";

    // Convert string angka seperti "0.10000" → double → format 2 decimal
    final value = double.tryParse(lot.toString()) ?? 0.0;

    return value.toStringAsFixed(2);
  }

  /// Format time to Meta-style format (YYYY.MM.DD HH:mm:ss) with -7 hours offset
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    
    try {
      // Parse the DateTime from the string
      DateTime dateTime = DateTime.parse(timeStr);
      
      // Subtract 7 hours for timezone offset
      dateTime = dateTime.subtract(const Duration(hours: 7));
      
      // Format as YYYY.MM.DD HH:mm:ss (Meta-style)
      return DateFormat('yyyy.MM.dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return timeStr; // Return original if parsing fails
    }
  }

  // Calculate total swap and commission from filtered orders
  Map<String, double> _calculateTotals(List<dynamic> orders) {
    double totalSwap = 0.0;
    double totalCommission = 0.0;
    double totalProfit = 0.0;

    for (var order in orders) {
      // Handle swap - treat null, empty, or invalid as 0
      final swapValue = double.tryParse(order.swap?.toString() ?? '0') ?? 0.0;
      totalSwap += swapValue;

      // Handle commission - treat null, empty, or invalid as 0
      final commissionValue =
          double.tryParse(order.commission?.toString() ?? '0') ?? 0.0;
      totalCommission += commissionValue;

      // Handle profit - treat null, empty, or invalid as 0
      final profitValue =
          double.tryParse(order.profit?.toString() ?? '0') ?? 0.0;
      totalProfit += profitValue;
    }

    return {
      'swap': totalSwap,
      'commission': totalCommission,
      'profit': totalProfit,
    };
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor.withValues(alpha: 0.1),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double totalSwap;
  final double totalCommission;
  final double totalProfit;

  _BalanceHeaderDelegate({
    required this.totalSwap,
    required this.totalCommission,
    required this.totalProfit,
  });

  @override
  double get minExtent => 140;

  @override
  double get maxExtent => 150;

  final accountController = Get.find<AccountController>();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => _balanceRow(
              "Account ID",
              accountController.selectedAccount.value?.login ?? "N/A",
              context,
            ),
          ),
          _balanceRow("Profit", totalProfit.toStringAsFixed(2), context),
          _balanceRow("Swap", totalSwap.toStringAsFixed(2), context),
          _balanceRow(
            "Commission",
            totalCommission.toStringAsFixed(2),
            context,
          ),
          Obx(
            () => _balanceRow(
              "Balance",
              accountController.selectedAccount.value?.balance ?? "N/A",
              context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '. ' * 80,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: GoogleFonts.roboto(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Get.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _BalanceHeaderDelegate oldDelegate) =>
      totalSwap != oldDelegate.totalSwap ||
      totalCommission != oldDelegate.totalCommission ||
      totalProfit != oldDelegate.totalProfit;
}

class _PositionTile extends StatelessWidget {
  final String? positionId;
  final String? openTime;
  final String? swap;
  final String? stopLoss;
  final String? takeProfit;
  final String? profit;
  final String? symbol;
  final String? direction;
  final String? volume;
  final String? openPrice;
  final String? closePrice;
  final String? closeTime;
  final String? commission;

  const _PositionTile({
    this.positionId,
    this.openTime,
    this.closeTime,
    this.swap,
    this.stopLoss,
    this.takeProfit,
    this.profit,
    this.symbol,
    this.direction,
    this.volume,
    this.openPrice,
    this.closePrice,
    this.commission,
  });

  @override
  Widget build(BuildContext context) {
    final double parsedProfit = double.tryParse(profit ?? "0") ?? 0.0;

    final bool isPositive = parsedProfit > 0;
    final bool isNegative = parsedProfit < 0;

    final String profitText =
        isPositive
            ? parsedProfit.toStringAsFixed(2)
            : isNegative
            ? "-${parsedProfit.abs().toStringAsFixed(2)}"
            : "0.00";

    final Color profitColor =
        isPositive
            ? Colors.blue
            : isNegative
            ? Colors.red
            : Theme.of(context).colorScheme.onSurfaceVariant;

    final Color buySellColor =
        direction?.toLowerCase() == "buy" ? Colors.blue : Colors.red;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey(positionId),
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: symbol ?? "-",
                style: GoogleFonts.oswald(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const TextSpan(text: ", "),
              TextSpan(
                text:
                    direction != null
                        ? "${direction!.toLowerCase()} ${volume ?? "0.0"}"
                        : "-",
                style: GoogleFonts.oswald(
                  color: buySellColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        subtitle: Text(
          "${openPrice ?? '0.00000'} → ${closePrice == "null" || closePrice == null || closePrice == "" ? '0' : closePrice}",
          style: GoogleFonts.poppins(
            fontSize: 10.0,
            fontWeight: FontWeight.w700,
            color: Get.theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              closeTime ?? '-',
              style: GoogleFonts.poppins(
                color: Get.theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
                fontSize: 10.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profitText,
              style: GoogleFonts.poppins(
                color: profitColor,
                fontWeight: FontWeight.w600,
                fontSize: 10.0,
              ),
            ),
          ],
        ),

        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Get.theme.dividerColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROW 1: Position ID + Open Time
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "#${positionId ?? "-"}",
                        style: GoogleFonts.oswald(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Open: ",
                            style: GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              openTime ?? "-",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ROW 2: SL + Swap
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "S / L: ",
                            style: GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (stopLoss != null && stopLoss != "0")
                                  ? stopLoss!
                                  : "–",
                              style: GoogleFonts.poppins(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Swap: ",
                            style: GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              swap ?? "0.00",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ROW 3: TP only (Left)
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "T / P: ",
                            style: GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            (takeProfit != null && takeProfit != "0")
                                ? takeProfit!
                                : "–",
                            style: GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Commission: ",
                            style: GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              commission ?? "-",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
