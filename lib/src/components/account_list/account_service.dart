import 'package:get/get.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_model.dart';

class AccountService extends GetxController{
  final _authService = Get.find<AuthService>();
  RxString responseMessage = ''.obs;

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if(accessToken == null){
      return "";
    }
    return accessToken;
  }

  Future<AccountModel> fetchAccountInfo({String? accessToken}) async {
    Map<String, dynamic> result = await _authService.get('/account/info');
    final errorMessage = result['message'] ?? 'Gagal mengambil data akun.';
    if(!result['status']) {
      throw Exception(errorMessage);
    }
    return AccountModel.fromJson(result);
  }

  Future<bool> connectingAccountToMeta5({String? loginNumber}) async {
    final body = {
      'account': loginNumber,
    };
    Map<String, dynamic> result = await _authService.post('/market/account/connect', body);
    print(result);
    responseMessage.value = result['message'] ?? 'Invalid account credentials.';
    if(!result['status']) {
      return false;
    }
    return true;
  }

  Future<bool> changePasswordMeta5({String? loginNumber, String? newPassword, String? otp}) async {
    final body = {
      'account': loginNumber,
      'password': newPassword,
      // 'otp': otp
    };
    Map<String, dynamic> result = await _authService.post('/market/account/update', body);
    responseMessage.value = result['message'] ?? 'Invalid account credentials.';
    print(responseMessage.value);
    if(!result['status']) {
      return false;
    }
    return true;
  }

  Future<bool> sendOTPChangePasswordMeta() async {
    Map<String, dynamic> result = await _authService.post('/market/account/update-otp', {});
    responseMessage.value = result['message'] ?? 'Invalid account credentials.';
    if(!result['status']) {
      return false;
    }
    return true;
  }
}