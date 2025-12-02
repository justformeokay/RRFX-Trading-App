class PendingModel {
  PendingModel({
    this.response,
  });
  List<Response>? response;

  PendingModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.login,
    this.type,
    this.product,
    this.rate,
    this.currency,
    this.minDeposit,
    this.status,
    this.dateCreated,
  });
  String? id;
  String? login;
  String? type;
  String? product;
  String? rate;
  String? currency;
  int? minDeposit;
  String? status;
  String? dateCreated;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    login = json['login'];
    type = json['type'];
    product = json['product'];
    rate = json['rate'];
    currency = json['currency'];
    minDeposit = json['min_deposit'];
    status = json['status'];
    dateCreated = json['date_created'];
  }
}