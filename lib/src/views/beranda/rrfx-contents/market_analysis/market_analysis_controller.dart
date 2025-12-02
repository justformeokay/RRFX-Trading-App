import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'market_analysis_model.dart';

class MarketAnalysisController extends GetxController {
  final Dio _dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isLoadMore = false.obs;

  RxList<MarketAnalysisModel> analysis = <MarketAnalysisModel>[].obs;

  int limit = 7; // default API limit
  bool canLoadMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchMarketAnalysis();
  }

  Future<void> fetchMarketAnalysis() async {
    try {
      isLoading.value = true;

      final res = await _dio.get(
        "https://gateway.rrfx.co.id/api/v1/contents/category/all",
        queryParameters: {
          "type": "MARKET_ANALYTIC",
          "limit": limit,
        },
      );

      final List data = res.data["data"]["list"];
      final options = res.data["data"]["options"];

      canLoadMore = options["is_load_more"] ?? false;

      analysis.value = data.map((e) => MarketAnalysisModel.fromJson(e)).toList();
    } catch (e) {
      print("Error fetch market analytic: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    if (isLoadMore.value || !canLoadMore) return;

    try {
      isLoadMore.value = true;

      final res = await _dio.get(
        "https://gateway.rrfx.co.id/api/v1/contents/category/all",
        queryParameters: {
          "type": "MARKET_ANALYTIC",
          "limit": limit,
          "skip": analysis.length,
        },
      );

      final List data = res.data["data"]["list"];
      final options = res.data["data"]["options"];

      canLoadMore = options["is_load_more"] ?? false;

      analysis.addAll(
        data.map((e) => MarketAnalysisModel.fromJson(e)).toList(),
      );
    } catch (e) {
      print("Error fetchMore market analytic: $e");
    } finally {
      isLoadMore.value = false;
    }
  }
}
