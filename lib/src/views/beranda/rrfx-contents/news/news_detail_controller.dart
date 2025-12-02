import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'news_detail_model.dart';

class NewsDetailController extends GetxController {
  var isLoading = true.obs;
  var detail = Rxn<NewsDetailModel>();

  Future<void> fetchDetail(String slug) async {
    try {
      isLoading.value = true;

      final url = Uri.parse("https://gateway.rrfx.co.id/api/v1/contents/$slug");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        detail.value = NewsDetailModel.fromJson(json["data"]);
      } else {
        Get.snackbar("Error", "Failed to load news detail");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
