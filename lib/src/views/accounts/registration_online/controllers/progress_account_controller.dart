import 'package:get/get.dart';
import 'package:rrfx/src/views/accounts/registration_online/models/progress_account_response.dart';
import 'package:rrfx/src/views/accounts/registration_online/services/progress_account_service.dart';

class ProgressAccountController extends GetxController {
  final ProgressAccountService _service = ProgressAccountService();
  var isLoading = false.obs;
  var progressData = Rxn<ProgressAccountResponse>();
  var tipeIdentitasList = <String>[].obs;
  var hubunganDaruratList = <String>[].obs;

  @override
  void onInit() {
    _service.getToken();
    super.onInit();
  }

  Future<void> fetchProgressAccount() async {
    try {
      isLoading.value = true;
      final data = await _service.getProgressAccount();
      if (data?.status == true) {
        progressData.value = data;
        final tipeList = data?.data?.tipeIdentitas ?? [];
        tipeIdentitasList.assignAll(tipeList);
        final list = data?.data?.jenisHubunganPihakDarurat ?? [];
        hubunganDaruratList.assignAll(list);
      } else {
        Get.snackbar('Error', 'Gagal memuat data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
