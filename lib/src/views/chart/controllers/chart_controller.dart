import 'dart:async'; // 👈 Import library async untuk Timer
import 'dart:math';
import 'package:get/get.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/views/chart/controllers/market_list_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ChartControllers extends GetxController {
  RxBool isLoading = false.obs;
  final accountController = Get.put(AccountController());
  final TradingController tradingController = Get.put(TradingController());
  final marketListController = Get.put(MarketListController());

  // Deklarasi Timer
  Timer? _pollingTimer; // 👈 Variabel untuk menyimpan instance Timer

  final selectedMarket = 'XAUUSD.db'.obs;
  final lot = 0.10.obs;
  final RxDouble currentPrice = 0.0.obs;
  final RxString timeFrame = "H1".obs;
  final RxDouble spreadValue = 0.0.obs;
  DateTime now = DateTime.now();
  final RxList<String> availableTimeframes = ['M1', 'M5', 'M15', 'M30', 'H1', 'H4','D1', 'W1', 'MN'].obs;

  RealtimeChannel? channel;
  final AuthService authService = AuthService();

  @override
  void onInit() {
    initConnection();
    _runProcessInit();
    _startDataPolling(); // 👈 Mulai polling saat inisialisasi
    super.onInit();
  }

  @override
  void onClose() {
    _stopDataPolling(); // 👈 Hentikan polling saat controller dihancurkan
    super.onClose();
  }

  int timeframeToGranularity(String tf) {
    switch (tf) {
      case 'M1':
        return 60;
      case 'M5':
        return 300;
      case 'M15':
        return 900;
      case 'M30':
        return 1800;
      case 'H1':
        return 3600;
      case 'H4':
        return 14400;
      default:
        return 3600;
    }
  }

  void initConnection() {
    isLoading.value = true;
    if(!accountController.hasAccounts){
      isLoading.value = false;
      return;
    }
    if (accountController.selectedAccount.value == null) {
      isLoading.value = false;
      return;
    }
    accountController.connectToMeta5(loginNumber: accountController.selectedAccount.value?.login).then((success) {
      if (success) {
        AppSnackbar.success('Akun ${accountController.selectedAccount.value?.type} ${accountController.selectedAccount.value?.login} berhasil dihubungkan ke MetaTrader 5.');
      } else {
        showMt5PasswordPopup(
          Get.context!,
          login: accountController.selectedAccount.value?.login ?? "",
          onSubmit: (password) async {
            final changeSuccess = await accountController.changePasswordMeta5(
              loginNumber: accountController.selectedAccount.value?.login,
              newPassword: password,
            );

            if (changeSuccess) {
              AppSnackbar.success("Password akun ${accountController.selectedAccount.value?.login} berhasil diubah.");

              final reconnect = await accountController.connectToMeta5(
                loginNumber: accountController.selectedAccount.value?.login,
              );

              if (reconnect) {
                AppSnackbar.success(
                  "Akun ${accountController.selectedAccount.value?.login} berhasil dihubungkan ke MetaTrader 5."
                );
              } else {
                AppSnackbar.error(
                  "Gagal menghubungkan akun ${accountController.selectedAccount.value?.login} setelah mengubah password."
                );
              }

            } else {
              AppSnackbar.error(
                "Gagal mengubah password akun ${accountController.selectedAccount.value?.login}."
              );
            }
          },
        );

        // showMt5PasswordPopup(Get.context!, login: accountController.selectedAccount.value?.login ?? "",
        //   onSubmit: (password, otp) async {
        //     final changeSuccess = await accountController.changePasswordMeta5(
        //       loginNumber: accountController.selectedAccount.value?.login,
        //       newPassword: password,
        //       otp: otp,
        //     );
        //     if (changeSuccess) {
        //       AppSnackbar.success("Password akun ${accountController.selectedAccount.value?.login} berhasil diubah.");
        //       final reconnect = await accountController.connectToMeta5(loginNumber: accountController.selectedAccount.value?.login);
        //       if (reconnect) {
        //         AppSnackbar.success("Akun ${accountController.selectedAccount.value?.login} berhasil dihubungkan ke MetaTrader 5.");
        //       } else {
        //         AppSnackbar.error("Gagal menghubungkan akun ${accountController.selectedAccount.value?.login} setelah mengubah password.");
        //       }
        //     } else {
        //       AppSnackbar.error("Gagal mengubah password akun ${accountController.selectedAccount.value?.login}.");
        //     }
        //   },
        //   /// KIRIM OTP KE SERVER
        //   onSendOtp: () async {
        //     final res = await accountController.sendOTPChangePasswordMeta();
        //     return res;
        //   },
        // );
      }
    });
    isLoading.value = false;
  }

  void changeTimeframe(String newTimeframe) async {
    timeFrame.value = newTimeframe;

    // Hentikan polling lama
    _stopDataPolling(); 

    // Load ulang data chart langsung (biar tidak perlu nunggu timer)
    await loadChartData();

    // Jalankan ulang proses initial (jika perlu load spread, dsb)
    await _runProcessInit();

    // Mulai polling ulang
    _startDataPolling();
  }


  /// === Polling Logic ===

  void _startDataPolling() {
    bool runIt = isForexHoliday(now);
    if(runIt) {
      Get.log("Forex Libur");
      return;
    }
    // Pastikan tidak ada timer yang berjalan sebelumnya
    _stopDataPolling(); 
    

    
    // Polling setiap 10 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // Panggil fungsi yang hanya memuat ulang data chart
      loadChartData(); 
    });
    Get.log("Polling data chart dimulai (10 detik)");
  }

  void _stopDataPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      _pollingTimer!.cancel();
      Get.log("Polling data chart dihentikan");
    }
  }
  
  // Fungsi terpisah untuk memuat data chart saja
  Future<void> loadChartData({String? timeframe}) async {
    final loginID = accountController.selectedAccount.value?.login;
    if (loginID == null) return;
    final accessToken = await getAccessToken();
    if (accessToken == null) return;
    final resultCandle = await tradingController.getMarketForDerivChartV3(
      loginID: loginID,
      symbol: selectedMarket.value,
      timeframe: timeframe ?? timeFrame.value,
    );
    if (resultCandle) {
      currentPrice.value = tradingController.ohlcDataDeriv.last.close;
      Get.log("Data chart untuk ${selectedMarket.value} di-refresh (${timeFrame.value}).");
    }
  }


  /// === Token ===
  Future<String?> getAccessToken() async {
    // ... (kode getAccessToken tetap sama)
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      Get.log("Error getAccessToken: $e");
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    // ... (kode getRefreshToken tetap sama)
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('refreshToken');
    } catch (e) {
      Get.log("Error getRefreshToken: $e");
      return null;
    }
  }

  /// === INIT ===
  Future<void> _runProcessInit() async {
    final loginID = accountController.selectedAccount.value?.login;
    if (loginID == null) {
      Get.log("LOGIN ID NULL pada CHART");
      return;
    }

    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    if (accessToken == null) return;

    // Fetch market list (Ini hanya perlu di awal, tidak perlu di polling)
    await marketListController.fetchSymbols(
      accessToken: accessToken,
      refreshToken: refreshToken,
      loginID: loginID,
    );

    // ... (Logika Spread dan Symbol tetap sama)
    final resultSymbol = await getSymbolsGroup(
      accessToken: accessToken,
      loginID: loginID,
    );

    if (resultSymbol == null || resultSymbol.isEmpty) {
      Get.log("Tidak ada simbol ditemukan");
      return;
    }

    final selectedSymbolData = resultSymbol.firstWhereOrNull(
      (e) => e['symbol'] == selectedMarket.value,
    );

    if (selectedSymbolData != null) {
      final spreadInt = (selectedSymbolData['spread'] ?? 0).toInt();
      final digits = (selectedSymbolData['digits'] ?? 2).toInt();

      final calcSpread = getSpreadInPrice(
        spread: spreadInt,
        digits: digits,
      );
      spreadValue.value = calcSpread;
    }

    // === Load Chart Data saat INIT ===
    await loadChartData(); // Panggil load data pertama kali
  }

  /// === Fungsi Baru: Ambil symbol group langsung dari API ===
  Future<List<Map<String, dynamic>>?> getSymbolsGroup({
    required String accessToken,
    required String loginID,
  }) async {
    // ... (kode getSymbolsGroup tetap sama)
    try {
      final result = await authService.get("market/symbols-group?account=$loginID");

      if (result['status'] != true) {
        Get.log("Gagal ambil symbols-group: ${result['message']}");
        return null;
      }

      final response = result['response'];
      if (response == null || response is! List) return null;

      final List<Map<String, dynamic>> allSymbols = [];
      for (var group in response) {
        if (group['symbols'] != null) {
          for (var s in group['symbols']) {
            allSymbols.add(s as Map<String, dynamic>);
          }
        }
      }
      return allSymbols;
    } catch (e) {
      Get.log("Error getSymbolsGroup: $e");
      return null;
    }
  }

  /// === Kalkulasi spread ke harga ===
  double getSpreadInPrice({required int spread, required int digits}) {
    // ... (kode getSpreadInPrice tetap sama)
    return spread / pow(10, digits);
  }
}