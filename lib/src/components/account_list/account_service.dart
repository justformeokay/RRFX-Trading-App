import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/service/account_credentials_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_model.dart';

class AccountService extends GetxController{
  final _authService = Get.find<AuthService>();
  RxString responseMessage = ''.obs;
  static String? _pendingInvalidAccount;
  static String get _mt5ConnectBase => GlobalVariable.tradingApiBase;

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
    
    if(result['status']) {
      return true;
    }
    
    // ⚠️ FALLBACK: Jika API /market/account/connect gagal,
    // coba direct connection ke MT5 server menggunakan connectMT5
    print('⚠️ [AccountService] API /market/account/connect gagal, mencoba direct MT5 connection...');
    try {
      // Ambil kredensial akun dari cache
      final credential = AccountCredentialsService.getCredentialByLogin(loginNumber ?? '');
      
      if (credential == null) {
        print('❌ [AccountService] Credential tidak ditemukan untuk login: $loginNumber');
        return false;
      }
      
      final password = credential['password']?.toString() ?? '';
      final host = credential['server']?.toString() ?? '';
      
      if (password.isEmpty || host.isEmpty) {
        print('❌ [AccountService] Password atau host kosong untuk login: $loginNumber');
        return false;
      }
      
      // Direct call ke MT5 Connect API
      final token = await connectMT5(
        user: loginNumber ?? '',
        password: password,
        host: host,
      );
      
      if (token != null && token.isNotEmpty) {
        print('✅ [AccountService] Direct MT5 connect BERHASIL untuk login: $loginNumber, token: $token');
        responseMessage.value = 'Berhasil terhubung ke MetaTrader 5';
        return true;
      }
    } catch (e) {
      print('❌ [AccountService] Direct MT5 connect gagal: $e');
    }
    
    return false;
  }

  static Future<String?> connectMT5({
    required String user,
    required String password,
    required String host,
  }) async {
    print("🔗 [AcctCreds] Connecting MT5 for user $user at host $host...");
    final uri = Uri.parse(
      '$_mt5ConnectBase/Connect'
      '?user=$user'
      '&password=${Uri.encodeComponent(password)}'
      '&host=$host'
      '&port=443'
      '&connectTimeoutSeconds=30'
      '&downloadOrderHistory=false'
      '&reconnectOnSymbolUpdate=false',
    );

    // Get.log('🔗 [AcctCreds] Connecting MT5 for user $user...');

    final response = await http.get(
      uri,
      headers: {'accept': 'text/plain'},
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('MT5 Connect timeout'),
    );

    if (response.statusCode == 200) {
      final token = response.body.trim();
      // Validate token format (UUID-like)
      if (token.isNotEmpty && !token.startsWith('{')) {
        return token;
      }
      // Get.log('⚠️ [AcctCreds] Response bukan token valid: $token');
      return null;
    } else {
      // Get.log('❌ [AcctCreds] MT5 Connect error ${response.statusCode}: ${response.body}');

      // Parse error response untuk cek INVALID_ACCOUNT
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("🔍 [AcctCreds] MT5 Connect error response: $data");
        if (data['code'] == 'INVALID_ACCOUNT') {
          // Get.log('🔒 [AcctCreds] INVALID_ACCOUNT untuk user $user → simpan flag');
          _pendingInvalidAccount = user;
        }
      } catch (_) {}

      return null;
    }
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