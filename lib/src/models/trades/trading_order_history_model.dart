class ClosedOrderModel {
  ClosedOrderModel({
    this.response,
  });
  List<Response>? response;
  
  ClosedOrderModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.ticket,
    this.profit,
    this.closePrice,
    this.closeTime,
    this.openPrice,
    this.openTime,
    this.lot,
    this.orderType,
    this.symbol,
    this.stopLoss,
    this.takeProfit,
    this.digits,
    this.commission,
    this.swap
  });
  dynamic ticket;
  dynamic profit;
  dynamic closePrice;
  dynamic closeTime;
  dynamic openPrice;
  dynamic openTime;
  dynamic lot;
  dynamic swap;
  String? orderType;
  String? symbol;
  dynamic stopLoss;
  dynamic takeProfit;
  dynamic digits;
  dynamic commission;
  
  Response.fromJson(Map<String, dynamic> json){
    ticket = json['ticket'];
    profit = json['profit'];
    closePrice = json['closePrice'];
    closeTime = json['closeTime'];
    openPrice = json['openPrice'];
    openTime = json['openTime'];
    lot = json['lot'];
    swap = json['swap'];
    orderType = json['orderType'];
    symbol = json['symbol'];
    stopLoss = json['stopLoss'];
    takeProfit = json['takeProfit'];
    commission = json['commission'];
    digits = json['digits'];
  }
}