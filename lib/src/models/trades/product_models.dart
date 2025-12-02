class ProductModels {
  ProductModels({
    required this.response,
  });
  late final List<Response> response;

  ProductModels.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    required this.type,
    required this.products,
  });
  String? type;
  List<Products>? products;

  Response.fromJson(Map<String, dynamic> json){
    type = json['type'];
    products = List.from(json['products']).map((e)=>Products.fromJson(e)).toList();
  }
}

class Products {
  Products({
    this.suffix,
    this.name,
    this.rate,
    this.currency,
    this.komisi,
    this.leverage
  });
  String? suffix;
  String? name;
  String? rate;
  String? currency;
  String? komisi;
  String? leverage;

  Products.fromJson(Map<String, dynamic> json){
    suffix = json['suffix'];
    name = json['name'];
    rate = json['rate'];
    currency = json['currency'];
    komisi = json['komisi'];
    leverage = json['leverage'];
  }
}