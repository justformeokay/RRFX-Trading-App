class DepositWithdrawDetailModel {
  DepositWithdrawDetailModel({
    required this.status,
    required this.message,
    required this.response,
  });
  bool? status;
  String? message;
  Response? response;
  
  DepositWithdrawDetailModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    response = Response.fromJson(json['response']);
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
    this.bankUser,
    this.bankAdmin,
  });
  dynamic id;
  dynamic type;
  dynamic login;
  dynamic amount;
  dynamic amountReceived;
  dynamic status;
  dynamic datetime;
  BankUser? bankUser;
  BankAdmin? bankAdmin;
  
  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    type = json['type'];
    login = json['login'];
    amount = json['amount'];
    amountReceived = json['amount_received'];
    status = json['status'];
    datetime = json['datetime'];
    bankUser = BankUser.fromJson(json['bank_user']);
    bankAdmin = BankAdmin.fromJson(json['bank_admin']);
  }
}

class BankUser {
  BankUser({
    this.name,
    this.accountNumber,
    this.accountName,
  });
  dynamic name;
  dynamic accountNumber;
  dynamic accountName;
  
  BankUser.fromJson(Map<String, dynamic> json){
    name = json['name'];
    accountNumber = json['account_number'];
    accountName = json['account_name'];
  }
}

class BankAdmin {
  BankAdmin({
    this.name,
    this.accountNumber,
    this.accountName,
  });
  dynamic name;
  dynamic accountNumber;
  dynamic accountName;
  
  BankAdmin.fromJson(Map<String, dynamic> json){
    name = json['name'];
    accountNumber = json['account_number'];
    accountName = json['account_name'];
  }
}