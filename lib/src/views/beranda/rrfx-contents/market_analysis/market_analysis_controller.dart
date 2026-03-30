import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'market_analysis_model.dart';

enum MarketAnalysisErrorType {
  none,
  noConnection,
  timeout,
  serverError,
  unknown,
}

class MarketAnalysisController extends GetxController {
  final Dio _dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isLoadMore = false.obs;
  Rx<MarketAnalysisErrorType> errorType = Rx<MarketAnalysisErrorType>(MarketAnalysisErrorType.none);
  RxString errorMessage = ''.obs;

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
      errorType.value = MarketAnalysisErrorType.none;
      errorMessage.value = '';

      // Check connection first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        errorType.value = MarketAnalysisErrorType.noConnection;
        errorMessage.value = 'Tidak ada koneksi internet';
        isLoading.value = false;
        return;
      }

      final res = await _dio
          .get(
            "${GlobalVariable.gatewayURL}/api/v1/contents/category/all",
            queryParameters: {
              "type": "MARKET_ANALYTIC",
              "limit": limit,
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      final List data = res.data["data"]["list"];
      final options = res.data["data"]["options"];

      canLoadMore = options["is_load_more"] ?? false;

      analysis.value = data.map((e) => MarketAnalysisModel.fromJson(e)).toList();
      errorType.value = MarketAnalysisErrorType.none;
    } on TimeoutException catch (_) {
      errorType.value = MarketAnalysisErrorType.timeout;
      errorMessage.value = 'Koneksi terlalu lambat (> 15 detik)';
    } catch (e) {
      errorType.value = MarketAnalysisErrorType.serverError;
      errorMessage.value = 'Terjadi kesalahan';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    if (isLoadMore.value || !canLoadMore) return;

    try {
      isLoadMore.value = true;

      // Check connection first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return;
      }

      final res = await _dio
          .get(
            "${GlobalVariable.gatewayURL}/api/v1/contents/category/all",
            queryParameters: {
              "type": "MARKET_ANALYTIC",
              "limit": limit,
              "skip": analysis.length,
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      final List data = res.data["data"]["list"];
      final options = res.data["data"]["options"];

      canLoadMore = options["is_load_more"] ?? false;

      analysis.addAll(
        data.map((e) => MarketAnalysisModel.fromJson(e)).toList(),
      );
    } catch (e) {
      // Silent fail for load more
    } finally {
      isLoadMore.value = false;
    }
  }

  void retryFetch() {
    fetchMarketAnalysis();
  }
}
