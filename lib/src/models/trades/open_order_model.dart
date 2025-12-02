class OpenOrderModel {
  OpenOrderModel({
    this.response,
  });
  List<Response>? response;
  
  OpenOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['response'] != null && json['response'] is List) {
      response = List<Response>.from(
        (json['response'] as List).map((e) => Response.fromJson(e)),
      );
    } else {
      response = [];
    }
  }
}

class Response {
  Response({
    this.ticket,
    this.lot,
    this.openPrice,
    this.currentPrice,
    this.openTime,
    this.stopLoss,
    this.takeProfit,
    this.swap,
    this.profit,
    this.symbol,
    this.orderType,
    this.digits,
  });
  dynamic ticket;
  dynamic lot;
  String? symbol;
  dynamic openPrice;
  dynamic currentPrice;
  String? openTime;
  dynamic stopLoss;
  dynamic takeProfit;
  dynamic swap;
  dynamic profit;
  String? orderType;
  dynamic digits;
  
  Response.fromJson(Map<String, dynamic> json){
    ticket = json['ticket'];
    lot = json['lot'];
    symbol = json['symbol'];
    openPrice = json['openPrice'];
    currentPrice = json['currentPrice'];
    openTime = json['openTime'];
    stopLoss = json['stopLoss'];
    takeProfit = json['takeProfit'];
    swap = json['swap'];
    profit = json['profit'];
    orderType = json['orderType'];
    digits = json['digits'];
  }
}