import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/websocket_controller.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/service/account_credentials_service.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/symbols_controller.dart';
import 'widgets/market_selector_sheet.dart';
import 'widgets/chart_trading_panel.dart';
import 'dart:io' show Platform;
import 'dart:async';

class WebViewChartView extends StatefulWidget {
  final String? symbol;
  final String? serverType;
  final String? login;

  const WebViewChartView({super.key, this.symbol, this.serverType, this.login});

  @override
  State<WebViewChartView> createState() => _WebViewChartViewState();
}

class _WebViewChartViewState extends State<WebViewChartView>
    with WidgetsBindingObserver {
  final chartController = Get.put(ChartControllers());
  final accountController = Get.put(AccountController());
  final symbolsController = Get.put(SymbolsController());
  final tickController = Get.put(TickWSSController());
  late final TradingController _tradingController;
  Worker? _chartRefreshWorker;

  InAppWebViewController? webViewController;
  bool isLoading = true;
  bool hasError = false;
  double loadingProgress = 0;
  String? errorMessage;
  bool _previousTheme = Get.isDarkMode;
  String? _currentSymbol;
  bool _hasConnection = true;
  bool _isTimeout = false;
  bool _isCreatingDemoAccount = false; // Track demo account creation
  bool _waitingForAccount = false; // Guard untuk _waitForAccount
  Worker? _accountWorker;
  Worker? _symbolWorker;
  late StreamSubscription _connectionSubscription;
  Timer? _timeoutTimer;
  Timer? _chartRefreshDebounce;
  
  // Current price from chart
  final RxnDouble currentPrice = RxnDouble(null);

  // Reactive bid/ask — updated via ever() worker, not inside Obx
  final RxString _bidObs = '0.00'.obs;
  final RxString _askObs = '0.00'.obs;
  Worker? _tickWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _previousTheme = Get.isDarkMode;

    // Use symbol from widget parameter if provided, otherwise use chartController's saved value
    if (widget.symbol != null && widget.symbol!.isNotEmpty) {
      _currentSymbol = widget.symbol;
      chartController.selectedMarket.value = widget.symbol!;
    } else {
      _currentSymbol = chartController.selectedMarket.value;
    }

    // Listen for position closes from other tabs and reload the chart
    // Debounce agar: (1) server punya waktu proses close, (2) Close All hanya trigger 1x reload
    _tradingController = Get.find<TradingController>();
    _chartRefreshWorker = ever(_tradingController.chartRefreshTrigger, (_) {
      _chartRefreshDebounce?.cancel();
      _chartRefreshDebounce = Timer(const Duration(milliseconds: 1500), () {
        if (webViewController != null && mounted) {
          _reloadChart();
        }
      });
    });

    // Listen to selectedMarket changes (e.g., triggered from Market tab)
    _symbolWorker = ever(chartController.selectedMarket, (symbol) {
      if (symbol != _currentSymbol && mounted) {
        setState(() {
          _currentSymbol = symbol;
        });
        // Reset prices until first tick arrives for the new symbol
        _bidObs.value = '0.00';
        _askObs.value = '0.00';
        _reloadChart();
      }
    });

    // Update bid/ask/currentPrice from tick — runs outside Obx to avoid full panel rebuild
    _tickWorker = ever(tickController.ticks, (map) {
      final tick = map[_currentSymbol];
      if (tick != null) {
        _bidObs.value = tick.bid.toStringAsFixed(tick.digits);
        _askObs.value = tick.ask.toStringAsFixed(tick.digits);
        currentPrice.value = tick.bid;
      }
    });

    // Monitor connection
    _checkConnection();
    _connectionSubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _hasConnection = !result.contains(ConnectivityResult.none);
      });
    });

    // Pre-fetch MT5 token agar sudah siap saat user klik Buy/Sell
    AccountCredentialsService.fetchAndCache();

    Future.delayed(const Duration(seconds: 1), () {
      _initConnectWSSTick();
    });
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _hasConnection = !result.contains(ConnectivityResult.none);
      });
    }
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && isLoading && !hasError) {
        setState(() {
          isLoading = false;
          hasError = true;
          _isTimeout = true;
        });
      }
    });
  }

  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Jika chart dimuat sebelum account tersedia (login kosong),
  /// tunggu account lalu reload chart dengan login yang benar.
  void _waitForAccount() {
    if (_waitingForAccount) return;
    _waitingForAccount = true;
    _accountWorker?.dispose();
    _accountWorker = ever(accountController.selectedAccount, (account) {
      if (account != null && account.login != null && account.login!.isNotEmpty) {
        _waitingForAccount = false;
        _accountWorker?.dispose();
        _accountWorker = null;
        if (mounted) {
          _reloadChart();
        }
      }
    });
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
    final symbol = _currentSymbol ?? widget.symbol ?? chartController.selectedMarket.value;
    final server = widget.serverType ?? accountController.selectedAccount.value?.type ?? 'demo';
    final login = widget.login ?? accountController.selectedAccount.value?.login ?? '';
    final theme = Get.isDarkMode ? 'dark' : 'light';

    // Jika login masih kosong (account belum loaded), gunakan placeholder
    // Chart akan di-reload saat account tersedia
    if (login.isEmpty) {
      _waitForAccount();
    }

    final baseUrl = 'https://webchart-rrfx.techcrm.dev/?symbol=$symbol&server=${server.toLowerCase()}&login=$login&theme=$theme';
    // final baseUrl = 'https://tv-rrfx-web.techcrm.dev/?theme=$theme&login=$login&server=${server.toLowerCase()}&symbol=$symbol';

    // Untuk iOS, tambahkan parameter khusus (skip untuk web)
    if (!kIsWeb && Platform.isIOS) {
      return '$baseUrl&platform=ios&mobile=1';
    }

    return baseUrl;
  }

  void _reloadChart() {
    setState(() {
      isLoading = true;
      hasError = false;
      _isTimeout = false;
      errorMessage = null;
      loadingProgress = 0;
    });
    _startTimeoutTimer();
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

  _initConnectWSSTick() async {
    String? login = widget.login ?? accountController.selectedAccount.value?.login; 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('wsToken');
    String? server = widget.serverType ?? accountController.selectedAccount.value?.type?.toLowerCase() ?? 'demo';
    
    // Jangan konek jika credentials belum tersedia — mencegah flood koneksi kosong
    if (token == null || token.isEmpty || login == null || login.isEmpty) {
      return;
    }

    tickController.connectToSocket(
      login: login,
      token: token,
      server: server,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Check if user has demo accounts - reactive with Obx
    return Obx(() {
      if (accountController.demoAccounts.isEmpty) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
            appBar: AppBar(
              leadingWidth: size.width * 0.25,
              title: Text(
                'Demo Chart',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
            body: _buildNoDemoAccountState(theme, isDark),
          ),
        );
      }

    // Show error if no connection
    if (!_hasConnection) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: AppBar(
            leadingWidth: size.width * 0.25,
            title: Text(
              _currentSymbol ?? 'XAUUSD.db',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
          body: _buildConnectionErrorState(theme, isDark),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
        body: Column(
          children: [
            // Info Bar — Market Selector + Login (tidak overlay WebView)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Market Button
                  GestureDetector(
                    onTap: _showMarketSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: CustomColor.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: CustomColor.secondaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.chart_square_outline,
                            size: 16,
                            color: CustomColor.secondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentSymbol ?? 'XAUUSD.db',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CustomColor.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Divider
                  Container(
                    width: 1,
                    height: 20,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),

                  // Login Info
                  Expanded(
                    child: Text(
                      '${widget.serverType ?? (accountController.selectedAccount.value?.type?.capitalize ?? 'Demo')} • ${widget.login ?? accountController.selectedAccount.value?.login ?? ''}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Obx(() {
                  //   final tick = tickController.ticks[_currentSymbol];
                  //   final displayColor = tickController.tickColors[_currentSymbol] ?? Colors.grey;
                  //   if (tick == null) {
                  //     return const SizedBox(
                  //       height: 12,
                  //       width: 12,
                  //       child: CircularProgressIndicator(strokeWidth: 2),
                  //     );
                  //   }
                  //   return Column(
                  //     children: [
                  //       Text(
                  //         "bid ${tick.bid.toStringAsFixed(tick.digits)}",
                  //         style: GoogleFonts.inter(
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.w700,
                  //           color: displayColor, // Warna berubah dinamis sesuai logika di controller
                  //         ),
                  //       ),
                  //       Text(
                  //         "ask ${tick.ask.toStringAsFixed(tick.digits)}",
                  //         style: GoogleFonts.inter(
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.w700,
                  //           color: displayColor, // Warna berubah dinamis sesuai logika di controller
                  //         ),
                  //       ),
                  //     ],
                  //   );
                  // })
                ],
              ),
            ),

            // WebView + Overlays (loading, error)
            Expanded(
              child: Stack(
                children: [
                  // WebView
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_buildChartUrl())),
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
              
                      // Untuk iOS, gunakan setting yang lebih simple (skip untuk web)
                      useHybridComposition:
                          kIsWeb ? false : !Platform.isIOS, // Disable hybrid composition di iOS
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
                      // Untuk Web, langsung set loading false setelah delay karena onLoadStop tidak reliable
                      if (kIsWeb) {
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && isLoading) {
                            setState(() {
                              isLoading = false;
                              loadingProgress = 1.0;
                            });
                          }
                        });
                      }
                      
                      // JavaScript handler untuk menerima price updates dari chart (skip untuk web)
                      if (!kIsWeb) {
                        controller.addJavaScriptHandler(
                          handlerName: 'priceUpdate',
                          callback: (args) {
                            if (args.isNotEmpty && mounted) {
                              try {
                                final price = double.tryParse(args[0].toString());
                                if (price != null) {
                                  currentPrice.value = price;
                                }
                              } catch (e) {
                                Get.log('⚠️ Error parsing price: $e');
                              }
                            }
                          },
                        );
                      }
              
                      // Set timeout untuk iOS (skip untuk web)
                      // Jika setelah 15s masih loading, timeout timer akan handle
                      // (dihapus auto-reload 10s karena conflict dengan timeout timer)
                    },
                    onLoadStart: (controller, url) {
                      _startTimeoutTimer();
                      if (mounted) {
                        setState(() {
                          isLoading = true;
                          hasError = false;
                          _isTimeout = false;
                          errorMessage = null;
                          loadingProgress = 0;
                        });
                      }
                    },
                    onLoadStop: (controller, url) async {
                      _cancelTimeoutTimer();
              
                      // Inject JavaScript untuk ambil price dari chart (skip untuk web)
                      if (!kIsWeb) {
                        try {
                          await controller.evaluateJavascript(
                            source: """
                          (function() {
                            
                            // Suppress console logs untuk "Creating stop loss line"
                            const originalLog = console.log;
                            console.log = function(...args) {
                              const message = args.join(' ');
                              if (!message.includes('Creating stop loss line')) {
                                originalLog.apply(console, args);
                              }
                            };
                            
                            // Function untuk kirim price ke Flutter
                            function sendPriceToFlutter(price) {
                              try {
                                if (window.flutter_inappwebview) {
                                  window.flutter_inappwebview.callHandler('priceUpdate', price.toString());
                                }
                              } catch (e) {
                                console.error('❌ Error sending price:', e);
                              }
                            }
                            
                            // Coba ambil price dari berbagai sumber
                            function findAndSendPrice() {
                              // Method 1: Cari di price element yang umum
                              const priceSelectors = [
                                '.current-price',
                                '.price-value',
                                '#current-price',
                                '[data-price]',
                                '.last-price'
                              ];
                              
                              for (let selector of priceSelectors) {
                                const element = document.querySelector(selector);
                                if (element) {
                                  const priceText = element.innerText || element.textContent;
                                  const price = parseFloat(priceText.replace(/[^0-9.]/g, ''));
                                  if (!isNaN(price) && price > 0) {
                                    sendPriceToFlutter(price);
                                    return true;
                                  }
                              }
                            }
                            
                            // Method 2: Cari text yang match pattern harga (e.g., 4919.17)
                            const bodyText = document.body.innerText;
                            const pricePattern = /\b\d{4}\.\d{2}\b/g;
                            const matches = bodyText.match(pricePattern);
                            if (matches && matches.length > 0) {
                              const price = parseFloat(matches[0]);
                              if (!isNaN(price)) {
                                sendPriceToFlutter(price);
                                return true;
                              }
                            }
                            
                            return false;
                          }
                          
                          // Set basic viewport
                          var viewport = document.querySelector('meta[name=viewport]');
                          if (!viewport) {
                            var meta = document.createElement('meta');
                            meta.name = 'viewport';
                            meta.content = 'width=device-width, initial-scale=1.0, user-scalable=no';
                            document.head.appendChild(meta);
                          }
                          
                          // Coba ambil price immediately
                          setTimeout(function() {
                            findAndSendPrice();
                          }, 500);
                          
                          // Poll price setiap 2 detik
                          setInterval(function() {
                            findAndSendPrice();
                          }, 2000);
                          
                          // Expose function globally untuk manual trigger
                          window.sendPriceToFlutter = sendPriceToFlutter;
                          
                          // console.log('✅ Price tracker initialized');
                        })();
                        """,
                          );
                        } catch (e) {
                          Get.log('⚠️ JavaScript injection error: $e');
                        }
                      }
              
                      // Update loading state untuk semua platform (mobile dan web)
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
                      Get.log('❌ Load error: $code - $message');
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                          hasError = true;
                          errorMessage = null;
                        });
                      }
                    },
                    onLoadHttpError: (controller, url, statusCode, description) {
                      Get.log('❌ HTTP error: $statusCode - $description');
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                          hasError = true;
                          errorMessage = null;
                        });
                      }
                    },
                    onConsoleMessage: (controller, consoleMessage) {},
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
              
                  // Loading Overlay (only on initial load, skip for web after brief moment)
                  if (isLoading && loadingProgress < 0.5 && !kIsWeb)
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
                        child: _buildErrorStateContent(theme, isDark),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        
        // Bottom info bar + Trading Panel
        bottomNavigationBar:
            !hasError
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trading panel — no Obx here; bid/ask update via RxString internally
                    ChartTradingPanel(
                      bidObs: _bidObs,
                      askObs: _askObs,
                      login:
                          widget.login ??
                          accountController.selectedAccount.value?.login ??
                          '',
                      symbol:
                          _currentSymbol ??
                          widget.symbol ??
                          chartController.selectedMarket.value,
                      currentPrice: currentPrice,
                      onOrderExecuted: (operation) {
                        // _reloadChart(); // Uncomment jika ingin auto-reload chart setelah order
                      },
                    ),
                  ],
                )
                : null,
            ),
      ));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      // Pause JS timers in WebView to reduce background CPU usage
      webViewController?.pauseTimers();
    } else if (state == AppLifecycleState.resumed) {
      webViewController?.resumeTimers();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chartRefreshWorker?.dispose();
    _symbolWorker?.dispose();
    _tickWorker?.dispose();
    _chartRefreshDebounce?.cancel();
    _connectionSubscription.cancel();
    _cancelTimeoutTimer();
    _accountWorker?.dispose();
    webViewController = null;
    super.dispose();
  }

  /// Create demo account via API POST
  Future<void> _createDemoAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken'); 
    if(accessToken == null || accessToken.isEmpty){
      ModernAlertDialog.error(
        title: 'Gagal',
        message: 'Anda harus login terlebih dahulu untuk membuat akun demo.',
        buttonText: 'OK',
        onPressed: () {
          Get.offAll(() => MainpageWithoutLogin());
        },
      );
      return;
    }
    if (_isCreatingDemoAccount) return; // Prevent multiple requests

    setState(() {
      _isCreatingDemoAccount = true;
    });

    try {
      Get.log('🔄 [WebViewChart] Creating demo account...');
      
      final response = await http.post(
        Uri.parse('${GlobalVariable.mainURL}/regol/createDemo'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Request timeout'),
      );

      Get.log('📥 [WebViewChart] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.log('✅ [WebViewChart] Demo account created successfully');
        
        // Show success dialog
        ModernAlertDialog.success(
          title: 'Berhasil',
          message: 'Akun demo berhasil dibuat! Silakan refresh halaman ini untuk melihat akun demo Anda.',
          buttonText: 'OK',
          onPressed: () {
            Get.back(); // Close dialog
            // Refresh account data
            accountController.fetchAccountInfo(forceRefresh: true).then((_) {
              // Refresh page
              setState(() {
                _isCreatingDemoAccount = false;
              });
            });
          },
        );
      } else {
        Get.log('❌ [WebViewChart] Failed to create demo account: ${response.statusCode}');
        ModernAlertDialog.error(
          title: 'Gagal',
          message: 'Gagal membuat akun demo. Coba lagi nanti.',
          buttonText: 'OK',
          onPressed: () {
            setState(() {
              _isCreatingDemoAccount = false;
            });
          },
        );
      }
    } on TimeoutException catch (_) {
      Get.log('⚠️ [WebViewChart] Demo account creation timeout');
      ModernAlertDialog.error(
        title: 'Timeout',
        message: 'Koneksi ke server memakan waktu terlalu lama. Silakan coba lagi.',
        buttonText: 'OK',
        onPressed: () {
          setState(() {
            _isCreatingDemoAccount = false;
          });
        },
      );
    } catch (e) {
      Get.log('❌ [WebViewChart] Error creating demo account: $e');
      ModernAlertDialog.error(
        title: 'Gagal',
        message: 'Terjadi kesalahan saat membuat akun demo. Coba lagi nanti.',
        buttonText: 'OK',
        onPressed: () {
          setState(() {
            _isCreatingDemoAccount = false;
          });
        },
      );
    }
  }

  /// Build UI for no demo account state
  Widget _buildNoDemoAccountState(ThemeData theme, bool isDarkMode) {
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
                        Iconsax.chart_square_outline,
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
                'Belum Ada Akun Demo',
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
                'Untuk menggunakan fitur demo chart, Anda perlu membuat akun demo terlebih dahulu. Akun demo memungkinkan Anda berlatih trading tanpa risiko finansial.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Benefits Card
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
                          Iconsax.info_circle_outline,
                          size: 18,
                          color: CustomColor.secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Keuntungan Akun Demo',
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
                      '• Praktik trading tanpa risiko finansial\n• Dana virtual unlimited\n• Akses ke semua fitur chart\n• Sempurna untuk pemula',
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
                  // Create demo button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isCreatingDemoAccount ? null : _createDemoAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: CustomColor.secondaryColor.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: _isCreatingDemoAccount
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode ? Colors.black87 : Colors.white,
                                ),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Iconsax.add_circle_outline, size: 20),
                      label: Text(
                        _isCreatingDemoAccount ? 'Membuat Akun...' : 'Buat Akun Demo',
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

  Widget _buildConnectionErrorState(ThemeData theme, bool isDarkMode) {
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
                'Tidak Ada Koneksi',
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
                'Sepertinya Anda tidak terhubung ke internet. Periksa koneksi WiFi atau data seluler Anda.',
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
                          setState(() {
                            hasError = false;
                            _isTimeout = false;
                          });
                          _reloadChart();
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

  Widget _buildErrorStateContent(ThemeData theme, bool isDarkMode) {
    final isTimeout = _isTimeout;
    
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
                        isTimeout 
                          ? Iconsax.timer_1_outline 
                          : Iconsax.chart_fail_outline,
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
                isTimeout ? 'Koneksi Terlalu Lambat' : 'Chart Tidak Dapat Dimuat',
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
                isTimeout
                    ? 'Server membutuhkan waktu terlalu lama untuk merespons. Coba lagi atau periksa kecepatan internet Anda.'
                    : 'Gagal memuat chart. Periksa koneksi internet Anda dan coba lagi.',
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
                      isTimeout
                          ? '• Periksa kecepatan koneksi internet Anda\n• Tunggu beberapa saat dan coba lagi\n• Jika masalah berlanjut, coba ubah server'
                          : '• Pastikan koneksi internet stabil\n• Coba menyegarkan halaman\n• Periksa pengaturan jaringan Anda',
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
                        setState(() {
                          hasError = false;
                          _isTimeout = false;
                        });
                        _reloadChart();
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
}
