import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/models/auth/profile.dart';
import 'package:rrfx/src/models/settings/detail_history_dp_wd_model.dart';
import 'package:rrfx/src/models/settings/history_withdraw_deposit_model.dart';
import 'package:rrfx/src/models/settings/internal_transfer_model.dart';
import 'package:rrfx/src/models/settings/internal_transfer_history_model.dart';
import 'package:rrfx/src/service/auth_service.dart';

class UserController extends GetxController {
  RxBool isLoading = false.obs;
  RxInt photoVersion = 0.obs;
  RxString responseMessage = "".obs;
  AuthService authService = AuthService();
  Rxn<ProfileModel> profileModel = Rxn<ProfileModel>();
  Rxn<InternalTransferModel> internalTransfer = Rxn<InternalTransferModel>();
  Rxn<InternalTransferHistoryModel> internalTransferHistory = Rxn<InternalTransferHistoryModel>();
  Rxn<HistoryWithdrawDepositModel> historyDepoWd = Rxn<HistoryWithdrawDepositModel>();
  Rxn<DepositWithdrawDetailModel> transactionDetail = Rxn<DepositWithdrawDetailModel>();

  Future<bool> getProfile() async {
    isLoading(true);
    try {
      Map<String, dynamic> response = await authService.get("/profile/info");
      isLoading(false);
      responseMessage(response['message']);
      photoVersion.value++;
      if(response['status'] != true) {
        return false;
      }
      profileModel(ProfileModel.fromJson(response['response']));
      return true;

    } catch (e) {
      debugPrint(e.toString());
      isLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    String? province,
    String? gender,
    String? dateOfBirth,
    String? placeOfBirth,
    String? address,
    String? city,
    String? district,
    String? village,
    String? zipcode
  }) async {
    isLoading(true);
    try {
      Map<String, dynamic> response = await authService.post("/profile/update-info",
        {
          'zip': zipcode,
          'place_of_birth': placeOfBirth,
          'date_of_birth': dateOfBirth,
          'province': province,
          'gender': gender,
          'city': city,
          'district': district,
          'villages': village,
          'address': address
        }
      );
      isLoading(false);
      responseMessage(response['message']);
      if(response['status'] != true) {
        return false;
      }
      return true;

    } catch (e) {
      debugPrint(e.toString());
      isLoading(false);
      return false;
    }
  }

  Future<bool> updateAvatar({String? urlImage}) async {
    try {
      isLoading(true);
      Map<String, String> file = {};
      if(urlImage != null) {
        file['image'] = urlImage;
      }
      Map<String, dynamic> result = await authService.multipart("profile/update-avatar", {}, file);
      isLoading(false);
      await getProfile(); 
      responseMessage(result['message']);
      if(result['status'] != true) {
        return false;
      }
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> historyWithdrawAndDeposit() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("transaction/history");
      isLoading(false);

      // ✅ Parsing langsung dari List
      var model = HistoryWithdrawDepositModel.fromJson(result['response']);
      historyDepoWd(model); // Pastikan ini menerima tipe yang sesuai

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

  // Future<bool> internalTransferHistory({String? loginID}) async {
  //   try {
  //     isLoading(true);
  //     Map<String, dynamic> result = await authService.get("transaction/history?login=$loginID");
  //     isLoading(false);
  //     // ✅ Parsing langsung dari List
  //     var model = InternalTransferModel.fromJson(result);
  //     internalTransfer(model); // Pastikan ini menerima tipe yang sesuai

  //     responseMessage(result['message']);
  //     if (result['status'] != true) {
  //       return false;
  //     }
  //     return true;
  //   } catch (e) {
  //     isLoading(false);
  //     responseMessage(e.toString());
  //     return false;
  //   }
  // }

  // Method baru untuk API history-internal-transfer
  Future<bool> getInternalTransferHistory() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("transaction/history-internal-transfer");
      isLoading(false);
      
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      
      var model = InternalTransferHistoryModel.fromJson(result);
      internalTransferHistory(model);
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> historyTransactionDetail({String? id}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.get("transaction/history-detail?id=$id");
      isLoading(false);
      transactionDetail(DepositWithdrawDetailModel.fromJson(result));
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

  Future<bool> addBank({String? currency, String? bankName, String? bankBranch, String? bankHolder, String? type, String? account}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("bank/create", {
        'currency': currency,
        'bank_name': bankName,
        'bank_branch': bankBranch,
        'name': bankHolder,
        'bank-name': bankName,
        'bank-number': account
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

  Future<bool> confirmOTPBank({String? id, String? otp}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("bank/otp-verification", {
        'id': id,
        'otp': otp,
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

  Future<bool> resendOTPBank({String? id}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("bank/resend-otp", {
        'id': id,
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

  Future<bool> addBankRegol({
    String? bankName,
    String? account,
    String? urlBukuRekening,
    String? bankPemilik,
  }) async {
    try {
      isLoading(true);

      // Body selalu dikirim walaupun nilainya kosong
      Map<String, String> body = {
        'bank-name': bankName ?? "",
        'bank-number': account ?? "",
        'bank-pemilik': bankPemilik ?? "",
      };

      // File hanya ditambahkan jika user benar-benar memilih gambar
      Map<String, String> file = {};
      if (urlBukuRekening != null && urlBukuRekening.isNotEmpty) {
        file['bank-image'] = urlBukuRekening;
      }

      // Eksekusi multipart (tetap berjalan meskipun file kosong)
      Map<String, dynamic> result =
          await authService.multipart("bank/create", body, file);

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


  Future<bool> editBankRegol({String? bankName, String? account, String? urlBukuRekening, String? bankID, String? bankHolder}) async {
    try {
      if(bankID == null) {
        responseMessage("ID bank tidak ditemukan");
        return false;
      }
      if(bankHolder == null) {
        responseMessage("Nama pemilik bank tidak ditemukan");
        return false;
      }
      if(bankName == null) {
        responseMessage("Nama bank tidak ditemukan");
        return false;
      }
      if(account == null) {
        responseMessage("Nomor rekening tidak ditemukan");
        return false;
      }
      isLoading(true);
      Map<String, String> body = {
        'id': bankID,
        'bank-holder': bankHolder,
        'bank-name': bankName,
        'bank-number': account,
      };

      Map<String, String> file = {};
      if(urlBukuRekening != null) {
        file['bank-image'] = urlBukuRekening;
      }

      Map<String, dynamic> result = await authService.multipart("bank/update", body, file);
      isLoading(false);
      responseMessage(result['message']);
      if(result['status'] != true) {
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