import 'package:flutter/material.dart';

import 'number_formatter.dart';

// Class untuk menampilkan harga dengan digit terakhir sebagai superscript
class PriceDisplayWidget extends StatelessWidget {
  final String fullPriceString; // Contoh: "1.15462" atau "166.610"
  final Color textColor;
  final double mainFontSize;
  final double superscriptFontSize;
  final Color color;
  final double superscriptOffsetY; // Seberapa tinggi superscript dinaikkan (nilai negatif)

  const PriceDisplayWidget({super.key,
    required this.fullPriceString,
    this.textColor = Colors.blue, // Warna default seperti gambar
    this.mainFontSize = 36.0,    // Ukuran font utama
    this.superscriptFontSize = 20.0, // Ukuran font superscript
    this.superscriptOffsetY = -12.0,
    required this.color, // Sesuaikan nilai ini untuk mengatur posisi Y
  });

  @override
  Widget build(BuildContext context) {
    if (fullPriceString.isEmpty) {
      return Text(''); // Kembalikan widget kosong jika string kosong
    }

    // Ambil bagian utama harga (semua kecuali karakter terakhir)
    String first = fullPriceString.substring(0, 4);
    String second = fullPriceString.substring(4, 6);
    // Ambil karakter terakhir untuk dijadikan superscript
    String superscriptDigit = fullPriceString[fullPriceString.length - 1];

    return RichText(
      text: TextSpan(
        children: [
          // TextSpan untuk bagian utama harga (misal: "1.1546" atau "166.61")
          TextSpan(
            text: first,
            style: TextStyle(
              fontSize: 18.0, // Contoh 15px, sesuaikan nilai piksel sesuai kebutuhan
              fontWeight: FontWeight.bold,
              color: color, // Warna sesuai gambar
            ),
          ),
          TextSpan(
            text: second,
            style: TextStyle(
              fontSize: 25.0, // Contoh 20px, sesuaikan nilai piksel
              fontWeight: FontWeight.bold, // Terlihat lebih tebal di gambar
              color: color, // Warna sesuai gambar
            ),
          ),
          // WidgetSpan untuk digit superscript (misal: "2" atau "0")
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: Offset(0.0, -12.0),
              child: Text(
                superscriptDigit,
                style: TextStyle(
                  fontSize: 13.0,
                  color: textColor,
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

// --- Fungsi formatPrice (dari sebelumnya, untuk menyiapkan string) ---
String formatPrices(String price, {required String currency}) {
  double? value = double.tryParse(price);

  if (value == null) {
    return price; // Mengembalikan string asli jika tidak valid
  }

  final String upperCaseCurrency = currency.toUpperCase();

  if (upperCaseCurrency == "JPY") {
    return value.toStringAsFixed(3); // 3 desimal untuk JPY
  } else {
    return value.toStringAsFixed(5); // 5 desimal untuk mata uang lainnya
  }
}

// --- Fungsi extractPriceParts (dari sebelumnya, untuk keperluan logik internal, BUKAN untuk display langsung) ---
PriceParts extractPriceParts(String price) {
  String cleanedPrice = price.replaceAll('.', '');
  // ... (logic extractPriceParts lainnya tetap sama seperti sebelumnya)
  String? firstPart;
  String? secondPart;
  String? thirdPart;

  if (cleanedPrice.length >= 3) {
    firstPart = cleanedPrice.substring(0, 3);
  }
  if (cleanedPrice.length >= 5) {
    secondPart = cleanedPrice.substring(3, 5);
  }
  if (cleanedPrice.isNotEmpty) {
    thirdPart = cleanedPrice[cleanedPrice.length - 1];
  }
  return PriceParts(first: firstPart, second: secondPart, third: thirdPart);
}