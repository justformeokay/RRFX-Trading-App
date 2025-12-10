import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:share_plus/share_plus.dart';

class InviteLink extends StatefulWidget {
  const InviteLink({super.key});

  @override
  State<InviteLink> createState() => _InviteLinkState();
}

class _InviteLinkState extends State<InviteLink>
    with SingleTickerProviderStateMixin {
  final UtilitiesController utilitiesController =
      Get.put(UtilitiesController());
  late TabController _tabController;
  final RxString searchQuery = ''.obs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      utilitiesController.getRefferalLinks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String name) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      '✅ Berhasil!',
      'Link $name berhasil disalin',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Iconsax.tick_circle_bold, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  void _shareLink(String link, String name) {
    SharePlus.instance.share(ShareParams(
        text:
            '🎉 Yuk gabung ke Platform RRFX menggunakan tautan referral $name: $link'));
    Get.snackbar(
      '📤 Membagikan Link',
      'Berbagi link $name',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CustomColor.secondaryColor.withOpacity(0.9),
      colorText: Colors.black,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 1),
    );
  }

  List<dynamic> _filterLinks(List<dynamic> links) {
    if (searchQuery.value.isEmpty) return links;
    return links
        .where((link) => link.name
            .toString()
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Referral Links',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (utilitiesController.isLoading.value) {
          return _buildLoadingState(isDark);
        }

        final inviteModel = utilitiesController.inviteLinkModel.value;

        // Debug print
        print('🔍 InviteModel check: ${inviteModel != null}');
        print('🔍 General: ${inviteModel?.data?.general?.length}');
        print('🔍 Specific: ${inviteModel?.data?.spesific?.length}');

        // Show message if user is not a sales (no referral links)
        if (inviteModel == null || inviteModel.data == null) {
          // Check if the message indicates non-sales account
          if (utilitiesController.responseMessage.value.toLowerCase().contains('bukan sales') ||
              utilitiesController.responseMessage.value.toLowerCase().contains('tidak ada refferal')) {
            return _buildNoSalesState(isDark);
          }
          return _buildErrorState(isDark);
        }

        final generalLinks = inviteModel.data?.general ?? [];
        final specificLinks = inviteModel.data?.spesific ?? [];

        print('🔍 Final - General: ${generalLinks.length}, Specific: ${specificLinks.length}');

        if (generalLinks.isEmpty && specificLinks.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return Column(
          children: [
            // Header with stats
            _buildHeaderStats(generalLinks.length, specificLinks.length, isDark),

            // Search bar
            _buildSearchBar(isDark),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: CustomColor.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor:
                    isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.link_outline, size: 18),
                        const SizedBox(width: 8),
                        Text('General (${generalLinks.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.diamonds_outline, size: 18),
                        const SizedBox(width: 8),
                        Text('Specific (${specificLinks.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLinksList(generalLinks, isDark, isGeneral: true),
                  _buildLinksList(specificLinks, isDark, isGeneral: false),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }


  Widget _buildHeaderStats(int generalCount, int specificCount, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColor.secondaryColor.withOpacity(0.8),
            CustomColor.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColor.secondaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.share_bold,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Referral Links',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${generalCount + specificCount} Links',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'General',
                  generalCount.toString(),
                  Iconsax.link_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Specific',
                  specificCount.toString(),
                  Iconsax.diamonds_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                count,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => searchQuery.value = value,
        style: GoogleFonts.inter(
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Cari referral link...',
          hintStyle: GoogleFonts.inter(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal_outline,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          suffixIcon: Obx(() {
            return searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Iconsax.close_circle_outline,
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      searchQuery.value = '';
                    },
                  )
                : const SizedBox.shrink();
          }),
          filled: true,
          fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLinksList(List<dynamic> links, bool isDark,
      {required bool isGeneral}) {
    return Obx(() {
      final filteredLinks = _filterLinks(links);

      if (filteredLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.value.isEmpty
                      ? Iconsax.link_outline
                      : Iconsax.search_normal_outline,
                  size: 64,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.value.isEmpty
                      ? 'Tidak Ada Link'
                      : 'Tidak Ditemukan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchQuery.value.isEmpty
                      ? 'Belum ada referral link ${isGeneral ? "general" : "specific"}'
                      : 'Coba kata kunci lain',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: filteredLinks.length,
        itemBuilder: (context, index) {
          final linkData = filteredLinks[index];
          final String name = linkData.name ?? "-";
          final String link = linkData.link ?? "";

          return _buildLinkCard(name, link, isDark, isGeneral, index);
        },
      );
    });
  }

  Widget _buildLinkCard(
      String name, String link, bool isDark, bool isGeneral, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isGeneral
                      ? Colors.blue
                      : CustomColor.secondaryColor)
                  .withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isGeneral ? Colors.blue : CustomColor.secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isGeneral ? Iconsax.link_bold : Iconsax.diamonds_bold,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isGeneral
                                      ? Colors.blue
                                      : CustomColor.secondaryColor)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isGeneral ? 'GENERAL' : 'SPECIFIC',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isGeneral
                                    ? Colors.blue
                                    : CustomColor.secondaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#${(index + 1).toString().padLeft(2, '0')}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Link preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade900
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.link_21_outline,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          link,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(link, name),
                        icon: const Icon(Iconsax.copy_outline, size: 18),
                        label: Text(
                          'Copy',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareLink(link, name),
                        icon: const Icon(Iconsax.share_outline, size: 18, color: Colors.white,),
                        label: Text(
                          'Share',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isGeneral
                              ? Colors.blue
                              : CustomColor.secondaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/json/loader.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat referral links...',
            style: GoogleFonts.inter(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.info_circle_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Data',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              utilitiesController.responseMessage.value.isNotEmpty
                  ? utilitiesController.responseMessage.value
                  : 'Terjadi kesalahan saat memuat referral links',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => utilitiesController.getRefferalLinks(),
              icon: const Icon(Iconsax.refresh_outline, color: Colors.white),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.link_outline,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Referral Links',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Referral links Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSalesState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                Iconsax.user_outline,
                size: 60,
                color: CustomColor.secondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Akun Non-Sales',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              utilitiesController.responseMessage.value.isNotEmpty
                  ? utilitiesController.responseMessage.value
                  : 'Fitur referral link hanya tersedia untuk akun sales',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.info_circle_outline,
                    size: 20,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Hubungi admin untuk upgrade ke akun sales',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}