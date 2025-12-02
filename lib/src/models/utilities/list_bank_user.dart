class ListBankUserV2 {
  ListBankUserV2({
    this.response,
  });
  List<Response>? response;
  
  ListBankUserV2.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.holder,
    this.name,
    this.currency,
    this.account,
    this.branch,
    this.type,
  });
  String? id;
  String? holder;
  String? name;
  String? currency;
  String? account;
  String? branch;
  String? type;
  
  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    holder = json['holder'];
    name = json['name'];
    currency = null;
    account = json['account'];
    branch = json['branch'];
    type = json['type'];
  }
}