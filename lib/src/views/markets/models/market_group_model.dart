// market_group_model.dart
import 'dart:convert';

List<MarketGroup> marketGroupFromJson(String str) =>
    List<MarketGroup>.from(json.decode(str)['response'].map((x) => MarketGroup.fromJson(x)));

class MarketGroup {
    final String name;
    final List<MarketSymbol> symbols;

    MarketGroup({
        required this.name,
        required this.symbols,
    });

    factory MarketGroup.fromJson(Map<String, dynamic> json) => MarketGroup(
        name: json["name"],
        symbols: List<MarketSymbol>.from(json["symbols"].map((x) => MarketSymbol.fromJson(x))),
    );
}

class MarketSymbol {
    final String symbol;
    final String symbolAlias;
    final int contractSize;
    final int spread;
    final int digits;
    final int trademode;
    final double volumeMin;
    final double volumeMax;
    
    // Properti eksplisit untuk menyimpan nama grup
    final String groupName; 

    MarketSymbol({
        required this.symbol,
        required this.symbolAlias,
        required this.contractSize,
        required this.spread,
        required this.digits,
        required this.trademode,
        required this.volumeMin,
        required this.volumeMax,
        this.groupName = '', // Nilai default untuk data yang baru diambil
    });

    factory MarketSymbol.fromJson(Map<String, dynamic> json) => MarketSymbol(
        symbol: json["symbol"],
        symbolAlias: json["symbol_alias"],
        contractSize: json["contract_size"],
        spread: json["spread"],
        digits: json["digits"],
        trademode: json["trademode"],
        volumeMin: json["volume_min"].toDouble(),
        volumeMax: json["volume_max"].toDouble(),
        groupName: '', 
    );

    // Untuk GetStorage: Mengubah MarketSymbol menjadi Map
    Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "symbol_alias": symbolAlias,
        "contract_size": contractSize,
        "spread": spread,
        "digits": digits,
        "trademode": trademode,
        "volume_min": volumeMin,
        "volume_max": volumeMax,
        "group_name": groupName,
    };

    // Untuk GetStorage: Mengubah Map kembali menjadi MarketSymbol
    factory MarketSymbol.fromLocalJson(Map<String, dynamic> json) => MarketSymbol(
        symbol: json["symbol"],
        symbolAlias: json["symbol_alias"],
        contractSize: json["contract_size"],
        spread: json["spread"],
        digits: json["digits"],
        trademode: json["trademode"],
        volumeMin: json["volume_min"],
        volumeMax: json["volume_max"],
        groupName: json["group_name"] ?? '', 
    );
}