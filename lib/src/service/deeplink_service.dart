import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  // UBAH: dari void menjadi Future<void>
  Future<void> init() async {
    // 🔹 Listen untuk link yang masuk saat app sedang terbuka (background/foreground)
    _sub = _appLinks.uriLinkStream.listen(_handleIncomingUri);

    // 🔹 Tangani link awal (saat app dibuka via deeplink dari kondisi mati/terminated)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  void _handleIncomingUri(Uri uri) {
    print('Incoming deep link: $uri');
    
    // Cek apakah URL-nya mengarah ke signup page
    if (uri.path.contains('signup')) {
      final referralCode = uri.queryParameters['referral'];

      if (referralCode != null && referralCode.isNotEmpty) {
        // Beri jeda sedikit agar GetMaterialApp siap melakukan navigasi
        Future.delayed(const Duration(milliseconds: 800), () {
          Get.toNamed(
            '/signup',
            arguments: {'code': referralCode},
          );
        });
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}