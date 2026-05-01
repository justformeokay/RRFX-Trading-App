import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rrfx/src/models/settings/activity_model.dart';
import 'package:rrfx/src/service/auth_service.dart';

class ActivityLogsController extends GetxController {
  // List untuk menyimpan log aktivitas
  var activityLogs = <ActivityLog>[].obs;
  AuthService authService = AuthService();
  final GetStorage storage = GetStorage();

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var responseMessage = ''.obs;
  var loadMoreError = ''.obs;  // ← Error tracking untuk load more

  // Pagination State
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var failedPage = 0.obs;  // ← Track which page failed
  final int rowsPerPage = 20;  // ← Optimized dari 25

  @override
  void onInit() {
    super.onInit();
    _restoreCachedState();
    fetchActivityLogs();
  }

  /// Restore pagination state dari cache
  void _restoreCachedState() {
    try {
      final cachedPage = storage.read('activity_current_page') ?? 1;
      final cachedHasMore = storage.read('activity_has_more') ?? true;
      currentPage.value = cachedPage;
      hasMoreData.value = cachedHasMore;
    } catch (e) {
      print('⚠️ [ActivityLogs] Error restoring cache: $e');
    }
  }

  /// Cache pagination state untuk reopen app
  void _cacheState() {
    try {
      storage.write('activity_current_page', currentPage.value);
      storage.write('activity_has_more', hasMoreData.value);
    } catch (e) {
      print('⚠️ [ActivityLogs] Error caching state: $e');
    }
  }

  /// Memanggil API untuk pertama kali atau Refresh
  Future<void> fetchActivityLogs({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      loadMoreError.value = '';  // Clear error state
      failedPage.value = 0;
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
        _cacheState();  // ← Cache state setelah sukses
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
      loadMoreError.value = '';  // Clear previous error
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
          failedPage.value = 0;  // Clear failed page tracking
        }

        final pagination = result['response']['pagination'];
        if (pagination != null && activityLogs.length >= (pagination['total_rows'] ?? 0)) {
          hasMoreData.value = false;
        }
        _cacheState();  // ← Cache state setelah sukses
      } else {
        // Set error state untuk retry
        loadMoreError.value = result['message'] ?? "Gagal memuat data lebih banyak";
        failedPage.value = nextPage;  // Track which page failed
      }
    } catch (e) {
      loadMoreError.value = "Kesalahan jaringan: ${e.toString()}";
      failedPage.value = currentPage.value + 1;
    } finally {
      isMoreLoading.value = false;
    }
  }

  /// Retry load more untuk page yang gagal
  Future<void> retryLoadMore() async {
    if (failedPage.value > 0) {
      print('🔄 [ActivityLogs] Retrying load more for page: ${failedPage.value}');
      await loadMoreLogs();
    }
  }

  /// Fungsi Request yang disesuaikan dengan AuthService kamu
  Future<Map<String, dynamic>> _executeRequest(int page) async {
    final String url = "/profile/activity?page=$page&rows=$rowsPerPage";
    return await authService.get(url);
  }
}