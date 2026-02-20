import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

/// Page WebView untuk handle URL external (seperti reset password)
/// yang di-deeplink-kan ke app tapi perlu dibuka di webview
class ExternalWebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const ExternalWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<ExternalWebViewPage> createState() => _ExternalWebViewPageState();
}

class _ExternalWebViewPageState extends State<ExternalWebViewPage> {
  InAppWebViewController? _webViewController;
  final RxBool _isLoading = true.obs;
  final RxDouble _progress = 0.0.obs;
  final RxString _currentTitle = ''.obs;

  @override
  void initState() {
    super.initState();
    _currentTitle.value = widget.title ?? 'Loading...';
    print('🌐 [ExternalWebView] Opening URL: ${widget.url}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentTitle.value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _extractDomain(widget.url),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        )),
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(
              Iconsax.refresh_outline,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 22,
            ),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Obx(() => _progress.value < 1.0
              ? LinearProgressIndicator(
                  value: _progress.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CustomColor.secondaryColor,
                  ),
                  minHeight: 2,
                )
              : const SizedBox.shrink()),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              supportZoom: true,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              print('✅ [ExternalWebView] WebView created');
            },
            onLoadStart: (controller, url) {
              print('🔄 [ExternalWebView] Loading: $url');
              _isLoading.value = true;
            },
            onProgressChanged: (controller, progress) {
              _progress.value = progress / 100;
            },
            onLoadStop: (controller, url) async {
              print('✅ [ExternalWebView] Loaded: $url');
              _isLoading.value = false;
              _progress.value = 1.0;
              
              // Get page title
              final title = await controller.getTitle();
              if (title != null && title.isNotEmpty) {
                _currentTitle.value = title;
              }
            },
            onLoadError: (controller, url, code, message) {
              print('❌ [ExternalWebView] Error: $code - $message');
              _isLoading.value = false;
            },
            onReceivedHttpError: (controller, request, response) {
              print('❌ [ExternalWebView] HTTP Error: ${response.statusCode}');
            },
          ),
          
          // Loading overlay
          Obx(() => _isLoading.value && _progress.value < 0.3
              ? Container(
                  color: isDark
                      ? Colors.grey.shade900.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: CustomColor.secondaryColor,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat halaman...',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
}
