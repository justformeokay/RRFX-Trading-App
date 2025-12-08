class SymbolModel {
  final String symbol;
  final String symbolAlias;
  final int contractSize;
  final int spread;
  final int digits;
  final int trademode;
  final double volumeMin;
  final double volumeMax;

  SymbolModel({
    required this.symbol,
    required this.symbolAlias,
    required this.contractSize,
    required this.spread,
    required this.digits,
    required this.trademode,
    required this.volumeMin,
    required this.volumeMax,
  });

  factory SymbolModel.fromJson(Map<String, dynamic> json) {
    return SymbolModel(
      symbol: json['symbol'] ?? '',
      symbolAlias: json['symbol_alias'] ?? '',
      contractSize: json['contract_size'] ?? 0,
      spread: json['spread'] ?? 0,
      digits: json['digits'] ?? 0,
      trademode: json['trademode'] ?? 0,
      volumeMin: (json['volume_min'] ?? 0).toDouble(),
      volumeMax: (json['volume_max'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'symbol_alias': symbolAlias,
      'contract_size': contractSize,
      'spread': spread,
      'digits': digits,
      'trademode': trademode,
      'volume_min': volumeMin,
      'volume_max': volumeMax,
    };
  }
}

class SymbolGroupModel {
  final String name;
  final List<SymbolModel> symbols;

  SymbolGroupModel({
    required this.name,
    required this.symbols,
  });

  factory SymbolGroupModel.fromJson(Map<String, dynamic> json) {
    return SymbolGroupModel(
      name: json['name'] ?? '',
      symbols: (json['symbols'] as List<dynamic>?)
              ?.map((e) => SymbolModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbols': symbols.map((e) => e.toJson()).toList(),
    };
  }
}

class SymbolsResponse {
  final bool status;
  final String message;
  final List<SymbolGroupModel> response;

  SymbolsResponse({
    required this.status,
    required this.message,
    required this.response,
  });

  factory SymbolsResponse.fromJson(Map<String, dynamic> json) {
    return SymbolsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      response: (json['response'] as List<dynamic>?)
              ?.map((e) => SymbolGroupModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': response.map((e) => e.toJson()).toList(),
    };
  }
}
