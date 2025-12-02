class UserBankModel {
  UserBankModel({
    this.response,
  });
  List<Response>? response;

  UserBankModel.fromJson(Map<String, dynamic> json) {
  final data = json['response'];
  response = (data != null && (data as List).isNotEmpty) ? data.map((e) => Response.fromJson(e)).toList() : null;
}
}

class Response {
  Response({
    this.id,
    this.name,
    this.account,
    this.holder,
    this.image,
    this.status,
    this.statusString
  });
  String? id;
  String? name;
  String? account;
  String? status;
  String? statusString;
  String? image;
  String? holder;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    account = json['account'];
    holder = json['holder'];
    status = json['status'];
    statusString = json['status_string'];
    image = json['image'];
  }
}