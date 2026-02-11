import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'market_analysis_detail_controller.dart';

class MarketAnalysisDetailPage extends StatelessWidget {
  final String slug;

  const MarketAnalysisDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketAnalysisDetailController());
    controller.fetchDetail(slug);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isDark ? Colors.black : Colors.grey[50],
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0.5,
        forceMaterialTransparency: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'Market Analysis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: IconButton(
        //       icon: Icon(
        //         Icons.more_vert,
        //         color: isDark ? Colors.white : Colors.black,
        //       ),
        //       onPressed: () {
        //         // Menu functionality
        //       },
        //     ),
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CustomColor.secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    color: CustomColor.secondaryColor,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Memuat data...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          );
        }

        // ✅ Show error state if there's an error
        if (controller.errorMessage.value != null &&
            controller.errorMessage.value!.isNotEmpty) {
          return _buildErrorState(context, controller, slug);
        }

        final data = controller.analysis.value;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CustomColor.secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: CustomColor.secondaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Data tidak ditemukan",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Coba muat ulang halaman",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // 1. HERO IMAGE WITH GRADIENT OVERLAY
              // ============================================
              Stack(
                children: [
                  // Image
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(data.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Content over image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: CustomColor.secondaryColor.withOpacity(
                                0.9,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '📊 Market Analysis',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            data.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ============================================
              // 2. METADATA SECTION
              // ============================================
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author & Date row
                    Row(
                      children: [
                        // Author Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.08),
                          backgroundImage:
                              data.authorAvatar != null
                                  ? NetworkImage(data.authorAvatar!)
                                  : null,
                          child:
                              data.authorAvatar == null
                                  ? Icon(
                                    Icons.person,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),

                        // Author info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.authorName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                data.authorSpecialist ?? 'Analyst',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Follow button (bisa di-uncomment sesuai kebutuhan)
                        // Container(
                        //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //   decoration: BoxDecoration(
                        //     color: CustomColor.secondaryColor.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Text(
                        //     'Follow',
                        //     style: TextStyle(
                        //       color: CustomColor.secondaryColor,
                        //       fontWeight: FontWeight.w600,
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Metadata badges
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildMetadataBadge(
                          context,
                          icon: Icons.calendar_today,
                          label: _formatDate(data.publishDate),
                          isDark: isDark,
                        ),
                        _buildMetadataBadge(
                          context,
                          icon: Icons.access_time,
                          label: '5 min read',
                          isDark: isDark,
                        ),
                        _buildMetadataBadge(
                          context,
                          icon: Icons.visibility,
                          label: '1.2K views',
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),

                    const SizedBox(height: 20),

                    // Share buttons - Modern Design
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Article',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showShareBottomSheet(context, data.title);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColor.secondaryColor
                                  .withOpacity(0.1),
                              foregroundColor: CustomColor.secondaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: CustomColor.secondaryColor.withOpacity(
                                    0.3,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.share,
                                  size: 18,
                                  color: CustomColor.secondaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Share This Article',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: CustomColor.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ============================================
              // 3. CONTENT SECTION
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        isDark
                            ? Border.all(color: Colors.white10, width: 1)
                            : null,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Html(
                    data: data.content,
                    style: {
                      "p": Style(
                        fontSize: FontSize(16),
                        color: isDark ? Colors.white : Colors.black87,
                        lineHeight: LineHeight(1.8),
                        margin: Margins.only(bottom: 16),
                      ),
                      "h2": Style(
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        margin: Margins.only(top: 24, bottom: 12),
                      ),
                      "h3": Style(
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      "ul": Style(
                        lineHeight: LineHeight(2),
                        margin: Margins.symmetric(vertical: 16),
                      ),
                      "li": Style(
                        fontSize: FontSize(16),
                        color: isDark ? Colors.white : Colors.black87,
                        lineHeight: LineHeight(1.8),
                      ),
                      "a": Style(
                        color: CustomColor.secondaryColor,
                        textDecoration: TextDecoration.underline,
                      ),
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ============================================
              // 4. CTA SECTION
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomColor.secondaryColor.withOpacity(0.8),
                        CustomColor.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to trade?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buka akun Anda sekarang dan mulai trading dengan strategi terbaik',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to trading or signup
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: CustomColor.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Mulai Trading Sekarang',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ============================
  // METADATA BADGE WIDGET
  // ============================
  Widget _buildMetadataBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border:
            isDark
                ? Border.all(color: Colors.white10, width: 1)
                : Border.all(color: Colors.black12, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: CustomColor.secondaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // ERROR STATE WIDGET
  // ============================
  Widget _buildErrorState(
    BuildContext context,
    dynamic controller,
    String slug,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorType = controller.errorType.value;
    final errorMessage = controller.errorMessage.value ?? 'Terjadi kesalahan';

    // Determine icon dan warna berdasarkan error type
    IconData errorIcon = Icons.error_outline;
    Color iconColor = Colors.orange;
    String title = 'Terjadi Kesalahan';

    switch (errorType) {
      case 'timeout':
        errorIcon = Icons.schedule;
        iconColor = Colors.amber;
        title = 'Koneksi Lambat';
        break;
      case 'network':
        errorIcon = Icons.wifi_off;
        iconColor = Colors.red;
        title = 'Koneksi Internet Error';
        break;
      case 'server':
        errorIcon = Icons.cloud_off;
        iconColor = Colors.blue;
        title = 'Server Error';
        break;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error Icon with gradient background
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.1),
                ),
                child: Icon(errorIcon, size: 64, color: iconColor),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Error Message
              Text(
                errorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.retry(slug);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Helpful text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Tips:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTipText(context, '1. Periksa koneksi internet Anda'),
                    _buildTipText(
                      context,
                      '2. Tutup aplikasi lain yang menggunakan internet',
                    ),
                    _buildTipText(context, '3. Coba lagi dalam beberapa saat'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipText(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }

  // ============================
  // DATE FORMATTER INDONESIA
  // ============================
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";

    try {
      final dateOnly = rawDate.split("T").first;
      final date = DateTime.parse(dateOnly);

      return DateFormat("EEEE, d MMMM yyyy", "id_ID").format(date);
    } catch (_) {
      return rawDate;
    }
  }

  // ============================
  // MODERN SHARE BOTTOM SHEET
  // ============================
  void _showShareBottomSheet(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share Article',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social Share Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    icon: 'facebook',
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      _shareToFacebook(title);
                      Navigator.pop(context);
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: 'twitter',
                    label: 'X',
                    color: isDark ? Colors.white : Colors.black,
                    onTap: () {
                      _shareToTwitter(title);
                      Navigator.pop(context);
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: 'whatsapp',
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      _shareToWhatsApp(title);
                      Navigator.pop(context);
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: 'link',
                    label: 'Copy Link',
                    color: CustomColor.secondaryColor,
                    onTap: () {
                      _copyToClipboard(title);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // More Share Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _shareMore(title);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('More Options'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================
  // SHARE OPTION WIDGET
  // ============================
  Widget _buildShareOption(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient background pada hover
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                // Icon based on platform
                _buildSocialIcon(icon, color),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================
  // SOCIAL ICON BUILDER
  // ============================
  Widget _buildSocialIcon(String platform, Color color) {
    switch (platform) {
      case 'facebook':
        return Icon(Icons.facebook, color: color, size: 28);
      case 'twitter':
        return Icon(FontAwesome.x_twitter_brand, color: color, size: 28);
      case 'whatsapp':
        return Icon(Iconsax.whatsapp_bold, color: color, size: 28);
      case 'link':
        return Icon(Icons.link, color: color, size: 28);
      default:
        return Icon(Icons.share, color: color, size: 28);
    }
  }

  // ============================
  // SHARE FUNCTIONS
  // ============================
  Future<void> _shareToFacebook(String title) async {
    const facebookUrl =
        'https://www.facebook.com/sharer/sharer.php?u=https://app.rrfx.co.id/market-analysis';
    if (await canLaunchUrl(Uri.parse(facebookUrl))) {
      await launchUrl(Uri.parse(facebookUrl));
      Get.snackbar(
        'Dibagikan ke Facebook',
        'Artikel berhasil dibagikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1877F2),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka Facebook');
    }
  }

  Future<void> _shareToTwitter(String title) async {
    final twitterUrl =
        'https://twitter.com/intent/tweet?text=$title&url=https://app.rrfx.co.id/market-analysis';
    if (await canLaunchUrl(Uri.parse(twitterUrl))) {
      await launchUrl(Uri.parse(twitterUrl));
      Get.snackbar(
        'Dibagikan ke X (Twitter)',
        'Artikel berhasil dibagikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka Twitter/X');
    }
  }

  Future<void> _shareToWhatsApp(String title) async {
    final whatsappUrl =
        'https://wa.me/?text=$title - https://app.rrfx.co.id/market-analysis';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
      Get.snackbar(
        'Dibagikan ke WhatsApp',
        'Artikel berhasil dibagikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF25D366),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
    }
  }

  Future<void> _copyToClipboard(String title) async {
    const link = 'https://app.rrfx.co.id/market-analysis';
    await Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'Link Copied!',
      'URL berhasil disalin ke clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CustomColor.secondaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> _shareMore(String title) async {
    const link = 'https://app.rrfx.co.id/market-analysis';
    await Share.share('$title\n\n$link', subject: title);
    Get.snackbar(
      'Dibagikan',
      'Artikel berhasil dibagikan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CustomColor.secondaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
