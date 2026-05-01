import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Enum untuk tipe update
enum UpdateType { none, flexible, immediate }

class InAppUpdateService {
  // Singleton pattern
  static final InAppUpdateService _instance = InAppUpdateService._internal();

  factory InAppUpdateService() {
    return _instance;
  }

  InAppUpdateService._internal();

  // iOS App Store configuration
  static const String _iosAppId = '6756466599'; // From App Store URL
  static const String _iosAppStoreUrl = 'https://apps.apple.com/id/app/rrfx-mobile-trading/id$_iosAppId';

  // Check for updates (Cross-platform)
  Future<void> checkForUpdate() async {
    if (kIsWeb) {
      // print('ℹ️  [VERSION_CHECK] Web platform - version checking not supported');
      return;
    }
    
    if (Platform.isAndroid) {
      await _checkAndroidUpdate();
    } else if (Platform.isIOS) {
      await _checkIOSUpdate();
    } else {
      // print('ℹ️  [VERSION_CHECK] Platform not supported for version checking');
    }
  }

  /// Android-specific update check using in_app_update
  Future<void> _checkAndroidUpdate() async {
    try {
      // print('🔍 [ANDROID_UPDATE] Checking for updates...');
      
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      
      // print('📱 [ANDROID_UPDATE] Flexible update allowed: ${updateInfo.flexibleUpdateAllowed}');
      // print('📱 [ANDROID_UPDATE] Immediate update allowed: ${updateInfo.immediateUpdateAllowed}');

      if (!updateInfo.flexibleUpdateAllowed && !updateInfo.immediateUpdateAllowed) {
        // print('✅ [ANDROID_UPDATE] App is already up to date');
        return;
      }

      // Priority 5 = Force update (tidak bisa di-skip)
      if (updateInfo.immediateUpdateAllowed) {
        // print('🚨 [ANDROID_UPDATE] Immediate update available');
        await _performImmediateUpdate(updateInfo);
      }
      // Flexible update
      else if (updateInfo.flexibleUpdateAllowed) {
        // print('ℹ️  [ANDROID_UPDATE] Flexible update available');
        await _performFlexibleUpdate(updateInfo);
      }
    } on Exception catch (e) {
      // Handle specific error: app not owned by user
      if (e.toString().contains('ERROR_APP_NOT_OWNED') || 
          e.toString().contains('TASK_FAILURE') ||
          e.toString().contains('not owned by any user')) {
        // print('ℹ️  [ANDROID_UPDATE] App not installed from Play Store - skipping');
        return;
      }
      // print('❌ [ANDROID_UPDATE] Error checking for update: $e');
    }
  }

  /// iOS-specific update check using upgrader package
  Future<void> _checkIOSUpdate() async {
    try {
      // print('🔍 [IOS_UPDATE] Checking App Store for updates...');
      
      // Get current app version
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      
      // print('📱 [IOS_UPDATE] Current version: $currentVersion');
      
      // Initialize Upgrader
      final upgrader = Upgrader(
        countryCode: 'ID', // Indonesia
        debugDisplayAlways: false,
        debugDisplayOnce: false,
        debugLogging: false,
      );
      
      // Check for update
      await upgrader.initialize();
      
      final isUpdateAvailable = await upgrader.isUpdateAvailable();
      
      if (isUpdateAvailable) {
        final storeVersion = upgrader.currentAppStoreVersion;
        // print('🚨 [IOS_UPDATE] New version available: $storeVersion');
        
        // Show update dialog
        _showIOSUpdateDialog(currentVersion, storeVersion ?? 'Latest');
      } else {
        // print('✅ [IOS_UPDATE] App is up to date');
      }
    } catch (e) {
      // print('❌ [IOS_UPDATE] Error checking for update: $e');
    }
  }

  /// Show iOS update dialog
  void _showIOSUpdateDialog(String currentVersion, String newVersion) {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          'A new version ($newVersion) is available.\n'
          'Current version: $currentVersion\n\n'
          'Would you like to update now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openAppStore();
            },
            child: const Text('Update'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Open iOS App Store
  Future<void> _openAppStore() async {
    try {
      final Uri appStoreUri = Uri.parse(_iosAppStoreUrl);
      
      if (await canLaunchUrl(appStoreUri)) {
        await launchUrl(
          appStoreUri,
          mode: LaunchMode.externalApplication,
        );
        // print('✅ [IOS_UPDATE] Opened App Store');
      } else {
        // print('❌ [IOS_UPDATE] Could not launch App Store URL');
        Get.snackbar(
          'Error',
          'Could not open App Store',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // print('❌ [IOS_UPDATE] Error opening App Store: $e');
    }
  }

  /// Perform immediate (forced) update (Android only)
  Future<void> _performImmediateUpdate(AppUpdateInfo updateInfo) async {
    try {
      // print('📥 [ANDROID_UPDATE] Starting immediate update...');
      await InAppUpdate.performImmediateUpdate();
      // print('✅ [ANDROID_UPDATE] Immediate update completed');
    } on Exception catch (e) {
      // print('❌ [ANDROID_UPDATE] Immediate update error: $e');
    }
  }

  /// Perform flexible (optional) update with snackbar (Android only)
  Future<void> _performFlexibleUpdate(AppUpdateInfo updateInfo) async {
    try {
      // print('📥 [ANDROID_UPDATE] Starting flexible update...');
      await InAppUpdate.startFlexibleUpdate().then((_) {
        // print('✅ [ANDROID_UPDATE] Flexible update started');
        // Show message that update is downloading
        Get.snackbar(
          'Update Available',
          'New version is being downloaded. You can continue using the app.',
          duration: const Duration(seconds: 3),
        );
        
        // Complete flexible update after download
        _completeFlexibleUpdate();
      }).catchError((e) {
        // print('❌ [ANDROID_UPDATE] Flexible update error: $e');
      });
    } on Exception catch (e) {
      // print('❌ [ANDROID_UPDATE] Flexible update exception: $e');
    }
  }

  /// Complete flexible update after download (Android only)
  Future<void> _completeFlexibleUpdate() async {
    try {
      // print('✅ [ANDROID_UPDATE] Completing flexible update...');
      await InAppUpdate.completeFlexibleUpdate();
      // print('🔄 [ANDROID_UPDATE] App will restart to install update');
    } on Exception catch (e) {
      // print('❌ [ANDROID_UPDATE] Complete flexible update error: $e');
    }
  }

  /// Get available update status (Android only)
  Future<bool> hasAvailableUpdate() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.flexibleUpdateAllowed || updateInfo.immediateUpdateAllowed;
    } catch (e) {
      // print('❌ [ANDROID_UPDATE] Error checking available update: $e');
      return false;
    }
  }
}
