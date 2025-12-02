class DesaModelsAPI {
  DesaModelsAPI({required this.response});
  List<Response>? response;

  DesaModelsAPI.fromJson(Map<String, dynamic> json){
    response = json['response'] == null ? [] : List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({this.village, this.code, this.selected, this.postalCode});
  String? village;
  String? code;
  bool? selected;
  String? postalCode;

  Response.fromJson(Map<String, dynamic> json){
    village = json['village'];
    code = json['code'];
    selected = json['selected'];
    postalCode = json['postalCode'];
  }
}