import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Image.network yang bypass CORS di web menggunakan HTML element strategy.
/// Di mobile/desktop berjalan persis seperti Image.network biasa.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final String? semanticLabel;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Alignment alignment;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.errorBuilder,
    this.loadingBuilder,
    this.semanticLabel,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image(
        image: NetworkImage(
          url,
          // Gunakan HTML <img> element - bypass CORS restriction di browser
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        ),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        semanticLabel: semanticLabel,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      semanticLabel: semanticLabel,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
    );
  }
}
