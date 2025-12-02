class InternalTransferModel {
  InternalTransferModel({
    required this.response,
  });
  late final List<Response> response;
  
  InternalTransferModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['response'] = response.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Response {
  Response({
    this.id,
    this.type,
    this.login,
    this.amount,
    this.amountReceived,
    this.status,
    this.datetime,
  });
  String? id;
  String? type;
  String? login;
  String? amount;
  String? amountReceived;
  String? status;
  String? datetime;
  
  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    type = json['type'];
    login = json['login'];
    amount = json['amount'];
    amountReceived = json['amount_received'];
    status = json['status'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['type'] = type;
    _data['login'] = login;
    _data['amount'] = amount;
    _data['amount_received'] = amountReceived;
    _data['status'] = status;
    _data['datetime'] = datetime;
    return _data;
  }
}