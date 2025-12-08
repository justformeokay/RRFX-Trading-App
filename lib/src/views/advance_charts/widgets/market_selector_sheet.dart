import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import '../controllers/symbols_controller.dart';
import '../models/symbol_model.dart';

class MarketSelectorSheet extends StatefulWidget {
  final Function(SymbolModel)? onSymbolSelected;

  const MarketSelectorSheet({
    super.key,
    this.onSymbolSelected,
  });

  @override
  State<MarketSelectorSheet> createState() => _MarketSelectorSheetState();
}

class _MarketSelectorSheetState extends State<MarketSelectorSheet> {
  final symbolsController = Get.put(SymbolsController());
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch symbols if not loaded
    if (symbolsController.allSymbols.isEmpty) {
      symbolsController.fetchSymbols();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Iconsax.chart_outline,
                  color: CustomColor.secondaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pilih Market',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Iconsax.close_circle_outline,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) => symbolsController.searchSymbols(value),
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Cari symbol (EURUSD, XAUUSD, dll)',
                hintStyle: GoogleFonts.inter(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal_outline,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                suffixIcon: Obx(() {
                  return symbolsController.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Iconsax.close_circle_outline,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            searchController.clear();
                            symbolsController.clearSearch();
                          },
                        )
                      : const SizedBox.shrink();
                }),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: Obx(() {
              // Loading state
              if (symbolsController.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: CustomColor.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat daftar market...',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Error state
              if (symbolsController.hasError.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.info_circle_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal Memuat Market',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          symbolsController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => symbolsController.refreshSymbols(),
                          icon: const Icon(Iconsax.refresh_outline, color: Colors.black),
                          label: Text(
                            'Coba Lagi',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColor.secondaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
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

              // Empty state
              if (symbolsController.filteredSymbols.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_normal_outline,
                          size: 64,
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Market Tidak Ditemukan',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba gunakan kata kunci lain',
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Symbol list grouped by category
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: symbolsController.searchQuery.value.isEmpty
                    ? symbolsController.symbolGroups.length
                    : 1,
                itemBuilder: (context, index) {
                  if (symbolsController.searchQuery.value.isNotEmpty) {
                    // Show filtered results without grouping
                    return _buildSymbolList(
                      'Hasil Pencarian',
                      symbolsController.filteredSymbols,
                      isDark,
                    );
                  } else {
                    // Show grouped results
                    final group = symbolsController.symbolGroups[index];
                    return _buildSymbolList(
                      group.name,
                      group.symbols,
                      isDark,
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolList(String groupName, List<SymbolModel> symbols, bool isDark) {
    if (symbols.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            groupName,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CustomColor.secondaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Symbol items
        ...symbols.map((symbol) => _buildSymbolItem(symbol, isDark)),
      ],
    );
  }

  Widget _buildSymbolItem(SymbolModel symbol, bool isDark) {
    final isSelected = symbolsController.selectedSymbol.value?.symbol == symbol.symbol;

    return InkWell(
      onTap: () {
        symbolsController.selectSymbol(symbol);
        widget.onSymbolSelected?.call(symbol);
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? CustomColor.secondaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? CustomColor.secondaryColor
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Symbol info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol.symbolAlias,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(
                        'Spread: ${symbol.spread}',
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        'Lot: ${symbol.volumeMin}-${symbol.volumeMax}',
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Icon(
                Iconsax.tick_circle_bold,
                color: CustomColor.secondaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }
}
