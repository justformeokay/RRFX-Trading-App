// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:rrfx/src/helpers/variables/global_variables.dart';
// import 'package:rrfx/src/views/markets/models/market_group_model.dart';
// import 'package:rrfx/src/views/markets/models/tick_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// final supabase = Supabase.instance.client;

// class MarketsNoAuthController extends GetxController {
//   var isLoading = true.obs;
//   final liveTicks = <String, TickData>{}.obs;
//   RealtimeChannel? tickChannel;
//   var tabCategories = <String>['Komoditi', 'Forex', 'Index'].obs; 
//   var allGroups = <MarketGroup>[].obs;

//   // === FETCH MARKET SYMBOLS ===
//   void fetchSymbols() async {
//     try {
//       isLoading(true);
//       String url = '${GlobalVariable.mainURL}/public/symbol-group';
//       final response = await http.get(Uri.parse(url),
//         headers: {
//           'Cookie': 'PHPSESSID=h68no0nl0d77u8q3nh07s4orrv',
//           'x-api-key': GlobalVariable.x_api_key,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<MarketGroup> groups = marketGroupFromJson(response.body);
//         allGroups.assignAll(groups);
//         groups.map((g) => g.name.toUpperCase()).toList();
//         subscribeToRealtimeTicks();
//       } else {
//         Get.log('Terjadi kesalahan: ${response.statusCode}');
//       }
//     } catch (e) {
//       Get.log('Terjadi kesalahan: $e');
//     } finally {
//       isLoading(false);
//     }
//   }

//   // === REALTIME LISTENER (VERSI AMAN) ===
//   void subscribeToRealtimeTicks() {
//     tickChannel?.unsubscribe();
//     tickChannel = supabase.channel('public:mt5_ticks')
//       ..onPostgresChanges(
//         event: PostgresChangeEvent.insert,
//         schema: 'public',
//         table: 'mt5_ticks',
//         callback: (payload) {
//           final data = payload.newRecord;
//           if (data.isEmpty == true || data['symbol'] == null) return;
//           final tick = TickData.fromJson(data);
//           liveTicks[tick.symbol] = tick;
//           liveTicks.refresh();
//         },
//       )
//       ..subscribe();
//   }

//   List<MarketSymbol> getSymbolsForCategory(String category) {
//     final group = allGroups.firstWhereOrNull((g) => g.name.toUpperCase() == category.toUpperCase());
//     return group?.symbols.map((s) => MarketSymbol(
//       symbol: s.symbol,
//       symbolAlias: s.symbolAlias,
//       contractSize: s.contractSize,
//       spread: s.spread,
//       digits: s.digits,
//       trademode: s.trademode,
//       volumeMin: s.volumeMin,
//       volumeMax: s.volumeMax,
//       groupName: group.name,
//     )).toList() ?? [];
//   }

//   @override
//   void onClose() {
//     tickChannel?.unsubscribe();
//     super.onClose();
//   }
// }
