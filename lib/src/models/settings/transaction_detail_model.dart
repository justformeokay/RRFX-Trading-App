class TransactionDetailModel {
  TransactionDetailModel({
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
  String? id;
  String? type;
  String? login;
  String? amount;
  String? amountReceived;
  String? status;
  String? datetime;
  BankUser? bankUser;
  BankAdmin? bankAdmin;
  
  TransactionDetailModel.fromJson(Map<String, dynamic> json){
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
  String? name;
  String? accountNumber;
  String? accountName;
  
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
  String? name;
  String? accountNumber;
  String? accountName;
  
  BankAdmin.fromJson(Map<String, dynamic> json){
    name = json['name'];
    accountNumber = json['account_number'];
    accountName = json['account_name'];
  }
}