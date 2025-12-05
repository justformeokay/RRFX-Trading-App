// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:rrfx/src/components/account_list/account_controller.dart';
// import 'package:rrfx/src/components/colors/default.dart';
// import 'package:rrfx/src/components/containers/no_account.dart';
// import 'package:rrfx/src/views/chart/components/flag_pair.dart';
// import 'package:rrfx/src/views/trade/deriv_chart_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../controllers/market_controller.dart';
// import '../models/market_group_model.dart';

// class MarketPage extends StatefulWidget {
//   const MarketPage({super.key});

//   @override
//   State<MarketPage> createState() => _MarketPageState();
// }

// class _MarketPageState extends State<MarketPage> {
//   final controller = Get.put(MarketController());
//   final accountController = Get.put(AccountController());

//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('accessToken');
//   }

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1), () async {
//       if (!accountController.hasAccounts) return;

//       final access = await getAccessToken();
//       final login = accountController.selectedAccount.value?.login;

//       if (access != null && login != null) {
//         controller.fetchSymbols(accessToken: access, account: login);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final onSurface = theme.colorScheme.onSurface;
//     final categories = controller.tabCategories;
//     return Obx(() {
//         if(!accountController.hasAccounts) return noAccountDetected();
//         return DefaultTabController(
//           length: categories.length,
//           child: Scaffold(
//             appBar: PreferredSize(
//               preferredSize: const Size.fromHeight(120),
//               child: Container(
//                 padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
//                 decoration: BoxDecoration(
//                   color: theme.scaffoldBackgroundColor,
//                   boxShadow: [
//                     BoxShadow(
//                       color: onSurface.withOpacity(0.06),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     )
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Market",
//                       style: GoogleFonts.inter(
//                         fontSize: 30,
//                         fontWeight: FontWeight.w800,
//                         color: CustomColor.secondaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
        
//                     /// ✔ Adaptive TabBar
//                     TabBar(
//                       tabAlignment: TabAlignment.center,
//                       isScrollable: true,
//                       overlayColor: MaterialStateProperty.all(Colors.transparent),
//                       labelPadding: const EdgeInsets.symmetric(horizontal: 20),
//                       labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       indicatorColor: CustomColor.secondaryColor,
//                       indicatorWeight: 3,
//                       labelColor: CustomColor.secondaryColor,
//                       unselectedLabelColor: onSurface.withOpacity(0.5),
//                       dividerColor: onSurface.withOpacity(0.1),
//                       tabs: categories.map((e) {
//                         return Tab(text: e.capitalizeFirst ?? e);
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
        
//             /// BODY
//             body: TabBarView(
//               children: categories.map((cat) {
//                 return TabBody(
//                   accountController,
//                   category: cat,
//                 );
//               }).toList(),
//             ),
//           ),
//         );}
//       );
//     }
//   }


// class TabBody extends GetView<MarketController> {
//   final String category;
//   final AccountController accountController;
//   const TabBody(this.accountController, {super.key, required this.category});

//   @override
//   Widget build(BuildContext context) {
//     final symbols = controller.getSymbolsForCategory(category);
//     IconData icon;
//     switch(category.capitalizeFirst){
//       case "Favorit":
//         icon = Iconsax.star_1_outline;
//       case "Komoditi":
//         icon = Iconsax.box_1_outline;
//       default:
//         icon = Iconsax.dollar_circle_outline;
//     }
//       if (symbols.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 45.0),
//               const SizedBox(height: 8.0),
//               Text('Tidak ada simbol di kategori ${category.capitalizeFirst}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
//             ],
//           ),
//         );
//       }
//     return RefreshIndicator(
//         onRefresh: () async {
//           controller.fetchSymbols();
//         },
//         child: ListView.builder(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(12),
//           itemCount: symbols.length,
//           itemBuilder: (context, index) {
//             final symbol = symbols[index];
//             return Obx(
//               () {
//                 final tick = controller.liveTicks[symbol.symbol];
//                 return SymbolCardTile(
//                 symbol: symbol,
//                 currentCategory: category,
//                 bid: tick?.bid.toStringAsFixed(symbol.digits) ?? "-",
//                 ask: tick?.ask.toStringAsFixed(symbol.digits) ?? "-",
//                 high: tick?.bidHigh.toStringAsFixed(symbol.digits) ?? "-",
//                 low: tick?.bidLow.toStringAsFixed(symbol.digits) ?? "-",
//               );
//               }
//             );
//           },
//         ),
//       );
//   }
// }


// class SymbolCardTile extends GetView<MarketController> {
//   final MarketSymbol symbol;
//   final String currentCategory;
//   final String bid;
//   final String ask;
//   final String high;
//   final String low;

//   const SymbolCardTile({
//     super.key,
//     required this.symbol,
//     required this.currentCategory,
//     required this.bid,
//     required this.ask,
//     required this.high,
//     required this.low,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final accountController = Get.put(AccountController());
//     final theme = Theme.of(context);
//     final onSurface = theme.colorScheme.onSurface;
//     final cardColor = theme.cardColor;

//     String? urlLogo;
//     switch(symbol.symbolAlias){
//       case "JPK":
//         urlLogo = 'https://s3-symbol-logo.tradingview.com/country/JP--big.svg';
//         break;
//       case "USK":
//         urlLogo = 'https://s3-symbol-logo.tradingview.com/indices/dow-jones-global--big.svg';
//         break;
//       case "UPK":
//         urlLogo = 'https://s3-symbol-logo.tradingview.com/indices/s-and-p-500--big.svg';
//         break;
//       case "HKK":
//         urlLogo = 'https://s3-symbol-logo.tradingview.com/indices/hang-seng--big.svg';
//         break;
//       case "UNK":
//         urlLogo = 'https://s3-symbol-logo.tradingview.com/indices/nasdaq-100--big.svg';
//         break;
//       default: 
//         urlLogo = null;
//     }

//     return Obx(() {
//       final isFav = controller.isFavorite(symbol);

//       return GestureDetector(
//         onTap: accountController.isLoading.value ? null : () {
//           Get.to(() => DerivChartPage(
//             login: accountController.selectedAccount.value?.login != null ? int.parse(accountController.selectedAccount.value!.login!) : 0,
//             marketName: symbol.symbol,
//             balance: accountController.selectedAccount.value?.balance,
//           ));
//         },
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 14),
//           decoration: BoxDecoration(
//             color: cardColor,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isFav ? Colors.amber.withOpacity(0.4) : onSurface.withOpacity(0.1),
//               width: isFav ? 1.5 : 1.0,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: onSurface.withOpacity(0.08),
//                 blurRadius: 6,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// HEADER
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         FlagPair(marketName: symbol.symbolAlias, size: 35, logoUrl: urlLogo),
//                         const SizedBox(width: 10),
//                         Text(
//                           symbol.symbolAlias,
//                           style: GoogleFonts.inter(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w800,
//                             color: CustomColor.secondaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     GestureDetector(
//                       onTap: () => controller.toggleFavorite(symbol),
//                       child: Icon(
//                         isFav ? Icons.star_rounded : Icons.star_border_rounded,
//                         size: 26,
//                         color: isFav
//                             ? Colors.amber
//                             : onSurface.withOpacity(0.4),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   currentCategory == "FAVORIT" ? symbol.groupName.capitalizeFirst ?? "Pasar" : currentCategory.capitalizeFirst ?? "Pasar",
//                   style: GoogleFonts.inter(
//                     fontSize: 12,
//                     color: onSurface.withOpacity(0.5),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),

//                 const SizedBox(height: 14),
//                 Divider(color: onSurface.withOpacity(0.1)),
//                 const SizedBox(height: 14),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildMiniInfo(context, "Bid", bid, Colors.greenAccent),
//                     _buildMiniInfo(context, "Ask", ask, Colors.redAccent),
//                     _buildMiniInfo(context, "High", high, Colors.blueAccent.shade200),
//                     _buildMiniInfo(context, "Low", low, Colors.orangeAccent.shade200),
//                   ],
//                 ),

//                 const SizedBox(height: 14),
//                 Divider(color: onSurface.withOpacity(0.1)),
//                 const SizedBox(height: 12),

//                 Wrap(
//                   spacing: 20,
//                   runSpacing: 10,
//                   children: [
//                     _buildDetail(context, "Spread", symbol.spread.toString()),
//                     _buildDetail(context, "Min Vol", symbol.volumeMin.toString()),
//                     _buildDetail(context, "Max Vol", symbol.volumeMax.toString()),
//                     _buildDetail(context, "Contract", symbol.contractSize.toString()),
//                     _buildDetail(context, "Digits", symbol.digits.toString()),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildMiniInfo(BuildContext context, String label, String value, Color color) {
//     final onSurface = Theme.of(context).colorScheme.onSurface;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: GoogleFonts.inter(
//               fontSize: 11,
//               color: onSurface.withOpacity(0.55),
//             )),
//         const SizedBox(height: 2),
//         Text(value,
//             style: GoogleFonts.inter(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//             )),
//       ],
//     );
//   }

//   Widget _buildDetail(BuildContext context, String label, String value) {
//     final onSurface = Theme.of(context).colorScheme.onSurface;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: GoogleFonts.inter(
//               fontSize: 11,
//               color: onSurface.withOpacity(0.55),
//             )),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: GoogleFonts.inter(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: onSurface,
//           ),
//         ),
//       ],
//     );
//   }
// }