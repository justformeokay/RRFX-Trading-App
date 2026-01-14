// // views/chart_page.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:rrfx/src/experimentals/charts/controllers/chart_controller.dart';
// import 'package:rrfx/src/experimentals/charts/controllers/theme_controllers.dart';

// class ChartPageExperimentals extends StatelessWidget {
//   final ChartControllerExperimentals chartController = Get.find<ChartControllerExperimentals>();
//   final ThemeControllerExperimentals themeController = Get.find<ThemeControllerExperimentals>();

//   ChartPageExperimentals({super.key});

//   RxBool isLoading = false.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildHeader(),
//           const Divider(height: 1, thickness: 1),
//           // Chart akan mengambil sisa ruang vertikal
//           Expanded(
//             child: Obx(
//               () => isLoading.value
//                   ? const Center(child: CircularProgressIndicator())
//                   : _buildChart(),
//             ),
//           ),
//           const Divider(height: 1, thickness: 1),
//           _buildTradingBar(),
//         ],
//       ),
//     );
//   }

//   /// 1. App Bar
//   AppBar _buildAppBar() {
//     return AppBar(
//       title: Obx(() => Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Nama Market
//               Text(chartController.selectedMarket.value,
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               // Balance & ID
//               Text(
//                 'Balance: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(chartController.accountBalance.value)} | ID: ${chartController.accountId.value}',
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ],
//           )),
//       actions: [
//         // Button untuk toggle Dark/Light Mode
//         Obx(() => IconButton(
//               icon: Icon(themeController.isDark.value ? Icons.wb_sunny : Icons.nights_stay),
//               onPressed: themeController.toggleTheme,
//             )),
//       ],
//     );
//   }

//   /// 2. Header (Timeframe & Tools)
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Button Market List (Dummy)
//           ElevatedButton.icon(
//             onPressed: () {
//               // TODO: Implementasi logika tampilkan daftar market
//               Get.snackbar('Info', 'Market List button pressed!');
//             },
//             icon: const Icon(Icons.list),
//             label: const Text('Markets'),
//           ),

//           // Dropdown Timeframe
//           Obx(() => DropdownButton<String>(
//                 value: chartController.timeFrame.value,
//                 items: chartController.timeframeList.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//                   );
//                 }).toList(),
//                 onChanged: chartController.changeTimeframe,
//               )),

//           // Button Tools (Dummy)
//           IconButton(
//             icon: const Icon(Icons.gesture),
//             onPressed: () {
//               Get.snackbar('Info', 'Chart Tools button pressed!');
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   /// 3. Trading Chart (DerivChart)
//   Widget _buildChart() {
//     return Obx(
//       () {
//         final currentTheme = themeController.isDark.value ? ChartDefaultDarkTheme(): ChartDefaultLightTheme();
            
//         // Gunakan currentAsk/currentBid sebagai pengganti currentPrice jika ingin lebih akurat
//         final lastTickValue = chartController.currentPrice.value; 
//         return DerivChart(
//           key: Key(
//             // Key harus unik untuk me-render ulang chart saat parameter berubah
//             'chart_${chartController.timeFrame.value}_${chartController.selectedMarket.value}',
//           ),
//           granularity: chartController.timeframeToGranularity(
//             chartController.timeFrame.value,
//           ),
//           showScrollToLastTickButton: false,
//           dataFitPadding: const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 10,
//           ),
//           isLive: true,
//           theme: currentTheme,
//           mainSeries: CandleSeries(chartController.ohlcDataDeriv),
//           showDataFitButton: true,
//           pipSize:
//               chartController.selectedMarket.value.contains("JPY") ||
//                       chartController.selectedMarket.value.contains("XAU")
//                   ? 3
//                   : 5,
//           showCurrentTickBlinkAnimation: true,
//           activeSymbol: chartController.selectedMarket.value,
//           loadingAnimationColor: Colors.transparent,
//           // Menggunakan lastTickValue dari WS untuk membuat bar terakhir bergerak
//           annotations: _buildAnnotations(),
//         );
//       },
//     );
//   }

//   List<HorizontalBarrier> _buildAnnotations() {
//     final List<HorizontalBarrier> annotations = [];
//     final currentBid = chartController.currentBid.value;
//     final currentAsk = chartController.currentAsk.value;
//     final digits = chartController.pipSize; // Digits dari WS

//     if (currentBid > 0.0 && currentAsk > 0.0) {
//       // 1. Garis ASK (Harga Jual / Red) - Sesuai dengan spread_barrier Anda
//       annotations.add(
//         HorizontalBarrier(
//           currentAsk,
//           id: "ask_barrier",
//           // Tampilkan label harga Ask
//           title: "ASK ${currentAsk.toStringAsFixed(digits)}", 
//           style: HorizontalBarrierStyle(
//             color: Colors.red,
//             lineColor: Colors.red,
//             titleBackgroundColor: Colors.red,
//             labelShapeBackgroundColor: Colors.red,
//             hasBlinkingDot: true,
//           ),
//         ),
//       );

//       // 2. Garis BID (Harga Beli / Green) - Sesuai dengan current_price_barrier Anda
//       annotations.add(
//         HorizontalBarrier(
//           currentBid,
//           id: "bid_barrier",
//           // Tampilkan label harga Bid
//           title: "BID ${currentBid.toStringAsFixed(digits)}",
//           style: HorizontalBarrierStyle(
//             color: Colors.green,
//             lineColor: Colors.green,
//             titleBackgroundColor: Colors.green,
//             labelShapeBackgroundColor: Colors.green,
//             hasBlinkingDot: true,
//           ),
//         ),
//       );
//     }
//     return annotations;
//   }


//   /// 4. Trading Bar (Sell, Lot, Buy)
//   Widget _buildTradingBar() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       color: themeController.colorScheme.surface,
//       child: Obx(() {
//         // Tentukan jumlah digit berdasarkan marketDigits dari WS
//         final digits = chartController.marketDigits.value; 
//         final bidPrice = chartController.currentBid.value.toStringAsFixed(digits);
//         final askPrice = chartController.currentAsk.value.toStringAsFixed(digits);

//         return Row(
//           children: [
//             // Button SELL (menggunakan Harga BID)
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Get.snackbar('Trading', 'SELL ${chartController.currentLot.value} at $bidPrice');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text('SELL\n$bidPrice', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
//               ),
//             ),
            
//             const SizedBox(width: 8),

//             // Kontrol LOT
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.add_circle, color: Colors.green),
//                   onPressed: chartController.incrementLot,
//                 ),
//                 Text(
//                   chartController.currentLot.value.toStringAsFixed(2),
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.remove_circle, color: Colors.red),
//                   onPressed: chartController.decrementLot,
//                 ),
//               ],
//             ),
            
//             const SizedBox(width: 8),

//             // Button BUY (menggunakan Harga ASK)
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Get.snackbar('Trading', 'BUY ${chartController.currentLot.value} at $askPrice');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text('BUY\n$askPrice', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }