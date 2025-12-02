// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';

// class LotSelector extends StatelessWidget {
//   final controller = Get.find<ChartControllers>();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             onPressed: controller.decreaseLot,
//             icon: const Icon(Icons.remove_circle_outline),
//           ),
//           Text(
//             controller.lot.value.toStringAsFixed(2),
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           IconButton(
//             onPressed: controller.increaseLot,
//             icon: const Icon(Icons.add_circle_outline),
//           ),
//         ],
//       );
//     });
//   }
// }
