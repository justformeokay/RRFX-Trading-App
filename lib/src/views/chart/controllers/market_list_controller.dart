import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/chart/models/symbol_group.dart';

class MarketListController extends GetxController {
  var groups = <SymbolGroup>[].obs;
  var favorites = <SymbolItem>[].obs;
  var isLoading = false.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  Future<void> fetchSymbols({String? loginID, String? accessToken, String? refreshToken}) async {
    if (loginID == null || accessToken == null) return;
    try {
      isLoading.value = true;
      final url = Uri.parse('${GlobalVariable.mainURL}/market/symbols-group?account=$loginID');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List response = data['response'];
        groups.value = response.map((e) => SymbolGroup.fromJson(e)).toList();
      } else {
        Get.snackbar('Error', 'Gagal mengambil data market');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Toggle favorit + simpan ke storage
  void toggleFavorite(SymbolItem item) {
    if (favorites.any((f) => f.symbol == item.symbol)) {
      favorites.removeWhere((f) => f.symbol == item.symbol);
    } else {
      favorites.add(item);
    }
    _saveFavorites();
  }

  /// 💾 Simpan ke lokal
  void _saveFavorites() {
    final favList = favorites.map((f) => f.toJson()).toList();
    box.write('favorites', favList);
  }

  /// 📦 Ambil dari lokal
  void _loadFavorites() {
    final stored = box.read<List>('favorites');
    if (stored != null) {
      favorites.value = stored.map((e) => SymbolItem.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }
}
