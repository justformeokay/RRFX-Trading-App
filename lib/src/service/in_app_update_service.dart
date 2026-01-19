import 'package:in_app_update/in_app_update.dart';
import 'package:get/get.dart';

// Enum untuk tipe update
enum UpdateType { none, flexible, immediate }

class InAppUpdateService {
  // Singleton pattern
  static final InAppUpdateService _instance = InAppUpdateService._internal();

  factory InAppUpdateService() {
    return _instance;
  }

  InAppUpdateService._internal();

  // Check for updates
  Future<void> checkForUpdate() async {
    try {
      print('🔍 [IN_APP_UPDATE] Checking for updates...');
      
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      
      print('📱 [IN_APP_UPDATE] Flexible update allowed: ${updateInfo.flexibleUpdateAllowed}');
      print('📱 [IN_APP_UPDATE] Immediate update allowed: ${updateInfo.immediateUpdateAllowed}');

      if (!updateInfo.flexibleUpdateAllowed && !updateInfo.immediateUpdateAllowed) {
        print('✅ [IN_APP_UPDATE] App is already up to date or no updates available');
        return;
      }

      // Priority 5 = Force update (tidak bisa di-skip)
      if (updateInfo.immediateUpdateAllowed) {
        print('🚨 [IN_APP_UPDATE] Immediate update available');
        await _performImmediateUpdate(updateInfo);
      }
      // Flexible update
      else if (updateInfo.flexibleUpdateAllowed) {
        print('ℹ️  [IN_APP_UPDATE] Flexible update available');
        await _performFlexibleUpdate(updateInfo);
      }
    } on Exception catch (e) {
      // Handle specific error: app not owned by user (ERROR_APP_NOT_OWNED -10)
      // This happens when app is not installed from Play Store
      if (e.toString().contains('ERROR_APP_NOT_OWNED') || 
          e.toString().contains('TASK_FAILURE') ||
          e.toString().contains('not owned by any user')) {
        print('ℹ️  [IN_APP_UPDATE] App not installed from Play Store - skipping update check');
        print('💡 [IN_APP_UPDATE] To test in-app updates, install from Google Play Console Internal Testing');
        return;
      }
      print('❌ [IN_APP_UPDATE] Error checking for update: $e');
    }
  }

  /// Perform immediate (forced) update
  Future<void> _performImmediateUpdate(AppUpdateInfo updateInfo) async {
    try {
      print('📥 [IN_APP_UPDATE] Starting immediate update...');
      await InAppUpdate.performImmediateUpdate();
      print('✅ [IN_APP_UPDATE] Immediate update completed');
    } on Exception catch (e) {
      print('❌ [IN_APP_UPDATE] Immediate update error: $e');
    }
  }

  /// Perform flexible (optional) update with snackbar
  Future<void> _performFlexibleUpdate(AppUpdateInfo updateInfo) async {
    try {
      print('📥 [IN_APP_UPDATE] Starting flexible update...');
      await InAppUpdate.startFlexibleUpdate().then((_) {
        print('✅ [IN_APP_UPDATE] Flexible update started');
        // Show message that update is downloading
        Get.snackbar(
          'Update Available',
          'New version is being downloaded. You can continue using the app.',
          duration: const Duration(seconds: 3),
        );
        
        // Complete flexible update after download
        _completeFlexibleUpdate();
      }).catchError((e) {
        print('❌ [IN_APP_UPDATE] Flexible update error: $e');
      });
    } on Exception catch (e) {
      print('❌ [IN_APP_UPDATE] Flexible update exception: $e');
    }
  }

  /// Complete flexible update after download
  Future<void> _completeFlexibleUpdate() async {
    try {
      print('✅ [IN_APP_UPDATE] Completing flexible update...');
      await InAppUpdate.completeFlexibleUpdate();
      print('🔄 [IN_APP_UPDATE] App will restart to install update');
    } on Exception catch (e) {
      print('❌ [IN_APP_UPDATE] Complete flexible update error: $e');
    }
  }

  /// Get available update status
  Future<bool> hasAvailableUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.flexibleUpdateAllowed || updateInfo.immediateUpdateAllowed;
    } catch (e) {
      print('❌ [IN_APP_UPDATE] Error checking available update: $e');
      return false;
    }
  }
}
