// import 'dart:async';
// import 'dart:collection';
// import 'dart:math';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:deriv_chart/deriv_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
// import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
// import 'package:rrfx/src/components/colors/default.dart';
// import 'package:rrfx/src/components/textfields/number_textfield.dart';
// import 'package:rrfx/src/controllers/theme_controller.dart';
// import 'package:rrfx/src/controllers/trading.dart';
// import 'package:rrfx/src/helpers/handlers/date_market_active.dart';
// import 'package:rrfx/src/helpers/variables/global_variables.dart';

// import 'components/chart_section.dart';

// class DerivChartPage extends StatefulWidget {
//   const DerivChartPage({super.key, required this.login, this.marketName, this.balance, this.isDemo, this.openPositionPrice});
//   final int login;
//   final bool? isDemo;
//   final String? marketName;
//   final dynamic balance;
//   final dynamic openPositionPrice;

//   @override
//   State<DerivChartPage> createState() => _DerivChartPageState();
// }

// class _DerivChartPageState extends State<DerivChartPage> with WidgetsBindingObserver {
//   final TradingController tradingController = Get.put(TradingController());
//   final TextEditingController lotController = TextEditingController();
//   ThemeController themeController = Get.find();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final ChartController _controller = ChartController();
//   String? marketSymbol; // simbol dari user
//   dynamic ohlcData;
//   final RxBool isLoading = false.obs;
//   final RxDouble currentPrice = 0.0.obs;
//   final RxDouble lotSize = 0.01.obs;
//   Timer? _refreshTimer;
//   RxString currentSymbol = "Select Market".obs;
//   TimeFrame selectedTf = TimeFrame.h1;
//   RxInt granulity = 3600.obs;
//   RxBool cantGetSymbolFromAPI = false.obs;
//   final RxInt candleCount = 0.obs;
//   RxList<ChartAnnotation<ChartObject>> annotations = <ChartAnnotation<ChartObject>>[].obs;
//   Future<void> playSuccessSound() async {
//     await _audioPlayer.play(AssetSource("sounds/applepay.mp3"));
//   }
//   RxList<Map<String, dynamic>> indicators = <Map<String, dynamic>>[
//     {
//       "name" : "MACD",
//       "indicator" : MACDIndicatorConfig()
//     },
//     {
//       "name" : "RSI",
//       "indicator" : RSIIndicatorConfig()
//     },
//     {
//       "name" : "Aligator",
//       "indicator" : AlligatorIndicatorConfig()
//     },
//     {
//       "name" : "Moving Average",
//       "indicator" : MAIndicatorConfig()
//     },
//     {
//       "name" : "Stochestic Oscillator",
//       "indicator" : StochasticOscillatorIndicatorConfig()
//     },
//   ].obs;

//   RxList<Map<String, dynamic>> drawingTools = <Map<String, dynamic>>[
//     {
//       "name" : "Line",
//       "indicator" : LineDrawingToolConfig()
//     },
//     {
//       "name" : "Horizontal",
//       "indicator" : HorizontalDrawingToolConfig()
//     },
//     {
//       "name" : "Vertical",
//       "indicator" : VerticalDrawingToolConfig()
//     },
//     {
//       "name" : "Ray",
//       "indicator" : RayDrawingToolConfig(),
//     },
//     {
//       "name" : "Trend",
//       "indicator" : TrendDrawingToolConfig()
//     },
//     {
//       "name" : "Rectangle",
//       "indicator" : RectangleDrawingToolConfig()
//     },
//     {
//       "name" : "Channel",
//       "indicator" : ChannelDrawingToolConfig()
//     },
//     {
//       "name" : "Fibbonaci Fan",
//       "indicator" : FibfanDrawingToolConfig()
//     },
//   ].obs;
//   final planets = SplayTreeSet<Marker>((a, b) => a.compareTo(b));


//   RxBool isInitialized = false.obs;
//   bool isPaused = false;
//   DateTime now = DateTime.now();
//   AddOnsRepository<IndicatorConfig>? indicatorsRepo;
//   Repository<DrawingToolConfig>? _drawingToolsRepo;
//   final DrawingTools _drawingTools = DrawingTools();
//   DrawingToolConfig? _selectedDrawingTool;
//   RxString balanceAccount = "0".obs;

//   void _initializeDrawingTools() {
//     if (isInitialized.value) {
//       return;
//     }

//     setState(() {
//       _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
//         createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
//         sharedPrefKey: 'drawing_tools_screen',
//       );

//       _drawingTools.drawingToolsRepo = _drawingToolsRepo;
//       isInitialized(true);
//     });
//   }

//   String getBestSymbol({required String? marketName, required List<String> apiSymbols, required List<String> hardcodedSymbols}) {
//     if (marketName != null && apiSymbols.isNotEmpty) {
//       final foundApi = apiSymbols.firstWhere((s) => s.contains(marketName), orElse: () => apiSymbols.first);
//       return foundApi;
//     }
//     if (marketName != null) {
//       final foundHardcode = hardcodedSymbols.firstWhere((s) => s.contains(marketName), orElse: () => hardcodedSymbols.first);
//       return foundHardcode;
//     }
//     return hardcodedSymbols.first;
//   }

//   final spreadValue = 0.0.obs;

//   double getSpreadInPrice({required int spread, required int digits}) {
//     return spread / pow(10, digits);
//   }

//   void _loadChartDataV2() {
//     tradingController.getSymbols(loginID: widget.login.toString()).then((resultSymbol) {
//       final apiSymbols = tradingController.symbolModel.value?.response?.map((e) => e.symbol.toString()).toList() ?? [];
//       cantGetSymbolFromAPI(apiSymbols.isEmpty);
//       var selectedSymbolData;
//       try {
//         selectedSymbolData = tradingController.symbolModel.value?.response?.firstWhere((e) => e.symbol == currentSymbol.value);
//       } catch (_) {
//         selectedSymbolData = null;
//       }

//       if (selectedSymbolData != null) {
//         final calcSpread = getSpreadInPrice(
//           spread: selectedSymbolData.spread ?? 0,
//           digits: selectedSymbolData.digits ?? 0,
//         );
//         spreadValue(calcSpread);
//       }

//       tradingController.getMarketForDerivChartV3(
//         loginID: widget.login.toString(),
//         symbol: currentSymbol.value,
//         timeframe: selectedTf.name,
//       ).then((resultOHLC) {
//         if (!resultOHLC) {
//           return;
//         }
//         currentPrice.value = tradingController.ohlcDataDeriv.last.close;
//         _initializeDrawingTools();
//       });
//     });
//   }

//   RxBool availableOrder = false.obs;

//   @override
//   void initState() {
//     super.initState();
//     isLoading(true);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final bool isHoliday = isForexMarketHoliday(now);

//       if (isHoliday) {
//         CustomScaffoldMessanger.showAppSnackBar(context, message: "Hari ini market forex libur.");
//       }

//       await _loadSymbolsAndOrders();

//       if (!isHoliday) {
//         _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
//           _loadChartDataV2();
//         });
//       }

//       _loadChartDataV2();
//       isLoading(false);
//     });
//   }

//   Future<void> _loadSymbolsAndOrders() async {
//     final resultSymbol = await tradingController.getSymbols(loginID: widget.login.toString());
//     final apiSymbols = tradingController.symbolModel.value?.response?.map((e) => e.symbol.toString()).toList() ?? [];

//     final selected = getBestSymbol(
//       marketName: widget.marketName,
//       apiSymbols: resultSymbol && apiSymbols.isNotEmpty ? apiSymbols : [],
//       hardcodedSymbols: GlobalVariable.symbolHardCode,
//     );

//     currentSymbol(selected);

//     // final resultOpen = await tradingController.openOrder(login: widget.login.toString());
//     final orders = tradingController.openOrderModel.value?.response ?? [];
//     final foundOrder = orders.any((o) => o.symbol == widget.marketName);

//     availableOrder.value = foundOrder;
//     if (foundOrder) {
//       print("OYA ADA => ${widget.marketName}");
//     }
//   }


//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       isPaused = true;
//     } else if (state == AppLifecycleState.resumed) {
//       isPaused = false;
//     }
//   }

//   Future<void> _loadChartData() async {
//     try {
//       final result = await tradingController.getMarketForDerivChart(
//         market: currentSymbol.value,
//         timeframe: selectedTf.name.toUpperCase(),
//       );

//       switch(selectedTf){
//         case TimeFrame.h1:
//           granulity(3600);
//           break;
//         case TimeFrame.m1:
//           granulity(60);
//           break;
//         case TimeFrame.m30:
//           granulity(1800);
//           break;
//         default:
//           granulity(3600);
//       }

//       if(selectedTf == TimeFrame.h1){

//       }
      
//       if (result) {
//         candleCount.value = tradingController.ohlcDataDeriv.length;
//         // Update current price from the last candle
//         if (tradingController.ohlcDataDeriv.isNotEmpty) {
//           currentPrice.value = tradingController.ohlcDataDeriv.last.close;
//         }
//         isLoading(false);
//       } else {
//         debugPrint("Failed to load chart data");
//       }
//     } catch (e) {
//       debugPrint("Error loading chart data: $e");
//       isLoading(true);
//     }
//   }

//   void showDrawingToolsDialog() {
//     if (!isInitialized.value) {
//       return;
//     }

//     _drawingTools.init();

//     showDialog<void>(
//       context: context,
//       builder: (BuildContext context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.zero,
//         child: DrawingToolsDialog(
//           drawingTools: _drawingTools,
//         ),
//       ),
//     );
//   }

//   void _addDrawingTool() {
//     if (!isInitialized.value || _selectedDrawingTool == null) {
//       return;
//     }

//     _drawingTools.onDrawingToolSelection(_selectedDrawingTool!);
//     _drawingToolsRepo?.update();
//     setState(() {
//       _selectedDrawingTool = null;
//     });
//   }

//   Widget buildToolChip(String label, IconData icon) {
//     return Chip(
//       avatar: Icon(icon, size: 18),
//       label: Text(label),
//       backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     print("CURRENT SYMBOL : ${currentSymbol.value}");
//     print("CURRENT SYMBOL FROM HOME : ${widget.marketName}");
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           children: [
//             Obx(() => Text(currentSymbol.value)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(widget.login.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w300, color: Theme.of(context).textTheme.bodyMedium?.color)),
//                 const SizedBox(width: 5.0),
//                 Text("-"),
//                 const SizedBox(width: 5.0),
//                 widget.balance != null ? Text("\$${widget.balance}") : Text("\$0")
//               ],
//             )
//           ],
//         ),
//       ),
//       body: OrientationBuilder(
//         builder: (context, orientation) {
//           if (orientation == Orientation.portrait) {
//             return potraitView(size);
//           } else {
//             return landscapeView(size);
//           }
//         },
//       ),
//       bottomNavigationBar: widget.isDemo == true ? const SizedBox() : OrientationBuilder(
//         builder: (context, orientation) {
//           if(orientation == Orientation.portrait){
//             return Container(
//               padding: EdgeInsets.only(top: 5,  left: 16.0, right: 16.0, bottom: 50.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Obx(() => TradingProperty.sellButton(price: double.tryParse(currentPrice.value.toStringAsFixed(5)), onPressed: (){
//                     tradingController.executionOrder(symbol: currentSymbol.value, type: "sell", login: widget.login.toString(), lot: TradingProperty.volumeInit.value.toStringAsFixed(2)).then((result){
//                       if(result['status']){
//                         playSuccessSound();
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
//                         tradingController.openOrder(login: widget.login.toString()); // fungsi get open order API
//                       }else{
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.error);
//                       }
//                     });
//                   })),
//                   TradingProperty.lotButton(context),
//                   Obx(() => TradingProperty.buyButton(price: double.tryParse(currentPrice.value.toStringAsFixed(5)), onPressed: () {
//                     tradingController.executionOrder(symbol: currentSymbol.value, type: "buy", login: widget.login.toString(), lot: TradingProperty.volumeInit.value.toString()).then((result){
//                       if(result['status']){
//                         playSuccessSound();
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
//                         tradingController.openOrder(login: widget.login.toString()); // fungsi get open order API
//                       }else{
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.error);
//                       }
//                     });
//                   }))
//                 ],
//               ),
//             );
//           }
//           return SizedBox();
//         },
//       )
//     );
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel(); // stop timer kalau widget ditutup
//     WidgetsBinding.instance.removeObserver(this);
//     lotController.dispose();
//     super.dispose();
//   }


//   final previousPrice = 0.0.obs;

//   void updatePrice(double newPrice) {
//     previousPrice.value = currentPrice.value; // simpan harga lama
//     currentPrice.value = newPrice;            // update harga baru
//   }

//   Widget landscapeView(Size size){
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 0),
//                   child: Row(
//                     children: [
//                       Row(
//                         children: [
//                           Obx(
//                             () => GestureDetector(
//                               onTap: tradingController.isLoading.value ? null : (){
//                                 CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Market Symbols", children: List.generate(tradingController.symbolModel.value?.response?.length ?? 0, (i){
//                                   return ListTile(
//                                     leading: Container(
//                                       width: 25,
//                                       height: 25,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey.shade200,
//                                         shape: BoxShape.circle
//                                       ),
//                                       child: Center(child: Text("${i+1}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
//                                     ),
//                                     title: Text(tradingController.symbolModel.value?.response?[i].symbol ?? "", style: GoogleFonts.inter()),
//                                     onTap: () async {
//                                       Get.back();
//                                       currentSymbol.value = tradingController.symbolModel.value?.response?[i].symbol ?? "EURUSD";
//                                       _loadChartDataV2();
//                                     },
//                                   );
//                                 }));
//                               },
//                               child: Container(
//                                 margin: EdgeInsets.only(left: 10.0),
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).cardColor,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Obx(() => Text(currentSymbol.value, style: GoogleFonts.inter(color: Colors.white))),
//                                     Icon(Icons.keyboard_arrow_down, color: Colors.white),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           DropdownButton<TimeFrame>(
//                             borderRadius: BorderRadius.circular(10),
//                             elevation: 1,
//                             padding: EdgeInsets.zero,
//                             icon: Visibility (visible:false, child: Icon(Icons.arrow_downward)),
//                             underline: SizedBox(),
//                             value: selectedTf,
//                             items: TimeFrame.values.map((tf) => DropdownMenuItem(
//                               value: tf,
//                               child: Text(tf.name.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
//                             )).toList(),
//                             onChanged: (tf) async {
//                               // reloadMarket(timeframe: tf?.name.toUpperCase());
//                               await _loadChartData();
//                               setState(() {
//                                 selectedTf = tf!;
//                               });
//                               debugPrint(selectedTf.name);
//                             },
//                           ),
//                         ],
//                       ),
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Obx(
//                               () => isLoading.value ? const SizedBox() : TradingProperty.iconButton(context, AntDesign.function_outline, (){
//                                 CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Indicators", children: List.generate(indicators.length, (i){
//                                   return ListTile(
//                                     onTap: (){
//                                       Navigator.pop(context);
//                                       indicatorsRepo!.add(indicators[i]['indicator']);
//                                     },
//                                     title: Text(indicators[i]['name'], style: GoogleFonts.inter()),
//                                   );
//                                 }));
//                               }),
//                             ),
//                             Obx(
//                               () => isLoading.value ? const SizedBox() : TradingProperty.iconButton(context, Icons.edit, (){
//                                 CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Drawing Tools", children: List.generate(drawingTools.length, (i){
//                                   return ListTile(
//                                     onTap: (){
//                                       Navigator.pop(context);
//                                       _selectedDrawingTool = drawingTools[i]['indicator'];
//                                       _selectedDrawingTool != null ? _addDrawingTool : null;
//                                     },
//                                     title: Text(drawingTools[i]['name'], style: GoogleFonts.inter()),
//                                   );
//                                 }));
//                               }),
//                             ),
//                             TradingProperty.iconButton(context, Icons.layers, (){}),
//                             TradingProperty.iconButton(context, Icons.tune, (){}),
//                             TradingProperty.iconButton(context, Icons.fullscreen, (){}),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Obx(() => isLoading.value
//                     ? Center(child: CircularProgressIndicator(color: CustomColor.defaultColor))
//                     : Stack(
//                       children: [
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width,
//                           height: MediaQuery.of(context).size.height,
//                           child: Obx(
//                             () => tradingController.isLoading.value ? const SizedBox() :
//                             DerivChart(
//                               key: const Key('drawing_tools_chart'),
//                               indicatorsRepo: indicatorsRepo,
//                               controller: _controller,
//                               chartAxisConfig: ChartAxisConfig(
//                                 showEpochGrid: true,
//                                 smoothScrolling: true,
//                                 defaultIntervalWidth: 100,
//                                 showQuoteGrid: true,
//                               ),
//                               dataFitEnabled: true,
//                               showCrosshair: true,
//                               markerSeries: MarkerSeries(
//                                 planets,
//                                 markerIconPainter: AccumulatorMarkerIconPainter(),
//                                 style: MarkerStyle(
//                                   backgroundColor: CustomColor.secondaryColor
//                                 )
//                               ),
//                               // loadingAnimationColor: CustomColor.defaultColor,
//                               showScrollToLastTickButton: true,
//                               dataFitPadding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
//                               isLive: true,
//                               theme: themeController.isDark.value ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
//                               drawingTools: _drawingTools,
//                               mainSeries: CandleSeries(tradingController.ohlcDataDeriv),
//                               // mainSeries: CandleSeries(ohlcData),
//                               granularity: granulity.value,
//                               showDataFitButton: true,
//                               pipSize: currentSymbol.value.contains("JPY") || currentSymbol.value.contains("XAU") || currentSymbol.value.contains("GOLD") ? 3 : 5,
//                               opacity: 1,
//                               drawingToolsRepo: _drawingToolsRepo,
//                               showCurrentTickBlinkAnimation: true,
//                               activeSymbol: currentSymbol.value,
//                               annotations: [
//                                 HorizontalBarrier(
//                                   style: HorizontalBarrierStyle(
//                                     color: Colors.grey,
//                                     hasArrow: true,
//                                     arrowSize: 20,
//                                     titleBackgroundColor: Colors.black45,
//                                     hasBlinkingDot: true,
//                                     labelShape: LabelShape.pentagon,
//                                     blinkingDotColor: Colors.red,
//                                     secondaryBackgroundColor: Colors.black12
//                                   ),
//                                   currentPrice.value,
//                                   visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // _buildTradingControls(),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 5.0),
//         Container(
//           padding: EdgeInsets.only(right:5.0),
//           width: size.width / 3.3,
//           height: size.height,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Obx(() => TradingProperty.sellButton(price: double.tryParse(currentPrice.value.toStringAsFixed(4)), onPressed: (){
//                     tradingController.executionOrder(symbol: currentSymbol.value, type: "sell", login: widget.login.toString(), lot: lotController.text).then((result){
//                       if(result['status']){
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
//                       }else{
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.error);
//                       }
//                     });
//                   })),
//                   Obx(() => TradingProperty.buyButton(price: double.tryParse(currentPrice.value.toStringAsFixed(4)), onPressed: () {
//                     tradingController.executionOrder(symbol: currentSymbol.value, type: "buy", login: widget.login.toString(), lot: lotController.text).then((result){
//                       if(result['status']){
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
//                       }else{
//                         CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.error);
//                       }
//                     });
//                   }))
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Jumlah Lot"),
//                     const SizedBox(height: 10),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: NumberTextField(
//                             controller: lotController,
//                             readOnly: true,
//                             useValidator: false,
//                             fieldName: "Lot Size",
//                             hintText: "1.0",
//                             labelText: "Lot Size",
//                           ),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             backgroundColor: CustomColor.defaultColor,
//                             shape: const CircleBorder(),
//                           ),
//                           onPressed: () {
//                             double currentLot = double.tryParse(lotController.text) ?? 1.0;
//                             currentLot -= 1.0;
//                             if (currentLot < 1) currentLot = 1; // optional: prevent negative lots
//                             lotController.text = currentLot.toStringAsFixed(2);
//                           },
//                           child: const Icon(Icons.remove, color: Colors.white),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             backgroundColor: Colors.green,
//                             shape: const CircleBorder(),
//                           ),
//                           onPressed: () {
//                             double currentLot = double.tryParse(lotController.text) ?? 1.0;
//                             currentLot += 1.0;
//                             lotController.text = currentLot.toStringAsFixed(2);
//                           },
//                           child: const Icon(Icons.add, color: Colors.white),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Current Price: ", style: GoogleFonts.inter(fontSize: 16.0, color: CustomColor.textThemeLightColor)),
//                         Obx(() {
//                           Color priceColor = Colors.green; // default
//                             if (currentPrice.value > previousPrice.value) {
//                               priceColor = Colors.green; // naik
//                             } else if (currentPrice.value < previousPrice.value) {
//                               priceColor = Colors.red; // turun
//                             }
//                           String price = currentPrice.value.toStringAsFixed(5); // contoh 1.18757
//                           List<String> parts = [
//                             price.substring(0, price.length - 3),  // 1.18
//                             price.substring(price.length - 3, price.length - 1), // 75
//                             price.substring(price.length - 1), // 7
//                           ];

//                           return RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: parts[0],
//                                   style: GoogleFonts.inter(
//                                     fontSize: 18,
//                                     color: priceColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: parts[1],
//                                   style: GoogleFonts.inter(
//                                     fontSize: 30,
//                                     color: priceColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 WidgetSpan(
//                                   child: Transform.translate(
//                                     offset: const Offset(0, -8), // posisi naik (superscript)
//                                     child: Text(
//                                       parts[2],
//                                       style: GoogleFonts.inter(
//                                         fontSize: 18,
//                                         color: priceColor,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }),
//                       ],
//                     ),
//                     // Obx(() => Text("Candle Count: ${candleCount.value}", style: GoogleFonts.inter(fontSize: 16.0, color: CustomColor.textThemeLightColor))),
//                     // const SizedBox(height: 10),
//                     // Obx(() => Text("Granularity: ${granulity.value} seconds", style: GoogleFonts.inter(fontSize: 16.0, color: CustomColor.textThemeLightColor))),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget potraitView(Size? size) {
//   return Column(
//     children: [
//       Padding(
//         padding: EdgeInsets.zero,
//         child: Row(
//           children: [
//             // _buildSymbolSelector(size), // fungsi market
//             const SizedBox(width: 8),
//             _buildTimeframeSelector(),
//             Expanded(child: _buildToolbar(size)),
//           ],
//         ),
//       ),
//       Expanded(child: _buildChart()),
//     ],
//   );
// }

// Widget _buildTimeframeSelector() {
//   return DropdownButton<TimeFrame>(
//     borderRadius: BorderRadius.circular(10),
//     elevation: 1,
//     underline: const SizedBox(),
//     icon: const SizedBox.shrink(),
//     value: selectedTf,
//     items: TimeFrame.values.map((tf) => DropdownMenuItem(value: tf, child: Text(tf.name.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)))).toList(),
//     onChanged: (tf) async {
//       if (tf == null) return;
//       setState(() => selectedTf = tf);

//       debugPrint("Timeframe: ${selectedTf.name}");

//       await tradingController.getMarketForDerivChartV3(
//         loginID: widget.login.toString(),
//         symbol: currentSymbol.value,
//         timeframe: selectedTf.name.toUpperCase(),
//       );

//       if (tradingController.ohlcDataDeriv.isEmpty) {
//         // CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
//         return;
//       }

//       currentPrice.value = tradingController.ohlcDataDeriv.last.close;
//     },
//   );
// }

// Widget _buildToolbar(Size? size) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: [
//       Obx(() => isLoading.value
//         ? const SizedBox()
//         : TradingProperty.iconButton(
//             context,
//             AntDesign.function_outline,
//             () {
//               CustomMaterialBottomSheets.defaultBottomSheet(
//                 context,
//                 size: size,
//                 title: "Indicators",
//                 children: indicators
//                   .map(
//                     (ind) => ListTile(
//                       title: Text(ind['name'], style: GoogleFonts.inter()),
//                       onTap: () {
//                         Navigator.pop(context);
//                         indicatorsRepo!.add(ind['indicator']);
//                       },
//                     ),
//                   )
//                   .toList(),
//               );
//             },
//           )
//         ),
//     Obx(() => isLoading.value
//       ? const SizedBox()
//       : TradingProperty.iconButton(
//           context,
//           Icons.edit,
//           () {
//             CustomMaterialBottomSheets.defaultBottomSheet(
//               context,
//               size: size,
//               title: "Drawing Tools",
//               children: drawingTools.map((tool) => ListTile(title: Text(tool['name'], style: GoogleFonts.inter()), 
//                 onTap: () {
//                     Navigator.pop(context);
//                     _selectedDrawingTool = tool['indicator'];
//                     if (_selectedDrawingTool != null) _addDrawingTool();
//                   },
//                 ),
//               ).toList(),
//             );
//           },
//         )
//       ),
//       TradingProperty.iconButton(context, Icons.layers, () {}),
//       TradingProperty.iconButton(context, Icons.tune, () {}),
//       TradingProperty.iconButton(context, Icons.fullscreen, () {}),
//     ],
//   );
// }

// Widget _buildChart() {
//   return Obx(
//     () => isLoading.value
//       ? Center(child: CircularProgressIndicator(color: CustomColor.defaultColor))
//       : DerivChart(
//           key: const Key('drawing_tools_chart'),
//           indicatorsRepo: indicatorsRepo,
//           controller: _controller,
//           chartAxisConfig: const ChartAxisConfig(showEpochGrid: true, smoothScrolling: true, defaultIntervalWidth: 100, showQuoteGrid: true),
//           dataFitEnabled: true,
//           showCrosshair: true,
//           markerSeries: MarkerSeries(planets, markerIconPainter: AccumulatorMarkerIconPainter(), style: MarkerStyle(backgroundColor: CustomColor.secondaryColor)),
//           showScrollToLastTickButton: true,
//           dataFitPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           isLive: true,
//           theme: themeController.isDark.value ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
//           drawingTools: _drawingTools,
//           mainSeries: CandleSeries(tradingController.ohlcDataDeriv),
//           granularity: granulity.value,
//           showDataFitButton: true,
//           pipSize: currentSymbol.value.contains("JPY") || currentSymbol.value.contains("XAU") || currentSymbol.value.contains("GOLD") ? 3 : 5,
//           opacity: 1,
//           drawingToolsRepo: _drawingToolsRepo,
//           showCurrentTickBlinkAnimation: true,
//           activeSymbol: currentSymbol.value,
//           loadingAnimationColor: Colors.transparent,
//           annotations: [
//             HorizontalBarrier(
//               id: "1",
//               currentPrice.value + spreadValue.value,
//               style: HorizontalBarrierStyle(
//                 color: Colors.red,
//                 lineColor: Colors.red,
//                 titleBackgroundColor: Colors.red,
//                 labelShapeBackgroundColor: Colors.red,
//                 hasBlinkingDot: true,
//               ),
//             ),

//             // default barrier current price
//             HorizontalBarrier(
//               id: "2",
//               currentPrice.value,
//               style: HorizontalBarrierStyle(
//                 color: Colors.green,
//                 lineColor: Colors.green,
//                 titleBackgroundColor: Colors.green,
//                 labelShapeBackgroundColor: Colors.green,
//                 hasBlinkingDot: true,
//               ),
//             ),

//             ...tradingController.openOrderModel.value?.response?.map((order) {
//               final double openPrice = double.tryParse(order.openPrice.toString()) ?? 0.0;
//               final String type = order.orderType?.toUpperCase() ?? "";
//               final double lot = order.lot ?? 0.0;

//               if (order.symbol == widget.marketName) {
//                 return [
//                   HorizontalBarrier(
//                     openPrice,
//                     id: "barrier_${order.ticket}_${order.orderType}", // 👈 unik per order
//                     title: "$type ${lot.toStringAsFixed(2)} lot",
//                     style: HorizontalBarrierStyle(
//                       color: type == "BUY" ? Colors.blue : Colors.red,
//                       lineColor: type == "BUY" ? Colors.blue : Colors.red,
//                       titleBackgroundColor: type == "BUY" ? Colors.blue : Colors.red,
//                       labelShapeBackgroundColor: type == "BUY" ? Colors.blue : Colors.red,
//                       hasBlinkingDot: true,
//                     ),
//                   ),
//                 ];
//               }
//               return [];
//             }).expand((e) => e).toList() ?? [],
//           ],
//         ),
//     );
//   }
// }
