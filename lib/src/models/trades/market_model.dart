class MarketModel {
  MarketModel({
    required this.result,
    required this.message,
  });
  late final String result;
  late final List<Message> message;

  MarketModel.fromJson(Map<String, dynamic> json){
    result = json['result'];
    message = List.from(json['message']).map((e)=>Message.fromJson(e)).toList();
  }
}

class Message {
  Message({
    required this.currency,
    required this.bid,
    required this.ask,
    required this.high,
    required this.low,
    required this.spread,
    required this.digits,
  });
  String? currency;
  double? bid;
  double? ask;
  double? high;
  double? low;
  int? spread;
  int? digits;

  Message.fromJson(Map<String, dynamic> json){
    currency = json['currency'];
    bid = json['bid'];
    ask = json['ask'];
    high = json['high'];
    low = json['low'];
    spread = json['spread'];
    digits = json['digits'];
  }
}