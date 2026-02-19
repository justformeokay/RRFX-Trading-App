import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// Asumsi ini adalah import untuk dialog Anda
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) 'package:rrfx/src/helpers/http/webview_flutter_stub.dart';

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
  bool _hasConnection = true;
  late StreamSubscription _connectionSubscription;
  bool _webViewLoadError = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Monitor connection
    _checkConnection();
    _connectionSubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _hasConnection = !result.contains(ConnectivityResult.none);
      });
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _webViewLoadError = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => _webViewLoadError = true);
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildChartUrl()));
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _hasConnection = !result.contains(ConnectivityResult.none);
    });
  }

  String _buildChartUrl() {
    // Pastikan marketName memiliki suffix .db
    String symbol = widget.marketName.trim();
    if (!symbol.toLowerCase().endsWith('.db')) {
      symbol = '$symbol.db';
    }
    final theme = Get.isDarkMode ? 'dark' : 'light';
    
    // return 'https://chart-rrfx.techcrm.dev/chart.php?symbol=$symbol&server=demo&theme=$theme';
    return 'https://webchart-rrfx.techcrm.dev/?symbol=$symbol&server=demo&theme=$theme';
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDarkMode ? Colors.black : Colors.white;
    final theme = Theme.of(context);

    // Show error if no connection
    if (!_hasConnection || _webViewLoadError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Chart ${normalizeSymbol(widget.marketName)}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: _buildErrorState(theme, isDarkMode),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chart ${normalizeSymbol(widget.marketName)}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: scaffoldBgColor, 
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
             _buildButton()
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomColor.secondaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Iconsax.wifi_square_outline,
                        size: 60,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                _webViewLoadError ? 'Gagal Memuat Chart' : 'Tidak Ada Koneksi',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                _webViewLoadError
                    ? 'Gagal memuat chart. Periksa koneksi internet Anda dan coba lagi.'
                    : 'Sepertinya Anda tidak terhubung ke internet. Periksa koneksi WiFi atau data seluler Anda.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Tips Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CustomColor.secondaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.lamp_charge_outline,
                          size: 18,
                          color: CustomColor.secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Pastikan WiFi atau data mobile Anda aktif\n• Coba matikan dan nyalakan ulang perangkat\n• Periksa pengaturan jaringan Anda',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Column(
                children: [
                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _checkConnection();
                        if (_hasConnection) {
                          setState(() => _webViewLoadError = false);
                          _controller.loadRequest(Uri.parse(_buildChartUrl()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Iconsax.refresh_outline, size: 20),
                      label: Text(
                        'Coba Lagi',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Back button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.dividerColor.withOpacity(0.5),
                        ),
                      ),
                      icon: const Icon(Iconsax.arrow_left_outline, size: 20),
                      label: Text(
                        'Kembali',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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

  Widget _buildButton(){
    final isDark = Get.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // SELL button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: (){
                  AuthDirectionPopup.show();
                },
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'SELL',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Lot selector in the middle
            Expanded(
              flex: 3,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Decrement button
                    Expanded(
                      child: Center(
                        child: Text(
                          '-',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    
                    // Lot display
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          AuthDirectionPopup.show();
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              _lotSize.toStringAsFixed(2),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Increment button
                    Expanded(
                      child: Center(
                        child: Text(
                          '+',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // BUY button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: (){
                  AuthDirectionPopup.show();
                },
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'BUY',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}