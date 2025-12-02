import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void init() async {
    // 🔹 Listen untuk link yang masuk saat app sedang terbuka
    _sub = _appLinks.uriLinkStream.listen(_handleIncomingUri);

    // 🔹 Tangani link awal (saat app dibuka via deeplink)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleIncomingUri(initialUri);
    }
  }

  void _handleIncomingUri(Uri uri) {
    // Cek apakah URL-nya mengarah ke signup page
    if (uri.path.contains('signup')) {
      final referralCode = uri.queryParameters['referral'];

      if (referralCode != null && referralCode.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
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
