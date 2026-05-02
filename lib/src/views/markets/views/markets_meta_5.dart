import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
// Asumsikan path import ini sudah benar di project Anda
import 'package:rrfx/src/views/markets/controllers/market_mt5_controller.dart'; 
import 'package:rrfx/src/views/markets/models/market_mt5_model.dart';
import 'package:rrfx/src/views/markets/components/empty_market_state.dart';
import 'package:rrfx/src/controllers/navigation_controller.dart';
import 'package:rrfx/src/views/chart/controllers/chart_controller.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definisi warna trading (tetap)
const Color _upColor = Colors.blue;
const Color _downColor = Colors.red;
const Color _neutralColor = Colors.grey;

class MarketsMeta5View extends GetView<MarketMt5Controller> {
  const MarketsMeta5View({super.key});

  // --- Helper: Create demo account ---
  Future<void> _createDemoAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken == null || accessToken.isEmpty) {
      ModernAlertDialog.warning(
        title: 'Perlu Login',
        message: 'Anda harus login terlebih dahulu untuk membuat akun demo.',
        buttonText: 'OK',
        onPressed: () {
          Get.offAll(() => MainpageWithoutLogin());
        },
      );
      return;
    }
    try {
      final header = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final response = await http
          .post(Uri.parse('${GlobalVariable.mainURL}/regol/createDemo'), headers: header)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException('Request timeout');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accountController = Get.find<AccountController>();
        
        ModernAlertDialog.success(
          title: 'Berhasil',
          message: 'Akun demo berhasil dibuat! Refresh halaman untuk melihat akun demo Anda.',
          buttonText: 'OK',
          onPressed: () {
            Get.back();
            accountController.fetchAccountInfo();
          },
        );
      } else {
        ModernAlertDialog.error(
          title: 'Gagal',
          message: 'Gagal membuat akun demo. Coba lagi nanti.',
          buttonText: 'OK',
          onPressed: () => Get.back(),
        );
      }
    } on TimeoutException catch (_) {
      ModernAlertDialog.error(
        title: 'Timeout',
        message: 'Koneksi ke server memakan waktu terlalu lama. Coba lagi nanti.',
        buttonText: 'OK',
        onPressed: () => Get.back(),
      );
    } catch (e) {
      ModernAlertDialog.error(
        title: 'Gagal',
        message: 'Terjadi kesalahan saat membuat akun demo. Coba lagi nanti.',
        buttonText: 'OK',
        onPressed: () => Get.back(),
      );
    }
  }

  // --- Helper: Menentukan apakah sebuah simbol harus 0 desimal ---
  bool _isZeroDecimalPair(String symbol) {
    // JPK menggunakan format 0 desimal
    const zeroDecimalSymbols = ['JPK.DB'];
    return zeroDecimalSymbols.contains(symbol.toUpperCase());
  }

  // --- Helper: Menentukan apakah sebuah simbol harus 2 desimal ---
  bool _isTwoDecimalPair(String symbol) {
    // List simbol yang harus menampilkan 2 desimal (UNK, UPK, CLSK, XAUUSD, dll)
    const twoDecimalSymbols = ['UNK.DB', 'UPK.DB', 'CLSK.DB', 'XAUUSD.DB'];
    return twoDecimalSymbols.contains(symbol.toUpperCase());
  }

  // Filter markets based on search query
  List<String> _filterMarkets(Map<String, MarketMt5Model> marketData, String query) {
    if (query.isEmpty) {
      return marketData.keys.toList();
    }
    
    final lowerQuery = query.toLowerCase();
    return marketData.keys.where((symbol) {
      return symbol.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Format last update time
  String _formatLastUpdate(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    Get.put(MarketMt5Controller());
    RxBool isLoading = false.obs;
    final RxString searchQuery = ''.obs;
    final TextEditingController searchController = TextEditingController();
    final RxBool isSearching = false.obs;
    
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Obx(() {
          if (isSearching.value) {
            return TextField(
              controller: searchController,
              autofocus: true,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search market...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                searchQuery.value = value;
              },
            );
          }
          
          // Show selection count in edit mode
          if (controller.isEditMode.value) {
            return Obx(() => Text(
              "${controller.selectedMarkets.length} selected",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
            ));
          }
          
          final isDark = Get.isDarkMode;
          return Row(
            children: [
              Text("Live Markets", style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              )),
              const SizedBox(width: 8),
              _buildConnectionIndicator(),
            ],
          );
        }),
        actions: [
          Obx(() => controller.isEditMode.value
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Iconsax.archive_tick_outline,
                      color: controller.selectedMarkets.isEmpty 
                        ? Colors.grey.shade600 
                        : CustomColor.secondaryColor,
                    ),
                    onPressed: controller.selectedMarkets.isEmpty 
                      ? null 
                      : () {
                          controller.archiveSelected();
                          Get.snackbar(
                            'Archives',
                            '${controller.selectedMarkets.length} market(s) archived',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                    tooltip: 'Archive Selected',
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.close_square_outline,
                      color: CustomColor.secondaryColor,
                    ),
                    onPressed: () {
                      controller.toggleEditMode();
                    },
                    tooltip: 'Close Edit Mode',
                  ),
                ],
              )
            : isSearching.value
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchQuery.value.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle_outline,
                        color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      onPressed: () {
                        searchController.clear();
                        searchQuery.value = '';
                      },
                      tooltip: 'Clear',
                    ),
                  IconButton(
                    icon: Icon(
                      Iconsax.close_square_outline,
                      color: CustomColor.secondaryColor,
                    ),
                    onPressed: () {
                      searchController.clear();
                      searchQuery.value = '';
                      isSearching.value = false;
                    },
                    tooltip: 'Close Search',
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.archive_1_outline,
                      color: CustomColor.secondaryColor,
                    ),
                    onPressed: () {
                      controller.toggleEditMode();
                    },
                    tooltip: 'Edit Markets',
                  ),
                  IconButton(
                    icon: Obx(() => Badge.count(
                      count: controller.archivedMarkets.length,
                      isLabelVisible: controller.archivedMarkets.isNotEmpty,
                      child: Icon(
                        Iconsax.archive_2_outline,
                        color: CustomColor.secondaryColor,
                      ),
                    )),
                    onPressed: () {
                      _showArchivedMarketsDialog();
                    },
                    tooltip: 'View Archives',
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Obx(() => Badge.count(
                      count: controller.archivedMarkets.length,
                      isLabelVisible: controller.archivedMarkets.isNotEmpty,
                      child: Icon(
                        Iconsax.archive_2_outline,
                        color: CustomColor.secondaryColor,
                      ),
                    )),
                    onPressed: () {
                      _showArchivedMarketsDialog();
                    },
                    tooltip: 'View Archives',
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.search_normal_outline,
                      color: CustomColor.secondaryColor,
                    ),
                    onPressed: () {
                      isSearching.value = true;
                    },
                    tooltip: 'Search Market',
                  ),
                ],
              ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            // WebSocket Status Handling (Priority 0)
            if (controller.isReconnecting.value && controller.marketData.isEmpty) {
              return _buildConnectingState();
            }
            
            if(isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColor.secondaryColor,
                  strokeWidth: 1.0,
                ),
              );
            }
            // Tentukan warna latar belakang dan teks berdasarkan tema sistem
            final isDarkMode = Get.isDarkMode;
            final fgColor = isDarkMode ? Colors.white : Colors.black;
            final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey[700];
            
            // Cek apakah market sedang tutup (weekend/holiday) - gunakan UTC untuk konsistensi global
            final now = DateTime.now().toUtc();
            final isMarketClosed = isForexHoliday(now);
            
            // Priority 1: Cek jika market tutup
            if (isMarketClosed) {
              return EmptyMarketState(
                reason: MarketEmptyReason.marketClosed,
              );
            }
            
            // Priority 2: Cek error koneksi
            if (controller.hasConnectionError.value && controller.marketData.isEmpty) {
              return EmptyMarketState(
                reason: MarketEmptyReason.disconnected,
                onRetry: controller.retryConnection,
                isRetrying: controller.isReconnecting.value,
              );
            }
            
            // Priority 3: Cek data kosong
            if (controller.marketData.isEmpty) {
              // Jika sedang connecting, tampilkan empty state no data
              return EmptyMarketState(
                reason: MarketEmptyReason.noData,
              );
            }
            
            // Filter markets based on search query
            final allSymbols = controller.marketData.keys.toList();
            final filteredSymbols = _filterMarkets(controller.marketData, searchQuery.value);
            
            // Show "no results" if search query doesn't match any market
            if (searchQuery.value.isNotEmpty && filteredSymbols.isEmpty) {
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
                        Iconsax.search_status_outline,
                        size: 64,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Markets Found',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No markets match "${searchQuery.value}".\nTry a different search term.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Data tersedia, tampilkan list
            final screenWidth = MediaQuery.of(context).size.width;
            final isDesktop = screenWidth > 600;
            final maxWidth = isDesktop ? 420.0 : double.infinity;
            
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // Offline/Cached data banner
                    if (controller.isUsingCachedData.value || !controller.isConnected.value)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.orange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.warning_2_outline,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.lastUpdateTime.value != null
                                  ? 'Showing cached data from ${_formatLastUpdate(controller.lastUpdateTime.value!)}'
                                  : 'Showing cached data',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.retryConnection,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Search result info (only show when searching)
                    if (searchQuery.value.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: CustomColor.secondaryColor.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode 
                                ? Colors.grey.shade800 
                                : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.search_status_1_outline,
                              size: 16,
                              color: CustomColor.secondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${filteredSymbols.length} of ${allSymbols.length} markets',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: CustomColor.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Market list
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredSymbols.length,
                        itemBuilder: (context, index) {
                          final model = controller.marketData[filteredSymbols[index]]!;
                          final bool isZeroDecimal = _isZeroDecimalPair(model.symbol);
                          final bool isTwoDecimal = _isTwoDecimalPair(model.symbol);
                          
                          return _buildMarketTile(
                            model, 
                            fgColor, 
                            secondaryTextColor!, 
                            isZeroDecimal,
                            isTwoDecimal,
                            searchQuery: searchQuery.value, // Pass search query for highlighting
                          ); 
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int trimSpread(int spread) {
    final s = spread.toString();
    if (s.length == 1) {
      return int.parse(s); // 5 → 5
    }
    return int.parse(s.substring(0, 2)); // 125000 → 12
  }

  int calcSpread(String symbol, double spread) {
    bool isJPY = symbol.contains("JPY");
    int pip;
    if (isJPY) {
      pip = (spread * 1000).round();     // contoh: 18.200 → 18200
    } else {
      pip = (spread * 100000).round();   // contoh: 0.00125 → 125
    }
    return trimSpread(pip);
  }



  Widget _buildMarketTile(
    MarketMt5Model model, 
    Color primaryTextColor, 
    Color secondaryTextColor,
    bool isZeroDecimal,
    bool isTwoDecimal,
    {String searchQuery = ''} // Optional search query for highlighting
  ) {
    final accountController = Get.put(AccountController());

    final DateTime time = DateTime.fromMillisecondsSinceEpoch(model.datetimeMsc);
    final int decimalPlaces = isZeroDecimal ? 0 : (isTwoDecimal ? 2 : model.digits);
    final spreadInt = calcSpread(model.symbol, model.spread);

    void goToChart() {
      // Check if user has demo accounts
      if (accountController.demoAccounts.isEmpty) {
        ModernAlertDialog.warning(
          title: 'Belum Ada Akun Demo',
          message: 'Anda perlu membuat akun demo terlebih dahulu untuk menggunakan fitur chart trading. Tekan tombol di bawah untuk membuat akun demo.',
          buttonText: 'Buat Akun Demo',
          onPressed: _createDemoAccount,
        );
        return;
      }

      // Set market symbol ke ChartController lalu switch ke tab Trade (index 2)
      final chartController = Get.find<ChartControllers>();
      chartController.selectedMarket.value = model.symbol;
      NavigationController.to.goTo(2);
    }

    // Highlight matching text in symbol name
    Widget buildHighlightedSymbol() {
      if (searchQuery.isEmpty) {
        return Text(
          model.symbol,
          style: GoogleFonts.inter(
            color: primaryTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        );
      }

      final lowerSymbol = model.symbol.toLowerCase();
      final lowerQuery = searchQuery.toLowerCase();
      final index = lowerSymbol.indexOf(lowerQuery);

      if (index == -1) {
        return Text(
          model.symbol,
          style: GoogleFonts.inter(
            color: primaryTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        );
      }

      final before = model.symbol.substring(0, index);
      final match = model.symbol.substring(index, index + searchQuery.length);
      final after = model.symbol.substring(index + searchQuery.length);

      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: before,
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: match,
              style: GoogleFonts.inter(
                color: CustomColor.secondaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                backgroundColor: CustomColor.secondaryColor.withOpacity(0.2),
              ),
            ),
            TextSpan(
              text: after,
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final isSelected = controller.selectedMarkets.contains(model.symbol);
      final isInEditMode = controller.isEditMode.value;

      return Dismissible(
        key: Key(model.symbol),
        direction: isInEditMode ? DismissDirection.none : DismissDirection.endToStart,

        background: Container(
          color: Colors.green,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Icon(Iconsax.arrow_swap_horizontal_outline, color: Colors.white),
        ),

        // === TAP WRAPPER ===
        child: GestureDetector(
          onLongPress: isInEditMode ? null : () {
            controller.toggleEditMode();
            controller.toggleSelection(model.symbol);
          },
          child: InkWell(
            onTap: isInEditMode 
              ? () => controller.toggleSelection(model.symbol)
              : goToChart,
            child: Container(
              color: isSelected 
                ? CustomColor.secondaryColor.withOpacity(0.1)
                : (Get.isDarkMode ? Colors.black : Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Checkbox indicator (hanya muncul saat edit mode)
                    if (isInEditMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () => controller.toggleSelection(model.symbol),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? CustomColor.secondaryColor 
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected 
                                  ? CustomColor.secondaryColor 
                                  : (Get.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                          ),
                        ),
                      ),

                    // Kolom kiri
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHighlightedSymbol(),
                          const SizedBox(height: 4),
                          Text(
                            '${time.hour}:${time.minute}:${time.second} | Spread: $spreadInt',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Kolom kanan price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 85, // Fixed width untuk alignment
                          height: 28, // Fixed height untuk alignment
                          alignment: Alignment.centerRight,
                          child: _buildPriceText(model.bid, model.previousBid, decimalPlaces, isZeroDecimal, isTwoDecimal),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'L: ${model.bidLow.toStringAsFixed(decimalPlaces)}',
                          style: TextStyle(color: secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 85, // Fixed width untuk alignment
                          height: 28, // Fixed height untuk alignment
                          alignment: Alignment.centerRight,
                          child: _buildPriceText(model.ask, model.previousAsk, decimalPlaces, isZeroDecimal, isTwoDecimal),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'H: ${model.askHigh.toStringAsFixed(decimalPlaces)}',
                          style: TextStyle(color: secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // === SWIPE ACTION → GO TO PAGE ===
        confirmDismiss: (direction) async {
          goToChart();
          return false; // tile tetap ada
        },
      );
    });
  }


  // --- Fungsi untuk Implementasi Rich Text Harga Unik dengan 3 ukuran berbeda ---
  Widget _buildPriceText(
    double currentPrice,
    double previousPrice,
    int decimalDigits, // Jumlah desimal total (berasal dari model.digits atau 0)
    bool isZeroDecimal,
    bool isTwoDecimal,
  ) {
    // 1. Tentukan Warna
    Color color;
    if (currentPrice > previousPrice) {
      color = _upColor; // Biru
    } else if (currentPrice < previousPrice) {
      color = _downColor; // Merah
    } else {
      color = _neutralColor; 
    }

    String priceStr = currentPrice.toStringAsFixed(decimalDigits);
    
    // Tampilan sederhana jika digits < 2
    if (decimalDigits < 2) {
        return Text(
          priceStr, 
          style: TextStyle(
              color: color, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
          ),
        );
    }

    final dotIndex = priceStr.indexOf('.');
    
    if (dotIndex == -1) {
        // Fallback jika tidak ada titik desimal
        return Text(
          priceStr, 
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)
        );
    }

    // Ambil bagian desimal
    final decimalPart = priceStr.substring(dotIndex + 1);
    final integerPart = priceStr.substring(0, dotIndex + 1); // Include dot
    
    // Validasi panjang desimal
    if (decimalPart.length < decimalDigits) {
        return Text(
          priceStr, 
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
        );
    }

    // Logic berdasarkan digits (hitung dari belakang):
    // digits 2 = angka ke-2 sampai ke-1 besar
    // digits 3, 4, 5 = angka ke-3 sampai ke-2 besar, angka ke-1 kecil di atas

    if (decimalDigits == 2) {
        // digits 2: semua desimal besar
        // Contoh: 2432.43 -> "2432." (16px) + "43" (22px bold)
        return RichText(
          text: TextSpan(
            children: <InlineSpan>[
              // Integer + dot (ukuran normal)
              TextSpan(
                text: integerPart,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              // 2 decimal digits (ukuran besar)
              TextSpan(
                text: decimalPart,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        );
    } else if (decimalDigits >= 3 && decimalDigits <= 5) {
        // digits 3, 4, 5: dari belakang
        // - 1 digit terakhir = kecil di atas (superscript)
        // - 2 digit sebelumnya = besar
        // - sisanya = normal
        
        // Contoh digits 5: 0.65757
        // - Digit ke-1 dari belakang: "7" (superscript)
        // - Digit ke-3 sampai ke-2 dari belakang: "75" (besar)
        // - Sisanya: "0.65" (normal)
        
        // Ambil dari belakang
        final lastDigit = decimalPart[decimalPart.length - 1]; // digit ke-1 dari belakang
        final majorPips = decimalPart.substring(decimalPart.length - 3, decimalPart.length - 1); // digit ke-3 sampai ke-2 dari belakang
        final prefixDecimals = decimalPart.substring(0, decimalPart.length - 3); // sisanya
        
        return RichText(
          text: TextSpan(
            children: <InlineSpan>[
              // Bagian 1: Integer + dot + prefix decimals (ukuran normal)
              TextSpan(
                text: integerPart + prefixDecimals,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Bagian 2: Major pips - 2 digit sebelum terakhir (ukuran besar)
              TextSpan(
                text: majorPips,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              // Bagian 3: Last digit - pipette (superscript kecil)
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    lastDigit,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }

    // Fallback untuk digits > 5 atau kondisi lainnya
    return Text(
      priceStr, 
      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
    );
  }

  // Connection Status Indicator (in AppBar)
  Widget _buildConnectionIndicator() {
    return Obx(() {
      if (controller.isReconnecting.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Connecting',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      }
      
      if (controller.hasConnectionError.value || !controller.isConnected.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Offline',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      }
      
      // Connected
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Live',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    });
  }

  // Connecting State
  Widget _buildConnectingState() {
    final isDarkMode = Get.isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Loading Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(CustomColor.secondaryColor),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.chart_outline,
                  size: 32,
                  color: CustomColor.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Connecting to Market',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Please wait while we establish connection\nto the live market data server',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog untuk menampilkan archived markets
  void _showArchivedMarketsDialog() {
    final isDarkMode = Get.isDarkMode;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.archive_2_outline,
                      color: CustomColor.secondaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Archived Markets',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Obx(() => Badge.count(
                      count: controller.archivedMarkets.length,
                      backgroundColor: CustomColor.secondaryColor,
                    )),
                  ],
                ),
              ),
              
              // Content
              Obx(() {
                if (controller.archivedMarkets.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.archive_slash_outline,
                          size: 64,
                          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Archived Markets',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Markets you archive will appear here',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  constraints: BoxConstraints(
                    maxHeight: Get.height * 0.5,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.archivedMarkets.length,
                    itemBuilder: (context, index) {
                      final symbol = controller.archivedMarkets.toList()[index];
                      
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.archive_1_outline,
                                color: CustomColor.secondaryColor.withOpacity(0.6),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  symbol,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Iconsax.import_outline,
                                  color: CustomColor.secondaryColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  controller.unarchiveMarket(symbol);
                                  Get.back();
                                  Get.snackbar(
                                    'Restored',
                                    '$symbol restored to Live Markets',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                tooltip: 'Restore',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      foregroundColor: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.3),
    );
  }
}