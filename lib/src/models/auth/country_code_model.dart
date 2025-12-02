class CountryCodeModel {
  CountryCodeModel({
    required this.response,
  });
  List<Response>? response;
  
  CountryCodeModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.name,
    this.code,
    this.phoneCode,
  });
  String? name;
  String? code;
  String? phoneCode;
  
  Response.fromJson(Map<String, dynamic> json){
    name = json['name'];
    code = json['code'];
    phoneCode = json['phone_code'];
  }
}