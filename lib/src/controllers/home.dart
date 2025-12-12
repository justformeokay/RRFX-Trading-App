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
    Get.log("📡 [HOME_CONTROLLER] profile() called");
    try {
      Get.log("🌐 [HOME_CONTROLLER] Calling API: profile/info");
      Map<String, dynamic> response = await authService.get("profile/info");
      Get.log("📥 [HOME_CONTROLLER] API Response status: ${response['status']}");
      Get.log("📋 [HOME_CONTROLLER] API Response message: ${response['message']}");
      
      responseMessage(response['message']);
      if(response['status'] != true) {
        Get.log("❌ [HOME_CONTROLLER] Profile fetch failed - status not true");
        return false;
      }

      /** Coba access token disalahkan agar terdeteksi token expired */
      // authService.accessToken = "abogoboga";

      Get.log("✅ [HOME_CONTROLLER] Profile data received:");
      Get.log("   - Name: ${response['response']?['name'] ?? 'NULL'}");
      Get.log("   - Email: ${response['response']?['email'] ?? 'NULL'}");
      Get.log("   - Phone: ${response['response']?['phone'] ?? 'NULL'}");
      
      profileModel(ProfileModel.fromJson(response['response']));
      Get.log("💾 [HOME_CONTROLLER] profileModel updated successfully");
      Get.log("🔍 [HOME_CONTROLLER] Current profileModel value: ${profileModel.value?.email ?? 'NULL'}");
      return true;

    } catch (e) {
      Get.log("❌ [HOME_CONTROLLER] Exception in profile(): $e");
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