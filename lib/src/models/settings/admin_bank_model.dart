class BankAdminModel {
  BankAdminModel({
    this.response,
  });
  List<Response>? response;

  BankAdminModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.currency,
    this.bankName,
    this.bankHolder,
    this.bankAccount,
  });
  String? id;
  String? currency;
  String? bankName;
  String? bankHolder;
  String? bankAccount;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    currency = json['currency'];
    bankName = json['bank_name'];
    bankHolder = json['bank_holder'];
    bankAccount = json['bank_account'];
  }
}