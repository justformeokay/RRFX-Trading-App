// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:candlesticks/candlesticks.dart' as cs;
// import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';

// class ChartCandleStick extends StatelessWidget {
//   final controller = Get.find<ChartControllers>();

//   @override
// Widget build(BuildContext context) {
//   return Obx(() {
//     final candleList = controller.candles
//         .where((e) =>
//             e.open.isFinite &&
//             e.high.isFinite &&
//             e.low.isFinite &&
//             e.close.isFinite)
//         .map((e) => cs.Candle(
//               date: e.time,
//               open: e.open.isFinite ? e.open : 0,
//               high: e.high.isFinite ? e.high : 0,
//               low: e.low.isFinite ? e.low : 0,
//               close: e.close.isFinite ? e.close : 0,
//               volume: 0,
//             ))
//         .toList();

//     if (candleList.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.55,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 10,
//             color: Colors.black.withOpacity(0.1),
//           ),
//         ],
//       ),
//       child: cs.Candlesticks(candles: candleList),
//     );
//   });
// }

// }
