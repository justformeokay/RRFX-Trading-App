import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/registration_online/models/new_product_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController extends GetxController {
  var isLoading = false.obs;
  var groupedProducts = <String, List<Product>>{}.obs;
  var availableRates = <String>[].obs;
  var selectedRate = ''.obs;
  var selectedProduct = Rxn<Product>();
  RxString komisiSelected = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) return;

      final response = await http.get(
        Uri.parse('${GlobalVariable.mainURL}/regol/product'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['response'] is List) {
          final responseList = data['response'] as List;
          final Map<String, List<Product>> grouped = {};
          final Set<String> rateSet = {};

          for (var item in responseList) {
            final type = item['type'] ?? '';
            final List productsJson = item['products'] ?? [];

            final List<Product> productList =
                productsJson.map((e) => Product.fromJson(e)).toList();

            grouped[type] = productList;
            rateSet.addAll(productList.map((e) => e.rate));
          }

          groupedProducts.assignAll(grouped);
          availableRates.assignAll(rateSet.toList());

          // Pilih rate pertama secara otomatis
          if (availableRates.isNotEmpty) {
            selectedRate.value = availableRates.first;
          }
        }
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Produk terfilter sesuai rate yang dipilih
  Map<String, List<Product>> get filteredGroupedProducts {
    if (selectedRate.value.isEmpty) return {};
    final Map<String, List<Product>> filtered = {};

    groupedProducts.forEach((type, products) {
      final filteredList =
          products.where((p) => p.rate == selectedRate.value).toList();
      if (filteredList.isNotEmpty) filtered[type] = filteredList;
    });

    return filtered;
  }
}
