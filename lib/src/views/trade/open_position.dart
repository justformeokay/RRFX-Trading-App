// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
// import 'package:rrfx/src/components/buttons/outlined_button.dart';
// import 'package:rrfx/src/components/colors/default.dart';
// import 'package:rrfx/src/controllers/trading.dart';

// import 'components/position_tile.dart';

// class OpenPosition extends StatefulWidget {
//   const OpenPosition({super.key, this.loginID});
//   final String? loginID;

//   @override
//   State<OpenPosition> createState() => _OpenPositionState();
// }

// class _OpenPositionState extends State<OpenPosition> {

//   TradingController tradingController = Get.find();
//   RxBool isLoading = false.obs;
//   Timer? timer;
//   RxInt lengthOpenOrder = 0.obs;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, (){
//       isLoading(true);
//       tradingController.openOrder(login: widget.loginID!).then((result){
//         lengthOpenOrder(result['response'].length);
//       });
//       isLoading(false);
//       timer = Timer.periodic(const Duration(seconds: 2), (_){
//         tradingController.openOrder(login: widget.loginID!).then((result){
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Obx(
//       () => isLoading.value ? Center(child: Text("Getting Open Order...")) : SingleChildScrollView(
//         child: Obx(
//           () => lengthOpenOrder.value < 1 ? SizedBox(
//             width: size.width,
//             height: size.height / 1.4,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(CupertinoIcons.equal_circle_fill, color: CustomColor.defaultColor, size: 30),
//                 const SizedBox(height: 10),
//                 Text("Tidak Ada Order Aktif")
//               ],
//             ),
//           ) : Column(
//             children: List.generate(tradingController.openOrderModel.value?.response?.length ?? 0, (i){
//               return CustomSlideAbleListTile.openListTile(
//                 context,
//                 onPressedClose: (p0) {
//                   CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Apakah anda yakin menutup order ${tradingController.openOrderModel.value?.response?[i].symbol}, dengan jumlah lot ${tradingController.openOrderModel.value?.response?[i].lots?.toDouble()}?", isScrolledController: false, children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomOutlinedButton.defaultOutlinedButton(
//                             title: "Batalkan",
//                             onPressed: (){
//                               Get.back();
//                             }
//                           )
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Obx(
//                             () => ElevatedButton(
//                               onPressed: tradingController.isLoading.value ? null : () async {
//                                 await tradingController.closingOrder(loginID: widget.loginID!, ticketID: tradingController.openOrderModel.value!.response![i].ticket.toString());
//                                 Get.back();
//                               },
//                               child: Obx(() => tradingController.isLoading.value ? CircularProgressIndicator(color: CustomColor.defaultColor) : Text("Close Order")),
//                             ),
//                           )
//                         ),
//                       ],
//                     )
//                   ]);
//                 },
//                 onPressedEdit: (p0) {},
//                 market: tradingController.openOrderModel.value?.response?[i].symbol,
//                 lot: tradingController.openOrderModel.value?.response?[i].lots!,
//                 orderType: tradingController.openOrderModel.value?.response?[i].orderType,
//                 dateTime: tradingController.openOrderModel.value?.response?[i].openTime,
//                 profitLoss: tradingController.openOrderModel.value!.response![i].profit,
//                 currentPrice: tradingController.openOrderModel.value?.response?[i].priceCurrent,
//                 openPrice: tradingController.openOrderModel.value?.response?[i].openPrice,
//                 sl: tradingController.openOrderModel.value?.response?[i].stopLoss,
//                 swap: tradingController.openOrderModel.value!.response![i].swap,
//                 id: tradingController.openOrderModel.value?.response?[i].ticket,
//               );
//             })
//           ),
//         ),
//       ),
//     );
//   }
// }
