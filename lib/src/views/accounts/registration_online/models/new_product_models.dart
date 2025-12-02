class Product {
  final String suffix;
  final String name;
  final String rate;
  final String currency;
  final String komisi;
  final String leverage;
  final String freeswap;
  final String spread;
  final String minimumDeposit;
  final String minimumTrade;

  Product({
    required this.suffix,
    required this.name,
    required this.rate,
    required this.currency,
    required this.komisi,
    required this.leverage,
    required this.freeswap,
    required this.spread,
    required this.minimumDeposit,
    required this.minimumTrade,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        suffix: json['suffix'] ?? '',
        name: json['name'] ?? '',
        rate: json['rate'] ?? '',
        currency: json['currency'] ?? '',
        komisi: json['komisi'] ?? '',
        leverage: json['leverage'] ?? '',
        freeswap: json['freeswap'] ?? '',
        spread: json['spread'] ?? '',
        minimumDeposit: json['minimum_deposit'] ?? '',
        minimumTrade: json['minimum_trade'] ?? '',
      );
}
