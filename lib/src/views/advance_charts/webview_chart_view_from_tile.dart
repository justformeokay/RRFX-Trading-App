import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/advance_charts/controllers/symbols_controller.dart';
import 'package:rrfx/src/views/advance_charts/widgets/market_selector_sheet.dart';
import 'package:rrfx/src/views/advance_charts/widgets/chart_trading_panel.dart';

/// WebView Chart View untuk dibuka dari Market Tile
/// Langsung load chart dengan market yang dipilih
class WebViewChartViewFromTile extends StatefulWidget {
  final int login;
  final String marketName;
  final double? balance;
  final String? serverType;

  const WebViewChartViewFromTile({
    super.key,
    required this.login,
    required this.marketName,
    this.balance,
    this.serverType,
  });

  @override
  State<WebViewChartViewFromTile> createState() => _WebViewChartViewFromTileState();
}

class _WebViewChartViewFromTileState extends State<WebViewChartViewFromTile> {
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
    _currentSymbol = widget.marketName;
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
    final symbol = _currentSymbol ?? widget.marketName;
    final server = widget.serverType ?? 
                   accountController.selectedAccount.value?.type ?? 
                   'demo';
    final login = widget.login.toString();
    final theme = Get.isDarkMode ? 'dark' : 'light';

    return 'http://207.148.119.106/rrfx/chart.php?symbol=$symbol&server=${server.toLowerCase()}&login=$login&theme=$theme';
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
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          _currentSymbol ?? widget.marketName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
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
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
              useHybridComposition: true,
              supportZoom: false,
              builtInZoomControls: false,
              displayZoomControls: false,
              transparentBackground: true,
              clearCache: false,
              cacheEnabled: true,
              minimumFontSize: 1,
              textZoom: 100,
              disableVerticalScroll: false,
              disableHorizontalScroll: false,
              verticalScrollBarEnabled: true,
              horizontalScrollBarEnabled: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              print('🌐 WebView created for ${widget.marketName}');
              
              // Inject JavaScript to disable zoom
              controller.evaluateJavascript(source: """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(meta);
              """);
            },
            onLoadStart: (controller, url) {
              print('📥 Loading started: $url');
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
              
              // Inject viewport meta tag to prevent zooming
              await controller.evaluateJavascript(source: """
                var meta = document.querySelector('meta[name=viewport]');
                if (meta) {
                  meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
                } else {
                  var newMeta = document.createElement('meta');
                  newMeta.name = 'viewport';
                  newMeta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                  document.head.appendChild(newMeta);
                }
                
                // Prevent zoom gestures
                document.addEventListener('gesturestart', function(e) {
                  e.preventDefault();
                });
                document.addEventListener('touchmove', function(e) {
                  if (e.scale !== 1) {
                    e.preventDefault();
                  }
                }, { passive: false });
              """);
              
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
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = message;
                });
              }
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              print('❌ HTTP error: $statusCode - $description');
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
                // Info bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.chart_outline,
                        size: 16,
                        color: CustomColor.secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (_currentSymbol ?? widget.marketName),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      if (widget.balance != null) ...[
                        Text(
                          '\$${widget.balance?.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${widget.serverType ?? accountController.selectedAccount.value?.type ?? 'Demo'} • ${widget.login}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Trading panel
                ChartTradingPanel(
                  login: widget.login.toString(),
                  symbol: _currentSymbol ?? widget.marketName,
                  onOrderExecuted: (operation) {
                    print('✅ Order executed: $operation');
                    // Bisa tambahkan refresh chart atau logic lainnya
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
