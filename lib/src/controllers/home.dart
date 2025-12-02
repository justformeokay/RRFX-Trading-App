import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/models/auth/pending_model.dart';
import 'package:rrfx/src/models/auth/profile.dart';
import 'package:rrfx/src/service/auth_service.dart';

class HomeController extends GetxController {
  AuthService authService = Get.find();
  RxString responseMessage = "".obs;
  RxBool isLoading = false.obs;
  Rxn<ProfileModel> profileModel = Rxn<ProfileModel>();
  Rxn<PendingModel> pendingModel = Rxn<PendingModel>();

  Future<bool> profile() async {
    try {
      Map<String, dynamic> response = await authService.get("profile/info");
      responseMessage(response['message']);
      if(response['status'] != true) {
        return false;
      }

      /** Coba access token disalahkan agar terdeteksi token expired */
      // authService.accessToken = "abogoboga";

      profileModel(ProfileModel.fromJson(response['response']));
      return true;

    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }


  Future<bool> getPendingAccount() async {
    isLoading(true);
    try {
      Map<String, dynamic> response = await authService.get("account/pending");
      isLoading(false);
      responseMessage(response['message']);
      if(response['status'] != true) {
        return false;
      }
      pendingModel(PendingModel.fromJson(response));
      return true;

    } catch (e) {
      debugPrint(e.toString());
      isLoading(false);
      return false;
    }
  }
}