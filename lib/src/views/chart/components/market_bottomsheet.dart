// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';

// class MarketBottomSheet extends StatelessWidget {
//   final controller = Get.find<ChartControllers>();

//   final List<String> categories = ['Favorit', 'Forex', 'Komoditi', 'Index'];

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: categories.length,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 8),
//           Container(
//             height: 4,
//             width: 40,
//             decoration: BoxDecoration(
//               color: Colors.grey[400],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 10),
//           const TabBar(isScrollable: true, tabs: [
//             Tab(text: 'Favorit'),
//             Tab(text: 'Forex'),
//             Tab(text: 'Komoditi'),
//             Tab(text: 'Index'),
//           ]),
//           SizedBox(
//             height: 300,
//             child: TabBarView(
//               children: categories.map((cat) {
//                 return ListView.builder(
//                   itemCount: 8,
//                   itemBuilder: (context, i) {
//                     final symbol = '$cat-$i';
//                     return ListTile(
//                       title: Text(symbol),
//                       onTap: () {
//                         controller.changeMarket(symbol);
//                         Get.back();
//                       },
//                     );
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
