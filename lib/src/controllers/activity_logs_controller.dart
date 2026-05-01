import 'package:get/get.dart';
import 'package:rrfx/src/models/settings/activity_model.dart';
import 'package:rrfx/src/service/auth_service.dart';
// Pastikan import AuthService dan GlobalVariable kamu benar

class ActivityLogsController extends GetxController {
  // List untuk menyimpan log aktivitas
  var activityLogs = <ActivityLog>[].obs;
  AuthService authService = AuthService();

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var responseMessage = ''.obs;

  // Pagination State
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int rowsPerPage = 25;

  @override
  void onInit() {
    super.onInit();
    fetchActivityLogs();
  }

  /// Memanggil API untuk pertama kali atau Refresh
  Future<void> fetchActivityLogs({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      // Jangan langsung clear jika ingin efek 'pull to refresh' yang smooth, 
      // clear setelah data baru didapat.
    }

    try {
      isLoading.value = true;
      responseMessage.value = '';

      final result = await _executeRequest(currentPage.value);

      if (result['status'] == true) {
        final List rawData = result['response']['data'] ?? [];
        final List<ActivityLog> fetchedLogs = 
            rawData.map((e) => ActivityLog.fromJson(e)).toList();

        if (isRefresh) {
          activityLogs.assignAll(fetchedLogs);
        } else {
          activityLogs.assignAll(fetchedLogs);
        }

        // Cek pagination dari response
        final pagination = result['response']['pagination'];
        if (pagination != null) {
          if (activityLogs.length >= (pagination['total_rows'] ?? 0)) {
            hasMoreData.value = false;
          }
        }
      } else {
        responseMessage.value = result['message'] ?? "Gagal mengambil data";
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Memanggil API untuk Load More (Pagination)
  Future<void> loadMoreLogs() async {
    if (isMoreLoading.value || !hasMoreData.value) return;

    try {
      isMoreLoading.value = true;
      int nextPage = currentPage.value + 1;

      final result = await _executeRequest(nextPage);

      if (result['status'] == true) {
        final List rawData = result['response']['data'] ?? [];
        final List<ActivityLog> fetchedLogs = 
            rawData.map((e) => ActivityLog.fromJson(e)).toList();

        if (fetchedLogs.isEmpty) {
          hasMoreData.value = false;
        } else {
          activityLogs.addAll(fetchedLogs);
          currentPage.value = nextPage; // Update page jika sukses
        }

        final pagination = result['response']['pagination'];
        if (pagination != null && activityLogs.length >= (pagination['total_rows'] ?? 0)) {
          hasMoreData.value = false;
        }
      }
    } finally {
      isMoreLoading.value = false;
    }
  }

  /// Fungsi Request yang disesuaikan dengan AuthService kamu
  Future<Map<String, dynamic>> _executeRequest(int page) async {
    final String url = "/profile/activity?page=$page&rows=$rowsPerPage";
    return await authService.get(url);
  }
}