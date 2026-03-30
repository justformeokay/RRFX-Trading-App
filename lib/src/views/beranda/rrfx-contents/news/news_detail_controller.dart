import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'news_detail_model.dart';

enum NewsErrorType {
  none,
  noConnection,
  timeout,
  serverError,
  notFound,
  unknown,
}

class NewsDetailController extends GetxController {
  var isLoading = true.obs;
  var detail = Rxn<NewsDetailModel>();
  var errorType = Rx<NewsErrorType>(NewsErrorType.none);
  var errorMessage = ''.obs;

  Future<void> fetchDetail(String slug) async {
    try {
      isLoading.value = true;
      errorType.value = NewsErrorType.none;
      errorMessage.value = '';

      // Check connection first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        errorType.value = NewsErrorType.noConnection;
        errorMessage.value = 'Tidak ada koneksi internet';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse("${GlobalVariable.gatewayURL}/api/v1/contents/$slug");

      // Add timeout of 10 seconds
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        detail.value = NewsDetailModel.fromJson(json["data"]);
        errorType.value = NewsErrorType.none;
      } else if (response.statusCode == 404) {
        errorType.value = NewsErrorType.notFound;
        errorMessage.value = 'Berita tidak ditemukan';
      } else {
        errorType.value = NewsErrorType.serverError;
        errorMessage.value = 'Gagal memuat data (${response.statusCode})';
      }
    } on TimeoutException catch (_) {
      errorType.value = NewsErrorType.timeout;
      errorMessage.value = 'Koneksi terlalu lambat (> 10 detik)';
    } on SocketException catch (_) {
      errorType.value = NewsErrorType.noConnection;
      errorMessage.value = 'Tidak dapat terhubung ke server';
    } catch (e) {
      errorType.value = NewsErrorType.unknown;
      errorMessage.value = 'Terjadi kesalahan';
      print('Error fetching news detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retryFetch(String slug) {
    fetchDetail(slug);
  }
}
