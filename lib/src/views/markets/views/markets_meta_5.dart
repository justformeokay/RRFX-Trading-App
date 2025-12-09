import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
// Asumsikan path import ini sudah benar di project Anda
import 'package:rrfx/src/views/markets/controllers/market_mt5_controller.dart'; 
import 'package:rrfx/src/views/markets/models/market_mt5_model.dart';
import 'package:rrfx/src/views/markets/components/empty_market_state.dart';
import 'package:rrfx/src/views/advance_charts/webview_chart_view_from_tile.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';

// Definisi warna trading (tetap)
const Color _upColor = Colors.blue;
const Color _downColor = Colors.red;
const Color _neutralColor = Colors.grey;

class MarketsMeta5View extends GetView<MarketMt5Controller> {
  const MarketsMeta5View({super.key});

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
          
          final isDark = Get.isDarkMode;
          return Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.isConnected.value 
                    ? Colors.green 
                    : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                controller.isConnected.value ? 'Live Market' : 'Disconnected',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          );
        }),
        actions: [
          Obx(() => isSearching.value
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
                ],
              )
            : IconButton(
                icon: Icon(
                  Iconsax.search_normal_outline,
                  color: CustomColor.secondaryColor,
                ),
                onPressed: () {
                  isSearching.value = true;
                },
                tooltip: 'Search Market',
              ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
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
            final secondaryTextColor = isDarkMode ? Colors.grey[600] : Colors.grey[400];
            
            // Cek apakah market sedang tutup (weekend/holiday)
            final now = DateTime.now();
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
            return Column(
              children: [
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
                        searchQuery.value, // Pass search query for highlighting
                      ); 
                    },
                  ),
                ),
              ],
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
    [String searchQuery = ''] // Optional search query for highlighting
  ) {
    final accountController = Get.put(AccountController());

    final DateTime time = DateTime.fromMillisecondsSinceEpoch(model.datetimeMsc);
    final int decimalPlaces = isZeroDecimal ? 0 : (isTwoDecimal ? 2 : model.digits);
    final spreadInt = calcSpread(model.symbol, model.spread);

    void goToChart() {
      Get.to(() => WebViewChartViewFromTile(
        login: int.tryParse(accountController.selectedAccount.value?.login ?? "0") ?? 0,
        marketName: model.symbol,
        balance: double.tryParse(accountController.selectedAccount.value?.balance ?? "0"),
      ));
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

    return Dismissible(
      key: Key(model.symbol),
      direction: DismissDirection.endToStart,

      background: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(Iconsax.arrow_swap_horizontal_outline, color: Colors.white),
      ),

      // === TAP WRAPPER ===
      child: InkWell(
        onTap: goToChart,
        child: Container(
          color: Get.isDarkMode ? Colors.black : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                          fontSize: 12,
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
                      style: TextStyle(color: secondaryTextColor, fontSize: 10),
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
                      style: TextStyle(color: secondaryTextColor, fontSize: 10),
                    ),
                  ],
                ),
              ],
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
    
    // Tampilan sederhana jika:
    // 1. JPK (0 desimal)
    // 2. Pair dengan 1 desimal
    if (isZeroDecimal || decimalDigits == 1) {
        return Text(
          priceStr, 
          style: TextStyle(
              color: color, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
          ),
        );
    }

    // Tampilan RichText untuk 2 desimal (UNK, UPK, CLSK, XAUUSD)
    if (isTwoDecimal || decimalDigits == 2) {
        final dotIndex = priceStr.indexOf('.');
        if (dotIndex == -1) {
            return Text(
              priceStr, 
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)
            );
        }
        
        // Split: integer part + dot dan 2 decimal digits
        String integerPart = priceStr.substring(0, dotIndex + 1); // "2432."
        String decimalPart = priceStr.substring(dotIndex + 1); // "43"
        
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
    }

    // --- Logika RichText (Hanya untuk Pair dengan 3 atau lebih desimal) ---
    final dotIndex = priceStr.indexOf('.');
    
    if (dotIndex == -1 || decimalDigits < 3) {
        // Fallback jika format tidak sesuai
        return Text(
          priceStr, 
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
        );
    }
    
    // Tentukan aturan pemisahan berdasarkan jumlah digit desimal total
    int prefixDecimals; // Jumlah digit desimal untuk Prefix (ukuran sedang)
    int majorPipDigits; // Jumlah digit desimal untuk Major Pip (ukuran besar)

    if (decimalDigits == 3) {
        // EURJPY, XAGUSD: 1 desimal Prefix, 1 digit Major Pip, 1 digit Pipette.
        // Contoh: 180.725 -> 180.7 | 2 | 5
        prefixDecimals = 1; 
        majorPipDigits = 1;
    } else if (decimalDigits >= 4) { 
        // AUDUSD, EURUSD: 2 desimal Prefix, 2 digit Major Pip, 1 digit Pipette.
        // Contoh: 0.65757 -> 0.65 | 75 | 7
        prefixDecimals = 2; 
        majorPipDigits = 2;
    } else {
       // Should not happen, but serves as a safeguard
       return Text(priceStr, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold));
    }
    
    // Hitung posisi pemotongan
    // Posisi 1: Prefix (Semua sebelum desimal, ditambah '.' dan prefixDecimals)
    final int endPrefix = dotIndex + 1 + prefixDecimals; 
    
    // Posisi 2: Major Pip (Prefix + majorPipDigits)
    final int endMajorPip = endPrefix + majorPipDigits; 

    // Posisi 3: Pipette (Digit terakhir)
    final int endPipette = priceStr.length;

    // Pastikan posisi pemotongan valid (untuk menghindari error substring out of range)
    if (endMajorPip >= endPipette || endPrefix >= endMajorPip) {
       // Fallback jika string tidak cukup panjang untuk pembagian 3 bagian
       return Text(
          priceStr, 
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
        );
    }

    // Pemotongan String
    String prefixPart = priceStr.substring(0, endPrefix);      
    String majorPipPart = priceStr.substring(endPrefix, endMajorPip); 
    String pipetteDigit = priceStr.substring(endMajorPip, endPipette); 

    // 3. Implementasi RichText untuk 3+ desimal: prefix, major pip, dan pipette
    return RichText(
      text: TextSpan(
        children: <InlineSpan>[ 
          // Bagian 1: Prefix (Sedang/Normal)
          TextSpan(
            text: prefixPart,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Ukuran sedang
            ),
          ),
          // Bagian 2: Major Pip (Besar/Tebal)
          TextSpan(
            text: majorPipPart,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900, // Sangat tebal
              fontSize: 24, // Ukuran besar
            ),
          ),
          // Bagian 3: Pipette (Terkecil/Superscript)
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Transform.translate(
              // Geser sedikit ke atas dan sesuaikan ukuran
              offset: const Offset(0, -6),
              child: Text(
                pipetteDigit,
                style: TextStyle(
                  color: color,
                  fontSize: 11, // Ukuran terkecil
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}