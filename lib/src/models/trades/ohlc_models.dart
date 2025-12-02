class OHLCModels {
  OHLCModels({
    required this.status,
    required this.message,
    required this.response,
  });
  late final bool status;
  late final String message;
  late final List<Response> response;

  OHLCModels.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.date,
    this.open,
    this.high,
    this.low,
    this.close,
  });
  String? date;
  double? open;
  double? high;
  double? low;
  double? close;

  Response.fromJson(Map<String, dynamic> json){
    date = json['date'];
    open = json['open'];
    high = json['high'];
    low = json['low'];
    close = json['close'];
  }
}