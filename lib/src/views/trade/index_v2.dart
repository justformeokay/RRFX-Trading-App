import 'dart:async';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/websocket_controller.dart';
import 'package:rrfx/src/helpers/formatters/currency.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';
import 'package:rrfx/src/views/trade/derivchart_without_loginid.dart';
import 'deriv_chart_page.dart';

class MetaQuotesPage extends StatefulWidget {
  const MetaQuotesPage({super.key});

  @override
  State<MetaQuotesPage> createState() => _MetaQuotesPageState();
}

class _MetaQuotesPageState extends State<MetaQuotesPage> {
  final double appBarHeight = 66.0;
  MarketWebSocketController controller = Get.put(MarketWebSocketController());
  //

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final size = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: [
        Obx(
        () => SliverList(
            delegate: SliverChildListDelegate(
              () {
                if (controller.status.value == WebSocketStatus.connecting) {
                  return [
                    SizedBox(
                      width: size.width,
                      height: size.height / 2,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: CustomColor.secondaryColor, strokeWidth: 1.0),
                            SizedBox(height: 10.0),
                            Text("Getting Market...")
                          ],
                        )
                      )
                    ),
                  ];
                }

                if (controller.status.value == WebSocketStatus.failed) {
                  return [
                    SizedBox(
                      width: size.width,
                      height: size.height / 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning, color: Colors.red, size: 30.0),
                            const SizedBox(height: 10),
                            const Text("Failed to connect to WebSocket", style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            CupertinoButton(
                              onPressed: controller.reconnect,
                              child: Text("Retry", style: GoogleFonts.inter(color: CustomColor.defaultColor)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                }

                if (controller.marketData.isEmpty) {
                  return [
                    const Center(child: Text("Waiting for data...")),
                  ];
                }

                return controller.marketData.entries.map((entry) {
                  final symbol = entry.key;
                  final data = entry.value;
                  Icon? icon;
                  Color? color;
                  if(data.direction == "DOWN"){
                    color = Colors.red;
                    icon = Icon(TeenyIcons.down, color: color, size: 15.0);
                  }else if(data.direction == "UP"){
                    color = Colors.green;
                    icon = Icon(TeenyIcons.up, color: color, size: 15.0);
                  }else{
                    color = Colors.blue;
                    icon = Icon(TeenyIcons.line, color: color, size: 15.0);
                  }
                  final flags = RegexFormatter.getFlagsFromPairName(symbol);
                  return CupertinoButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 0,
                                  child: CountryFlag.fromCountryCode(
                                    flags['flag_two']!,
                                    width: 28,
                                    shape: const Circle(),
                                  ),
                                ),
                                CountryFlag.fromCountryCode(
                                  flags['flag_one']!,
                                  width: 28,
                                  shape: const Circle(),
                                ),
                              ],
                            ),
                          ),
                          // Symbol & Direction
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(symbol, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17, color: color)),
                                  const SizedBox(width: 5.0),
                                  icon
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.space_bar_rounded, size: 12.0, color: color),
                                  Text(" : ", style: TextStyle(fontSize: 12.0)),
                                  Text(
                                      "${data.spreadPips.toStringAsFixed(1)} pips", style: GoogleFonts.inter(fontSize: 12.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                    )
                                ],
                              )
                            ],
                          ),
                          // Prices
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                PriceDisplayWidget(fullPriceString: formatPrices(data.bid.toString(), currency: "USD"), color: color),
                                PriceDisplayWidget(fullPriceString: formatPrices(data.ask.toString(), currency: "USD"), color: color),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("L: ${data.bidLow.toStringAsFixed(4)}", style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                                  const SizedBox(width: 10),
                                  Text("H: ${data.bidHigh.toStringAsFixed(4)}", style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                                ],
                              ),
                              Text("Time: ${DateFormat('EEEE, dd MMMM yyyy').add_jms().format(DateTime.fromMillisecondsSinceEpoch(data.datetime * 1000))}", style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              }(),
            ),
          ),
        )

          // : SliverList(
          //   delegate: SliverChildListDelegate(
          //     List.generate(utilitiesController.marketModel.value?.message.length ?? 0, (i){
          //       // PriceParts bid = processAndExtractPriceParts(utilitiesController.marketModel.value?.message[i].bid != null ? utilitiesController.marketModel.value!.message[i].bid.toString() : "0", currency: utilitiesController.marketModel.value?.message[i].currency ?? "EURUSD");
          //       // PriceParts ask = processAndExtractPriceParts(utilitiesController.marketModel.value?.message[i].ask != null ? utilitiesController.marketModel.value!.message[i].ask.toString() : "0", currency: utilitiesController.marketModel.value?.message[i].currency ?? "EURUSD");
          //       return CupertinoButton(
          //         onPressed: (){
          //           Get.to(() => DerivChartPage(login: int.parse(tradingController.tradingAccountModels.value?.response.real?[selectedIndexAccountTrading.value].login ?? '0') ?? 0, marketName: utilitiesController.marketModel.value?.message[i].currency));
          //         },
          //         padding: EdgeInsets.zero,
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Obx(() => Text(utilitiesController.marketModel.value?.message[i].currency ?? "EURUSD", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 17))),
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.start,
          //                     children: [
          //                       Icon(Icons.space_bar_rounded, size: 12, color: Colors.black38),
          //                       const SizedBox(width: 3),
          //                       Text(utilitiesController.marketModel.value?.message[i].spread != null ? utilitiesController.marketModel.value!.message[i].spread.toString() : "0", style: GoogleFonts.inter(fontWeight: FontWeight.w400, color: Colors.black38, fontSize: 10))
          //                     ],
          //                   )
          //                 ],
          //               ),
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.center,
          //                 children: [
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       // BID Price
          //                       PriceDisplayWidget(
          //                         fullPriceString: formatPrices(utilitiesController.marketModel.value?.message[i].bid != null ? utilitiesController.marketModel.value!.message[i].bid.toString() : "0", currency: "USD"), // Hasilnya "1.15490"
          //                       ),
          //                       const SizedBox(width: 10),
          //                       // ASK Price
          //                       PriceDisplayWidget(
          //                         fullPriceString: formatPrices(utilitiesController.marketModel.value?.message[i].ask != null ? utilitiesController.marketModel.value!.message[i].ask.toString() : "0", currency: "USD"), // Hasilnya "1.15490"
          //                       ),
          //                     ],
          //                   ),
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       Obx(() => Text("L: ${utilitiesController.marketModel.value?.message[i].low != null ? utilitiesController.marketModel.value!.message[i].low.toString() : '0'}", style: GoogleFonts.inter(fontWeight: FontWeight.w400, color: Colors.black38, fontSize: 10))),
          //                       const SizedBox(width: 10),
          //                       Obx(() => Text("H: ${utilitiesController.marketModel.value?.message[i].high != null ? utilitiesController.marketModel.value!.message[i].high.toString() : '0'}", style: GoogleFonts.inter(fontWeight: FontWeight.w400, color: Colors.black38, fontSize: 10))),
          //                     ],
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     })
          //   )
          // ),

      ],
    );
  }
}


