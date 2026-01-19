import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/markets/controllers/market_mt5_controller.dart'; 
import 'package:rrfx/src/views/markets/models/market_mt5_model.dart';
import 'package:rrfx/src/views/trade/derivchart_without_loginid.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';

// Definisi warna trading (tetap)
const Color _upColor = Colors.blue;
const Color _downColor = Colors.red;
const Color _neutralColor = Colors.grey;

class MarketsMeta5NoAuth extends GetView<MarketMt5Controller> {
  const MarketsMeta5NoAuth({super.key});

  // --- Helper: Menentukan apakah sebuah simbol harus 0 desimal ---
  bool _isZeroDecimalPair(String symbol) {
    // List simbol yang harga Bid/Ask/Low/High-nya harus integer
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
    
    final RxString searchQuery = ''.obs;
    final TextEditingController searchController = TextEditingController();
    final RxBool isSearching = false.obs;
    
    // Tentukan warna latar belakang dan teks berdasarkan tema sistem
    final isDarkMode = Get.isDarkMode;
    final fgColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[600] : Colors.grey[400];
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        forceMaterialTransparency: true,
        title: Row(
          children: [
            Obx(() {
              if (isSearching.value) {
                return Expanded(
                  child: TextField(
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
                  ),
                );
              }
              
              return Expanded(
                child: Row(
                  children: [
                    Text(
                      'Live Markets',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildConnectionIndicator(),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          Obx(() => isSearching.value
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchQuery.value.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle_outline,
                        color: CustomColor.secondaryColor,
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
                  color: Colors.blue,
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
        child: isForexHoliday()
            ? _buildMarketHolidayState()
            : Obx(
                () {
                  // WebSocket Status Handling
                  if (controller.isReconnecting.value) {
                    return _buildConnectingState();
                  }
                  
                  if (controller.hasConnectionError.value) {
                    return _buildErrorState();
                  }
                  
                  if (!controller.isConnected.value) {
                    return _buildDisconnectedState();
                  }
            
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
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.search_status_outline,
                        size: 64,
                        color: Colors.blue,
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
            
            return Column(
              children: [
                // Search result info (only show when searching)
                if (searchQuery.value.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
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
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${filteredSymbols.length} of ${allSymbols.length} markets',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
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
                        searchQuery.value,
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
    [String searchQuery = '']
  ) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(model.datetimeMsc);
    final int decimalPlaces = isZeroDecimal ? 0 : (isTwoDecimal ? 2 : model.digits);
    final spreadInt = calcSpread(model.symbol, model.spread); 
    final String marketForTradingView = model.symbol.contains('.')
        ? model.symbol.split('.').first
        : model.symbol;

    void goToChart() {
      Get.to(() => TradingChartView(marketName: marketForTradingView));
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
                color: Colors.blue,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                backgroundColor: Colors.blue.withOpacity(0.2),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Connecting',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      }
      
      if (controller.hasConnectionError.value || !controller.isConnected.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Offline',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      }
      
      // Connected
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
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
            const SizedBox(width: 6),
            Text(
              'Live',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.chart_outline,
                  size: 32,
                  color: Colors.blue,
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

  // Disconnected State
  Widget _buildDisconnectedState() {
    final isDarkMode = Get.isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.wifi_square_outline,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Disconnected',
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
              'No connection to market data server.\nTap the button below to reconnect.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => controller.connectWebSocket(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(Iconsax.refresh_outline, size: 20),
            label: Text(
              'Reconnect',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState() {
    final isDarkMode = Get.isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.close_circle_outline,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connection Failed',
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
              'Unable to connect to market data server.\nPlease check your internet connection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => controller.connectWebSocket(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(Iconsax.refresh_outline, size: 20),
            label: Text(
              'Try Again',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Market Holiday State
  Widget _buildMarketHolidayState() {
    final isDarkMode = Get.isDarkMode;
    final now = DateTime.now().toUtc();
    final dayName = _getDayName(now.weekday);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.calendar_outline,
              size: 64,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Market Closed',
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
              'The Forex market is currently closed.\n$dayName is a market holiday.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'This page is not accessible during market holidays.\nPlease try again when the market reopens.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get day name in English
  String _getDayName(int weekday) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}