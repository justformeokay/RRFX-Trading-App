import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'market_analysis_detail_model.dart';

class MarketAnalysisDetailController extends GetxController {
  var isLoading = true.obs;
  var analysis = Rxn<MarketAnalysisDetailModel>();

  Future<void> fetchDetail(String slug) async {
    try {
      isLoading.value = true;

      final url = Uri.parse("https://gateway.rrfx.co.id/api/v1/contents/$slug");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        analysis.value = MarketAnalysisDetailModel.fromJson(data);
      } else {
        Get.snackbar("Error", "Failed to load market analysis");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
