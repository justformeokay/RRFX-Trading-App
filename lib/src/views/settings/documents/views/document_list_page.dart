import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import '../controllers/document_controller.dart';
import '../models/document_model.dart';

class DocumentListPage extends StatefulWidget {
  const DocumentListPage({super.key, this.loginID});
  final String? loginID;

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  late final DocumentController documentController;
  late final TextEditingController _searchController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    documentController = Get.put(DocumentController());
    if (widget.loginID != null) {
      documentController.fetchDocuments(loginID: widget.loginID!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final primaryColor = CustomColor.secondaryColor;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: Obx(() {
        if (documentController.isLoading.value) {
          return _buildLoadingState();
        }
        if (documentController.documents.isEmpty) {
          return _buildEmptyState(documentController);
        }

        final query = _searchController.text.toLowerCase();
        final filteredDocs = documentController.documents.where((doc) {
          final docName = doc.name.toLowerCase();
          final matchesFilter = _selectedFilter == 'all' ||
              docName.contains(_selectedFilter.toLowerCase());
          final matchesSearch = query.isEmpty || docName.contains(query);
          return matchesFilter && matchesSearch;
        }).toList();

        return CustomScrollView(
          slivers: [
            // Header Section
            _buildHeaderSection(primaryColor, isDarkMode),

            // Search & Filter Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: _buildSearchFilterSection(isDarkMode),
              ),
            ),

            // Document List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = filteredDocs[index];
                    return AnimatedScale(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      scale: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildModernDocumentCard(
                          context,
                          doc,
                          documentController,
                          isDarkMode,
                          primaryColor,
                        ),
                      ),
                    );
                  },
                  childCount: filteredDocs.length,
                ),
              ),
            ),

            // Bottom Padding
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: SliverToBoxAdapter(child: Container()),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: CustomColor.secondaryColor),
          const SizedBox(height: 16),
          Text(
            "Memuat dokumen...",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DocumentController controller) {
    final isDarkMode = Get.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColor.secondaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Iconsax.document_outline,
                size: 70,
                color: CustomColor.secondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Tidak Ada Dokumen",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dokumen Anda akan muncul di sini setelah tersedia",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.fetchDocuments(loginID: widget.loginID);
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  "Muat Ulang",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color primaryColor, bool isDarkMode) {
    return SliverAppBar(
      forceMaterialTransparency: true,
      expandedHeight: 125,
      collapsedHeight: 56,
      pinned: true,
      primary: true,
      elevation: 0,
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.12),
                primaryColor.withOpacity(0.03),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Dokumen Saya",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kelola semua dokumen penting Anda",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: primaryColor,
          ),
        ),
      ),
      leadingWidth: 50,
    );
  }

  Widget _buildSearchFilterSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: "Cari dokumen...",
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Iconsax.search_normal_outline,
                size: 20,
                color: CustomColor.secondaryColor,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(height: 14),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Semua', 'all', isDarkMode),
              const SizedBox(width: 8),
              _buildFilterChip('PDF', 'pdf', isDarkMode),
              const SizedBox(width: 8),
              _buildFilterChip('Terbaru', 'recent', isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDarkMode) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? CustomColor.secondaryColor
                  : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? CustomColor.secondaryColor
                    : (isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildModernDocumentCard(
    BuildContext context,
    Document doc,
    DocumentController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewDocument(doc),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Document Icon with Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.document_text_outline,
                        size: 32,
                        color: primaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "PDF",
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Document Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.file_download_outlined,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "PDF Document",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Buttons
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') {
                      controller.viewDocument(doc);
                    } else if (value == 'download') {
                      controller.downloadDocument(doc);
                    } else if (value == 'share') {
                      controller.shareDocument(doc);
                    }
                  },
                  icon: Icon(
                    Iconsax.more_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.eye_outline,
                            size: 18,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Lihat',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.import_outline,
                            size: 18,
                            color: Colors.blue.shade500,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Unduh',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.share_outline,
                            size: 18,
                            color: Colors.green.shade500,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Bagikan',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}