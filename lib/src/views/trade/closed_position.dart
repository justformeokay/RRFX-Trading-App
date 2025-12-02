// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/components/painters/loading_water.dart';
// import 'package:rrfx/src/controllers/trading.dart';
// import 'package:rrfx/src/views/trade/components/position_tile.dart';

// class ClosedPosition extends StatefulWidget {
//   final int? loginID;
//   const ClosedPosition({super.key, this.loginID});

//   @override
//   State<ClosedPosition> createState() => _ClosedPositionState();
// }

// class _ClosedPositionState extends State<ClosedPosition> {

//   TradingController tradingController = Get.find();
//   RxBool isLoading = false.obs;
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1), (){
//       isLoading(true);
//       tradingController.closedOrder(login: "${widget.loginID ?? 0}").then((result){

//       });
//       isLoading(false);
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Obx(
//             () => Column(
//               children: List.generate(tradingController.tradingHistoryModel.value?.response?.length ?? 0, (i){
//                 return CustomSlideAbleListTile.closedListTile(
//                   context,
//                   executionName: tradingController.tradingHistoryModel.value?.response?[i].orderType,
//                   marketName: tradingController.tradingHistoryModel.value?.response?[i].symbol,
//                   orderID: tradingController.tradingHistoryModel.value?.response?[i].ticket.toString(),
//                   lot: tradingController.tradingHistoryModel.value?.response?[i].lots.toString(),
//                   dateTime: tradingController.tradingHistoryModel.value?.response?[i].closeTime
//                 );
//               }),
//             ),
//           ),
//         ),
//         Obx(() => isLoading.value ? LoadingWater() : const SizedBox())
//       ],
//     );
//   }
// }
