class OpenedOrderModel {
  final int ticket;
  final String symbol;
  final double lot;
  final double openPrice;
  final double currentPrice;
  final double profit;
  final String orderType;

  OpenedOrderModel({
    required this.ticket,
    required this.symbol,
    required this.lot,
    required this.openPrice,
    required this.currentPrice,
    required this.profit,
    required this.orderType,
  });

  factory OpenedOrderModel.fromJson(Map<String, dynamic> json) {
    return OpenedOrderModel(
      ticket: json['ticket'],
      symbol: json['symbol'],
      lot: (json['lot'] as num).toDouble(),
      openPrice: (json['openPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      orderType: json['orderType'],
    );
  }
}
