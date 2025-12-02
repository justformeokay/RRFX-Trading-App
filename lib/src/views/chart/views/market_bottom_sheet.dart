import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'package:rrfx/src/views/chart/controllers/market_list_controller.dart';
import 'package:rrfx/src/views/chart/models/symbol_group.dart';
import 'package:rrfx/src/views/trade/deriv_chart_page.dart';

Future<void> showMarketBottomSheet(BuildContext context) async {
  final controller = Get.put(MarketListController());
  final chartController = Get.find<ChartControllers>(); // ✅ akses chart controller

  if (controller.groups.isEmpty) {
    final loginID = chartController.accountController.selectedAccount.value?.login;
    final accessToken = await chartController.getAccessToken();
    controller.fetchSymbols(loginID: loginID, accessToken: accessToken);
  }

  Get.bottomSheet(
    Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: Get.theme.bottomSheetTheme.backgroundColor ?? Get.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TabBar(
                labelColor: CustomColor.secondaryColor,
                unselectedLabelColor: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
                indicatorColor: CustomColor.secondaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: Get.theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                dividerColor: Get.theme.dividerColor.withOpacity(0.2),
                tabs: [
                  Tab(text: "Favorit"),
                  Tab(text: "Komoditi"),
                  Tab(text: "Forex"),
                  Tab(text: "Index"),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: CustomColor.secondaryColor),
                  );
                }

                final komoditi = controller.groups.firstWhereOrNull((g) => g.name == "KOMODITI");
                final forex = controller.groups.firstWhereOrNull((g) => g.name == "FOREX");
                final index = controller.groups.firstWhereOrNull((g) => g.name == "INDEX");

                return TabBarView(
                  children: [
                    buildSymbolList(controller.favorites, controller, chartController, isFavTab: true),
                    buildSymbolList(komoditi?.symbols ?? [], controller, chartController),
                    buildSymbolList(forex?.symbols ?? [], controller, chartController),
                    buildSymbolList(index?.symbols ?? [], controller, chartController),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showMarketBottomSheetForAccountInfo(BuildContext context, {String? loginID, String? balance}) async {
  final controller = Get.put(MarketListController());
  final chartController = Get.put(ChartControllers()); // ✅ akses chart controller

  if (controller.groups.isEmpty) {
    final accessToken = await chartController.getAccessToken();
    controller.fetchSymbols(loginID: loginID, accessToken: accessToken);
  }

  Get.bottomSheet(
    Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: Get.theme.bottomSheetTheme.backgroundColor ?? Get.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TabBar(
                labelColor: CustomColor.secondaryColor,
                unselectedLabelColor: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
                indicatorColor: CustomColor.secondaryColor,
                dividerColor: Get.theme.dividerColor.withOpacity(0.2),
                tabs: [
                  Tab(text: "Favorit"),
                  Tab(text: "Komoditi"),
                  Tab(text: "Forex"),
                  Tab(text: "Index"),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: CustomColor.secondaryColor),
                  );
                }

                final komoditi = controller.groups.firstWhereOrNull((g) => g.name == "KOMODITI");
                final forex = controller.groups.firstWhereOrNull((g) => g.name == "FOREX");
                final index = controller.groups.firstWhereOrNull((g) => g.name == "INDEX");

                return TabBarView(
                  children: [
                    buildSymbolListForAccountInformation(controller.favorites, controller, chartController, isFavTab: true, loginID: loginID, balance: balance),
                    buildSymbolListForAccountInformation(komoditi?.symbols ?? [], controller, chartController, loginID: loginID, balance: balance),
                    buildSymbolListForAccountInformation(forex?.symbols ?? [], controller, chartController, loginID: loginID, balance: balance),
                    buildSymbolListForAccountInformation(index?.symbols ?? [], controller, chartController, loginID: loginID, balance: balance),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildSymbolList(
  List<SymbolItem> items,
  MarketListController controller,
  ChartControllers chartController, {
  bool isFavTab = false,
}) {
  if (items.isEmpty) {
    return const Center(
      child: Text(
        'Tidak ada data',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  return ListView.separated(
    itemCount: items.length,
    separatorBuilder: (_, __) => Divider(color: Get.theme.dividerColor.withOpacity(0.2)),
    itemBuilder: (context, index) {
      final item = items[index];
      return Obx(() {
        final isFav = controller.favorites.any((f) => f.symbol == item.symbol);
        final isSelected = chartController.selectedMarket.value == item.symbol;
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: FlagPair(marketName: item.symbol, size: 40.0),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.alias,
                    style: TextStyle(
                      color: Get.theme.textTheme.bodyLarge!.color,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: CustomColor.secondaryColor, size: 20),
              ],
            ),
            subtitle: Text(
              "Spread: ${item.spread} | Digit: ${item.digits}",
              style: TextStyle(color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.6), fontSize: 13),
            ),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav 
                  ? Get.theme.colorScheme.primary 
                  : Get.theme.iconTheme.color!.withOpacity(0.5),
              ),
              onPressed: () => controller.toggleFavorite(item),
            ),
            onTap: () async {
              chartController.selectedMarket.value = item.symbol;
              Get.back();
              final loginID = chartController.accountController.selectedAccount.value?.login;
              final accessToken = await chartController.getAccessToken();
              if (loginID == null || accessToken == null) {
                Get.snackbar("Error", "Login atau token tidak ditemukan");
                return;
              }

              final resultCandle = await chartController
                  .tradingController
                  .getMarketForDerivChartV3(
                    loginID: loginID,
                    symbol: chartController.selectedMarket.value,
                    timeframe: chartController.timeFrame.value,
                  );

              if (resultCandle) {
                chartController.currentPrice.value =
                    chartController.tradingController.ohlcDataDeriv.last.close;
              }

              Get.snackbar(
                "Market Diganti",
                "Menampilkan chart ${item.alias}",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        );
      });
    },
  );
}


Widget buildSymbolListForAccountInformation(
  List<SymbolItem> items,
  MarketListController controller,
  ChartControllers chartController, {
  bool isFavTab = false,
  String? loginID,
  String? balance
}) {
  if (items.isEmpty) {
    return const Center(
      child: Text(
        'Tidak ada data',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  return ListView.separated(
    itemCount: items.length,
    separatorBuilder: (_, __) => Divider(color: Get.theme.dividerColor.withOpacity(0.2))
,
    itemBuilder: (context, index) {
      final item = items[index];
      return Obx(() {
        final isFav = controller.favorites.any((f) => f.symbol == item.symbol);

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: FlagPair(marketName: item.symbol, size: 40.0),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.alias,
                    style: TextStyle(
                      color: Get.theme.textTheme.bodyLarge!.color,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              "Spread: ${item.spread} | Digit: ${item.digits}",
              style: TextStyle(color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.6), fontSize: 13),
            ),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav 
    ? Get.theme.colorScheme.primary 
    : Get.theme.iconTheme.color!.withOpacity(0.5),

              ),
              onPressed: () => controller.toggleFavorite(item),
            ),
            onTap: () async {
              if(loginID != null){
                Get.back();
                Get.to(() => DerivChartPage(login: int.parse(loginID), marketName: item.symbol, balance: balance));
                return;
              }
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Login atau token tidak ditemukan");
            },
          ),
        );
      });
    },
  );
}