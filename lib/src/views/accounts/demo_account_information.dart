import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';
import 'package:rrfx/src/views/chart/views/market_bottom_sheet.dart';

class DemoAccountInformation extends StatefulWidget {
  const DemoAccountInformation({super.key, this.loginID});
  final String? loginID;

    @override
    State<DemoAccountInformation> createState() => _DemoAccountInformationState();
}

class _DemoAccountInformationState extends State<DemoAccountInformation> {
  int _tabIndex = 0; // Untuk tab ACTIONS / INFO

  TradingController tradingController = Get.find();
  Demo? selectedAccount;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      var result = tradingController.tradingAccountModels.value?.response.demo;
      if(result != null){
        for(int i = 0; i < result.length; i++){
          if(result[i].login == widget.loginID){
            setState(() {
              selectedAccount = result[i];
            });
            break; 
          }
        }
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 1.0,)),
            Text("Information", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 5.0),
            Text("Informasi lengkap mengenai akun trading demo ${widget.loginID}.", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 15)),
            const SizedBox(height: 10.0),
            // Header card
            _buildAccountCard(),
        
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

  Widget _buildAccountCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
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
                  Text("MetaTrader 5", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 4),
              Text(selectedAccount?.login != null ? selectedAccount!.login.toString() : "-", style: TextStyle(fontSize: 16)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryBackground.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("RATE ${selectedAccount?.rate != null ? NumberFormatter.formatCurrency(selectedAccount!.rate, currency: selectedAccount!.currency!) : ""}", style: TextStyle(color: CustomColor.secondaryColor, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 8),
              Text("\$${selectedAccount?.balance ?? 0}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          _menuItem(Iconsax.chart_2_outline, 'Market', onPressed: () {
            showMarketBottomSheetForAccountInfo(context, loginID: widget.loginID, balance: selectedAccount?.balance);
          }),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    // Contoh dummy data, ganti sesuai data aslimu
    String marginFree = NumberFormatter.formatCurrency(selectedAccount?.marginFree, currency: 'USD');
    String leverage = '1:${selectedAccount?.leverage != null ? NumberFormatter.formatWithoutTrailingZeros(selectedAccount!.leverage) : '0'}';
    String totalDeposit = selectedAccount?.totalDeposit != null ? NumberFormatter.formatCurrency(selectedAccount!.totalDeposit, currency: selectedAccount!.currency!) : '0';
    String minimumDeposit = selectedAccount?.minDeposit != null ? NumberFormatter.formatCurrency(selectedAccount!.minDeposit, currency: selectedAccount!.currency!) : '0';
    String fixedRate = selectedAccount?.rate != "Floating" ? 'Yes' : 'No';
    String server = 'RRFX-Demo';
    String currency = selectedAccount?.currency ?? "USD";
    String accountTypeName = selectedAccount?.namaTipeAkun ?? '-';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Account details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _infoItem(context, 'Margin Free', marginFree),
            _infoItem(context, 'Leverage', leverage),
            _infoItem(context, 'Fixed rate', fixedRate),
            _infoItem(context, 'Server', server),
            _infoItem(context, 'Currency', currency),
            _infoItem(context, 'Account Type Name', accountTypeName),
            _infoItem(context, 'Minimum Deposit', minimumDeposit),
            _infoItem(context, 'Total Deposit', totalDeposit),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6), // lebih soft
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600, // biar kontras
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
