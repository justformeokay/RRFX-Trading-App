import 'dart:async';
import 'package:get/get.dart';
import 'package:rrfx/src/views/transactions/models/account_model.dart';
import 'package:rrfx/src/views/transactions/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepController extends GetxController {
  var isLoading = false.obs;
  var selectedAccountType = 'real'.obs; // real/demo
  var cDDTypesList = ['Standart', 'Sederhana'].obs;
  var typeOfCDDList = ['SPA', 'Multilateral'].obs;
  var selectedCDD = 'Standart'.obs;
  var selectedTypeOfCDD = 'SPA'.obs;
  var accounts = <AccountModel>[].obs;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    return token;
  } 

  String? token;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchAccounts() async {
    await getToken().then((accessToken){
      token = "Bearer $accessToken";
    });
    try {
      if(token == null){
        Get.log('Token => $token');
        return;
      }
      Get.log('Token => $token');
      isLoading(true);
      final response = await ApiService.post('account/info',
        headers: {
          'Authorization': token!,
        },
      );
      if (response['status']) {
        final real = (response['response']['real'] as List)
            .map((e) => AccountModel.fromJson(e))
            .toList();
        final demo = (response['response']['demo'] as List)
            .map((e) => AccountModel.fromJson(e))
            .toList();
        // 1. Gabungkan kedua list menggunakan spread operator (...)
        final allAccounts = [...real, ...demo];

        // 2. Masukkan list yang sudah digabung ke 'accounts'
        accounts.assignAll(allAccounts);
      }
    } finally {
      isLoading(false);
    }
  }
}
