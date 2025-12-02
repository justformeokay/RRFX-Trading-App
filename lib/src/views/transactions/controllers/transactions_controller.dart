// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/views/transactions/models/account_model.dart';
// import 'package:rrfx/src/views/transactions/models/opened_order_model.dart';
// import 'package:rrfx/src/views/transactions/models/trade_model.dart';
// import 'package:rrfx/src/views/transactions/services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TransactionsController extends GetxController {
//   var isLoading = false.obs;
//   var selectedAccount = Rxn<AccountModel>(); // akun aktif
//   var selectedAccountType = 'real'.obs; // real/demo
//   var accounts = <AccountModel>[].obs;
//   var openedOrders = <OpenedOrderModel>[].obs;
//   var tradeHistory = <TradeModel>[].obs;
//   Timer? autoRefreshTimer;
//   int currentTabIndex = 0; // untuk tahu tab mana yang aktif
//   var isMarketClosed = false.obs;

//   Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('accessToken');
//     return token;
//   } 

//   String? token;

//   @override
//   void onInit() {
//     super.onInit();
//     // fetchAccounts();
//     // startAutoRefresh();
//   }

//   @override
//   void onClose() {
//     stopAutoRefresh();
//     super.onClose();
//   }

//   void startAutoRefresh() {
//     _isForexClosedNow();
//     autoRefreshTimer?.cancel();
//     autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (isMarketClosed.value) return;
//       final acc = selectedAccount.value;
//       if (acc == null) return;

//       if (currentTabIndex == 0) {
//         await fetchOpenedOrders(acc.login);
//       } else if (currentTabIndex == 2) {
//         await fetchTradeHistory(acc.login);
//       }
//     });
//   }


//   void stopAutoRefresh() {
//     autoRefreshTimer?.cancel();
//   }

//   /// 🔥 Cek apakah hari ini pasar forex tutup
//   bool _isForexClosedNow() {
//     final now = DateTime.now().toUtc().add(const Duration(hours: 7)); // WIB
//     final weekday = now.weekday; // 1 = Senin, 7 = Minggu
//     final hour = now.hour;

//     // Tutup Sabtu pagi (>=4:00) sampai Senin pagi (<5:00)
//     if (weekday == 6 && hour >= 4) return true; // Sabtu setelah 04:00
//     if (weekday == 7) return true; // Minggu full
//     if (weekday == 1 && hour < 5) return true; // Senin sebelum 05:00
//     return false;
//   }

//   Future<void> fetchAccounts() async {
//     await getToken().then((accessToken){
//       token = "Bearer $accessToken";
//     });
//     try {
//       if(token == null){
//         Get.log('Token => $token');
//         return;
//       }
//       Get.log('Token => $token');
//       isLoading(true);
//       final response = await ApiService.post('account/info',
//         headers: {
//           'Authorization': token!,
//         },
//       );
//       Get.log("Response Fetch Accounts");
//       Get.log(response.toString());
//       if (response['status']) {
//         final real = (response['response']['real'] as List)
//             .map((e) => AccountModel.fromJson(e))
//             .toList();
//         final demo = (response['response']['demo'] as List)
//             .map((e) => AccountModel.fromJson(e))
//             .toList();
//         accounts.assignAll([...real, ...demo]);
//         Get.log("Real count: ${real.length}, Demo count: ${demo.length}");
//         Get.log("Loaded accounts: ${accounts.length}");
//         // Pilih default akun pertama jika belum ada selectedAccount
//         if (selectedAccount.value == null && accounts.isNotEmpty) {
//           selectedAccount.value = accounts.first;
//         }
//       }
//     } finally {
//       isLoading(false);
//     }
//   }

//   void setSelectedAccount(AccountModel account) {
//     selectedAccount.value = account;

//     // refresh data sesuai tab aktif
//     if (currentTabIndex == 0) {
//       fetchOpenedOrders(account.login);
//     } else if (currentTabIndex == 2) {
//       fetchTradeHistory(account.login);
//     }
//   }


//   Future<void> fetchOpenedOrders(String login, {bool silent = false}) async {
//     try {
//       if(token == null){
//         Get.log('Token => $token');
//         return;
//       }
//       if (!silent) isLoading(true);
//       final response = await ApiService.get(
//         'market/opened-order?login=$login',
//         headers: {'Authorization': token!},
//       );
//       // Get.log("Response Fetch Opened Orders");
//       // Get.log(response.toString());
//       if (response['status']) {
//         openedOrders.assignAll(
//           (response['response'] as List).map((e) => OpenedOrderModel.fromJson(e)).toList(),
//         );
//       }
//     } finally {
//       if (!silent) isLoading(false);
//     }
//   }

//   Future<void> fetchTradeHistory(String login, {bool silent = false}) async {
//     try {
//       if (!silent) isLoading(true);
//       final response = await ApiService.get(
//         'market/trade-history?login=$login',
//         headers: {'Authorization': token!},
//       );
//       // Get.log("Response Fetch Trade History");
//       // Get.log(response.toString());
//       if (response['status']) {
//         tradeHistory.assignAll(
//           (response['response'] as List).map((e) => TradeModel.fromJson(e)).toList(),
//         );
//       }
//     } finally {
//       if (!silent) isLoading(false);
//     }
//   }

//   Future<void> closeOrder(String login, int ticket) async {
//   try {
//     if(token == null){
//       Get.log('Token => $token');
//       return;
//     }
//     isLoading(true);
//     final response = await ApiService.post(
//       'market/execution/close',
//       headers: {
//         'Authorization': token!,
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'login': login,
//         'ticket': ticket.toString(),
//       },
//     );

//     if (response['status'] == true) {
//       Get.snackbar(
//         "Success",
//         "Order #$ticket closed successfully.",
//         backgroundColor: Colors.green.withOpacity(0.2),
//       );
//       // Refresh open orders setelah close
//       if (accounts.isNotEmpty) {
//         await fetchOpenedOrders(accounts.first.login);
//       }
//     } else {
//       Get.snackbar(
//         "Failed",
//         response['message'] ?? "Failed to close order.",
//         backgroundColor: Colors.red.withOpacity(0.2),
//       );
//     }
//   } catch (e) {
//     print("❌ Error closing order: $e");
//     Get.snackbar("Error", "Unable to close order. Please try again.",
//         backgroundColor: Colors.red.withOpacity(0.2));
//   } finally {
//     isLoading(false);
//   }
// }
// }
