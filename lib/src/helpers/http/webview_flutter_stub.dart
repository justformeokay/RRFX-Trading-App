import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// WebViewController untuk Web platform menggunakan iframe
class WebViewController {
  String? _currentUrl;
  final String _viewType = 'iframe-${DateTime.now().millisecondsSinceEpoch}';
  html.IFrameElement? _iframeElement;
  
  WebViewController();

  Future<void> setJavaScriptMode(dynamic mode) async {
    // JavaScript selalu enabled di iframe
  }

  Future<void> enableZoom(bool enable) async {
    // Zoom handled by iframe
  }

  Future<void> setNavigationDelegate(dynamic delegate) async {
    // Delegates not fully supported in web iframe, but we can listen to load events
    if (_iframeElement != null && delegate != null) {
      _iframeElement!.onLoad.listen((_) {
        if (delegate.onPageFinished != null) {
          delegate.onPageFinished!(_currentUrl ?? '');
        }
      });
      
      _iframeElement!.onError.listen((_) {
        if (delegate.onWebResourceError != null) {
          delegate.onWebResourceError!(WebResourceError(description: 'Failed to load'));
        }
      });
    }
  }

  Future<void> loadRequest(Uri uri) async {
    _currentUrl = uri.toString();
    if (_iframeElement != null) {
      _iframeElement!.src = _currentUrl;
    }
  }

  Future<void> loadUrl(String url) async {
    return loadRequest(Uri.parse(url));
  }
  
  String get viewType => _viewType;
  String? get currentUrl => _currentUrl;
  
  void setIframeElement(html.IFrameElement element) {
    _iframeElement = element;
  }
}

/// Enum for JavaScript mode
enum JavaScriptMode { disabled, unrestricted }

/// WebResourceError untuk Web platform
class WebResourceError {
  final String description;
  WebResourceError({required this.description});
}

/// NavigationDelegate untuk Web platform
class NavigationDelegate {
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;
  final Function(WebResourceError)? onWebResourceError;

  NavigationDelegate({
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
  });
}

/// WebViewWidget untuk Web menggunakan iframe
class WebViewWidget extends StatefulWidget {
  final WebViewController? controller;

  const WebViewWidget({super.key, this.controller});

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.controller != null) {
      _registerIframe();
    }
  }

  void _registerIframe() {
    final viewType = widget.controller!.viewType;
    
    // Buat iframe element
    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
      ..allowFullscreen = true;

    // Set URL jika sudah ada
    if (widget.controller!.currentUrl != null) {
      iframe.src = widget.controller!.currentUrl;
    }

    // Store reference
    widget.controller!.setIframeElement(iframe);

    // Register platform view
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || widget.controller == null) {
      return const Center(
        child: Text('WebView only available on Web'),
      );
    }

    return HtmlElementView(
      viewType: widget.controller!.viewType,
    );
  }
}
