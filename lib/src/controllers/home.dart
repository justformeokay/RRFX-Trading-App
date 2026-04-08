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

  // ── Profile caching ──
  DateTime? _profileFetchedAt;
  Future<bool>? _profileFetchInProgress;
  static const Duration _profileCacheTTL = Duration(minutes: 5);

  // ── Pending account caching ──
  DateTime? _pendingAccountFetchedAt;
  Future<bool>? _pendingFetchInProgress;
  static const Duration _pendingAccountCacheTTL = Duration(minutes: 5);

  /// Fetch profile dengan caching.
  /// [forceRefresh] = true akan bypass cache (untuk pull-to-refresh, setelah update profil, dll).
  Future<bool> profile({bool forceRefresh = false}) async {
    Get.log("📡 [HOME_CONTROLLER] profile() called (forceRefresh: $forceRefresh)");

    // Return cached data jika masih fresh
    if (!forceRefresh &&
        profileModel.value != null &&
        _profileFetchedAt != null &&
        DateTime.now().difference(_profileFetchedAt!) < _profileCacheTTL) {
      Get.log("✅ [HOME_CONTROLLER] Using cached profile (age: ${DateTime.now().difference(_profileFetchedAt!).inSeconds}s)");
      return true;
    }

    // Deduplicate: jika fetch sedang berjalan, tunggu yang sudah ada
    if (_profileFetchInProgress != null) {
      Get.log("⏳ [HOME_CONTROLLER] Profile fetch already in progress, waiting...");
      return _profileFetchInProgress!;
    }

    _profileFetchInProgress = _doFetchProfile();
    try {
      return await _profileFetchInProgress!;
    } finally {
      _profileFetchInProgress = null;
    }
  }

  Future<bool> _doFetchProfile() async {
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

      Get.log("✅ [HOME_CONTROLLER] Profile data received:");
      Get.log("   - Name: ${response['response']?['name'] ?? 'NULL'}");
      Get.log("   - Email: ${response['response']?['email'] ?? 'NULL'}");
      Get.log("   - Phone: ${response['response']?['phone'] ?? 'NULL'}");
      
      profileModel(ProfileModel.fromJson(response['response']));
      _profileFetchedAt = DateTime.now();
      Get.log("💾 [HOME_CONTROLLER] profileModel updated & cached successfully");
      return true;

    } catch (e) {
      Get.log("❌ [HOME_CONTROLLER] Exception in profile(): $e");
      debugPrint(e.toString());
      return false;
    }
  }

  /// Invalidate profile cache (panggil setelah update profil / avatar / logout).
  void invalidateProfileCache() {
    _profileFetchedAt = null;
    Get.log("🗑️ [HOME_CONTROLLER] Profile cache invalidated");
  }

  /// Fetch pending account dengan caching.
  /// [forceRefresh] = true akan bypass cache.
  Future<bool> getPendingAccount({bool forceRefresh = false}) async {
    // Return cached data jika masih fresh
    if (!forceRefresh &&
        pendingModel.value != null &&
        _pendingAccountFetchedAt != null &&
        DateTime.now().difference(_pendingAccountFetchedAt!) < _pendingAccountCacheTTL) {
      return true;
    }

    // Deduplicate: jika fetch sedang berjalan, tunggu yang sudah ada
    if (_pendingFetchInProgress != null) {
      return _pendingFetchInProgress!;
    }

    _pendingFetchInProgress = _doFetchPendingAccount();
    try {
      return await _pendingFetchInProgress!;
    } finally {
      _pendingFetchInProgress = null;
    }
  }

  Future<bool> _doFetchPendingAccount() async {
    isLoading(true);
    try {
      Map<String, dynamic> response = await authService.get("account/pending");
      isLoading(false);
      responseMessage(response['message']);
      if(response['status'] != true) {
        return false;
      }
      pendingModel(PendingModel.fromJson(response));
      _pendingAccountFetchedAt = DateTime.now();
      return true;

    } catch (e) {
      debugPrint(e.toString());
      isLoading(false);
      return false;
    }
  }

  /// Invalidate pending account cache.
  void invalidatePendingAccountCache() {
    _pendingAccountFetchedAt = null;
  }

  /// Invalidate semua cache (untuk logout).
  void invalidateAllCaches() {
    invalidateProfileCache();
    invalidatePendingAccountCache();
    profileModel.value = null;
    pendingModel.value = null;
  }
}