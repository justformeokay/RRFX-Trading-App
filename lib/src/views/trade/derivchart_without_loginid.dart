import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// Asumsi ini adalah import untuk dialog Anda
import 'package:rrfx/src/components/alerts/popup.dart'; 
import 'package:webview_flutter/webview_flutter.dart';

class TradingChartView extends StatefulWidget {
  final String marketName;

  const TradingChartView({
    super.key,
    required this.marketName,
  });

  @override
  State<TradingChartView> createState() => _TradingChartViewState();
}

class _TradingChartViewState extends State<TradingChartView> {
  late final WebViewController _controller; 
  double _lotSize = 0.01;
  bool _isChartLoaded = false; // Flag untuk melacak apakah chart TradingView sudah dimuat di JS

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..loadRequest(Uri.parse(_buildChartUrl()));
  }

  String _buildChartUrl() {
    // Pastikan marketName memiliki suffix .db
    String symbol = widget.marketName.trim();
    if (!symbol.toLowerCase().endsWith('.db')) {
      symbol = '$symbol.db';
    }
    
    return 'http://207.148.119.106/rrfx/chart.php?symbol=$symbol&server=demo';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tidak perlu load chart lagi karena sudah di initState
  }

  @override
  void didUpdateWidget(covariant TradingChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cek jika marketName berubah
    if (oldWidget.marketName != widget.marketName) {
      _controller.loadRequest(Uri.parse(_buildChartUrl()));
      debugPrint("Market diubah ke ${widget.marketName}");
    }
  }

  String normalizeSymbol(String marketName) {
    if (marketName.contains(".")) {
      return marketName.split(".")[0];
    }
    return marketName;
  }

  void _updateLot(double delta) {
    final newValue = ((_lotSize * 100).round() + (delta * 100).round());
    
    int clampedValue;
    if (newValue <= 0) {
      clampedValue = 1; 
    } else {
      clampedValue = newValue.clamp(1, 100000).toInt(); 
    }

    setState(() => _lotSize = clampedValue / 100);
  }

  Widget _buildLotControl(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final containerColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: containerColor,
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _updateLot(-0.01),
            child: Icon(Icons.remove, color: textColor),
          ),
          const SizedBox(width: 12),
          Text(
            _lotSize.toStringAsFixed(2),
            style: TextStyle(fontSize: 18, color: textColor),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _updateLot(0.01),
            child: Icon(Icons.add, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingControls(bool isDarkMode) {
    final controlBgColor = isDarkMode ? Colors.black : Colors.white;
    final iconColor = Colors.white;

    return Container(
      color: controlBgColor, 
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () { 
                AuthDirectionPopup.show(); 
              }, 
              icon: Icon(Icons.arrow_upward, color: iconColor), 
              label: Text("Beli", style: TextStyle(fontWeight: FontWeight.bold, color: iconColor)), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildLotControl(isDarkMode), 
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                AuthDirectionPopup.show();
              },
              icon: Icon(Icons.arrow_downward, color: iconColor), 
              label: Text("Jual", style: TextStyle(fontWeight: FontWeight.bold, color: iconColor)), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor, 
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Trade",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
             _buildTradingControls(isDarkMode),
          ],
        ),
      ),
    );
  }
}