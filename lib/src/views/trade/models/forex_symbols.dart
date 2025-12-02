// forex_symbol.dart
import 'dart:convert';

List<ForexSymbol> forexSymbolFromJson(String str) => List<ForexSymbol>.from(json.decode(str)['response'].map((x) => ForexSymbol.fromJson(x)));

class ForexSymbol {
    String? symbol;
    int? contractSize;
    int? spread;
    int? digits;
    int? trademode;
    double? volumeMin;
    double? volumeMax;
    String? category; // Untuk filter tab

    ForexSymbol({
      this.symbol,
      this.contractSize,
      this.spread,
      this.digits,
      this.trademode,
      this.volumeMin,
      this.volumeMax,
      this.category,
    });

    factory ForexSymbol.fromJson(Map<String, dynamic> json) => ForexSymbol(
        symbol: json["symbol"] ?? '',
        contractSize: json["contract_size"] ?? 0,
        spread: json["spread"] ?? 0,
        digits: json["digits"] ?? 0,
        trademode: json["trademode"] ?? 0,
        volumeMin: json["volume_min"].toDouble(),
        volumeMax: json["volume_max"].toDouble(),
        category: json["category"] ?? '',
    );
}