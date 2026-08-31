import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';

class ChartControllers extends GetxController {
  final selectedMarket = 'XAUUSD.db'.obs;
  RxBool isLoading = false.obs;
  final accountController = Get.put(AccountController());
  // final TradingController tradingController = Get.put(TradingController());
  // final marketListController = Get.put(MarketListController());
  // final MarketWebSocketController wsController = Get.put(
  //   MarketWebSocketController(),
  //   permanent: true,
  // );

  // // Deklarasi Timer
  // Timer? _pollingTimer; // 👈 Variabel untuk menyimpan instance Timer

  // final lot = 0.10.obs;
  // final RxDouble currentPrice = 0.0.obs;
  // final RxDouble bidPrice = 0.0.obs;
  // final RxDouble askPrice = 0.0.obs;
  // final RxInt priceDigits = 2.obs; // Digits untuk format price
  // final RxString timeFrame = "H1".obs;
  // final RxDouble spreadValue = 0.0.obs;
  // DateTime now = DateTime.now();
  // final RxList<String> availableTimeframes =
  //     ['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1', 'W1', 'MN'].obs;

  // final AuthService authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    // Defer initConnection to after the first frame to avoid
    // showing dialogs before the widget tree is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      initConnection();
    });
  }

  // // @override
  // // void onInit() {
  // //   // Set initial priceDigits based on symbol
  // //   priceDigits.value = _getDefaultDigitsForSymbol(selectedMarket.value);
  // //   initConnection();
  // //   _runProcessInit();
  // //   _startDataPolling(); // 👈 Mulai polling saat inisialisasi
  // //   _listenToWebSocketPrices(); // 👈 Listen ke WebSocket untuk real-time prices
  // //   super.onInit();
  // // }

  // // Helper function untuk mendapatkan default digits berdasarkan symbol
  // int _getDefaultDigitsForSymbol(String symbol) {
  //   final upperSymbol = symbol.toUpperCase();
  //   if (upperSymbol.contains('JPY')) {
  //     return 3; // JPY pairs have 3 decimal places
  //   } else if (upperSymbol.contains('XAU') || upperSymbol.contains('GOLD')) {
  //     return 2; // Gold has 2 decimal places
  //   } else if (upperSymbol.contains('XAG') || upperSymbol.contains('SILVER')) {
  //     return 3; // Silver has 3 decimal places
  //   } else {
  //     return 5; // Most forex pairs have 5 decimal places
  //   }
  // }

  // void _listenToWebSocketPrices() {
  //   // Listen perubahan pada marketData dari WebSocket
  //   ever(wsController.marketData, (data) {
  //     final symbolKey = _getWebSocketSymbol(selectedMarket.value);
  //     // print(
  //     //   '📊 WebSocket data updated. Available symbols: ${data.keys.toList()}',
  //     // );
  //     // print('🔍 Looking for symbol: $symbolKey');

  //     if (data.containsKey(symbolKey)) {
  //       final marketData = data[symbolKey];
  //       if (marketData != null) {
  //         // print(
  //         //   '✅ Found data for $symbolKey - Bid: ${marketData.bid}, Ask: ${marketData.ask}, Digits: ${marketData.digits}',
  //         // );
  //         bidPrice.value = marketData.bid;
  //         askPrice.value = marketData.ask;
  //         priceDigits.value = marketData.digits;
  //         currentPrice.value =
  //             marketData.bid; // Update current price dengan bid
  //         spreadValue.value = marketData.ask - marketData.bid;
  //       }
  //     } else {
  //       // print('❌ Symbol $symbolKey not found in WebSocket data');
  //     }
  //   });

  //   // Listen perubahan selected market untuk update prices
  //   ever(selectedMarket, (market) {
  //     final symbolKey = _getWebSocketSymbol(market);
  //     print('🔄 Market changed to: $symbolKey');

  //     // Set default digits immediately berdasarkan symbol
  //     priceDigits.value = _getDefaultDigitsForSymbol(market);

  //     // Pastikan WebSocket tetap aktif saat pindah market
  //     _ensureWebSocketConnection();

  //     final data = wsController.marketData[symbolKey];
  //     if (data != null) {
  //       // print(
  //       //   '✅ Immediate data found - Bid: ${data.bid}, Ask: ${data.ask}, Digits: ${data.digits}',
  //       // );
  //       bidPrice.value = data.bid;
  //       askPrice.value = data.ask;
  //       priceDigits.value = data.digits; // Override dengan data dari WS
  //       currentPrice.value = data.bid;
  //       spreadValue.value = data.ask - data.bid;
  //     } else {
  //       print(
  //         '⏳ Waiting for WebSocket data for $symbolKey (using default digits: ${priceDigits.value})',
  //       );
  //     }
  //   });
  // }

  // String _getWebSocketSymbol(String market) {
  //   // WebSocket response sudah include '.db' (contoh: "XAUUSD.db")
  //   // Jadi kita langsung return market yang sudah sesuai format
  //   return market;
  // }

  // @override
  // void onClose() {
  //   _stopDataPolling(); // 👈 Hentikan polling saat controller dihancurkan
  //   super.onClose();
  // }

  // int timeframeToGranularity(String tf) {
  //   switch (tf) {
  //     case 'M1':
  //       return 60;
  //     case 'M5':
  //       return 300;
  //     case 'M15':
  //       return 900;
  //     case 'M30':
  //       return 1800;
  //     case 'H1':
  //       return 3600;
  //     case 'H4':
  //       return 14400;
  //     default:
  //       return 3600;
  //   }
  // }

  void initConnection() {
    isLoading.value = true;
    debugPrint('🔄 [ChartController] initConnection() dimulai');
    
    if (!accountController.hasAccounts) {
      debugPrint('❌ [ChartController] Tidak ada akun tersedia');
      isLoading.value = false;
      return;
    }
    
    final selectedAcc = accountController.selectedAccount.value;
    if (selectedAcc == null) {
      debugPrint('❌ [ChartController] selectedAccount null');
      isLoading.value = false;
      return;
    }
    
    debugPrint('🔗 [ChartController] Mencoba connectToMeta5 untuk login: ${selectedAcc.login}, type: ${selectedAcc.type}');
    
    accountController.connectToMeta5(loginNumber: selectedAcc.login).then((success) {
      debugPrint('📡 [ChartController] connectToMeta5 callback - success: $success');
      
      if (success) {
        debugPrint('✅ [ChartController] Koneksi berhasil untuk akun ${selectedAcc.type} ${selectedAcc.login}');
        AppSnackbar.success(
          'Akun ${selectedAcc.type} ${selectedAcc.login} berhasil dihubungkan ke MetaTrader 5.',
        );
      } else {
        debugPrint('⚠️ [ChartController] Koneksi gagal untuk akun ${selectedAcc.login}, menampilkan password popup');
        final ctx = Get.context;
        if (ctx == null) {
          debugPrint('❌ [ChartController] Get.context is null, cannot show password popup');
          return;
        }
        showMt5PasswordPopup(
          ctx,
          login: selectedAcc.login ?? "",
          onSubmit: (password) async {
            debugPrint('🔑 [ChartController] Password popup submit - mencoba changePasswordMeta5 untuk login: ${selectedAcc.login}');
            
            final changeSuccess = await accountController.changePasswordMeta5(
              loginNumber: selectedAcc.login,
              newPassword: password,
            );
            
            debugPrint('🔄 [ChartController] changePasswordMeta5 result: $changeSuccess');

            if (changeSuccess) {
              debugPrint('✅ [ChartController] Password berhasil diubah untuk ${selectedAcc.login}');
              AppSnackbar.success(
                "Password akun ${selectedAcc.login} berhasil diubah.",
              );

              debugPrint('🔗 [ChartController] Mencoba reconnect setelah password change untuk login: ${selectedAcc.login}');
              final reconnect = await accountController.connectToMeta5(
                loginNumber: selectedAcc.login,
              );
              
              debugPrint('📡 [ChartController] Reconnect result setelah password change: $reconnect');

              if (reconnect) {
                debugPrint('✅ [ChartController] Reconnect berhasil untuk ${selectedAcc.login}');
                AppSnackbar.success(
                  "Akun ${selectedAcc.login} berhasil dihubungkan ke MetaTrader 5.",
                );
              } else {
                debugPrint('❌ [ChartController] Reconnect gagal setelah password change untuk ${selectedAcc.login}');
                AppSnackbar.error(
                  "Gagal menghubungkan akun ${selectedAcc.login} setelah mengubah password.",
                );
              }
            } else {
              debugPrint('❌ [ChartController] Password change gagal untuk ${selectedAcc.login}');
              AppSnackbar.error(
                "Gagal mengubah password akun ${selectedAcc.login}.",
              );
            }
          },
        );
      }
    }).catchError((error) {
      debugPrint('❌ [ChartController] Error di connectToMeta5: $error');
    });
    
    isLoading.value = false;
  }

  // void changeTimeframe(String newTimeframe) async {
  //   timeFrame.value = newTimeframe;

  //   // Hentikan polling lama
  //   _stopDataPolling();

  //   // Pastikan WebSocket tetap aktif
  //   _ensureWebSocketConnection();

  //   // Load ulang data chart langsung (biar tidak perlu nunggu timer)
  //   await loadChartData();

  //   // Jalankan ulang proses initial (jika perlu load spread, dsb)
  //   await _runProcessInit();

  //   // Mulai polling ulang
  //   _startDataPolling();
  // }

  // void _ensureWebSocketConnection() {
  //   // Cek status WebSocket dan reconnect jika perlu
  //   if (wsController.status.value == WebSocketStatus.failed ||
  //       wsController.status.value == WebSocketStatus.disconnected) {
  //     Get.log("🔄 WebSocket disconnected, attempting reconnect...");
  //     wsController.reconnect();
  //   } else {
  //     Get.log("✅ WebSocket is ${wsController.status.value}");
  //   }
  // }

  // /// === Polling Logic ===

  // void _startDataPolling() {
  //   bool runIt = isForexHoliday(now);
  //   if (runIt) {
  //     Get.log("Forex Libur");
  //     return;
  //   }
  //   // Pastikan tidak ada timer yang berjalan sebelumnya
  //   _stopDataPolling();

  //   // Polling setiap 10 detik
  //   _pollingTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
  //     // Panggil fungsi yang hanya memuat ulang data chart
  //     loadChartData();
  //   });
  //   Get.log("Polling data chart dimulai (10 detik)");
  // }

  // void _stopDataPolling() {
  //   if (_pollingTimer != null && _pollingTimer!.isActive) {
  //     _pollingTimer!.cancel();
  //     Get.log("Polling data chart dihentikan");
  //   }
  // }

  // // Fungsi terpisah untuk memuat data chart saja
  // Future<void> loadChartData({String? timeframe}) async {
  //   final loginID = accountController.selectedAccount.value?.login;
  //   final accountType = accountController.selectedAccount.value?.type;
  //   if (loginID == null) return;
  //   final accessToken = await getAccessToken();
  //   if (accessToken == null) return;
  //   final resultCandle = await tradingController.getMarketForDerivChartV4(
  //     loginID: loginID,
  //     symbol: selectedMarket.value,
  //     timeFrame: timeframe ?? timeFrame.value,
  //     accountType: accountType ?? "demo",
  //   );
  //   if (resultCandle) {
  //     currentPrice.value = tradingController.ohlcDataDeriv.last.close;
  //     Get.log(
  //       "Data chart untuk ${selectedMarket.value} di-refresh (${timeFrame.value}).",
  //     );
  //   }
  // }

  // /// === Token ===
  // Future<String?> getAccessToken() async {
  //   // ... (kode getAccessToken tetap sama)
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     return prefs.getString('accessToken');
  //   } catch (e) {
  //     Get.log("Error getAccessToken: $e");
  //     return null;
  //   }
  // }

  // Future<String?> getRefreshToken() async {
  //   // ... (kode getRefreshToken tetap sama)
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     return prefs.getString('refreshToken');
  //   } catch (e) {
  //     Get.log("Error getRefreshToken: $e");
  //     return null;
  //   }
  // }

  // /// === INIT ===
  // Future<void> _runProcessInit() async {
  //   final loginID = accountController.selectedAccount.value?.login;
  //   if (loginID == null) {
  //     Get.log("LOGIN ID NULL pada CHART");
  //     return;
  //   }

  //   final accessToken = await getAccessToken();
  //   final refreshToken = await getRefreshToken();
  //   if (accessToken == null) return;

  //   // Fetch market list (Ini hanya perlu di awal, tidak perlu di polling)
  //   await marketListController.fetchSymbols(
  //     accessToken: accessToken,
  //     refreshToken: refreshToken,
  //     loginID: loginID,
  //   );

  //   // ... (Logika Spread dan Symbol tetap sama)
  //   final resultSymbol = await getSymbolsGroup(
  //     accessToken: accessToken,
  //     loginID: loginID,
  //   );

  //   if (resultSymbol == null || resultSymbol.isEmpty) {
  //     Get.log("Tidak ada simbol ditemukan");
  //     return;
  //   }

  //   final selectedSymbolData = resultSymbol.firstWhereOrNull(
  //     (e) => e['symbol'] == selectedMarket.value,
  //   );

  //   if (selectedSymbolData != null) {
  //     final spreadInt = (selectedSymbolData['spread'] ?? 0).toInt();
  //     final digits = (selectedSymbolData['digits'] ?? 2).toInt();

  //     final calcSpread = getSpreadInPrice(spread: spreadInt, digits: digits);
  //     spreadValue.value = calcSpread;
  //   }

  //   // === Load Chart Data saat INIT ===
  //   await loadChartData(); // Panggil load data pertama kali
  // }

  // /// === Fungsi Baru: Ambil symbol group langsung dari API ===
  // Future<List<Map<String, dynamic>>?> getSymbolsGroup({
  //   required String accessToken,
  //   required String loginID,
  // }) async {
  //   // ... (kode getSymbolsGroup tetap sama)
  //   try {
  //     final result = await authService.get(
  //       "market/symbols-group?account=$loginID",
  //     );

  //     if (result['status'] != true) {
  //       Get.log("Gagal ambil symbols-group: ${result['message']}");
  //       return null;
  //     }

  //     final response = result['response'];
  //     if (response == null || response is! List) return null;

  //     final List<Map<String, dynamic>> allSymbols = [];
  //     for (var group in response) {
  //       if (group['symbols'] != null) {
  //         for (var s in group['symbols']) {
  //           allSymbols.add(s as Map<String, dynamic>);
  //         }
  //       }
  //     }
  //     return allSymbols;
  //   } catch (e) {
  //     Get.log("Error getSymbolsGroup: $e");
  //     return null;
  //   }
  // }

  // /// === Kalkulasi spread ke harga ===
  // double getSpreadInPrice({required int spread, required int digits}) {
  //   // ... (kode getSpreadInPrice tetap sama)
  //   return spread / pow(10, digits);
  // }
}
