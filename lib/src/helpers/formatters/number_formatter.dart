import 'package:intl/intl.dart';

class NumberFormatter {

  static int parseRupiahToInt(String rupiah) {
    // Hapus "Rp", spasi, dan titik pemisah ribuan
    String cleaned = rupiah
        .replaceAll("Rp", "")
        .replaceAll(".", "")
        .replaceAll(",", "")
        .trim();

    // Convert ke int
    return int.tryParse(cleaned) ?? 0;
  }

  static String cleanCurrencyString(String input) {
    // Hilangkan semua karakter selain angka
    String cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned;
  }


  static String formatWithoutTrailingZeros(dynamic value) {
    double number = _toDouble(value);
    
    // Jika bilangan bulat, tampilkan tanpa desimal
    if (number == number.toInt()) {
      return number.toInt().toString();
    }

    // Jika ada desimal, tampilkan maksimal 2 digit
    return number.toStringAsFixed(2);
  }
  static double _toDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
  static String formatCurrency(dynamic value, {String currency = 'IDR'}) {
    double number = _toDouble(value);

    switch (currency.toUpperCase()) {
      case 'USD':
        return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(number);
      case 'IDR':
      default:
        return NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0).format(number);
    }
  }
  static String formatCardNumber(String number) {
    return number.replaceAllMapped(
        RegExp(r".{1,4}"), (match) => "${match.group(0)} ").trim();
  }

  static String formatPrice(String price, {required String currency}) {
    double? value = double.tryParse(price);

    if (value == null) {
      return price; // Or throw an error, or return a default.
    }

    // Convert the currency code to uppercase for case-insensitive comparison
    final String upperCaseCurrency = currency.toUpperCase();

    if (upperCaseCurrency.contains("JPY")) {
      // For JPY, format to 3 decimal places
      return value.toStringAsFixed(3);
    } else {
      // For other currencies, format to 5 decimal places
      return value.toStringAsFixed(5);
    }
  }

  static String cleanNumber(String input) {
    final d = double.parse(input);
    return d == d.toInt() ? d.toInt().toString() : d.toString();
  }
}


class PriceParts {
  final String? first;  // First 3 "digits" (excluding decimal)
  final String? second; // Next 2 "digits" (excluding decimal)
  final String? third;  // Last "digit" (excluding decimal)

  PriceParts({this.first, this.second, this.third});

  @override
  String toString() {
    return 'PriceParts(first: $first, second: $second, third: $third)';
  }
}

String formatPrice(String price, {required String currency}) {
  double? value = double.tryParse(price);

  if (value == null) {
    return price; // Return original string or handle error as per app logic
  }

  final String upperCaseCurrency = currency.toUpperCase();

  if (upperCaseCurrency.contains("JPY")) {
    return value.toStringAsFixed(3);
  } else {
    return value.toStringAsFixed(5);
  }
}


PriceParts extractPriceParts(String price) {
  String cleanedPrice = price.replaceAll('.', '');

  String? firstPart;
  String? secondPart;
  String? thirdPart;

  if (cleanedPrice.length >= 3) {
    firstPart = cleanedPrice.substring(0, 3);
  }

  // Extract 'second': characters from index 3 until 4 (meaning index 3 and 4)
  if (cleanedPrice.length >= 5) {
    secondPart = cleanedPrice.substring(3, 5);
  }

  // Extract 'third': the character at the last index of the cleaned string
  if (cleanedPrice.isNotEmpty) {
    thirdPart = cleanedPrice[cleanedPrice.length - 1];
  }

  return PriceParts(first: firstPart, second: secondPart, third: thirdPart);
}

PriceParts processAndExtractPriceParts(String originalPrice, {required String currency}) {
  String formattedPrice = formatPrice(originalPrice, currency: currency);
  return extractPriceParts(formattedPrice);
}