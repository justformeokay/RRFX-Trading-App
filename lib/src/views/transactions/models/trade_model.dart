class TradeModel {
  final String ticket;
  final String symbol;
  final String profit;
  final String openPrice;
  final String closePrice;
  final String orderType;

  TradeModel({
    required this.ticket,
    required this.symbol,
    required this.profit,
    required this.openPrice,
    required this.closePrice,
    required this.orderType,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) => TradeModel(
    ticket: json['ticket'],
    symbol: json['symbol'],
    profit: json['profit'] ?? '',
    openPrice: json['openPrice'] ?? '',
    closePrice: json['closePrice'] ?? '',
    orderType: json['orderType'],
  );
}
