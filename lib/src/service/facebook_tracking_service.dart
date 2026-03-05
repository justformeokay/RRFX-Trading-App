import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:get/get.dart';

/// Service untuk track conversions ke Facebook/Meta Ads Manager.
///
/// Events ini akan muncul di Meta Events Manager dan bisa digunakan
/// untuk optimisasi iklan Facebook/Instagram.
class FacebookTrackingService {
  static final FacebookTrackingService _instance = FacebookTrackingService._internal();
  factory FacebookTrackingService() => _instance;
  FacebookTrackingService._internal();

  final FacebookAppEvents _fb = FacebookAppEvents();

  /// Log saat app dibuka dari iklan Facebook/Instagram
  Future<void> logAppOpen({Map<String, String>? utmParams}) async {
    try {
      await _fb.logEvent(
        name: 'fb_mobile_activate_app',
        parameters: utmParams?.map((k, v) => MapEntry(k, v)),
      );
      Get.log('✅ [FB] App open logged');
    } catch (e) {
      Get.log('❌ [FB] Failed to log app open: $e');
    }
  }

  /// Log saat user berhasil registrasi
  /// Event ini digunakan untuk optimize "Registration" campaigns di Meta Ads
  Future<void> logCompleteRegistration({
    String? registrationMethod,
    Map<String, String>? utmParams,
  }) async {
    try {
      await _fb.logCompletedRegistration(registrationMethod: registrationMethod);
      Get.log('✅ [FB] Complete registration logged');
    } catch (e) {
      Get.log('❌ [FB] Failed to log registration: $e');
    }
  }

  /// Log custom event (misal: first_deposit, kyc_complete)
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _fb.logEvent(
        name: eventName,
        parameters: parameters,
      );
      Get.log('✅ [FB] Custom event "$eventName" logged');
    } catch (e) {
      Get.log('❌ [FB] Failed to log event: $e');
    }
  }

  /// Log purchase/deposit event
  /// Event ini digunakan untuk optimize "Purchase" campaigns di Meta Ads
  Future<void> logPurchase({
    required double amount,
    required String currency,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _fb.logPurchase(amount: amount, currency: currency, parameters: parameters);
      Get.log('✅ [FB] Purchase logged: $amount $currency');
    } catch (e) {
      Get.log('❌ [FB] Failed to log purchase: $e');
    }
  }
}
