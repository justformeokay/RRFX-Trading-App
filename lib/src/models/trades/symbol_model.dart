class SymbolModels {
  List<Response>? response;
  SymbolModels.fromJson(Map<String, dynamic> json) : response = (json['response'] as List?)?.map((e) => Response.fromJson(e)).toList();
}

class Response {
  Response({
    this.symbol,
    this.contractSize,
    this.spread,
    this.digits,
    this.trademode,
    this.volumeMin,
    this.volumeMax,
  });
  String? symbol;
  int? contractSize;
  int? spread;
  int? digits;
  int? trademode;
  double? volumeMin;
  int? volumeMax;
  
  Response.fromJson(Map<String, dynamic> json){
    symbol = json['symbol'];
    contractSize = json['contract_size'];
    spread = json['spread'];
    digits = json['digits'];
    trademode = json['trademode'];
    volumeMin = json['volume_min'];
    volumeMax = json['volume_max'];
  }
}