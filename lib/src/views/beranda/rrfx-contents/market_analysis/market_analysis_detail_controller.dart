import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'market_analysis_detail_model.dart';

class MarketAnalysisDetailController extends GetxController {
  var isLoading = true.obs;
  var analysis = Rxn<MarketAnalysisDetailModel>();
  var errorMessage = Rxn<String>();
  var errorType = Rxn<String>(); // 'timeout', 'network', 'server', null

  Future<void> fetchDetail(String slug) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      errorType.value = null;

      final url = Uri.parse("https://gateway.rrfx.co.id/api/v1/contents/$slug");
      
      // Set timeout 15 detik
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout - koneksi lambat atau server tidak merespons');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        analysis.value = MarketAnalysisDetailModel.fromJson(data);
        errorMessage.value = null;
        errorType.value = null;
      } else {
        errorType.value = 'server';
        errorMessage.value = 'Server mengalami gangguan (${response.statusCode})';
      }
    } on TimeoutException catch (e) {
      errorType.value = 'timeout';
      errorMessage.value = e.message;
      Get.log("❌ [MarketAnalysis] Timeout error: $e");
    } on SocketException catch (e) {
      errorType.value = 'network';
      errorMessage.value = 'Koneksi internet terputus atau tidak stabil';
      Get.log("❌ [MarketAnalysis] Network error: $e");
    } on FormatException catch (e) {
      errorType.value = 'server';
      errorMessage.value = 'Gagal memproses data dari server';
      Get.log("❌ [MarketAnalysis] Format error: $e");
    } catch (e) {
      errorType.value = 'network';
      errorMessage.value = e.toString().contains('Connection') 
          ? 'Koneksi internet terputus'
          : 'Terjadi kesalahan saat memuat data';
      Get.log("❌ [MarketAnalysis] Unexpected error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry fetch data
  void retry(String slug) {
    fetchDetail(slug);
  }
}
