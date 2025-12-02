// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/components/colors/default.dart';
// import 'package:rrfx/src/components/containers/popup.dart';
// import 'package:rrfx/src/views/trade/deriv_chart_page.dart';
// import 'package:rrfx/src/views/transactions/controllers/transactions_controller.dart';

// class TransactionsPage extends StatefulWidget {
//   const TransactionsPage({super.key});

//   @override
//   State<TransactionsPage> createState() => _TransactionsPageState();
// }

// class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin {
//   final controller = Get.find<TransactionsController>();
//   late TabController tabController;

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 3, vsync: this);
//     tabController.addListener(() async {
//       if (!tabController.indexIsChanging) {
//         controller.currentTabIndex = tabController.index;
//         final acc = controller.selectedAccount.value;
//         if (acc == null) return;

//         if (tabController.index == 0) {
//           await controller.fetchOpenedOrders(acc.login);
//         } else if (tabController.index == 2) {
//           await controller.fetchTradeHistory(acc.login);
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await controller.fetchAccounts();
//       final acc = controller.selectedAccount.value;
//       if (acc != null) {
//         await controller.fetchOpenedOrders(acc.login);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Transactions"),
//         // Menghilangkan bayangan dan memberi tampilan yang lebih datar/modern
//         elevation: 0, 
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(
//               Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
//             ),
//             onPressed: () {
//               print("Tombol Ganti Tema Ditekan!");
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Obx(() {
//             if (controller.isMarketClosed.value) {
//               return Container(
//                 width: double.infinity,
//                 color: colorScheme.errorContainer, 
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Forex market is closed — updates paused",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: colorScheme.onErrorContainer,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//           _buildAccountDropdown(context),
//           Expanded(
//             child: Column(
//               children: [
//                 // 🏷️ TabBar Modern
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: TabBar(
//                     dividerColor: Theme.of(context).dividerColor.withOpacity(0.1),
//                     controller: tabController,
//                     // Desain indikator modern (bulat, berwarna)
//                     indicatorSize: TabBarIndicatorSize.tab,
//                     indicator: BoxDecoration(
//                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
//                       color: CustomColor.secondaryColor, // Background tab aktif
//                     ),
//                     labelColor: Colors.black, // Warna teks tab aktif
//                     unselectedLabelColor: colorScheme.onSurfaceVariant, // Warna teks tab tidak aktif
//                     labelStyle: const TextStyle(fontWeight: FontWeight.bold),
//                     tabs: const [
//                       Tab(text: "Open Orders"),
//                       Tab(text: "Pending Orders"),
//                       Tab(text: "Closed Orders"),
//                     ],
//                   ),
//                 ),
//                 const Divider(height: 1, thickness: 0.5), // Garis pemisah yang tipis
//                 Expanded(
//                   child: TabBarView(
//                     controller: tabController,
//                     children: [
//                       _buildOpenOrders(context),
//                       _buildPendingOrders(),
//                       _buildClosedOrders(context),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 👇 Widget untuk Open Orders
//   Widget _buildOpenOrders(BuildContext context) {
//     return Obx(() {
//       final colorScheme = Theme.of(context).colorScheme;
//       if (controller.isLoading.value && controller.openedOrders.isEmpty) return const Center(child: CircularProgressIndicator());
//       if (controller.openedOrders.isEmpty) return const Center(child: Text("No open orders. Pull down to refresh."));
//       return RefreshIndicator(
//         onRefresh: () async {
//           final acc = controller.selectedAccount.value;
//           if (acc != null) await controller.fetchOpenedOrders(acc.login);
//         },
//         child: ListView.builder(
//           itemCount: controller.openedOrders.length,
//           itemBuilder: (_, i) {
//             final o = controller.openedOrders[i];
            
//             // Mengganti Card dengan container yang lebih modern (misalnya, Material dengan elevation kecil atau tanpa elevation)
//             return GestureDetector(
//               onTap: (){
//                 Get.to(() => DerivChartPage(
//                   login: controller.accounts.isNotEmpty ? int.parse(controller.accounts.first.login) : 0,
//                   balance: controller.accounts.isNotEmpty ? controller.accounts.first.balance : 0.0,
//                   marketName: o.symbol,
//                 ));
//               },
//               onLongPress: (){
//                 showClosePositionDialog(
//                   context: context,
//                   symbol: o.symbol,
//                   lot: o.lot,
//                   price: o.currentPrice,
//                   profit: o.profit,
//                   biaya: 0, // isi sesuai kebutuhanmu jika ada field biaya
//                   biayaInap: 0,
//                   onConfirm: () async {
//                     final acc = controller.selectedAccount.value;
//                     if (acc != null) {
//                       await controller.closeOrder(acc.login, o.ticket);
//                     }
//                   },
//                 );
//               },
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: colorScheme.surfaceContainerHigh, // Warna background yang lebih modern
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: colorScheme.shadow.withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Icon Buy/Sell
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: o.orderType == 'Buy' ? Colors.green.shade600 : Colors.red.shade600,
//                       ),
//                       child: Center(
//                         child: Text(
//                           o.orderType.substring(0, 1), 
//                           style: const TextStyle(
//                             color: Colors.white, 
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           )
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
                    
//                     // Detail Order
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             o.symbol,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: colorScheme.onSurface,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             "Lot: ${o.lot} | Open: ${o.openPrice} | Current: ${o.currentPrice}",
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // Profit
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: o.profit >= 0 ? Colors.green.shade100.withOpacity(0.9) : Colors.red.shade100.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         o.profit.toStringAsFixed(2),
//                         style: TextStyle(
//                           color: o.profit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
//                           fontWeight: FontWeight.w900, // Tebal sekali untuk penekanan
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   // 👇 Widget untuk Pending Orders
//   Widget _buildPendingOrders() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.access_time_filled_rounded, size: 48, color: Theme.of(context).colorScheme.outline),
//         const SizedBox(height: 12),
//         Text(
//           "Pending order API belum tersedia.",
//           style: TextStyle(color: Theme.of(context).colorScheme.outline),
//         ),
//       ],
//     ),
//   );

//   // 👇 Widget untuk Closed Orders (mirip dengan Open Orders)
//   Widget _buildClosedOrders(BuildContext context) {
//     return Obx(() {
//       final colorScheme = Theme.of(context).colorScheme;
//       if (controller.isLoading.value && controller.tradeHistory.isEmpty) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (controller.tradeHistory.isEmpty) {
//         return const Center(child: Text("No closed trades. Pull down to refresh."));
//       }
//       return RefreshIndicator(
//         onRefresh: () async {
//           final acc = controller.selectedAccount.value;
//           if (acc != null) await controller.fetchTradeHistory(acc.login);
//         },
//         child: ListView.builder(
//           itemCount: controller.tradeHistory.length,
//           itemBuilder: (_, i) {
//             final t = controller.tradeHistory[i];

//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: colorScheme.surfaceContainerHigh,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: colorScheme.shadow.withOpacity(0.05),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Icon Win/Loss
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: double.parse(t.profit) >= 0 ? Colors.green.shade700 : Colors.red.shade700,
//                     ),
//                     child: Center(
//                       child: Icon(
//                         double.parse(t.profit) >= 0 ? Icons.trending_up : Icons.trending_down,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Detail Transaksi
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "${t.symbol} (${t.orderType})",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: colorScheme.onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "Open: ${t.openPrice} | Close: ${t.closePrice}",
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: colorScheme.onSurfaceVariant,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Profit/Loss Akhir
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: double.parse(t.profit) >= 0 ? Colors.green.shade100.withOpacity(0.9) : Colors.red.shade100.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       t.profit,
//                       style: TextStyle(
//                         color: double.parse(t.profit) >= 0 ? Colors.green.shade800 : Colors.red.shade800,
//                         fontWeight: FontWeight.w900,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   Widget _buildAccountDropdown(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Obx(() {
//       final accounts = controller.accounts;

//       if (accounts.isEmpty) return const SizedBox(); // Tidak ada akun

//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: colorScheme.surfaceContainerHighest,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             dropdownColor: Theme.of(context).primaryColorDark,
//             isExpanded: true,
//             value: controller.selectedAccount.value?.login,
//             items: controller.accounts.map((acc) {
//               return DropdownMenuItem<String>(
//                 value: acc.login,
//                 child: Text("${acc.namaTipeAkun} (${acc.login}) - ${acc.currency} ${acc.balance}"),
//               );
//             }).toList(),
//             onChanged: (login) {
//               final acc = controller.accounts.firstWhereOrNull((a) => a.login == login);
//               if (acc != null) controller.setSelectedAccount(acc);
//             },
//           ),
//         )

//       );
//     });
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }
// }