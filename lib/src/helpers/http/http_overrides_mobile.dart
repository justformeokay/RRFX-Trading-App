import 'dart:io';

/// Custom HTTP overrides untuk handle image loading dengan status code 300
/// dan bypass SSL certificate validation (hanya untuk mobile)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void setupHttpOverrides() {
  HttpOverrides.global = MyHttpOverrides();
  print('📱 [HTTP] Running on Mobile platform - HttpOverrides configured');
}
