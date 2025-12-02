import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/markets/models/tick_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/market_group_model.dart';
import 'package:get_storage/get_storage.dart';

final supabase = Supabase.instance.client;

class MarketController extends GetxController {
  var isLoading = true.obs;

  /// Map symbol → TickData agar tidak duplikat dan update realtime
  final liveTicks = <String, TickData>{}.obs;
  RealtimeChannel? tickChannel;

  var allGroups = <MarketGroup>[].obs;
  var tabCategories = <String>['FAVORIT'].obs; 
  String? refreshToken;

  var favoriteSymbols = <MarketSymbol>[].obs;
  final GetStorage storage = GetStorage();
  static const FAVORITES_KEY = 'favorite_symbols';

  final Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  @override
  void onInit() {
    loadFavorites();
    isLoading.value = false;
    Future.delayed(Duration.zero, () async {
      refreshToken = await getRefreshToken();
    });

    super.onInit();
  }

  Future<String> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken') ?? "";
  }

  // === FAVORITE LOGIC ===
  void loadFavorites() {
    final List<dynamic>? storedList = storage.read(FAVORITES_KEY);
    if (storedList != null) {
      favoriteSymbols.assignAll(storedList.map((item) => MarketSymbol.fromLocalJson(item as Map<String, dynamic>)));
    }
  }

  void saveFavorites() {
    storage.write(FAVORITES_KEY, favoriteSymbols.map((s) => s.toJson()).toList());
  }

  void toggleFavorite(MarketSymbol symbol) {
    final isCurrentlyFavorite = isFavorite(symbol);
    if (isCurrentlyFavorite) {
      favoriteSymbols.removeWhere((s) => s.symbol == symbol.symbol);
    } else {
      final symbolWithGroup = MarketSymbol(
        symbol: symbol.symbol,
        symbolAlias: symbol.symbolAlias,
        contractSize: symbol.contractSize,
        spread: symbol.spread,
        digits: symbol.digits,
        trademode: symbol.trademode,
        volumeMin: symbol.volumeMin,
        volumeMax: symbol.volumeMax,
        groupName: symbol.groupName.isEmpty ? allGroups.firstWhereOrNull((g) => g.symbols.any((s) => s.symbol == symbol.symbol)) ?.name ?? '' : symbol.groupName,
      );
      favoriteSymbols.add(symbolWithGroup);
    }

    saveFavorites();
    favoriteSymbols.refresh();

    Get.snackbar('Favorit', isCurrentlyFavorite ? '${symbol.symbolAlias} dihapus dari Favorit' : '${symbol.symbolAlias} ditambahkan ke Favorit',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  bool isFavorite(MarketSymbol symbol) {
    return favoriteSymbols.any((s) => s.symbol == symbol.symbol);
  }

  void clearLocalStorage() {
    storage.erase();
    favoriteSymbols.clear();
    favoriteSymbols.refresh();
    Get.snackbar('Sesi berakhir', 'Data lokal (Favorit) telah dihapus.', snackPosition: SnackPosition.BOTTOM);
  }

  // === FETCH MARKET SYMBOLS ===
  void fetchSymbols({String? account, String? accessToken}) async {
    int maxReload = 0;
    try {
      isLoading(true);
      String url = '${GlobalVariable.mainURL}/market/symbols-group?account=$account';
      final response = await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cookie': 'PHPSESSID=h68no0nl0d77u8q3nh07s4orrv',
        },
      );

      if (response.statusCode == 300) {
        if (maxReload > 3) {
          throw Exception("Telah mencapai max reload, silakan login kembali");
        }
        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {'refresh_token': refreshToken ?? ""});
        accessToken = refreshTokenResponse['response']['access_token'];
        refreshToken = refreshTokenResponse['response']['refresh_token'];
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return fetchSymbols(accessToken: accessToken, account: account);
      }

      if (response.statusCode == 200) {
        final List<MarketGroup> groups = marketGroupFromJson(response.body);
        allGroups.assignAll(groups);
        final apiCategories = groups.map((g) => g.name.toUpperCase()).toList();
        tabCategories.assignAll(['FAVORIT', ...apiCategories]);
        subscribeToRealtimeTicks();
      } else {
        Get.log('Terjadi kesalahan: ${response.statusCode}');
      }
    } catch (e) {
      Get.log('Terjadi kesalahan: $e');
    } finally {
      isLoading(false);
    }
  }

  // === REALTIME LISTENER (VERSI AMAN) ===
  void subscribeToRealtimeTicks() {
    tickChannel?.unsubscribe();
    tickChannel = supabase.channel('public:mt5_ticks')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'mt5_ticks',
        callback: (payload) {
          final data = payload.newRecord;
          if (data.isEmpty == true || data['symbol'] == null) return;
          final tick = TickData.fromJson(data);
          liveTicks[tick.symbol] = tick;
          liveTicks.refresh();
        },
      )
      ..subscribe();
  }

  List<MarketSymbol> getSymbolsForCategory(String category) {
    if (category == 'FAVORIT') return favoriteSymbols;
    final group = allGroups.firstWhereOrNull((g) => g.name.toUpperCase() == category.toUpperCase());
    return group?.symbols.map((s) => MarketSymbol(
      symbol: s.symbol,
      symbolAlias: s.symbolAlias,
      contractSize: s.contractSize,
      spread: s.spread,
      digits: s.digits,
      trademode: s.trademode,
      volumeMin: s.volumeMin,
      volumeMax: s.volumeMax,
      groupName: group.name,
    )).toList() ?? [];
  }

  Future<Map<String, dynamic>> refreshingToken({required Map<String, dynamic> body}) async {
    try {
      http.Response response = await http.post(
        Uri.parse("${GlobalVariable.mainURL}/auth/refresh"),
        headers: headers,
        body: body,
      );
      Map<String, dynamic> refreshTokenResponse = jsonDecode(response.body);
      if (refreshTokenResponse['status'] != true) throw Exception("Session Expired, please re-login");
      if (!refreshTokenResponse.containsKey("response")) throw Exception("Invalid Response");
      if (!refreshTokenResponse['response'].containsKey("access_token") || !refreshTokenResponse['response'].containsKey("refresh_token")) throw Exception("Failed to refresh token, please re-login");
      return refreshTokenResponse;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void onClose() {
    tickChannel?.unsubscribe();
    super.onClose();
  }
}
