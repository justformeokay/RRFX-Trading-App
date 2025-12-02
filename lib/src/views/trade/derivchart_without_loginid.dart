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
      // Tambahkan listener untuk komunikasi dari JavaScript
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'chart_ready') {
            setState(() {
              _isChartLoaded = true;
            });
            debugPrint("TradingView Widget siap digunakan.");
          }
        },
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Memuat chart di sini setelah context tersedia
    if (!_isChartLoaded) {
      _loadChart(context);
    }
  }

  @override
  void didUpdateWidget(covariant TradingChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cek jika marketName berubah
    if (oldWidget.marketName != widget.marketName) {
      final newSymbol = normalizeSymbol(widget.marketName);
      
      if (_isChartLoaded) {
        // OPTIMASI: Jika chart sudah dimuat, cukup panggil fungsi setSymbol dari JS
        _controller.runJavaScript("window.tvWidget.setSymbol('${newSymbol}');");
        debugPrint("Market diubah ke $newSymbol menggunakan JS API.");
      } else {
        // Fallback: Jika belum dimuat (walaupun jarang terjadi), muat ulang HTML
        _loadChart(context); 
        debugPrint("Market diubah ke $newSymbol dengan full reload.");
      }
    }
  }

  String normalizeSymbol(String marketName) {
    if (marketName.contains(".")) {
      return marketName.split(".")[0];
    }
    return marketName;
  }

  // Menerima BuildContext untuk mengakses tema
  void _loadChart(BuildContext context) {
    final symbol = normalizeSymbol(widget.marketName);
    
    // --- PENYESUAIAN TEMA DINAMIS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final themeName = isDarkMode ? "dark" : "light";
    final backgroundColor = isDarkMode ? "#1C2023" : "#FCFDFF"; 

    final html = """
    <!DOCTYPE html>
    <html>
    <head>
      <!-- Hapus maximum-scale agar zoom di WebView berfungsi -->
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        html, body {
          margin:0;
          padding:0;
          height:100%;
          background:$backgroundColor;
          overflow:hidden;
        }
        #tvchart {
          width:100%;
          height:100%;
        }
      </style>
    </head>
    <body>
      <div id="tvchart"></div>
      <script src="https://s3.tradingview.com/tv.js"></script>
      <script>
        function loadTradingView() {
          // 1. Simpan instance widget secara global di window
          window.tvWidget = new TradingView.widget({
            "width": "100%",
            "height": "100%",
            "symbol": "$symbol",
            "interval": "60",
            "timezone": "Etc/UTC",
            "theme": "$themeName",
            "style": "1",
            "backgroundColor": "$backgroundColor",
            "hide_volume": true,
            "container_id": "tvchart",
            "locale": "id"
          });
          
          // 2. Beri tahu Flutter bahwa widget sudah siap
          window.FlutterChannel.postMessage('chart_ready');
        }
        window.onload = loadTradingView;
      </script>
    </body>
    </html>
    """;

    _controller.loadHtmlString(html);
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