import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/service/facebook_tracking_service.dart';

/// Service for tracking UTM campaign parameters via Firebase Analytics.
///
/// Integrates with [DeepLinkService] to capture UTM params from incoming
/// deep links and logs them as Firebase Analytics events.
///
/// Events logged:
/// - `campaign_details`  — standard GA4 campaign attribution event
/// - `app_open_via_campaign` — custom event when app is opened via UTM link
/// - `sign_up`           — conversion event attributed to the campaign
class UtmTrackingService {
  static final UtmTrackingService _instance = UtmTrackingService._internal();
  factory UtmTrackingService() => _instance;
  UtmTrackingService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FacebookTrackingService _fb = FacebookTrackingService();
  final GetStorage _box = GetStorage();

  static const _storageKey = 'utm_session';

  // ────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────

  /// Call this from [DeepLinkService] whenever UTM parameters are extracted
  /// from an incoming URI.
  ///
  /// Logs:
  ///  1. `campaign_details` — standard GA4 campaign attribution
  ///  2. `app_open_via_campaign` — custom event for funnel tracking
  Future<void> logCampaignFromLink({
    required Map<String, String> utmParams,
    required String sourceUri,
    bool isInitialLink = false,
  }) async {
    if (utmParams.isEmpty) return;

    // Persist the session so conversion can be attributed even after restart
    _box.write(_storageKey, utmParams);

    Get.log('📊 [UTM] Logging campaign from link: $utmParams');

    // 1 — Standard GA4 campaign_details event
    await _logCampaignDetails(utmParams);

    // 2 — Custom app-open attribution event
    await _analytics.logEvent(
      name: 'app_open_via_campaign',
      parameters: {
        'source': utmParams['utm_source'] ?? 'unknown',
        'medium': utmParams['utm_medium'] ?? 'unknown',
        'campaign': utmParams['utm_campaign'] ?? 'unknown',
        'content': utmParams['utm_content'] ?? '',
        'term': utmParams['utm_term'] ?? '',
        'utm_id': utmParams['utm_id'] ?? '',
        'fbclid': utmParams['fbclid'] ?? '',
        'is_initial_link': isInitialLink ? 'true' : 'false',
        'source_uri': sourceUri.length > 100
            ? sourceUri.substring(0, 100)
            : sourceUri,
      },
    );

    Get.log('✅ [UTM] campaign_details + app_open_via_campaign logged');

    // 3 — Log to Facebook SDK (for Meta Ads attribution)
    if (utmParams['fbclid'] != null || 
        utmParams['utm_source']?.toLowerCase() == 'facebook' ||
        utmParams['utm_source']?.toLowerCase() == 'instagram' ||
        utmParams['utm_source']?.toLowerCase() == 'meta') {
      await _fb.logAppOpen(utmParams: utmParams);
    }
  }

  /// Call this after a successful user **registration** to attribute
  /// sign-ups to their originating campaign.
  ///
  /// If no active UTM params are provided explicitly, it falls back to any
  /// persisted session from the last seen deep link.
  Future<void> logSignUpConversion({
    Map<String, String>? utmParams,
    String method = 'email',
  }) async {
    final params = utmParams ?? _loadPersistedSession();
    if (params == null || params.isEmpty) {
      Get.log('📊 [UTM] sign_up logged (no campaign attribution)');
      await _analytics.logSignUp(signUpMethod: method);
      return;
    }

    Get.log('📊 [UTM] sign_up with campaign attribution: $params');

    // Log standard sign_up event
    await _analytics.logSignUp(signUpMethod: method);

    // Log attributed conversion
    await _analytics.logEvent(
      name: 'sign_up_campaign_attributed',
      parameters: {
        'method': method,
        'source': params['utm_source'] ?? 'unknown',
        'medium': params['utm_medium'] ?? 'unknown',
        'campaign': params['utm_campaign'] ?? 'unknown',
        'content': params['utm_content'] ?? '',
        'term': params['utm_term'] ?? '',
        'utm_id': params['utm_id'] ?? '',
      },
    );

    // Set user properties for cohort analysis in Firebase / BigQuery
    await _analytics.setUserProperty(
      name: 'acquisition_source',
      value: params['utm_source'],
    );
    await _analytics.setUserProperty(
      name: 'acquisition_campaign',
      value: params['utm_campaign'],
    );
    await _analytics.setUserProperty(
      name: 'acquisition_medium',
      value: params['utm_medium'],
    );

    Get.log('✅ [UTM] sign_up_campaign_attributed logged');

    // Log to Facebook SDK (for Meta Ads conversion tracking)
    if (params['fbclid'] != null || 
        params['utm_source']?.toLowerCase() == 'facebook' ||
        params['utm_source']?.toLowerCase() == 'instagram' ||
        params['utm_source']?.toLowerCase() == 'meta') {
      await _fb.logCompleteRegistration(
        registrationMethod: method,
        utmParams: params,
      );
    }

    // Clear session after conversion is recorded
    clearSession();
  }

  /// Log a custom conversion event (e.g., first deposit, KYC complete)
  /// attributed to the originating campaign.
  Future<void> logConversionEvent({
    required String eventName,
    Map<String, String>? utmParams,
    Map<String, Object>? extraParams,
  }) async {
    final params = utmParams ?? _loadPersistedSession();

    final Map<String, Object> payload = {
      if (params != null) ...{
        'source': params['utm_source'] ?? 'unknown',
        'medium': params['utm_medium'] ?? 'unknown',
        'campaign': params['utm_campaign'] ?? 'unknown',
        'content': params['utm_content'] ?? '',
        'term': params['utm_term'] ?? '',
      },
      if (extraParams != null) ...extraParams,
    };

    await _analytics.logEvent(name: eventName, parameters: payload);
    Get.log('✅ [UTM] Conversion event "$eventName" logged');
  }

  /// Returns the currently persisted UTM session (if any).
  Map<String, String>? get currentSession => _loadPersistedSession();

  /// Clear persisted UTM session (call after attribution is complete).
  void clearSession() {
    _box.remove(_storageKey);
    Get.log('📊 [UTM] Session cleared');
  }

  // ────────────────────────────────────────────────────
  // Internal helpers
  // ────────────────────────────────────────────────────

  /// Log the standard GA4 `campaign_details` event.
  /// Parameter names match the GA4 schema exactly so Firebase auto-populates
  /// the Acquisition reports.
  Future<void> _logCampaignDetails(Map<String, String> p) async {
    await _analytics.logEvent(
      name: 'campaign_details',
      parameters: {
        // GA4 reserved parameter names
        'source': p['utm_source'] ?? 'unknown',
        'medium': p['utm_medium'] ?? 'unknown',
        'campaign': p['utm_campaign'] ?? 'unknown',
        'content': p['utm_content'] ?? '',
        'term': p['utm_term'] ?? '',
        // Extras
        'cp1': p['utm_id'] ?? '',
        'fbclid': p['fbclid'] ?? '',      // Facebook/Instagram
        'ttclid': p['ttclid'] ?? '',      // TikTok
        'igshid': p['igshid'] ?? '',      // Instagram
        'gclid': p['_gl'] ?? '',
      },
    );
  }

  Map<String, String>? _loadPersistedSession() {
    final raw = _box.read(_storageKey);
    if (raw == null || raw is! Map) return null;
    return Map<String, String>.from(raw);
  }
}
