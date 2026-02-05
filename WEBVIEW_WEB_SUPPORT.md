# 🌐 WebView Support untuk Flutter Web

## Masalah
`webview_flutter` tidak support platform Web karena WebView adalah komponen native yang tidak ada di browser.

## Solusi
Menggunakan **iframe HTML** untuk platform Web dan **WebView native** untuk platform Mobile.

## Implementasi

### 1. Conditional Import
File yang menggunakan WebView harus menggunakan conditional import:

```dart
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) 'package:rrfx/src/helpers/http/webview_flutter_stub.dart';
```

### 2. Stub Implementation untuk Web
File `webview_flutter_stub.dart` berisi:
- `WebViewController` - menggunakan `iframe` HTML
- `WebViewWidget` - menggunakan `HtmlElementView`
- `NavigationDelegate` - partial support untuk callbacks
- Enums & Classes yang kompatibel dengan webview_flutter

### 3. Cara Kerja
**Di Mobile (Android/iOS):**
- Menggunakan `webview_flutter` asli
- WebView native dengan performa penuh

**Di Web:**
- Menggunakan `dart:html` untuk membuat iframe
- Registrasi iframe dengan `platformViewRegistry`
- Render menggunakan `HtmlElementView`

## Fitur yang Didukung

✅ **Supported:**
- Load URL (`loadRequest`, `loadUrl`)
- JavaScript mode (selalu enabled di iframe)
- Basic navigation callbacks
- Full screen support
- Auto-resize

❌ **Limited/Not Supported:**
- JavaScript channels (two-way communication)
- Fine-grained navigation control
- Download handling
- Some WebView-specific features

## Contoh Penggunaan

```dart
class MyWebViewPage extends StatefulWidget {
  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) => print('Loaded: $url'),
          onWebResourceError: (error) => print('Error: ${error.description}'),
        ),
      )
      ..loadRequest(Uri.parse('https://example.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
```

## URL yang Digunakan

Dalam proyek ini, WebView digunakan untuk:
- **Trading Chart:** `https://chart-rrfx.techcrm.dev/chart.php?symbol=$symbol&server=demo&theme=$theme`
- **PDF Viewer:** Various PDF URLs

## Notes

⚠️ **CORS Consideration:**
- Pastikan server API mengirim header CORS yang benar
- Untuk development, gunakan flag `--web-browser-flag "--disable-web-security"`
- Untuk production, configure CORS di server

⚠️ **Security:**
- iframe memiliki limitasi keamanan dari browser
- Tidak bisa bypass same-origin policy tanpa CORS
- Gunakan HTTPS untuk konten external

## Testing

```bash
# Development dengan CORS disabled
flutter run -d chrome --web-browser-flag "--disable-web-security"

# Production build
flutter build web --release
```
