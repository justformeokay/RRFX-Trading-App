import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/authentication.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _isProcessingLink = false; // Flag untuk prevent duplicate navigation
  Uri? _lastProcessedUri; // Track last processed URI

  // UBAH: dari void menjadi Future<void>
  Future<void> init() async {
    // 🔹 Listen untuk link yang masuk saat app sedang terbuka (background/foreground)
    _sub = _appLinks.uriLinkStream.listen(_handleIncomingUri);

    // 🔹 Tangani link awal (saat app dibuka via deeplink dari kondisi mati/terminated)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('🔗 [DeepLink] Initial link detected: $initialUri');
        _handleIncomingUri(initialUri, isInitial: true);
      }
    } catch (e) {
      print('❌ [DeepLink] Failed to get initial link: $e');
    }
  }

  void _handleIncomingUri(Uri uri, {bool isInitial = false}) {
    print('📥 [DeepLink] Incoming link: $uri (initial: $isInitial)');
    
    // Prevent duplicate handling of same URI
    if (_lastProcessedUri == uri) {
      print('⚠️ [DeepLink] Duplicate URI detected, ignoring');
      return;
    }
    
    // Prevent concurrent processing
    if (_isProcessingLink) {
      print('⚠️ [DeepLink] Already processing a link, ignoring');
      return;
    }
    
    _isProcessingLink = true;
    _lastProcessedUri = uri;
    
    // 📊 Extract UTM parameters dari URL
    final utmParams = _extractUtmParameters(uri);
    if (utmParams.isNotEmpty) {
      print('📊 [DeepLink] UTM parameters detected: $utmParams');
      
      // Save UTM parameters ke AuthController
      try {
        final authController = Get.find<AuthController>();
        authController.setUtmParameters(utmParams);
      } catch (e) {
        print('⚠️ [DeepLink] AuthController not found yet, will save later: $e');
        // AuthController belum diinisialisasi, simpan ke cache sementara
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            final authController = Get.find<AuthController>();
            authController.setUtmParameters(utmParams);
          } catch (e) {
            print('❌ [DeepLink] Failed to save UTM parameters: $e');
          }
        });
      }
    }
    
    // Cek apakah URL-nya mengarah ke signup page
    if (uri.path.contains('signup')) {
      final referralCode = uri.queryParameters['referral'];
      print('🎯 [DeepLink] Signup path detected, referral code: $referralCode');

      if (referralCode != null && referralCode.isNotEmpty) {
        // Beri jeda sedikit agar GetMaterialApp siap melakukan navigasi
        Future.delayed(const Duration(milliseconds: 800), () {
          // Cek apakah sudah di signup page
          if (Get.currentRoute == '/signup') {
            print('✅ [DeepLink] Already at signup page, skipping navigation');
            _isProcessingLink = false;
            return;
          }
          
          print('🚀 [DeepLink] Navigating to signup with referral: $referralCode');
          Get.offAllNamed(
            '/signup',
            arguments: {'code': referralCode},
          );
          
          // Reset flag setelah navigation complete
          Future.delayed(const Duration(milliseconds: 500), () {
            _isProcessingLink = false;
          });
        });
      } else {
        _isProcessingLink = false;
      }
    } else {
      _isProcessingLink = false;
    }
  }
  
  /// Extract UTM parameters dari URI
  Map<String, String> _extractUtmParameters(Uri uri) {
    final Map<String, String> utmParams = {};
    
    // List of UTM parameters to extract
    const utmKeys = [
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_content',
      'utm_term',
      'utm_id',
      '_gl',
      'fbclid',
    ];
    
    for (final key in utmKeys) {
      final value = uri.queryParameters[key];
      if (value != null && value.isNotEmpty) {
        utmParams[key] = value;
      }
    }
    
    return utmParams;
  }

  void dispose() {
    _sub?.cancel();
  }
}