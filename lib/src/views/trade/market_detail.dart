// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:rrfx/src/components/alerts/default.dart';
// import 'package:rrfx/src/components/appbars/default.dart';
// import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
// import 'package:rrfx/src/components/buttons/outlined_button.dart';
// import 'package:rrfx/src/components/colors/default.dart';
// import 'package:rrfx/src/components/painters/loading_water.dart';
// import 'package:rrfx/src/controllers/trading.dart';
// import 'package:rrfx/src/views/trade/components/chart_section.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/views/trade/trading_order_history.dart';

// import 'deriv_chart_page.dart';

// class MarketDetail extends StatefulWidget {
//   final int login;
//   const MarketDetail({super.key, required this.login});

//   @override
//   State<MarketDetail> createState() => _MarketDetailState();
// }

// class _MarketDetailState extends State<MarketDetail> {
//   TimeFrame selectedTf = TimeFrame.h1;
//   TrackballBehavior? _trackballBehavior;
//   List<OHLCDataModel>? _chartData;
//   CartesianChartAnnotation? _priceBox;
//   CartesianChartAnnotation? _priceBoxSell;
//   TradingController tradingController = Get.find();
//   RxBool showMarket = false.obs;
//   RxString activeSymbol = "Loading...".obs;
//   RxDouble symbolSpread = 0.0.obs;
//   RxDouble lastPriceOpen = 0.0.obs;
//   RxList indicators = ["SMA", "EMA", "RSI", "WMA"].obs;
//   // RxDouble lastPriceOpen = 0.0.obs;
//   Timer? _timer;

//   RxBool isLoading = false.obs;

//   Future<void> reloadMarket({String? timeframe}) async {
//     await tradingController.getMarket(market: activeSymbol.value, timeframe: timeframe).then((result){
//       if(result){
//         _trackballBehavior = TrackballBehavior(
//           enable: true,
//           activationMode: ActivationMode.singleTap,
//         );

//         _chartData = tradingController.ohlcData;
//         lastPriceOpen.value = tradingController.ohlcData.last.close ?? 0.0;
//         symbolSpread.value = double.parse(tradingController.symbols.where((e) => e['symbol'] == activeSymbol.value).first['digits'].toString());
//         // int multiplier = tradingController.symbols.where((e) => e['symbol'] == activeSymbol.value).first['digits'];
//         // String pad = "1".padRight(multiplier, '0');
//         // // symbolSpread.value = 1.toRadixString(1);
        
//         // String test = "1".padRight(5, '0');
//         // print(test);
//         // print(symbolSpread.value);
//         // lastPriceOpen.value = tradingController.ohlcData.last.open ?? 0.0;

//         /** Pricebox Buy */
//         _priceBox = CartesianChartAnnotation(
//           widget: TradingProperty.buildPriceBox(lastPriceOpen.value, Colors.green),
//           coordinateUnit: CoordinateUnit.point,
//           region: AnnotationRegion.chart,
//           x: tradingController.ohlcData.last.date?.add(Duration(minutes: 40)),
//           y: lastPriceOpen.value,
//           horizontalAlignment: ChartAlignment.near
//         );

//         /** Pricebox Sell */
//         _priceBoxSell = CartesianChartAnnotation(
//           widget: TradingProperty.buildPriceBox(lastPriceOpen.value + symbolSpread.value, Colors.red),
//           coordinateUnit: CoordinateUnit.point,
//           region: AnnotationRegion.chart,
//           x: tradingController.ohlcData.last.date?.add(Duration(minutes: 40)),
//           y: lastPriceOpen.value + symbolSpread.value,
//           horizontalAlignment: ChartAlignment.near
//         );

//         showMarket(true);
//       }
//     });
//   }

//   void updateLastCandle(OHLCDataModel newCandle) {
//     final lastIndex = _chartData!.length - 1;

//     if (_chartData?[lastIndex].date == newCandle.date) {
//       // ✅ Update candle terakhir jika timestamp sama
//       _chartData?[lastIndex] = newCandle;
//     } else {
//       // ✅ Jika timestamp berbeda (jam sudah berubah), tambahkan candle baru
//       _chartData?.add(newCandle);
//     }

//     setState(() {}); // Atau notifyListeners kalau pakai state management
//   }

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () async{
//       tradingController.isLoading(true);
//       await tradingController.getSymbols().then((result){
//         if(result.isNotEmpty){
//           activeSymbol(result[0]['symbol']);
//           TradingProperty.volumeInit(double.parse(result[0]['volume_min'].toString()));
//           TradingProperty.volumeMin(double.parse(result[0]['volume_min'].toString()));
//           TradingProperty.volumeMax(double.parse(result[0]['volume_max'].toString()));
//         }
//       });

//       await reloadMarket();
//       _timer = Timer.periodic(Duration(seconds: 3), (timer) {
//         reloadMarket();
//       });
//       tradingController.isLoading(false);
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _chartData?.clear();
//     _timer?.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Stack(
//       children: [
//         Scaffold(
//           appBar: CustomAppBar.defaultAppBar(title: widget.login.toString(), autoImplyLeading: true, actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: SizedBox(
//                 height: 30,
//                 child: CustomOutlinedButton.defaultOutlinedButton(
//                   onPressed: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     prefs.getString('accessToken');
//                     Get.to(() => TradingOrderHistory(accountID: widget.login));
//                   },
//                   title: "History"
//                 ),
//               ),
//             )
//           ]),
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 0),
//                   child: Row(
//                       children: [
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: (){
//                                 CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Market Symbols", children: List.generate(tradingController.symbols.length, (i){
//                                   return ListTile(
//                                     title: Text(tradingController.symbols[i]['symbol'], style: GoogleFonts.inter(color: CustomColor.textThemeLightColor)),
//                                     onTap: () async {
//                                       Get.back();
//                                       activeSymbol.value = await tradingController.symbols[i]['symbol'];
//                                       TradingProperty.volumeInit.value = double.parse(tradingController.symbols[i]['volume_min'].toString());
//                                       TradingProperty.volumeMin.value = double.parse(tradingController.symbols[i]['volume_min'].toString());
//                                       TradingProperty.volumeMax.value = double.parse(tradingController.symbols[i]['volume_max'].toString());
//                                       await reloadMarket();
//                                     },
//                                   );
//                                 }));
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFF5F6FA),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Obx(() => Text(activeSymbol.value, style: GoogleFonts.inter(color: CustomColor.textThemeLightColor))),
//                                     Icon(Icons.keyboard_arrow_down, color: CustomColor.textThemeLightSoftColor),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             DropdownButton<TimeFrame>(
//                               borderRadius: BorderRadius.circular(10),
//                               elevation: 1,
//                               padding: EdgeInsets.zero,
//                               icon: Visibility (visible:false, child: Icon(Icons.arrow_downward)),
//                               underline: SizedBox(),
//                               value: selectedTf,
//                               items: TimeFrame.values.map((tf) => DropdownMenuItem(
//                                 value: tf,
//                                 child: Text(tf.name.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
//                               )).toList(),
//                               onChanged: (tf) {
//                                   reloadMarket(timeframe: tf?.name.toUpperCase());
//                                   setState(() {
//                                     selectedTf = tf!;
//                                   });
//                                 },
//                               ),
//                             // Container(
//                             //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             //   decoration: BoxDecoration(
//                             //     color: const Color(0xFFF5F6FA),
//                             //     borderRadius: BorderRadius.circular(8),
//                             //   ),
//                             //   child: Text('H1', style: GoogleFonts.inter(color: CustomColor.textThemeLightColor)),
//                             // ),
//                           ],
//                         ),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Obx(
//                                 () => isLoading.value ? const SizedBox() : TradingProperty.iconButton(AntDesign.function_outline, (){
//                                   CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Indicators", children: List.generate(indicators.length, (i){
//                                     return ListTile(
//                                       onTap: (){
//                                         Navigator.pop(context);
//                                       },
//                                       title: Text(indicators[i], style: GoogleFonts.inter()),
//                                     );
//                                   }));
//                                 }),
//                               ),
//                               TradingProperty.iconButton(Icons.edit, (){}),
//                               TradingProperty.iconButton(Icons.layers, (){}),
//                               TradingProperty.iconButton(Icons.tune, (){}),
//                               TradingProperty.iconButton(Icons.fullscreen, (){
//                                 Get.to(() => DerivChartPage(login: widget.login));
//                               }),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
        
//                 // End of Tool Section
        
//                 // Chart Section
//                 Obx(
//                   () => tradingController.isLoading.value ? Container(
//                     width: size.width,
//                     // height: size.height / 1.35,
//                     height: double.maxFinite,
//                     decoration: BoxDecoration(border: Border.all(color: CustomColor.textThemeDarkSoftColor)),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(color: CustomColor.defaultColor),
//                         const SizedBox(height: 10),
//                         Text("Getting Market", style: GoogleFonts.inter())
//                       ],
//                     ),
//                   ) : showMarket.value ? Container(
//                     width: size.width,
//                     height: size.height / 1.4,
//                     decoration: BoxDecoration(border: Border.all(color: CustomColor.textThemeDarkSoftColor)),
//                     child: Obx(() => buildHiloOpenCloseOHLC(maximumPrice: tradingController.maxPrice.value, minimumPrice: tradingController.minPrice.value))
//                   ) : const SizedBox(),
//                 ),
//                 // End of Chart Section
//               ],
//             ),
//           ),
        
//           bottomNavigationBar: Container(
//             padding: EdgeInsets.symmetric(vertical: 16.0,  horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Obx(() => TradingProperty.sellButton(price: lastPriceOpen.value, onPressed: (){
//                   CustomAlert.alertDialogCustomInfo(title: "Sell", message: "Apakah anda yakin ingin melanjutkan?", colorPositiveButton: Colors.red, onTap: () {
//                     Get.back();
//                     tradingController.executionOrder(symbol: activeSymbol.value, type: "sell", login: widget.login.toString(), lot: TradingProperty.volumeInit.value.toString()).then((result) {
//                       if(result['status'] != true){
//                         CustomAlert.alertError(context, message: result['message']);
//                         return false;
//                       }
//                       CustomAlert.alertDialogCustomSuccess(message: result['message'], onTap: () {
//                         Get.back();
//                       });
//                     });
//                   });
//                 })),
//                 SizedBox(width: 8),
//                 TradingProperty.lotButton(),
//                 SizedBox(width: 8),
//                 Obx(() => TradingProperty.buyButton(price: (lastPriceOpen.value + symbolSpread.value), onPressed: () {
//                   CustomAlert.alertDialogCustomInfo(title: "Buy", message: "Apakah anda yakin ingin melanjutkan?", onTap: () {
//                     Get.back();
//                     tradingController.executionOrder(symbol: activeSymbol.value, type: "buy", login: widget.login.toString(), lot: TradingProperty.volumeInit.value.toString()).then((result) {
//                       if(result['status'] != true){
//                         CustomAlert.alertError(context, message: result['message']);
//                         return false;
//                       }
//                       CustomAlert.alertDialogCustomSuccess(message: result['message'], onTap: () {
//                         Get.back();
//                       });
//                     });
//                   });
//                 }))
//               ],
//             ),
//           ),
//         ),
//         Obx(() => tradingController.isLoading.value ? LoadingWater() : const SizedBox())
//       ],
//     );
//   }

//   /// Returns the cartesian High-low-open-close chart.
//   SfCartesianChart buildHiloOpenClose({double? minimumPrice, double? maximumPrice, DateTime? dateMax, DateTime? dateMin}) {
//     return SfCartesianChart(
//       annotations: <CartesianChartAnnotation>[_priceBox!, _priceBoxSell!],
//       plotAreaBorderWidth: 0,
//       zoomPanBehavior: TradingProperty.zoomPan,
//       // primaryXAxis: buildDateTimeAxis(tf: selectedTf),
//       primaryXAxis: DateTimeAxis(
//         intervalType: DateTimeIntervalType.minutes,
//         interval: 180,
//         edgeLabelPlacement: EdgeLabelPlacement.shift,
//         plotOffset: 5,
//         dateFormat: DateFormat('dd MMM HH:mm'),
//         majorGridLines: MajorGridLines(
//           width: 0.5,
//           color: Colors.grey.shade100,
//         ),
//       ),
//       primaryYAxis: NumericAxis(
//         plotOffset: 10,
//         majorGridLines: MajorGridLines(
//           width: 0.5,
//           color: Colors.grey.shade100,
//         ),
//         plotBands: <PlotBand>[
//           PlotBand(
//             isVisible: true,
//             start: lastPriceOpen.value,
//             end: lastPriceOpen.value,
//             borderColor: Colors.green,
//             borderWidth: 1,
//           ),
//           PlotBand(
//             isVisible: true,
//             start: lastPriceOpen.value + symbolSpread.value,
//             end: lastPriceOpen.value + symbolSpread.value,
//             borderColor: Colors.red,
//             borderWidth: 1,
//           ),
//         ],
//         opposedPosition: true,
//         borderColor: Colors.black12,
//         labelFormat: r'${value}',
//         minimum: minimumPrice,
//         maximum: maximumPrice,
//       ),
//       series: TradingProperty.buildHiloOpenCloseSeriesAPI(chartData: _chartData),
//       trackballBehavior: _trackballBehavior,
//     );
//   }


//   /// Returns the cartesian High-low-open-close chart.
//   SfCartesianChart buildHiloOpenCloseOHLC({double? minimumPrice, double? maximumPrice, DateTime? dateMax, DateTime? dateMin}) {
//     return SfCartesianChart(
//       annotations: <CartesianChartAnnotation>[_priceBox!, _priceBoxSell!],
//       plotAreaBorderWidth: 10,
//       zoomPanBehavior: TradingProperty.zoomPan,
//       primaryXAxis: DateTimeAxis(
//         intervalType: DateTimeIntervalType.minutes,
//         interval: 180,
//         edgeLabelPlacement: EdgeLabelPlacement.shift,
//         plotOffset: 5,
//         dateFormat: DateFormat('dd MMM HH:mm'),
//         majorGridLines: MajorGridLines(
//           width: 0.5,
//           color: Colors.grey.shade100,
//         ),
//       ),
//       primaryYAxis: NumericAxis(
//         plotOffset: 10,
//         majorGridLines: MajorGridLines(
//           width: 0.5,
//           color: Colors.grey.shade100,
//         ),
//         plotBands: <PlotBand>[
//           PlotBand(
//             isVisible: true,
//             start: lastPriceOpen.value,
//             end: lastPriceOpen.value,
//             borderColor: Colors.green,
//             borderWidth: 1,
//           ),
//           PlotBand(
//             isVisible: true,
//             start: lastPriceOpen.value + symbolSpread.value,
//             end: lastPriceOpen.value + symbolSpread.value,
//             borderColor: Colors.red,
//             borderWidth: 1,
//           ),
//         ],
//         opposedPosition: true,
//         borderColor: Colors.black12,
//         labelFormat: r'${value}',
//         minimum: minimumPrice,
//         maximum: maximumPrice,
//       ),
//       series: TradingProperty.buildCandleSeries(chartCandleData: _chartData),
//       trackballBehavior: _trackballBehavior,
//     );
//   }
// }
