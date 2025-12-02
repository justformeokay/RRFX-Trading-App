import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';
import 'package:rrfx/src/views/trade/deriv_chart_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  UtilitiesController utilitiesController = Get.find();
  TradingController tradingController = Get.find();
  RxInt selectedIndexAccountTrading = 0.obs;
  RxString selectedAccountTrading = "".obs;
  RxString selectedBalanceAccount = "0".obs;
  RxString selectedTypeAccount = "RRFX".obs;
  RxInt selectedEquityAccount = 0.obs;
  RxBool showHideBalance = true.obs;
  Map<String, String>? flag;

  @override
  void initState() {
    super.initState();
    tradingController.getTradingAccount().then((result){
      if(tradingController.tradingAccountModels.value?.response.real?.isNotEmpty == true){
        selectedAccountTrading(tradingController.tradingAccountModels.value?.response.real?[0].login);
        selectedIndexAccountTrading(0);
        selectedBalanceAccount(tradingController.tradingAccountModels.value?.response.real?[0].balance);
        selectedTypeAccount(tradingController.tradingAccountModels.value?.response.real?[0].namaTipeAkun);
        selectedEquityAccount(tradingController.tradingAccountModels.value?.response.real?[0].marginFree);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Produk'),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: CustomColor.secondaryColor),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: CustomColor.backgroundIcon,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'Forex'),
              Tab(text: 'Komoditas'),
              Tab(text: 'Indeks'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildProductList(size, 'Forex'),
              _buildProductList(size, 'Komoditas'),
              _buildProductList(size, 'Indeks'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(Size size, String category) {
    return ListView.builder(
      itemCount: min(3, utilitiesController.tradingSignal.value?.message?.length ?? 0),
      itemBuilder: (context, i) {
        final analysis = utilitiesController.tradingSignal.value?.message?[i].analysis;
        flag = RegexFormatter.getFlagsFromPairName(utilitiesController.tradingSignal.value?.message?[i].symbol ?? "EURUSD");
        return buildCard(
          context, size,
          upper: analysis?.indicators?.bollingerBands?.upper.toString(),
          lower: analysis?.indicators?.bollingerBands?.lower.toString(),
          recommendation: analysis?.recommendation?.toUpperCase(),
          marketName: utilitiesController.tradingSignal.value?.message?[i].symbol,
          flagPair: flag?['flag_one'],
          flagPaired: flag?['flag_two'],
          bid: analysis?.currentPrice?.bid.toString(),
          ask: analysis?.currentPrice?.ask.toString(),
          date: analysis?.lastUpdate != null ? DateFormat("EEEE, dd MMMM yyyy hh:mm:ss").format(DateTime.parse(analysis!.lastUpdate!)) : "-",
          stopLoss: analysis?.tradingSuggestions?.stopLoss.toString(),
        );
      },
    );
  }

  Widget buildCard(BuildContext context, Size size, {String? marketName, String? flagPair, String? flagPaired, String? date, String? stopLoss, String? bid, String? recommendation, String? ask, String? sma10, String? sma20, String? sma50, String? priceVsSMA, String? histogram, String? signalLine, String? macdLine, String? upper, String? lower, String? middle, String? pricePosition, String? rsi, String? signalSummaryRSI, String? signalSummaryMACD, String? signalSummarySMA, String? signalSummaryBollingerBands, List? tradingAccountUser}){
    Color? color;
    IconData? icon;
    switch(recommendation){
      case "BUY":
        color = Colors.green.shade400;
        icon = OctIcons.arrow_up_right;
        break;
      case "STRONG SELL":
        color = Colors.pink;
        icon = OctIcons.arrow_down_right;
        break;
      case "STRONG BUY":
        color = Colors.green;
        icon = OctIcons.arrow_up_right;
        break;
      case "SELL":
        color = Colors.red;
        icon = OctIcons.arrow_down_right;
        break;
      case "NEUTRAL":
        color = Colors.purple;
        icon = Icons.line_axis;
        break;
      default:
        color = Colors.blue;
        break;
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                child: CountryFlag.fromCountryCode(
                                  flagPaired ?? 'CH',
                                  width: 28,
                                  shape: const Circle(),
                                ),
                              ),
                              CountryFlag.fromCountryCode(
                                flagPair ?? 'AU',
                                width: 28,
                                shape: const Circle(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        Text(marketName ?? "AUDCHF", style: GoogleFonts.inter(fontWeight: FontWeight.w800))
                      ],
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Clarity.date_line, color: Colors.black45, size: 13.0),
                          const SizedBox(width: 5.0),
                          Flexible(child: Text(date ?? '', overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10.0)))
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Take Profit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bid",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          bid ?? "0.0",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15.0),
                    // Stop Loss
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ask",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          ask ?? "0.0",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15.0),
                    // Sumber
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "High",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          upper ?? '0.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15.0),
                    // Sumber
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Low",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          lower ?? "0.0",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text("Potensi"),
              CupertinoButton(
                onPressed: (){
                  if(selectedAccountTrading.value != ""){
                    Get.to(() => DerivChartPage(login: int.parse(selectedAccountTrading.value), marketName: marketName));
                  }else{
                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki atau memilih akun trading");
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: color
                  ),
                  child: Icon(icon, color: Colors.white, size: 30)
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
