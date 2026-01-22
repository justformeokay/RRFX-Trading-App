import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Advanced Floating Widget dengan scroll detection dan liquid glass animation
class BuildVersionIndicator extends StatefulWidget {
  final ScrollController? scrollController;
  final EdgeInsets margin;
  final bool showBuildNumber;
  final bool autoHideOnScroll;

  const BuildVersionIndicator({
    super.key,
    this.scrollController,
    this.margin = const EdgeInsets.fromLTRB(16, 16, 16, 16),
    this.showBuildNumber = true,
    this.autoHideOnScroll = true,
  });

  @override
  State<BuildVersionIndicator> createState() => _BuildVersionIndicatorState();
}

class _BuildVersionIndicatorState extends State<BuildVersionIndicator>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceOutController;
  late AnimationController _bounceInController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceOutAnimation;
  late Animation<double> _bounceInAnimation;

  String _versionInfo = "v0.0.0";
  bool _isExpanded = false;
  bool _isScrolling = false;
  Timer? _scrollIdleTimer;

  @override
  void initState() {
    super.initState();

    // Slide Animation (untuk hide/show saat scroll)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Bounce Out Animation (saat hide/scroll)
    _bounceOutController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceOutAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _bounceOutController, curve: Curves.easeInOut),
    );

    // Bounce In Animation (saat show)
    _bounceInController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _bounceInAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceInController, curve: Curves.elasticOut),
    );

    _loadVersionInfo();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.autoHideOnScroll) return;

    if (!_isScrolling) {
      _isScrolling = true;
      // Play bounce out animation saat scroll
      _playBounceOutAnimation();
    }

    // Cancel timer sebelumnya
    _scrollIdleTimer?.cancel();

    // Set timer baru untuk detect idle scroll
    _scrollIdleTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && _isScrolling) {
        _isScrolling = false;
        // Show kembali dengan slide dari kanan
        _slideController.reverse();
        // Play bounce animation saat muncul
        _playBounceAnimation();
      }
    });
  }

  void _playBounceOutAnimation() {
    _slideController.forward();
    _bounceOutController.forward();
  }

  void _playBounceAnimation() {
    _bounceOutController.reset();
    _bounceInController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceOutController.dispose();
    _bounceInController.dispose();
    _scrollIdleTimer?.cancel();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          if (widget.showBuildNumber) {
            _versionInfo = "v${packageInfo.version}+${packageInfo.buildNumber}";
          } else {
            _versionInfo = "v${packageInfo.version}";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _versionInfo = "v?";
        });
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: widget.margin,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _isScrolling ? _bounceOutAnimation : _bounceInAnimation,
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: _isExpanded ? 10 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  // Liquid Glass Effect
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(_isExpanded ? 16 : 12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICON dengan gradient background
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.25),
                            Colors.blue.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.info_outlined,
                        size: 14,
                        color: Colors.blue.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // VERSION TEXT
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isExpanded)
                          Text(
                            "Build Version",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54,
                              letterSpacing: 0.3,
                            ),
                          ),
                        Text(
                          _versionInfo,
                          style: GoogleFonts.poppins(
                            fontSize: _isExpanded ? 13 : 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : Colors.blue.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    if (_isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified Version - untuk yang langsung tampil
class SimpleVersionBadge extends StatefulWidget {
  final Alignment alignment;
  final EdgeInsets margin;

  const SimpleVersionBadge({
    super.key,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(12),
  });

  @override
  State<SimpleVersionBadge> createState() => _SimpleVersionBadgeState();
}

class _SimpleVersionBadgeState extends State<SimpleVersionBadge> {
  String _versionInfo = "v0.0.0";

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _versionInfo = "v${packageInfo.version}";
      });
    } catch (e) {
      setState(() {
        _versionInfo = "v?";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.margin,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.blue.shade900.withOpacity(0.4)
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _versionInfo,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
