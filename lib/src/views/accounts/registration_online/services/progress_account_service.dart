import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/registration_online/models/progress_account_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressAccountService extends GetxService {
  final String baseUrl = GlobalVariable.mainURL;
  String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMTc2MTkwMzMxNiIsInR5cGUiOiJhY2Nlc3MiLCJleHAiOjE3NjIyMjQ0NDl9.Mu35S+heaO19YiMoTIQ1bC2VP50Qt83vSWYDdjsNU9s=';

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? resultToken = prefs.getString('accessToken');
    if(resultToken != null){
      token = resultToken;
    }
    Get.log("Token => $resultToken");
    return resultToken ?? '';
  }

  Future<ProgressAccountResponse?> getProgressAccount() async {
    final url = Uri.parse('$baseUrl/regol/progressAccount');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProgressAccountResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
