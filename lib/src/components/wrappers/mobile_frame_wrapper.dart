import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Widget wrapper untuk membuat tampilan Web seperti Mobile
/// Membatasi lebar maksimum dan menempatkan di tengah layar
class MobileFrameWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;
  final bool showDeviceFrame;

  const MobileFrameWrapper({
    super.key,
    required this.child,
    this.maxWidth = 430, // iPhone 14 Pro Max width
    this.backgroundColor,
    this.showDeviceFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    // Jika bukan web, tampilkan child langsung tanpa frame
    if (!kIsWeb) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? const Color(0xFF1a1a2e) : const Color(0xFFf0f0f5));

    return Container(
      color: bgColor,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: double.infinity,
          ),
          decoration: showDeviceFrame
              ? BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                )
              : null,
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

/// Builder widget yang menggunakan GetMaterialApp dengan mobile frame
class MobileWebApp extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final double maxWidth;
  final Color? backgroundColor;
  final bool showDeviceFrame;

  const MobileWebApp({
    super.key,
    required this.builder,
    this.maxWidth = 430,
    this.backgroundColor,
    this.showDeviceFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return builder(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? const Color(0xFF1a1a2e) : const Color(0xFFf0f0f5));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: showDeviceFrame
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  )
                : null,
            clipBehavior: Clip.antiAlias,
            child: builder(context),
          ),
        ),
      ),
    );
  }
}
