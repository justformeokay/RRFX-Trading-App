import 'package:url_launcher/url_launcher.dart';

Future<void> openInChrome(String url) async {
  final Uri uri = Uri.parse(url);

  // Cek apakah bisa dibuka
  if (!await canLaunchUrl(uri)) {
    throw 'Tidak bisa membuka URL: $url';
  }

  // Android khusus: coba buka di Chrome
  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication, // Pastikan dibuka di luar app
    webViewConfiguration: const WebViewConfiguration(
      enableJavaScript: true,
    ),
  );
}