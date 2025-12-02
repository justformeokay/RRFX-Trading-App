// lib/src/views/chart/models/symbol_group.dart

class SymbolGroup {
  final String name;
  final List<SymbolItem> symbols;

  SymbolGroup({
    required this.name,
    required this.symbols,
  });

  factory SymbolGroup.fromJson(Map<String, dynamic> json) {
    return SymbolGroup(
      name: json['name']?.toString() ?? '',
      symbols: (json['symbols'] as List<dynamic>? ?? [])
          .map((e) => SymbolItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbols': symbols.map((s) => s.toJson()).toList(),
    };
  }
}

class SymbolItem {
  final String symbol;       // contoh: "XAUUSD.db"
  final String alias;        // contoh: "XAUUSD"
  final double contractSize; // contoh: 100
  final double spread;       // example: 0
  final int digits;          // example: 2
  final int trademode;
  final double volumeMin;
  final double volumeMax;

  SymbolItem({
    required this.symbol,
    required this.alias,
    required this.contractSize,
    required this.spread,
    required this.digits,
    required this.trademode,
    required this.volumeMin,
    required this.volumeMax,
  });

  factory SymbolItem.fromJson(Map<String, dynamic> json) {
    return SymbolItem(
      symbol: json['symbol']?.toString() ?? '',
      alias: json['symbol_alias']?.toString() ?? json['symbol']?.toString() ?? '',
      contractSize: _toDouble(json['contract_size']),
      spread: _toDouble(json['spread']),
      digits: (json['digits'] is int) ? json['digits'] as int : int.tryParse((json['digits'] ?? '0').toString()) ?? 0,
      trademode: (json['trademode'] is int) ? json['trademode'] as int : int.tryParse((json['trademode'] ?? '0').toString()) ?? 0,
      volumeMin: _toDouble(json['volume_min']),
      volumeMax: _toDouble(json['volume_max']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'symbol_alias': alias,
      'contract_size': contractSize,
      'spread': spread,
      'digits': digits,
      'trademode': trademode,
      'volume_min': volumeMin,
      'volume_max': volumeMax,
    };
  }

  // Utility helper
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
