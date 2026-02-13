import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';

import 'detail_deposit.dart';

class DepositWithdrawalHistory extends StatefulWidget {
  const DepositWithdrawalHistory({super.key});

  @override
  State<DepositWithdrawalHistory> createState() =>
      _DepositWithdrawalHistoryState();
}

class _DepositWithdrawalHistoryState extends State<DepositWithdrawalHistory> {
  UserController userController = Get.find();

  RxList<Map<String, dynamic>> listHistoryDeposit =
      <Map<String, dynamic>>[
        {"isDeposit": true, "balance": 300},
        {"isDeposit": false, "balance": 100},
      ].obs;

  RxInt selectedIndex = 0.obs;
  RxInt initialIndexTab = 0.obs;
  RxString selectedLoginID = "".obs;
  TradingController tradingController = Get.put(TradingController());

  // Filter state variables
  final RxBool _showFilters = false.obs;
  final RxString _selectedStatus = 'all'.obs;
  final RxString _selectedDateRange = 'all'.obs;
  final RxString _selectedAccount = 'all'.obs;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // ScrollControllers for each tab
  final ScrollController _depositScrollController = ScrollController();
  final ScrollController _withdrawalScrollController = ScrollController();
  final ScrollController _internalTransferScrollController = ScrollController();
  RxList<dynamic> allAccountTrading =
      [
        Real(
          balance: "0",
          currency: "USD",
          id: "0",
          leverage: "400.00",
          login: "0",
          marginFree: "0",
          marginFreePercent: "0",
          maxWithdrawal: "0",
          minDeposit: "0",
          minTopup: "0",
          minWithdrawal: "",
          namaTipeAkun: "-",
          pnl: "0",
          rate: "Floating",
          totalDeposit: "0",
          totalWithdrawal: "0",
          type: "Demo",
        ),
      ].obs;

  Future<void> getAndSetAccountTrading() async {
    await tradingController.getTradingAccount().then((resultTradingAccount) {
      if (!resultTradingAccount) {
        CustomScaffoldMessanger.showAppSnackBar(
          context,
          message: tradingController.responseMessage.value,
        );
        return;
      }
      final real =
          tradingController.tradingAccountModels.value?.response.real ?? [];
      allAccountTrading.clear();
      allAccountTrading
        ..clear()
        ..addAll(real);
      selectedIndex(0);
      selectedLoginID(allAccountTrading[0].login.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    // Set up search listener
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text;
    });
    
    Future.delayed(Duration.zero, () {
      getAndSetAccountTrading();
      userController.historyWithdrawAndDeposit();
      userController.getInternalTransferHistory();
    });
  }

  @override
  void dispose() {
    _depositScrollController.dispose();
    _withdrawalScrollController.dispose();
    _internalTransferScrollController.dispose();
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  // Filter methods
  List<dynamic> _applyFilters(List<dynamic> items) {
    return items.where((item) {
      // Status filter
      if (_selectedStatus.value != 'all' && item.status != _selectedStatus.value) {
        return false;
      }

      // Date range filter 
      if (_selectedDateRange.value != 'all') {
        try {
          final itemDate = DateTime.parse(item.datetime);
          final now = DateTime.now();
          
          switch (_selectedDateRange.value) {
            case 'last7days':
              if (itemDate.isBefore(now.subtract(const Duration(days: 7)))) {
                return false; 
              }
              break;
            case 'last30days':
              if (itemDate.isBefore(now.subtract(const Duration(days: 30)))) {
                return false;
              }
              break;
            case 'last90days':
              if (itemDate.isBefore(now.subtract(const Duration(days: 90)))) {
                return false;
              }
              break;
            case 'custom':
              if (_customStartDate != null && itemDate.isBefore(_customStartDate!)) {
                return false;
              }
              if (_customEndDate != null && itemDate.isAfter(_customEndDate!.add(const Duration(days: 1)))) {
                return false;
              }
              break;
          }
        } catch (e) {
          // If date parsing fails, exclude item
          return false;
        }
      }

      // Account filter
      if (_selectedAccount.value != 'all' && item.login?.toString() != _selectedAccount.value) {
        return false;
      }

      // Amount range filter
      if (_minAmountController.text.isNotEmpty || _maxAmountController.text.isNotEmpty) {
        try {
          // Extract numeric amount from string like '$100.00' or '100 USD'
          final amountStr = item.amount?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0';
          final itemAmount = double.tryParse(amountStr) ?? 0;
          
          if (_minAmountController.text.isNotEmpty) {
            final minAmount = double.tryParse(_minAmountController.text) ?? 0;
            if (itemAmount < minAmount) return false;
          }
          
          if (_maxAmountController.text.isNotEmpty) {
            final maxAmount = double.tryParse(_maxAmountController.text) ?? double.infinity;
            if (itemAmount > maxAmount) return false;
          }
        } catch (e) {
          // If amount parsing fails, include item
        }
      }

      // Search filter
      if (_searchQuery.value.isNotEmpty) {
        final query = _searchQuery.value.toLowerCase();
        final searchableText = [
          item.id?.toString() ?? '',
          item.type?.toString() ?? '',
          item.status?.toString() ?? '',
          item.amount?.toString() ?? '',
          item.login?.toString() ?? '',
        ].join(' ').toLowerCase();
        
        if (!searchableText.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _clearAllFilters() {
    _selectedStatus.value = 'all';
    _selectedDateRange.value = 'all';
    _selectedAccount.value = 'all';
    _searchController.clear();
    _minAmountController.clear();
    _maxAmountController.clear();
    _searchQuery.value = '';
    _customStartDate = null;
    _customEndDate = null;
  }

  bool get _hasActiveFilters => 
    _selectedStatus.value != 'all' ||
    _selectedDateRange.value != 'all' ||
    _selectedAccount.value != 'all' ||
    _searchQuery.value.isNotEmpty ||
    _minAmountController.text.isNotEmpty ||
    _maxAmountController.text.isNotEmpty;

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isExpanded = _showFilters.value;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded
                  ? CustomColor.secondaryColor.withOpacity(0.5)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: 1.5,
            ),
            boxShadow: [
              if (isExpanded)
                BoxShadow(
                  color: CustomColor.secondaryColor.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            children: [
              // Filter Header - Interactive
              GestureDetector(
                onTap: () => _showFilters.toggle(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CustomColor.secondaryColor.withOpacity(
                                isExpanded ? 0.2 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Iconsax.filter_outline,
                              size: 22,
                              color: CustomColor.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Advanced Filters',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (_hasActiveFilters)
                                Text(
                                  'Filters Applied',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (_hasActiveFilters) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.expand_more_rounded,
                              size: 24,
                              color: CustomColor.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Animated Filter Content
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Column(
                        children: [
                          Divider(
                            height: 1,
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Search Bar - Enhanced
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) => _searchQuery.value = value,
                                    decoration: InputDecoration(
                                      hintText: 'Search transactions...',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: CustomColor.secondaryColor,
                                      ),
                                      suffixIcon: _searchQuery.value.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                _searchController.clear();
                                                _searchQuery.value = '';
                                              },
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: Colors.red,
                                              ),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Status Filter - Chip Style
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: theme.textTheme.bodyLarge?.color,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildStatusChip('All', 'all', Colors.grey, theme),
                                        _buildStatusChip('Pending', 'pending', Colors.orange, theme),
                                        _buildStatusChip('Success', 'success', Colors.green, theme),
                                        _buildStatusChip('Rejected', 'reject', Colors.red, theme),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Date Range and Min Amount
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildFilterCard(
                                        context,
                                        'Date Range',
                                        Icons.calendar_month_rounded,
                                        DropdownButtonFormField<String>(
                                          value: _selectedDateRange.value,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 8,
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'all',
                                              child: Text('All Time', style: TextStyle(fontSize: 13)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'last7days',
                                              child: Text('Last 7 days', style: TextStyle(fontSize: 13)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'last30days',
                                              child: Text('Last 30 days', style: TextStyle(fontSize: 13)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'last90days',
                                              child: Text('Last 90 days', style: TextStyle(fontSize: 13)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'custom',
                                              child: Text('Custom Range', style: TextStyle(fontSize: 13)),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            _selectedDateRange.value = value ?? 'all';
                                            if (value == 'custom') {
                                              _showCustomDatePicker();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildFilterCard(
                                        context,
                                        'Min Amount',
                                        Icons.money_rounded,
                                        TextField(
                                          controller: _minAmountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: GoogleFonts.inter(fontSize: 13),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 8,
                                            ),
                                          ),
                                          style: GoogleFonts.inter(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Max Amount
                                _buildFilterCard(
                                  context,
                                  'Max Amount',
                                  Icons.money_rounded,
                                  TextField(
                                    controller: _maxAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '∞',
                                      hintStyle: GoogleFonts.inter(fontSize: 13),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 8,
                                      ),
                                    ),
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _clearAllFilters,
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Clear'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                          foregroundColor: isDark
                                              ? Colors.grey.shade100
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showFilters.toggle(),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Apply'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: CustomColor.secondaryColor,
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusChip(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Obx(() {
      final isSelected = _selectedStatus.value == value;
      return GestureDetector(
        onTap: () => _selectedStatus.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : (theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.6)
                  : (theme.brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: color,
                  ),
                ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterCard(
    BuildContext context,
    String label,
    IconData icon,
    Widget child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: CustomColor.secondaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );
    
    if (picked != null) {
      _customStartDate = picked.start;
      _customEndDate = picked.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Obx(
      () => DefaultTabController(
        length: 3,
        initialIndex: initialIndexTab.value,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: theme.brightness == Brightness.dark 
              ? Colors.grey.shade900 
              : Colors.white,
            title: Text(
              "Riwayat Deposit & Withdrawal",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TabBar(
                      dividerHeight: 0,
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: theme.textTheme.labelSmall?.color,
                      tabAlignment: TabAlignment.fill,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomColor.secondaryColor,
                            CustomColor.secondaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColor.secondaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_downward_rounded, size: 18),
                              const SizedBox(width: 8),
                              const Text('Deposit'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_upward_rounded, size: 18),
                              const SizedBox(width: 8),
                              const Text('Withdrawal'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.swap_horiz_rounded, size: 18),
                              const SizedBox(width: 8),
                              const Text('Transfer'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              buildDepositHistory(context, size),
              buildWithdrawHistory(context, size),
              buildInternalTransfer(context, size),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInternalTransfer(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (userController.isLoading.value) {
        return SizedBox(
          width: size.width,
          height: size.height / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/loader.json', width: 200, height: 200),
            ],
          ),
        );
      }

      if (userController.internalTransferHistory.value?.response.isEmpty ==
          true) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        CustomColor.secondaryColor.withValues(alpha: 0.2),
                        Colors.purple.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    BoxIcons.bx_transfer_alt,
                    size: 60,
                    color: CustomColor.secondaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  "No Internal Transfer",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Belum ada riwayat transfer internal\nantara akun trading Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        BoxIcons.bx_info_circle,
                        "Transfer Mudah",
                        "Pindahkan dana antar akun dengan cepat",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Iconsax.clock_outline,
                        "Riwayat Otomatis",
                        "Semua transfer tercatat secara otomatis",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userController.getInternalTransferHistory();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      "Refresh",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final transfers =
          userController.internalTransferHistory.value?.response ?? [];

      // Remove duplicates based on transaction code
      final uniqueTransfers = <String, dynamic>{};
      for (var transfer in transfers) {
        final key = transfer.code ?? transfer.datetime ?? '';
        if (key.isNotEmpty && !uniqueTransfers.containsKey(key)) {
          uniqueTransfers[key] = transfer;
        }
      }

      // Sort transfers by date descending (newest first)
      final sortedTransfers =
          uniqueTransfers.values.toList()..sort((a, b) {
            try {
              if (a.datetime == null && b.datetime == null) return 0;
              if (a.datetime == null) return 1;
              if (b.datetime == null) return -1;
              return DateTime.parse(
                b.datetime!,
              ).compareTo(DateTime.parse(a.datetime!));
            } catch (e) {
              return 0;
            }
          });

      // Apply filters to internal transfers (with modified filter for transfer-specific fields)
      final filteredTransfers = sortedTransfers.where((item) {
        // Date range filter 
        if (_selectedDateRange.value != 'all') {
          try {
            final itemDate = DateTime.parse(item.datetime);
            final now = DateTime.now();
            
            switch (_selectedDateRange.value) {
              case 'last7days':
                if (itemDate.isBefore(now.subtract(const Duration(days: 7)))) {
                  return false; 
                }
                break;
              case 'last30days':
                if (itemDate.isBefore(now.subtract(const Duration(days: 30)))) {
                  return false;
                }
                break;
              case 'last90days':
                if (itemDate.isBefore(now.subtract(const Duration(days: 90)))) {
                  return false;
                }
                break;
              case 'custom':
                if (_customStartDate != null && itemDate.isBefore(_customStartDate!)) {
                  return false;
                }
                if (_customEndDate != null && itemDate.isAfter(_customEndDate!.add(const Duration(days: 1)))) {
                  return false;
                }
                break;
            }
          } catch (e) {
            return false;
          }
        }

        // Amount range filter
        if (_minAmountController.text.isNotEmpty || _maxAmountController.text.isNotEmpty) {
          try {
            final amountStr = item.amount?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0';
            final itemAmount = double.tryParse(amountStr) ?? 0;
            
            if (_minAmountController.text.isNotEmpty) {
              final minAmount = double.tryParse(_minAmountController.text) ?? 0;
              if (itemAmount < minAmount) return false;
            }
            
            if (_maxAmountController.text.isNotEmpty) {
              final maxAmount = double.tryParse(_maxAmountController.text) ?? double.infinity;
              if (itemAmount > maxAmount) return false;
            }
          } catch (e) {
            // If amount parsing fails, include item
          }
        }

        // Search filter (for internal transfers, search in code, amount, from, to)
        if (_searchQuery.value.isNotEmpty) {
          final query = _searchQuery.value.toLowerCase();
          final searchableText = [
            item.code?.toString() ?? '',
            item.amount?.toString() ?? '',
            item.from?.toString() ?? '',
            item.to?.toString() ?? '',
            item.ticketFrom?.toString() ?? '',
            item.ticketTo?.toString() ?? '',
          ].join(' ').toLowerCase();
          
          if (!searchableText.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();

      if (filteredTransfers.isEmpty && transfers.isNotEmpty) {
        // Show no results message when filters return empty but original data exists
        return Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.search_status_1_outline,
                        size: 80,
                        color: CustomColor.secondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Results Found",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Try adjusting your filter criteria\nto see more results",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _clearAllFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Group by month (using filtered transfers)
      Map<String, List<dynamic>> groupedTransfers = {};
      for (var transfer in filteredTransfers) {
        try {
          if (transfer.datetime == null) continue; // Skip if datetime is null
          final dateTime = DateTime.parse(transfer.datetime!);
          final monthKey = "${_getMonthName(dateTime.month)} ${dateTime.year}";
          if (!groupedTransfers.containsKey(monthKey)) {
            groupedTransfers[monthKey] = [];
          }
          groupedTransfers[monthKey]!.add(transfer);
        } catch (e) {
          // If date parsing fails, group under "Unknown"
          if (!groupedTransfers.containsKey("Unknown")) {
            groupedTransfers["Unknown"] = [];
          }
          groupedTransfers["Unknown"]!.add(transfer);
        }
      }

      return Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              color: CustomColor.secondaryColor,
              onRefresh: () async {
                await userController.getInternalTransferHistory();
              },
              child: Scrollbar(
                controller: _internalTransferScrollController,
                thumbVisibility: true,
                thickness: 4.0,
          radius: const Radius.circular(10),
          child: ListView.builder(
            controller: _internalTransferScrollController,
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: groupedTransfers.length,
            itemBuilder: (context, groupIndex) {
              final monthKey = groupedTransfers.keys.elementAt(groupIndex);
              final monthTransfers = groupedTransfers[monthKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthKey,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month Items
                  ...List.generate(monthTransfers.length, (i) {
                    final item = monthTransfers[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            _showTransferDetail(context, item);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Header: Code & DateTime
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: CustomColor.secondaryColor
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            BoxIcons.bx_transfer_alt,
                                            color: CustomColor.secondaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "#${item.code ?? '-'}",
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatDateTime(
                                                item.datetime ?? '-',
                                              ),
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        item.amount ?? '\$0',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Divider
                                Container(
                                  height: 1,
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                ),

                                const SizedBox(height: 16),

                                // Transfer Details: From → To
                                Row(
                                  children: [
                                    // FROM
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_upward_rounded,
                                                  size: 14,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "FROM",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.from ?? '-',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Ticket: ${item.ticketFrom ?? '-'}",
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Arrow Icon
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: CustomColor.secondaryColor,
                                        size: 24,
                                      ),
                                    ),

                                    // TO
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_downward_rounded,
                                                  size: 14,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "TO",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.to ?? '-',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Ticket: ${item.ticketTo ?? '-'}",
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
              ),
            ),
          ],
        );
      });
  }

  void _showTransferDetail(BuildContext context, dynamic item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title
              Text(
                "Transfer Details",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              const SizedBox(height: 24),

              // Details
              _detailRow("Transaction Code", item.code ?? '-', theme),
              _detailRow("Amount", item.amount ?? '\$0', theme, isAmount: true),
              _detailRow("From Account", item.from ?? '-', theme),
              _detailRow("From Ticket", item.ticketFrom ?? '-', theme),
              _detailRow("To Account", item.to ?? '-', theme),
              _detailRow("To Ticket", item.ticketTo ?? '-', theme),
              _detailRow("Date & Time", item.datetime ?? '-', theme),

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.secondaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
    ThemeData theme, {
    bool isAmount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.w800 : FontWeight.w600,
              color: isAmount ? Colors.green : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDepositHistory(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (userController.isLoading.value) {
        return SizedBox(
          width: size.width,
          height: size.height / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/loader.json', width: 200, height: 200),
            ],
          ),
        );
      }

      if (userController.historyDepoWd.value?.response.isEmpty == true) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        Colors.green.withValues(alpha: 0.2),
                        Colors.teal.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    AntDesign.arrow_down_outline,
                    size: 60,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  "No Deposit History",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Belum ada riwayat deposit\nke akun trading Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Iconsax.wallet_add_outline,
                        "Deposit Cepat",
                        "Isi saldo dengan berbagai metode pembayaran",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Iconsax.shield_tick_outline,
                        "Aman & Terpercaya",
                        "Transaksi dilindungi dengan enkripsi",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userController.historyWithdrawAndDeposit();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      "Refresh",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final deposits =
          userController.historyDepoWd.value?.response
              .where(
                (res) =>
                    res.type == "Deposit" || res.type == "Deposit New Account",
              )
              .toList() ??
          [];

      // Apply filters to deposits
      final filteredDeposits = _applyFilters(deposits);

      if (filteredDeposits.isEmpty && deposits.isNotEmpty) {
        // Show no results message when filters return empty but original data exists
        return Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.search_status_1_outline,
                        size: 80,
                        color: CustomColor.secondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Results Found",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Try adjusting your filter criteria\nto see more results",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _clearAllFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      if (deposits.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        Colors.green.withValues(alpha: 0.2),
                        Colors.teal.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    AntDesign.arrow_down_outline,
                    size: 60,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  "No Deposit History",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Belum ada riwayat deposit\nke akun trading Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Iconsax.wallet_add_outline,
                        "Deposit Cepat",
                        "Isi saldo dengan berbagai metode pembayaran",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Iconsax.shield_tick_outline,
                        "Aman & Terpercaya",
                        "Transaksi dilindungi dengan enkripsi",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userController.historyWithdrawAndDeposit();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      "Refresh",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Group by month (using filtered deposits)
      Map<String, List<dynamic>> groupedDeposits = {};
      for (var deposit in filteredDeposits) {
        try {
          final dateTime = DateTime.parse(deposit.datetime);
          final monthKey = "${_getMonthName(dateTime.month)} ${dateTime.year}";
          if (!groupedDeposits.containsKey(monthKey)) {
            groupedDeposits[monthKey] = [];
          }
          groupedDeposits[monthKey]!.add(deposit);
        } catch (e) {
          // If date parsing fails, group under "Unknown"
          if (!groupedDeposits.containsKey("Unknown")) {
            groupedDeposits["Unknown"] = [];
          }
          groupedDeposits["Unknown"]!.add(deposit);
        }
      }

      return Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              color: CustomColor.secondaryColor,
              onRefresh: () async {
                await userController.historyWithdrawAndDeposit();
              },
              child: Scrollbar(
                controller: _depositScrollController,
                thumbVisibility: true,
                thickness: 4.0,
                radius: const Radius.circular(10),
                child: ListView.builder(
                  controller: _depositScrollController,
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedDeposits.length,
                  itemBuilder: (context, groupIndex) {
                    final monthKey = groupedDeposits.keys.elementAt(groupIndex);
                    final monthDeposits = groupedDeposits[monthKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthKey,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month Items
                  ...List.generate(monthDeposits.length, (i) {
                    final result = monthDeposits[i];

                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.pending;

                    switch (result.status) {
                      case "pending":
                        statusColor = Colors.orange.shade400;
                        statusIcon = Icons.pending;
                        break;
                      case "success":
                        statusColor = Colors.green.shade400;
                        statusIcon = Icons.check_circle;
                        break;
                      case "reject":
                        statusColor = Colors.red.shade400;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey.shade400;
                        statusIcon = Icons.help;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.to(() => TransactionDetailView(id: result.id));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    AntDesign.arrow_down_outline,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.type ?? "Deposit",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            size: 14,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "ID ${result.login ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(result.datetime),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount & Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      result.amount ?? '\$0',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            size: 12,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.status ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
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
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
              ),
            ),
          ],
        );
      });
  }

  Widget buildWithdrawHistory(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (userController.isLoading.value) {
        return SizedBox(
          width: size.width,
          height: size.height / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/loader.json', width: 200, height: 200),
            ],
          ),
        );
      }

      if (userController.historyDepoWd.value?.response.isEmpty == true) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        Colors.orange.withValues(alpha: 0.2),
                        Colors.deepOrange.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    AntDesign.arrow_up_outline,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  "No Withdrawal History",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Belum ada riwayat penarikan dana\ndari akun trading Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Iconsax.wallet_minus_outline,
                        "Penarikan Mudah",
                        "Tarik profit Anda kapan saja",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Iconsax.clock_outline,
                        "Proses Cepat",
                        "Withdrawal diproses dalam 1-24 jam",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userController.historyWithdrawAndDeposit();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      "Refresh",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final withdrawals =
          userController.historyDepoWd.value?.response
              .where((res) => res.type == "Withdrawal")
              .toList() ??
          [];

      // Apply filters to withdrawals
      final filteredWithdrawals = _applyFilters(withdrawals);

      if (filteredWithdrawals.isEmpty && withdrawals.isNotEmpty) {
        // Show no results message when filters return empty but original data exists
        return Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.search_status_1_outline,
                        size: 80,
                        color: CustomColor.secondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Results Found",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Try adjusting your filter criteria\nto see more results",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _clearAllFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      if (withdrawals.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        Colors.orange.withValues(alpha: 0.2),
                        Colors.deepOrange.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    AntDesign.arrow_up_outline,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  "No Withdrawal History",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Belum ada riwayat penarikan dana\ndari akun trading Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Iconsax.wallet_minus_outline,
                        "Penarikan Mudah",
                        "Tarik profit Anda kapan saja",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Iconsax.clock_outline,
                        "Proses Cepat",
                        "Withdrawal diproses dalam 1-24 jam",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userController.historyWithdrawAndDeposit();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      "Refresh",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Group by month (using filtered withdrawals)
      Map<String, List<dynamic>> groupedWithdrawals = {};
      for (var withdrawal in filteredWithdrawals) {
        try {
          final dateTime = DateTime.parse(withdrawal.datetime);
          final monthKey = "${_getMonthName(dateTime.month)} ${dateTime.year}";
          if (!groupedWithdrawals.containsKey(monthKey)) {
            groupedWithdrawals[monthKey] = [];
          }
          groupedWithdrawals[monthKey]!.add(withdrawal);
        } catch (e) {
          // If date parsing fails, group under "Unknown"
          if (!groupedWithdrawals.containsKey("Unknown")) {
            groupedWithdrawals["Unknown"] = [];
          }
          groupedWithdrawals["Unknown"]!.add(withdrawal);
        }
      }

      return Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              color: CustomColor.secondaryColor,
              onRefresh: () async {
                await userController.historyWithdrawAndDeposit();
              },
              child: Scrollbar(
                controller: _withdrawalScrollController,
                thumbVisibility: true,
                thickness: 4.0,
                radius: const Radius.circular(10),
                child: ListView.builder(
                  controller: _withdrawalScrollController,
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedWithdrawals.length,
                  itemBuilder: (context, groupIndex) {
                    final monthKey = groupedWithdrawals.keys.elementAt(groupIndex);
                    final monthWithdrawals = groupedWithdrawals[monthKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthKey,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month Items
                  ...List.generate(monthWithdrawals.length, (i) {
                    final result = monthWithdrawals[i];

                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.pending;

                    switch (result.status) {
                      case "pending":
                        statusColor = Colors.orange.shade400;
                        statusIcon = Icons.pending;
                        break;
                      case "success":
                        statusColor = Colors.green.shade400;
                        statusIcon = Icons.check_circle;
                        break;
                      case "reject":
                        statusColor = Colors.red.shade400;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey.shade400;
                        statusIcon = Icons.help;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.to(() => TransactionDetailView(id: result.id));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    AntDesign.arrow_up_outline,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.type ?? "Withdrawal",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            size: 14,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "ID ${result.login ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(result.datetime),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount & Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      result.amount ?? '\$0',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            size: 12,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.status ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
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
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
              ),
            ),
          ],
        );
      });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  String _formatDateTime(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateToCheck = DateTime(dt.year, dt.month, dt.day);

      if (dateToCheck == today) {
        return "Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
        return "Yesterday, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } else {
        return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
    } catch (e) {
      return datetime;
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CustomColor.secondaryColor.withValues(alpha: 0.2),
                CustomColor.secondaryColor.withValues(alpha: 0.1),
              ],
            ),
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
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
