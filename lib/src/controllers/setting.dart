import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/helpers/formatters/deposit_withdraw_prefix.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/models/settings/admin_bank_model.dart';
import 'package:rrfx/src/models/settings/user_bank_model.dart';
import 'package:rrfx/src/models/utilities/list_bank_user.dart';
import 'package:rrfx/src/service/auth_service.dart';

class SettingController extends GetxController{
  RxBool isLoading = false.obs;
  RxBool isLoadingOTP = false.obs;
  AuthService authService = AuthService();
  RxString responseMessage = "".obs;
  Rxn<UserBankModel> userBankModel = Rxn<UserBankModel>();
  Rxn<ListBankUserV2> userBankModelV2 = Rxn<ListBankUserV2>();
  Rxn<BankAdminModel> adminBankModel = Rxn<BankAdminModel>();


  // Pernataan Pailit
  Future<bool> getUserBank() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("bank/list");
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      userBankModel(UserBankModel.fromJson(result));
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> getUserBankV2() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("/bank/list");

      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      userBankModelV2(ListBankUserV2.fromJson(result));
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }



  // Pernataan Pailit
  Future<bool> editBank(
    {
      String? bankID,
      String? currencyType,
      String? bankName,
      String? owner,
      String? branch,
      String? type,
      String? number
    }
  ) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("bank/update", {
        'bank_id': bankID,
        'currency': currencyType,
        'bank_name': bankName,
        'bank_branch': branch,
        'bank_holder': owner,
        'type': type,
        'account': number
      });

      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      getUserBank();
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Pernataan Pailit
  Future<bool> getAdminBank() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("transaction/bank-admin?type_news");
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      adminBankModel(BankAdminModel.fromJson(result));
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Pernataan Pailit
  Future<bool> deposit({
    String? bankAdminID,
    String? bankUserID,
    String? accountID,
    String? amount,
    String? key,
    String? imageURL
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = {};
      Map<String, String> body = {
        'account': accountID!,
        'amount': amount!,
        'bank_user': bankUserID!,
        'bank_admin': bankAdminID!,
        'key': key ?? generateFixedId("deposit")
      };
      if(imageURL == null || imageURL == ''){
        result = await authService.post("transaction/deposit", body);
      }else{
         Map<String, String> file = {
          'image': imageURL
        };
        result = await authService.multipart("transaction/deposit", body, file);
      }
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }


   // Pernataan Pailit
  Future<bool> depositNewAccount({
    String? bankAdminID,
    String? bankUserID,
    String? amount,
    String? imageURL
  }) async {
      try {
        isLoading(true);
        Map<String, String> body = {
          'dpnewacc_bankusr': bankUserID!,
          'dpnewacc_bankcmpy': bankAdminID!,
          'dpnewacc_dpstval': amount!,
        };
        Map<String, String> file = {
          'dpnewacc_tfprove': imageURL!
        };
        Map<String, dynamic> result = await authService.multipart("regol/depositNewAccount", body, file);
        isLoading(false);
        responseMessage(result['message']);
        if (result['status'] != true) {
          return false;
        }
        return true;
      } catch (e) {
        isLoading(false);
        responseMessage(e.toString());
        return false;
      }
    }


    // Kirim OTP
  Future<bool> kirimOTPWithdraw() async {
    try {
      isLoadingOTP(true);
      Map<String, dynamic> result = await authService.post("transaction/send-otp", {});
      isLoadingOTP(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      return true;
    } catch (e) {
      isLoadingOTP(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Withdrawal dengan http langsung
  Future<bool> withdrawal({
    String? bankUserID,
    String? tradingID,
    String? otp,
    String? amount,
    String? key
  }) async {
    try {
      isLoading(true);
      
      // Get access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      
      if (accessToken == null || accessToken.isEmpty) {
        responseMessage('Token tidak ditemukan. Silakan login kembali.');
        isLoading(false);
        return false;
      }
      
      // Buat multipart request seperti di Postman
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${GlobalVariable.mainURL}/transaction/withdrawal'),
      );
      
      // Tambahkan headers
      request.headers['Authorization'] = 'Bearer $accessToken';
      
      // Tambahkan fields dengan quotes seperti di curl Postman
      request.fields['account'] = tradingID ?? '';
      request.fields['amount'] = amount ?? '';
      request.fields['bank_user'] = bankUserID ?? '';
      request.fields['otp'] = otp ?? '';
      request.fields['key'] = key ?? '';
      
      print("Fields: ${request.fields}");
      print("Headers: ${request.headers}");
      
      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
    
      
      // Cek jika response kosong
      if (response.body.trim().isEmpty) {
        isLoading(false);
        responseMessage('Server error: Response kosong (Status ${response.statusCode})');
        return false;
      }
      
      // Parse response
      Map<String, dynamic> result;
      try {
        result = jsonDecode(response.body);
      } catch (e) {
        print("JSON Parse Error: $e");
        isLoading(false);
        responseMessage('Server error: Invalid JSON response');
        return false;
      }
      
      isLoading(false);
      responseMessage(result['message']?.toString() ?? 'Unknown error');
      
      if (result['status'] == true) {
        return true;
      }
      return false;
      
    } catch (e) {
      isLoading(false);
      Get.log("Withdrawal Exception: $e");
      responseMessage('Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  // Pernataan Pailit
  Future<bool> internalTransfer({
    String? tradingIDReceiver,
    String? tradingIDSender,
    String? amount
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("transaction/internal-transfer", {
        'acc_from': tradingIDSender,
        'acc_to': tradingIDReceiver,
        'amount': amount
      });
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }
}