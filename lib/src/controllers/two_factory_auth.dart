import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/models/auth/personal_model.dart';

class TwoFactoryAuth extends GetxController{
  RxBool isLoading = false.obs;
  RxString accessToken = "".obs;
  RxString refreshToken = "".obs;
  RxString responseMessage = "".obs;
  Rxn<PersonalModels> personalModel = Rxn<PersonalModels>();

  /// Refresh Token API
  Future<bool> refreshTokenizer() async {
    try {
      isLoading(true);
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/refresh")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'refresh_token': refreshToken.value,
        },
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      if (response.statusCode == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        accessToken(result['response']['access_token']);
        refreshToken(result['response']['refresh_token']);
        preferences.setString('refreshToken', result['response']['refresh_token']);
        preferences.setString('accessToken', result['response']['access_token']);
        responseMessage.value = result['message'];
        return true;
      }
      responseMessage.value = result['message'];
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }
}