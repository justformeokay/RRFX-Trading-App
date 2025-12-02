import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';
import 'package:rrfx/src/views/trade/deriv_chart_page.dart';

import 'gauge_range.dart';

Widget marketItem(BuildContext context, Size size, {String? marketName, String? flagPair, String? flagPaired, String? date, String? stopLoss, String? bid, String? recommendation, String? ask, String? sma10, String? sma20, String? sma50, String? priceVsSMA, String? histogram, String? signalLine, String? macdLine, String? upper, String? lower, String? middle, String? pricePosition, String? rsi, String? signalSummaryRSI, String? signalSummaryMACD, String? signalSummarySMA, String? signalSummaryBollingerBands, List? tradingAccountUser}){
  final accountController = Get.put(AccountController());
  Color? color;
  switch(recommendation){
    case "BUY":
      color = Colors.green.shade400;
      break;
    case "STRONG SELL":
      color = Colors.pink;
      break;
    case "STRONG BUY":
      color = Colors.green;
      break;
    case "SELL":
      color = Colors.red;
      break;
    case "NEUTRAL":
      color = Colors.purple;
      break;
    default:
      color = Colors.blue;
      break;
  }
  return GestureDetector(
    onTap: () {
      showTradeAnalysis(
        context,
        size,
        marketName: marketName,
        bid: bid,
        ask: ask,
        sma50: sma50,
        sma20: sma20,
        sma10: sma10,
        priceVsSMA: priceVsSMA,
        histogram: histogram,
        macdLine: macdLine,
        signalLine: signalLine,
        pricePosition: pricePosition,
        lower: lower,
        middle: middle,
        upper: upper,
        rsi: rsi,
        recommendation: recommendation,
        signalSummaryBollingerBands: signalSummaryBollingerBands,
        signalSummaryMACD: signalSummaryMACD,
        signalSummaryRSI: signalSummaryRSI,
        signalSummarySMA: signalSummarySMA,
      );
    },
    child: Container(
    color: Colors.transparent,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flag
              FlagPair(marketName:  marketName ?? "", size: 35),
              const SizedBox(width: 10),
              Text(marketName ?? "",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              // Stop Loss
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stop Loss",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    stopLoss ?? "0",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  )
                ],
              ),
              const Spacer(),
              // Bid
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bid",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    bid ?? "-",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  )
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showTradeAnalysis(
                    context,
                    size,
                    marketName: marketName,
                    bid: bid,
                    ask: ask,
                    sma50: sma50,
                    sma20: sma20,
                    sma10: sma10,
                    priceVsSMA: priceVsSMA,
                    histogram: histogram,
                    macdLine: macdLine,
                    signalLine: signalLine,
                    pricePosition: pricePosition,
                    lower: lower,
                    middle: middle,
                    upper: upper,
                    rsi: rsi,
                    recommendation: recommendation,
                    signalSummaryBollingerBands: signalSummaryBollingerBands,
                    signalSummaryMACD: signalSummaryMACD,
                    signalSummaryRSI: signalSummaryRSI,
                    signalSummarySMA: signalSummarySMA,
                  );
                },
                child: Icon(
                  CupertinoIcons.arrow_right_circle_fill,
                  color: CustomColor.secondaryBackground,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                    date ?? "-",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // biar tetap kontras di atas background `color`
                    ),
                  ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              height: 35,
              width: 80,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(30),
                padding: EdgeInsets.zero,
                color: color,
                onPressed: () {
                  if(!accountController.hasAccounts){
                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki akun trading. Silakan buat akun trading terlebih dahulu.", type: SnackBarType.info);
                  } else {
                    if(accountController.selectedAccount.value?.login == null){
                      CustomScaffoldMessanger.showAppSnackBar(context, message: "Silakan pilih akun trading terlebih dahulu.", type: SnackBarType.info);
                      return;
                    }
                    Get.to(() => DerivChartPage(
                      marketName: marketName ?? "",
                      login: int.parse(accountController.selectedAccount.value!.login!),
                      balance: accountController.selectedAccount.value!.balance ?? "0",
                    ));
                  }
                },
                child: Text(
                  recommendation ?? "-",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          ],
        ),
        const Divider(thickness: 0.5),
      ],
    ),
    ),
  );
}

void showTradeAnalysis(BuildContext context, Size size, {String? marketName, String? bid, String? ask, String? spread, String? sma10, String? sma20, String? sma50, String? priceVsSMA, String? histogram, String? signalLine, String? macdLine, String? upper, String? lower, String? middle, String? pricePosition, String? rsi, String? recommendation, String? signalSummaryRSI, String? signalSummaryMACD, String? signalSummarySMA, String? signalSummaryBollingerBands}){
  CustomMaterialBottomSheets.defaultBottomSheet(
    context,
    title: "Trading Signal\n$marketName H1",
    size: size,
    children: [
      Text("  Recommendation", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20)),
      const SizedBox(height: 5),
      SizedBox(
        width: double.infinity,
        height: 250,
        child: GaugeScreen(
          recommendation: recommendation != null ? recommendation.toLowerCase() : "",
        )
      ),
      Text("  Price", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20)),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: itemCard(context, size, title: "Bid", content: bid, color: Colors.green, icons: CupertinoIcons.arrow_up_right)),
          const SizedBox(width: 5),
          Expanded(child: itemCard(context, size, title: "Ask", content: ask, color: Colors.red, icons: CupertinoIcons.arrow_down_right)),
        ],
      ),
      const SizedBox(height: 10),
      Text("  Indicators", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20)),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(child: itemCardIndicatorsSMA(context, size, title: "SMA", icons: Icons.line_axis_rounded, sma10: sma10, sma20: sma20, sma50: sma50, priceVsSMA50: priceVsSMA)),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(child: itemCardIndicatorsMACD(context, size, title: "MACD", icons: Icons.line_axis_rounded, macdLine: macdLine, histogram: histogram, signalLine: signalLine)),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(child: itemCardIndicatorsBollingerBand(context, size, title: "Bollinger Bands", icons: MingCute.chart_decrease_line, upper: macdLine, middle: histogram, lower: signalLine, pricePosition: pricePosition)),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(child: itemCardIndicatorsRSI(context, size, rsi: rsi, title: "RSI", icons: Clarity.line_chart_line)),
        ],
      ),

      const SizedBox(height: 20),
      Text("  Signals Summary", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20)),
      Row(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity / 2,
              height: 200,
              child: GaugeScreen(
                title: "RSI",
                recommendation: signalSummaryRSI != null ? signalSummaryRSI.toLowerCase() : "",
              )
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: SizedBox(
                width: double.infinity / 2,
                height: 200,
                child: GaugeScreen(
                  title: "MACD",
                  recommendation: signalSummaryMACD != null ? signalSummaryMACD.toLowerCase() : "",
                )
            ),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
            child: SizedBox(
                width: double.infinity / 2,
                height: 200,
                child: GaugeScreen(
                  title: "SMA",
                  recommendation: signalSummarySMA != null ? signalSummarySMA.toLowerCase() : "",
                )
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: SizedBox(
                width: double.infinity / 2,
                height: 200,
                child: GaugeScreen(
                  title: "Bollinger Bands",
                  recommendation: signalSummaryBollingerBands != null ? signalSummaryBollingerBands.toLowerCase() : "",
                )
            ),
          ),
        ],
      )
    ]
  );
}

Container itemCard(BuildContext context, Size size, {String? title, String? content, IconData? icons, Color? color}){
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: size.width / 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant, // adaptif
      border: Border.all(
        width: 0.3,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icons ?? CupertinoIcons.arrow_up_right, color:CustomColor.secondaryColor, size: 24),
            Text(title ?? "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(content ?? "0", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20))
      ],
    ),
  );
}

Container itemCardIndicatorsSMA(BuildContext context, size, {String? title, String? content, IconData? icons, Color? color, String? sma10, String? sma20, String? sma50, String? priceVsSMA50}){
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: size.width / 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant, // adaptif
      border: Border.all(
        width: 0.3,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icons ?? CupertinoIcons.arrow_up_right, color:CustomColor.secondaryColor, size: 24),
            const SizedBox(width: 5),
            Text(title ?? "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          ],
        ),
        Text("SMA 10: ${sma10 ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
        Text("SMA 20: ${sma20 ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        Text("SMA 50: ${sma50 ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        Text("Price vs SMA 50: ${priceVsSMA50 ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
      ],
    ),
  );
}

Container itemCardIndicatorsMACD(BuildContext context, Size size, {String? title, String? content, IconData? icons, Color? color, String? histogram, String? signalLine, String? macdLine}){
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: size.width / 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant, // adaptif
      border: Border.all(
        width: 0.3,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icons ?? CupertinoIcons.arrow_up_right, color:CustomColor.secondaryColor, size: 24),
            const SizedBox(width: 5),
            Text(title ?? "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          ],
        ),
        Text("MACD Line: ${macdLine ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
        Text("Signal Line: ${signalLine ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
        Text("Histogram: ${histogram ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
      ],
    ),
  );
}

Container itemCardIndicatorsBollingerBand(BuildContext context, Size size, {String? title, String? content, IconData? icons, Color? color, String? upper, String? middle, String? lower, String? pricePosition}){
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: size.width / 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant, // adaptif
      border: Border.all(
        width: 0.3,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icons ?? CupertinoIcons.arrow_up_right, color:CustomColor.secondaryColor, size: 24),
            const SizedBox(width: 5),
            Text(title ?? "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          ],
        ),
        Text("Upper: ${upper ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        Text("Middle: ${middle ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        Text("Lower: ${lower ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        Text("Price Position: ${pricePosition ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ],
    ),
  );
}

Container itemCardIndicatorsRSI(BuildContext context, Size size, {String? rsi, String? title, String? content, IconData? icons, Color? color}){
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: size.width / 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant, // adaptif
      border: Border.all(
        width: 0.3,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icons ?? CupertinoIcons.arrow_up_right, color:CustomColor.secondaryColor, size: 24),
            const SizedBox(width: 5),
            Text(title ?? "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          ],
        ),
        Text("RSI: ${rsi ?? "0"}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ],
    ),
  );
}