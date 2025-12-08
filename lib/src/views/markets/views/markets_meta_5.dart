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

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    Get.put(MarketMt5Controller());
    RxBool isLoading = false.obs;
    
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Obx(() {
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
        // actions: [
        //   Obx(() => IconButton(
        //     onPressed: controller.isReconnecting.value 
        //       ? null 
        //       : () {
        //           controller.retryConnection();
        //         },
        //     icon: controller.isReconnecting.value
        //       ? SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(
        //             strokeWidth: 2,
        //             color: CustomColor.secondaryColor,
        //           ),
        //         )
        //       : Icon(
        //           Iconsax.refresh_outline,
        //           color: CustomColor.secondaryColor,
        //         ),
        //     tooltip: 'Reconnect',
        //   )),
        // ],
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
            
            // Data tersedia, tampilkan list
            final symbols = controller.marketData.keys.toList();
            
            return ListView.builder(
              itemCount: symbols.length,
              itemBuilder: (context, index) {
                final model = controller.marketData[symbols[index]]!;
                final bool isZeroDecimal = _isZeroDecimalPair(model.symbol);
                
                return _buildMarketTile(
                  model, 
                  fgColor, 
                  secondaryTextColor!, 
                  isZeroDecimal
                ); 
              },
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
  ) {
    final accountController = Get.put(AccountController());

    final DateTime time = DateTime.fromMillisecondsSinceEpoch(model.datetimeMsc);
    final int decimalPlaces = isZeroDecimal ? 0 : model.digits;
    final spreadInt = calcSpread(model.symbol, model.spread);

    void goToChart() {
      Get.to(() => WebViewChartViewFromTile(
        login: int.tryParse(accountController.selectedAccount.value?.login ?? "0") ?? 0,
        marketName: model.symbol,
        balance: double.tryParse(accountController.selectedAccount.value?.balance ?? "0"),
      ));
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
                      Text(
                        model.symbol,
                        style: GoogleFonts.inter(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
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
                  children: [
                    Row(
                      children: [
                        _buildPriceText(model.bid, model.previousBid, decimalPlaces, isZeroDecimal),
                        const SizedBox(width: 16),
                        _buildPriceText(model.ask, model.previousAsk, decimalPlaces, isZeroDecimal),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'L: ${model.bidLow.toStringAsFixed(decimalPlaces)}',
                          style: TextStyle(color: secondaryTextColor, fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'H: ${model.askHigh.toStringAsFixed(decimalPlaces)}',
                          style: TextStyle(color: secondaryTextColor, fontSize: 10),
                        ),
                      ],
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
    
    // Tampilan sederhana jika 0 desimal (hanya JPK)
    if (isZeroDecimal || decimalDigits == 0) {
        return Text(
          priceStr, 
          style: TextStyle(
              color: color, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
          ),
        );
    }
    
    // Untuk 1 desimal, tampilkan sederhana
    if (decimalDigits == 1) {
        return Text(
          priceStr, 
          style: TextStyle(
              color: color, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
          ),
        );
    }

    // --- Logika RichText (untuk 2 desimal ke atas) ---
    final dotIndex = priceStr.indexOf('.');
    
    if (dotIndex == -1 || decimalDigits < 2) {
        // Fallback jika format tidak sesuai
        return Text(
          priceStr, 
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
        );
    }
    
    // Tentukan aturan pemisahan berdasarkan jumlah digit desimal total
    int prefixDecimals; // Jumlah digit desimal untuk Prefix (ukuran sedang)
    int majorPipDigits; // Jumlah digit desimal untuk Major Pip (ukuran besar)

    if (decimalDigits == 2) {
        // UNK, UPK, XAUUSD: Integer part sedang, 2 digit desimal besar
        // Contoh: 25796.00 -> 25796. | 00
        //         6889.50 -> 6889. | 50
        //         4210.69 -> 4210. | 69
        prefixDecimals = 0; // Hanya sampai titik
        majorPipDigits = 2; // 2 digit desimal besar
    } else if (decimalDigits == 3) {
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

    // 3. Implementasi RichText 
    // Untuk 2 desimal (UNK, UPK): tidak ada pipette, hanya prefix (integer+dot) dan major (2 digit desimal)
    if (decimalDigits == 2) {
      return RichText(
        text: TextSpan(
          children: <InlineSpan>[
            // Bagian 1: Integer + titik (ukuran sedang)
            TextSpan(
              text: priceStr.substring(0, dotIndex + 1), // "25796."
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16, // Ukuran sedang
              ),
            ),
            // Bagian 2: 2 digit desimal (ukuran besar)
            TextSpan(
              text: priceStr.substring(dotIndex + 1), // "00" atau "50"
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22, // Ukuran besar
              ),
            ),
          ],
        ),
      );
    }
    
    // Untuk 3+ desimal: prefix, major pip, dan pipette
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
                  fontSize: 12, // Ukuran terkecil
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}