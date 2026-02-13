import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';
import 'package:rrfx/src/views/accounts/components/change_mt5_password.dart';
import 'package:rrfx/src/views/trade/deposit.dart';
import 'package:rrfx/src/views/trade/internal_transfer.dart';
import 'package:rrfx/src/views/trade/withdrawal.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key, this.loginID});
  final String? loginID;

    @override
    State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  int _tabIndex = 0; // Untuk tab ACTIONS / INFO
  RxString selectedLoginID = "".obs;

  TradingController tradingController = Get.find();
  Real? selectedAccount;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      var result = tradingController.tradingAccountModels.value?.response.real;
      if(result != null){
        for(int i = 0; i < result.length; i++){
          if(result[i].login == widget.loginID){
            selectedLoginID(result[i].id);
            setState(() {
              selectedAccount = result[i];
            });
            // Debug logging - only called once in initState
            print("✅ Account loaded!");
            print("   - Login: ${selectedAccount?.login}");
            print("   - Rate: ${selectedAccount?.rate} (Type: ${selectedAccount?.rate.runtimeType})");
            print("   - Currency: ${selectedAccount?.currency}");
            print("   - Balance: ${selectedAccount?.balance}");
            print("   - Leverage: 1:${selectedAccount?.leverage}");
            break; 
          }
        }
        await tradingController.getSymbols();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account", style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 1.0,)),
            Text("Information", style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 5.0),
            Text("Informasi lengkap mengenai akun trading ${widget.loginID}.", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 13)),
            const SizedBox(height: 10.0),
            // Header card
            _buildAccountCard(context),
        
            // Tab switcher
            _buildTabBar(),
        
            // Menu list (ACTIONS tab)
            if (_tabIndex == 0) _buildActionList(size),
            if (_tabIndex == 1) _buildInfoTab(),
          ],
        ),
      ),
    );
  }

  // Helper method to format rate - handles both numeric and non-numeric values
  String _formatRate(dynamic rate, String? currency) {
    if (rate == null || rate.toString().isEmpty) {
      return "-";
    }
    
    // Check if rate is numeric
    final numericRate = double.tryParse(rate.toString());
    
    // If rate is numeric (not "Floating", "Fixed", etc), format as currency
    if (numericRate != null) {
      return NumberFormatter.formatCurrency(numericRate, currency: currency ?? 'IDR');
    }
    
    // If rate is non-numeric string (like "Floating", "Fixed"), display as-is
    return rate.toString().toUpperCase();
  }

  Widget _buildAccountCard(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[900] : Colors.white, // adaptive
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black54 : Colors.black12,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/mt5-removebg-preview.png', width: 20.0),
                const SizedBox(width: 5.0),
                Text(
                  "MetaTrader 5",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              selectedAccount?.login?.toString() ?? "-",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                  ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CustomColor.secondaryBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "RATE ${_formatRate(selectedAccount?.rate, selectedAccount?.currency)}",
                style: TextStyle(
                  color: CustomColor.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${selectedAccount?.balance ?? 0}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CustomColor.secondaryColor,
              ),
            ),
          ],
        )
      ],
    ),
  );
}


  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabItem("ACTIONS", 0),
        _tabItem("INFO", 1),
      ],
    );
  }

  Widget _tabItem(String label, int index) {
    bool selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? CustomColor.secondaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? CustomColor.secondaryColor : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionList(Size size) {
    return Expanded(
      child: ListView(
        children: [
          _menuItem(Iconsax.wallet_2_outline, 'Deposit', onPressed: () => Get.to(() => Deposit(idLogin: widget.loginID))),
          _menuItem(Bootstrap.box_arrow_up, 'Withdrawal', onPressed: () => Get.to(() => Withdrawal(idLogin: widget.loginID))),
          // _menuItem(MingCute.transfer_4_line, 'Internal transfer', onPressed: () => Get.to(() => InternalTransfer(loginID: selectedLoginID.value, loginNumber: widget.loginID))),
          _menuItem(MingCute.transfer_4_line, 'Internal transfer', onPressed: () {
            if(tradingController.tradingAccountModels.value!.response.real?.isNotEmpty == true){
              if(tradingController.tradingAccountModels.value!.response.real!.length < 2){
                CustomScaffoldMessanger.showAppSnackBar(context, message: "Menu Internal Transfer hanya bisa dilakukan jika anda memiliki minimal 2 akun Real", type: SnackBarType.warning);
                return;
              }
              Get.to(() => InternalTransfer(loginID: selectedLoginID.value, loginNumber: widget.loginID));
            }
          }),
          _menuItem(Iconsax.lock_1_outline, 'Ganti Password', onPressed: () => Get.to(() => ChangeMT5PasswordPage(mt5AccountId: widget.loginID))),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    String marginFree = NumberFormatter.formatCurrency(selectedAccount?.marginFree, currency: 'USD');
    String leverage = '1:${selectedAccount?.leverage != null ? NumberFormatter.formatWithoutTrailingZeros(selectedAccount!.leverage) : '0'}';
    String fixedRate = selectedAccount?.rate != "Floating" ? 'Yes' : 'No';
    String server = 'RRFX-Real';
    String currency = selectedAccount?.currency ?? "USD";
    String accountTypeName = selectedAccount?.namaTipeAkun ?? '-';
    String minimumDeposit = selectedAccount?.minDeposit != null ? NumberFormatter.formatCurrency(selectedAccount!.minDeposit, currency: selectedAccount!.currency!) : '0';
    
    // Get total deposit based on currency
    String totalDeposit = _getTotalDepositFormatted();
    String totalWithdrawal = _getTotalWithdrawalFormatted();
    
    // New fields
    String pnl = selectedAccount?.pnl != null ? NumberFormatter.formatCurrency(selectedAccount!.pnl, currency: selectedAccount!.currency!) : '0';
    String marginFreePercent = selectedAccount?.marginFreePercent != null ? '${NumberFormatter.formatWithoutTrailingZeros(selectedAccount!.marginFreePercent)}%' : '0%';
    String minTopup = selectedAccount?.minTopup != null ? NumberFormatter.formatCurrency(selectedAccount!.minTopup, currency: selectedAccount!.currency!) : '0';
    String minWithdrawal = selectedAccount?.minWithdrawal != null ? NumberFormatter.formatCurrency(selectedAccount!.minWithdrawal, currency: selectedAccount!.currency!) : '0';
    String maxWithdrawal = selectedAccount?.maxWithdrawal != null ? NumberFormatter.formatCurrency(selectedAccount!.maxWithdrawal, currency: selectedAccount!.currency!) : '0';

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 12),
          const Text(
            'Account details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _infoItem(context, 'Margin Free', marginFree),
          _infoItem(context, 'Margin Free Percent', marginFreePercent),
          _infoItem(context, 'Leverage', leverage),
          _infoItem(context, 'Fixed rate', fixedRate),
          _infoItem(context, 'Server', server),
          _infoItem(context, 'Currency', currency),
          _infoItem(context, 'Account Type Name', accountTypeName),
          _infoItem(context, 'Profit/Loss (PnL)', pnl),
          _infoItem(context, 'Minimum Deposit', minimumDeposit),
          _infoItem(context, 'Minimum Top-up', minTopup),
          _infoItem(context, 'Minimum Withdrawal', minWithdrawal),
          _infoItem(context, 'Maximum Withdrawal', maxWithdrawal),
          _infoItem(context, 'Total Deposit', totalDeposit),
          _infoItem(context, 'Total Withdrawal', totalWithdrawal),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper method to get total deposit formatted by currency
  String _getTotalDepositFormatted() {
    if (selectedAccount == null) {
      Get.log("❌ selectedAccount is NULL");
      return '0';
    }
    
    Get.log("✅ selectedAccount found");
    Get.log("   currency: '${selectedAccount!.currency}'");
    Get.log("   totalDepositIdr: '${selectedAccount!.totalDepositIdr}'");
    Get.log("   totalDepositUsd: '${selectedAccount!.totalDepositUsd}'");
    
    // If currency is IDR, show IDR value, otherwise show USD
    if (selectedAccount!.currency?.toUpperCase() == 'IDR') {
      Get.log("   → Returning IDR value");
      return selectedAccount!.totalDepositIdr ?? '0';
    } else {
      Get.log("   → Returning USD value");
      return selectedAccount!.totalDepositUsd ?? '0';
    }
  }

  // Helper method to get total withdrawal formatted by currency
  String _getTotalWithdrawalFormatted() {
    if (selectedAccount == null) {
      Get.log("❌ selectedAccount is NULL");
      return '0';
    }
    
    Get.log("✅ selectedAccount found");
    Get.log("   currency: '${selectedAccount!.currency}'");
    Get.log("   totalWithdrawalIdr: '${selectedAccount!.totalWithdrawalIdr}'");
    Get.log("   totalWithdrawalUsd: '${selectedAccount!.totalWithdrawalUsd}'");
    
    // If currency is IDR, show IDR value, otherwise show USD
    if (selectedAccount!.currency?.toUpperCase() == 'IDR') {
      Get.log("   → Returning IDR value");
      return selectedAccount!.totalWithdrawalIdr ?? '0';
    } else {
      Get.log("   → Returning USD value");
      return selectedAccount!.totalWithdrawalUsd ?? '0';
    }
  }

  Widget _infoItem(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _menuItem(IconData icon, String title, {VoidCallback? onPressed}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onPressed,
    );
  }
}
