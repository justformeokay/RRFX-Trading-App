import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:shimmer/shimmer.dart';

class CloseTransactionMeta5 extends StatefulWidget {
  const CloseTransactionMeta5({super.key});

  @override
  State<CloseTransactionMeta5> createState() => _CloseTransactionMeta5State();
}

class _CloseTransactionMeta5State extends State<CloseTransactionMeta5> {
  final TradingController tradingController = Get.put(TradingController());
  final AccountController controller = Get.put(AccountController());
  RxBool isLoading = false.obs;
  
  // Filter & Sort state
  String selectedSymbol = 'All';
  String sortBy = 'closeTime'; // ticket, type, volume, openTime, closeTime, profit
  bool sortAscending = false;
  String filterPeriod = 'All'; // All, Today, Last Week, Last Month, Last 3 Months, Custom
  DateTime? customStartDate;
  DateTime? customEndDate;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadClosedOrders);
  }

  Future<void> _loadClosedOrders() async {
    if (!controller.hasAccounts) {
      Get.log("TIDAK MEMILIKI AKUN TRADING DEMO MAUPUN REAL");
      return;
    }

    isLoading.value = true;
    String? loginID = controller.selectedAccount.value?.login;

    if (loginID != null) {
      await tradingController.closedOrder(login: loginID);
    }

    isLoading.value = false;

    await Future.delayed(const Duration(milliseconds: 600)); // smooth
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasAccounts) return noAccountDetected();
      var closed = tradingController.tradingHistoryModel.value?.response;
      if (closed == null) {
        return _buildShimmerList(context);
      }
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // Filter & Sort Bar
            SliverToBoxAdapter(
              child: _buildFilterBar(context, closed),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _BalanceHeaderDelegate(),
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

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final filteredAndSorted = _getFilteredAndSortedOrders(closed);
                if (index >= filteredAndSorted.length) return null;
                
                final order = filteredAndSorted[index];
                return _PositionTile(
                  index: index,
                  positionId: "${order.ticket}",
                  swap: "-",
                  stopLoss: "${order.stopLoss}",
                  openTime: "${order.openTime}",
                  closeTime: "${order.closeTime}",
                  takeProfit: "${order.takeProfit}",
                  doubleProfit: -0.10 * index,
                  profit:
                      order.profit != null
                          ? "${order.profit}"
                          : "0.00",
                  symbol: "${order.symbol}",
                  direction: "${order.orderType}",
                  volume: _formatLot(order.lot),
                  openPrice: "${order.openPrice}",
                  closePrice: "${order.closePrice}",
                );
              }, childCount: _getFilteredAndSortedOrders(closed).length),
            ),
          ],
        ),
      );
    });
  }

  // Filter dan Sort Logic
  List<dynamic> _getFilteredAndSortedOrders(List<dynamic> orders) {
    if (orders.isEmpty) return [];
    
    var filtered = orders.where((order) {
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
              if (closeTime.isBefore(customStartDate!) || closeTime.isAfter(customEndDate!)) {
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
    final symbols = orders.map((o) => o.symbol?.toString() ?? '').where((s) => s.isNotEmpty).toSet().toList();
    symbols.sort();
    return ['All', ...symbols];
  }

  Widget _buildFilterBar(BuildContext context, List<dynamic> orders) {
    final theme = Theme.of(context);
    final symbols = _getUniqueSymbols(orders);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Symbol Filter
          Row(
            children: [
              Icon(Iconsax.chart_outline, size: 18, color: CustomColor.secondaryColor),
              const SizedBox(width: 8),
              Text(
                'Symbol:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: symbols.length,
                    itemBuilder: (context, index) {
                      final symbol = symbols[index];
                      final isSelected = selectedSymbol == symbol;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            symbol,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: CustomColor.secondaryColor,
                          backgroundColor: theme.cardColor,
                          side: BorderSide(
                            color: isSelected ? CustomColor.secondaryColor : Colors.grey.withOpacity(0.3),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              selectedSymbol = symbol;
                            });
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          labelPadding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Row 2: Sort By
          Row(
            children: [
              Icon(Iconsax.sort_outline, size: 18, color: CustomColor.secondaryColor),
              const SizedBox(width: 8),
              Text(
                'Sort:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip(context, 'Ticket', 'ticket'),
                      _buildSortChip(context, 'Type', 'type'),
                      _buildSortChip(context, 'Volume', 'volume'),
                      _buildSortChip(context, 'Open Time', 'openTime'),
                      _buildSortChip(context, 'Close Time', 'closeTime'),
                      _buildSortChip(context, 'Profit', 'profit'),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  sortAscending ? Iconsax.arrow_up_3_outline : Iconsax.arrow_down_outline,
                  size: 20,
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
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Row 3: Period Filter
          Row(
            children: [
              Icon(Iconsax.calendar_outline, size: 18, color: CustomColor.secondaryColor),
              const SizedBox(width: 8),
              Text(
                'Period:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPeriodChip(context, 'All'),
                      _buildPeriodChip(context, 'Today'),
                      _buildPeriodChip(context, 'Last Week'),
                      _buildPeriodChip(context, 'Last Month'),
                      _buildPeriodChip(context, 'Last 3 Months'),
                      _buildPeriodChip(context, 'Custom'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Custom Date Range (if Custom selected)
          if (filterPeriod == 'Custom') ...[
            const SizedBox(height: 8),
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
                const SizedBox(width: 8),
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
  
  Widget _buildSortChip(BuildContext context, String label, String value) {
    final isSelected = sortBy == value;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : theme.textTheme.bodyMedium?.color,
          ),
        ),
        selected: isSelected,
        selectedColor: CustomColor.secondaryColor,
        backgroundColor: theme.cardColor,
        side: BorderSide(
          color: isSelected ? CustomColor.secondaryColor : Colors.grey.withOpacity(0.3),
        ),
        onSelected: (selected) {
          setState(() {
            sortBy = value;
          });
        },
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelPadding: EdgeInsets.zero,
      ),
    );
  }
  
  Widget _buildPeriodChip(BuildContext context, String period) {
    final isSelected = filterPeriod == period;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          period,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : theme.textTheme.bodyMedium?.color,
          ),
        ),
        selected: isSelected,
        selectedColor: CustomColor.secondaryColor,
        backgroundColor: theme.cardColor,
        side: BorderSide(
          color: isSelected ? CustomColor.secondaryColor : Colors.grey.withOpacity(0.3),
        ),
        onSelected: (selected) {
          setState(() {
            filterPeriod = period;
            if (period != 'Custom') {
              customStartDate = null;
              customEndDate = null;
            }
          });
        },
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelPadding: EdgeInsets.zero,
      ),
    );
  }
  
  Widget _buildDateButton(BuildContext context, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: CustomColor.secondaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.calendar_1_outline, size: 16, color: CustomColor.secondaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
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

  Widget _buildShimmerList(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;

    // Base shimmer = permukaan + sedikit opasitas
    final base = onSurface.withOpacity(0.10);
    final highlight = onSurface.withOpacity(0.20);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 2,
      itemBuilder: (context, i) {
        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 80,
            decoration: BoxDecoration(color: surface.withOpacity(0.6)),
          ),
        );
      },
    );
  }
}

// ---------------- BALANCE SECTION --------------------
class _BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
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
      padding: const EdgeInsets.all(16),
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
          Obx(
            () => _balanceRow(
              "Deposit",
              accountController.selectedAccount.value?.totalDepositUsd ?? "0",
              context,
            ),
          ),
          _balanceRow("Swap", "-", context),
          _balanceRow("Commission", "-", context),
          Obx(
            () => _balanceRow(
              "Balance",
              "${accountController.selectedAccount.value?.balance ?? "N/A"} ${accountController.selectedAccount.value?.accountCurrency ?? "0"}",
              context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w800,
          )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '. ' * 100,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: GoogleFonts.roboto(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.3),
                ),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Get.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w800,
            )
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _PositionTile extends StatelessWidget {
  final int index;
  final String? positionId;
  final String? openTime;
  final String? swap;
  final String? stopLoss;
  final String? takeProfit;
  final double? doubleProfit;
  final String? profit;
  final String? symbol;
  final String? direction;
  final String? volume;
  final String? openPrice;
  final String? closePrice;
  final String? closeTime;

  const _PositionTile({
    required this.index,
    this.positionId,
    this.openTime,
    this.closeTime,
    this.swap,
    this.stopLoss,
    this.takeProfit,
    this.doubleProfit,
    this.profit,
    this.symbol,
    this.direction,
    this.volume,
    this.openPrice,
    this.closePrice,
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

    return Slidable(
      key: ValueKey(positionId),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
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
            style: GoogleFonts.oswald(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: Get.theme.textTheme.bodySmall?.color,
            ),
          ),

          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$closeTime",
                style: GoogleFonts.oswald(
                  color: Get.theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profitText,
                style: GoogleFonts.oswald(
                  color: profitColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
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
                              style: GoogleFonts.oswald(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                openTime ?? "-",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.oswald(
                                  fontSize: 13.0,
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
                              style: GoogleFonts.oswald(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                (stopLoss != null && stopLoss != "0")
                                    ? stopLoss!
                                    : "–",
                                style: GoogleFonts.oswald(
                                  fontSize: 13.0,
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
                              style: GoogleFonts.oswald(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Get.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                swap ?? "0.00",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.oswald(
                                  fontSize: 13.0,
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
                      Text(
                        "T / P: ",
                        style: GoogleFonts.oswald(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        (takeProfit != null && takeProfit != "0")
                            ? takeProfit!
                            : "–",
                        style: GoogleFonts.oswald(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
