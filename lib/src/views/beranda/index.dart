// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:intl/intl.dart';
// import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
// import 'package:rrfx/src/components/colors/default.dart';
// import 'package:rrfx/src/controllers/trading.dart';
// import 'package:rrfx/src/controllers/utilities.dart';
// import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';
// import 'package:rrfx/src/views/settings/components/settings_components.dart';
// import 'package:rrfx/src/views/settings/documents.dart';
// import 'package:rrfx/src/views/trade/deposit.dart';
// import 'package:rrfx/src/views/trade/internal_transfer.dart';
// import 'package:rrfx/src/views/trade/withdrawal.dart';
// import 'all_trading_signals.dart';
// import 'components/forex_news.dart';
// import 'components/market_item.dart';
// import 'components/promotion.dart';

// class Beranda extends StatefulWidget {
//   const Beranda({super.key});

//   @override
//   State<Beranda> createState() => _BerandaState();
// }

// class _BerandaState extends State<Beranda>{
//   UtilitiesController utilitiesController = Get.put(UtilitiesController());
//   TradingController tradingController = Get.put(TradingController());
//   RxBool haveRealAccount = false.obs;

//   Future<void> loadTradingAccount() async {
//     tradingController.accountTrading.value = await tradingController.getTradingAccountV2().then((result) => result);
//   }

//   Map<String, String>? flag;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, (){
//       utilitiesController.getTradingSignals().then((result){
//         loadTradingAccount();
//         if(!result){}
//       });
//       tradingController.getTradingAccount().then((result){
//         if(tradingController.tradingAccountModels.value?.response.real?.length != 0){
//           haveRealAccount(true);
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return SafeArea(
//       child: Scrollbar(
//         radius: Radius.circular(20),
//         thickness: 7,
//         interactive: true,
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const PromotionSection(),
//               const SizedBox(height: 20),
//               Obx(
//                 () => utilitiesController.isLoading.value ? const SizedBox() : Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Trading Signals", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
//                     CupertinoButton(
//                       onPressed: (){
//                         Get.to(() => const AllTradingSignals());
//                       },
//                       padding: EdgeInsets.zero,
//                       child: Text("Lihat Semua", style: GoogleFonts.inter(fontStyle: FontStyle.italic, fontSize: 14, color: CustomColor.defaultColor, fontWeight: FontWeight.bold)),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Obx(
//                 () => utilitiesController.isLoading.value ? const SizedBox() : Container(
//                   padding: const EdgeInsets.only(right: 15, top: 15, bottom: 15),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Colors.grey[50],
//                     // border: Border.all(color: Colors.black12, width: 0.4),
//                     // boxShadow: const [
//                     //   BoxShadow(color: Colors.black12, blurRadius: 20),
//                     // ]
//                   ),
//                   child: Obx(
//                     () => Column(
//                       children: List.generate(utilitiesController.tradingSignal.value?.message?.length ?? 0, (index) {
//                         flag = RegexFormatter.getFlagsFromPairName(utilitiesController.tradingSignal.value?.message?[index].symbol ?? "EURUSD");
//                         if(index < 4){
//                           return marketItem(
//                             context,
//                             size,
//                             tradingAccountUser: tradingController.accountTrading,
//                             marketName: utilitiesController.tradingSignal.value?.message?[index].symbol,
//                             flagPair: flag?['flag_one'],
//                             flagPaired: flag?['flag_two'],
//                             ask: utilitiesController.tradingSignal.value?.message?[index].analysis?.currentPrice?.ask.toString(),
//                             recommendation: utilitiesController.tradingSignal.value?.message?[index].analysis?.recommendation != null ? utilitiesController.tradingSignal.value?.message![index].analysis!.recommendation!.toUpperCase() : "-",
//                             bid: utilitiesController.tradingSignal.value?.message?[index].analysis?.currentPrice?.bid.toString(),
//                             stopLoss: utilitiesController.tradingSignal.value?.message?[index].analysis?.tradingSuggestions?.stopLoss.toString(),
//                             date: utilitiesController.tradingSignal.value?.message?[index].analysis?.lastUpdate != null ? DateFormat("EEEE, dd MMMM yyyy hh:mm:ss").format(DateTime.parse(utilitiesController.tradingSignal.value!.message![index].analysis!.lastUpdate!)) : "-",
//                             sma10: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.sma_10.toString(),
//                             sma20: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.sma_20.toString(),
//                             sma50: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.sma_50.toString(),
//                             priceVsSMA: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.movingAverages?.priceVsSma50.toString(),
//                             macdLine: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.macd?.macdLine.toString(),
//                             signalLine: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.macd?.signalLine.toString(),
//                             histogram: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.macd?.histogram.toString(),
//                             upper: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.upper.toString(),
//                             lower: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.lower.toString(),
//                             middle: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.middle.toString(),
//                             pricePosition: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.bollingerBands?.pricePosition.toString(),
//                             rsi: utilitiesController.tradingSignal.value?.message?[index].analysis?.indicators?.rsi.toString(),
//                             signalSummaryBollingerBands: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.bollinger,
//                             signalSummarySMA: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.maCross,
//                             signalSummaryRSI: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.rsi,
//                             signalSummaryMACD: utilitiesController.tradingSignal.value?.message?[index].analysis?.signals?.macd,
//                           );
//                         }
//                         return const SizedBox();
//                       }),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text("Shortcuts", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Wrap(
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: [
//                   Obx(
//                         () => SettingComponents.storageCard(
//                         context,
//                         "Withdrawal",
//                         Bootstrap.box_arrow_up,
//                         haveRealAccount.value
//                             ? () => Get.to(() => const Withdrawal())
//                             : () => CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki akun real", type: SnackBarType.error)
//                     ),
//                   ),
//                   Obx(
//                         () => SettingComponents.storageCard(
//                         context,
//                         "Deposit",
//                         Bootstrap.box_arrow_down, haveRealAccount.value
//                         ? () => Get.to(() => const Deposit())
//                         : () => CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki akun real", type: SnackBarType.error)
//                     ),
//                   ),
//                   Obx(
//                         () => SettingComponents.storageCard(
//                         "Transfer",
//                         BoxIcons.bx_transfer_alt,
//                         haveRealAccount.value
//                             ? () => Get.to(() => const InternalTransfer())
//                             : () => CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki akun real", type: SnackBarType.error)
//                     ),
//                   ),
//                   Obx(
//                         () => SettingComponents.storageCard(
//                         "Documents",
//                         Iconsax.document_outline,
//                         haveRealAccount.value
//                             ? () => Get.to(() => const Documents())
//                             : () => CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki akun real", type: SnackBarType.error)
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               ForexNews(),
//               const SizedBox(height: 20),
//               // LearningSection()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
