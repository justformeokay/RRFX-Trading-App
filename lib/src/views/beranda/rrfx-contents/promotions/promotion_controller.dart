import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/promotions/promotion_model.dart';

class PromotionController extends GetxController {
  final promotions = <PromotionModel>[].obs;
  final isLoading = false.obs;

  final dio = Dio(BaseOptions(
    baseUrl: "https://gateway.rrfx.co.id",
  ));

  @override
  void onInit() {
    super.onInit();
    fetchPromotions();
  }

  Future<void> fetchPromotions() async {
    try {
      isLoading(true);
      final response = await dio.get(
        "/api/v1/contents/category/rewards",
        queryParameters: {
          "type": "PROMOTION",
          "limit": 7,
          "highlight": true,
        },
      );

      final list = response.data["data"]["list"] as List;

      promotions.value =
          list.map((e) => PromotionModel.fromJson(e)).toList();
    } catch (e) {
      promotions.clear();
    } finally {
      isLoading(false);
    }
  }
}
