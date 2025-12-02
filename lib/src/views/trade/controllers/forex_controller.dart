// forex_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'dart:convert';

import 'package:rrfx/src/views/trade/models/forex_symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForexController extends GetxController {
  RxBool isLoading = true.obs;
  RxList symbolList = <ForexSymbol>[].obs;
  RxString responseMessage = "".obs;
  RxList filteredSymbolList = <ForexSymbol>[].obs;
  RxString selectedCategory = 'Semua'.obs;

  final categories = ['Semua', 'forex', 'commodities', 'index'];

  @override
  void onInit() {
    fetchSymbols();
    super.onInit();
  }

  void fetchSymbols() async {
    try {
      isLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if(accessToken == null){
        isLoading.value = false;
        responseMessage.value = "Gagal mendapatkan market";
        return;
      }
      String url = '${GlobalVariable.mainURL}/market/symbols?account=389558';
      final response = await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cookie': 'PHPSESSID=7i23uohic8gqog097qv99onfnt',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<ForexSymbol> symbols = List<ForexSymbol>.from(jsonResponse['response'].map((x) => ForexSymbol.fromJson(x)));
        symbolList.assignAll(symbols);
        filterSymbols(selectedCategory.value); // Terapkan filter awal
      } else {
        AppSnackbar.error('Gagal memuat data market. Mohon gunakan aplikasi Metatrader 5 untuk trading.');
      }
    } catch (e) {
      Get.log(e.toString());
    } finally {
        isLoading(false);
    }
  }

  void filterSymbols(String category) {
    selectedCategory.value = category;
    if (category == 'Semua') {
        filteredSymbolList.assignAll(symbolList);
    } else {
        filteredSymbolList.assignAll(
            symbolList.where((symbol) => symbol.category == category).toList()
        );
    }
  }
}