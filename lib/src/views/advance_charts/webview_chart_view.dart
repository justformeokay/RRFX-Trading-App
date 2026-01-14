import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'controllers/symbols_controller.dart';
import 'widgets/market_selector_sheet.dart';
import 'widgets/chart_trading_panel.dart';
import 'dart:io' show Platform;

class WebViewChartView extends StatefulWidget {
  final String? symbol;
  final String? serverType;
  final String? login;

  const WebViewChartView({
    super.key,
    this.symbol,
    this.serverType,
    this.login,
  });

  @override
  State<WebViewChartView> createState() => _WebViewChartViewState();
}

class _WebViewChartViewState extends State<WebViewChartView> {
  final chartController = Get.put(ChartControllers());
  final accountController = Get.put(AccountController());
  final symbolsController = Get.put(SymbolsController());

  InAppWebViewController? webViewController;
  bool isLoading = true;
  bool hasError = false;
  double loadingProgress = 0;
  String? errorMessage;
  bool _previousTheme = Get.isDarkMode;
  String? _currentSymbol;

  @override
  void initState() {
    super.initState();
    _previousTheme = Get.isDarkMode;
    
    // Use symbol from widget parameter if provided, otherwise use chartController's saved value
    if (widget.symbol != null && widget.symbol!.isNotEmpty) {
      _currentSymbol = widget.symbol;
      chartController.selectedMarket.value = widget.symbol!;
    } else {
      _currentSymbol = chartController.selectedMarket.value;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detect theme change and reload WebView
    final currentTheme = Get.isDarkMode;
    if (currentTheme != _previousTheme) {
      _previousTheme = currentTheme;
      _reloadChart();
    }
  }

  String _buildChartUrl() {
    final symbol = _currentSymbol ?? 
                   widget.symbol ?? 
                   chartController.selectedMarket.value;
    final server = widget.serverType ?? 
                   accountController.selectedAccount.value?.type ?? 
                   'demo';
    final login = widget.login ?? 
                  accountController.selectedAccount.value?.login ?? 
                  '';
    final theme = Get.isDarkMode ? 'dark' : 'light';
    
    final baseUrl = 'http://207.148.119.106/rrfx/chart.php?symbol=$symbol&server=${server.toLowerCase()}&login=$login&theme=$theme';
    
    // Untuk iOS, tambahkan parameter khusus
    if (Platform.isIOS) {
      return '$baseUrl&platform=ios&mobile=1';
    }
    
    return baseUrl;
  }

  void _reloadChart() {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });
    webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_buildChartUrl())),
    );
  }

  void _showMarketSelector() {
    Get.bottomSheet(
      MarketSelectorSheet(
        onSymbolSelected: (symbol) {
          setState(() {
            _currentSymbol = symbol.symbol;
          });
          // Save to controller so it persists across page rebuilds
          chartController.selectedMarket.value = symbol.symbol;
          _reloadChart();
        },
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        leadingWidth: size.width * 0.25,
        title: Text(
          _currentSymbol ?? 'XAUUSD.db',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Center(
          child: Text(
            '${widget.serverType ?? accountController.selectedAccount.value?.type ?? 'Demo'} • ${widget.login ?? accountController.selectedAccount.value?.login ?? ''}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.chart_square_outline),
            onPressed: _showMarketSelector,
            color: CustomColor.secondaryColor,
            tooltip: 'Pilih Market',
          ),
          IconButton(
            icon: Icon(Iconsax.refresh_outline),
            onPressed: _reloadChart,
            color: CustomColor.secondaryColor,
            tooltip: 'Reload Chart',
          ),
          // IconButton(
          //   icon: Icon(Iconsax.home_outline),
          //   onPressed: () => webViewController?.loadUrl(
          //     urlRequest: URLRequest(url: WebUri(_buildChartUrl())),
          //   ),
          //   tooltip: 'Reset to Home',
          // ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_buildChartUrl()),
            ),
            initialSettings: InAppWebViewSettings(
              // Pengaturan umum
              useShouldOverrideUrlLoading: false, // Ubah ke false untuk iOS
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: false,
              supportZoom: false,
              builtInZoomControls: false,
              displayZoomControls: false,
              transparentBackground: false,
              clearCache: false,
              cacheEnabled: true,
              minimumFontSize: 1,
              textZoom: 100,
              
              // Untuk iOS, gunakan setting yang lebih simple
              useHybridComposition: !Platform.isIOS, // Disable hybrid composition di iOS
              
              // Pengaturan khusus iOS
              allowsInlineMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: false, // Disable PiP
              iframeAllow: "camera; microphone; geolocation",
              iframeAllowFullscreen: true,
              
              // Pengaturan untuk kompatibilitas HTTP di iOS
              allowUniversalAccessFromFileURLs: true,
              allowFileAccessFromFileURLs: true,
              
              // Network dan security settings untuk iOS
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              resourceCustomSchemes: [],
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              print('🌐 WebView created');
              print('📍 Chart URL: ${_buildChartUrl()}');
              
              // Set timeout untuk iOS
              if (Platform.isIOS) {
                Future.delayed(Duration(seconds: 10), () {
                  if (mounted && isLoading) {
                    print('⏰ WebView timeout pada iOS, mencoba reload...');
                    _reloadChart();
                  }
                });
              }
            },
            onLoadStart: (controller, url) {
              print('📥 Loading started: $url');
              print('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
              if (mounted) {
                setState(() {
                  isLoading = true;
                  hasError = false;
                  errorMessage = null;
                });
              }
            },
            onLoadStop: (controller, url) async {
              print('✅ Loading finished: $url');
              
              // Untuk iOS, inject JavaScript yang lebih simple
              if (Platform.isIOS) {
                try {
                  await controller.evaluateJavascript(source: """
                    console.log('iOS Chart loaded successfully');
                    
                    // Set basic viewport
                    var viewport = document.querySelector('meta[name=viewport]');
                    if (!viewport) {
                      var meta = document.createElement('meta');
                      meta.name = 'viewport';
                      meta.content = 'width=device-width, initial-scale=1.0, user-scalable=no';
                      document.head.appendChild(meta);
                    }
                  """);
                } catch (e) {
                  print('⚠️ JavaScript injection error: $e');
                }
              }
              
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  loadingProgress = progress / 100;
                });
              }
            },
            onLoadError: (controller, url, code, message) {
              print('❌ Load error: $code - $message');
              print('🌐 Failed URL: $url');
              print('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'Error $code: $message';
                });
              }
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              print('❌ HTTP error: $statusCode - $description');
              print('🌐 Failed URL: $url');
              print('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'HTTP Error $statusCode: $description';
                });
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('💬 Console: ${consoleMessage.message}');
            },
          ),

          // Loading Progress Bar
          if (isLoading && !hasError)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: loadingProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  CustomColor.secondaryColor,
                ),
              ),
            ),

          // Loading Overlay (only on initial load)
          if (isLoading && loadingProgress < 0.5)
            Container(
              color: isDark ? Colors.black87 : Colors.white70,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: CustomColor.secondaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat Chart...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error State
          if (hasError)
            Container(
              color: isDark ? Colors.black : Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.chart_fail_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chart Tidak Dapat Dimuat',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage ?? 
                        'Server chart sedang mengalami gangguan atau tidak dapat diakses.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _reloadChart,
                        icon: const Icon(
                          Iconsax.refresh_outline,
                          color: Colors.black,
                        ),
                        label: Text(
                          'Muat Ulang Chart',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Show URL info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.info_circle_outline,
                                  size: 16,
                                  color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'URL Chart',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              _buildChartUrl(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      
      // Bottom info bar + Trading Panel
      bottomNavigationBar: !hasError
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trading panel
                ChartTradingPanel(
                  login: widget.login ?? accountController.selectedAccount.value?.login ?? '',
                  symbol: _currentSymbol ?? widget.symbol ?? chartController.selectedMarket.value,
                  onOrderExecuted: (operation) {
                    print('✅ Order executed callback: $operation');
                    print('🔄 Symbol: ${_currentSymbol ?? widget.symbol}');
                    print('👤 Login: ${widget.login ?? accountController.selectedAccount.value?.login}');
                    // Bisa tambahkan refresh chart atau logic lainnya jika diperlukan
                    // _reloadChart(); // Uncomment jika ingin auto-reload chart setelah order
                  },
                ),
              ],
            )
          : null,
    );
  }

  @override
  void dispose() {
    webViewController = null;
    super.dispose();
  }
}
