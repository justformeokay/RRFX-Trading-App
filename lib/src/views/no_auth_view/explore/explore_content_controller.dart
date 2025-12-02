import 'package:get/get.dart';

class ExploreContentController extends GetxController {
  RxBool isLoadingNews = false.obs;
  RxBool isLoadingAnalysis = false.obs;

  RxList<dynamic> news = <dynamic>[].obs;
  RxList<dynamic> analysis = <dynamic>[].obs;

  final String baseUrl = "https://gateway.rrfx.co.id/api/v1/contents/category/all";

  RxBool isLoadingPromotions = false.obs;
  RxList<dynamic> promotions = <dynamic>[].obs;

  Future<void> fetchPromotions() async {
    isLoadingPromotions.value = true;
    try {
      final response = await GetConnect().get(
        "https://gateway.rrfx.co.id/api/v1/contents/category/rewards?type=PROMOTION&limit=3&highlight=true",
      );

      promotions.value = response.body["data"]["list"] ?? [];
    } finally {
      isLoadingPromotions.value = false;
    }
  }


  Future<void> fetchNews() async {
    isLoadingNews.value = true;
    try {
      final response = await GetConnect().get(
        "$baseUrl?type=NEWS&limit=3",
      );

      news.value = response.body["data"]["list"] ?? [];
    } finally {
      isLoadingNews.value = false;
    }
  }

  Future<void> fetchMarketAnalysis() async {
    isLoadingAnalysis.value = true;
    try {
      final response = await GetConnect().get(
        "$baseUrl?type=MARKET_ANALYTIC&limit=3",
      );

      analysis.value = response.body["data"]["list"] ?? [];
    } finally {
      isLoadingAnalysis.value = false;
    }
  }
}
