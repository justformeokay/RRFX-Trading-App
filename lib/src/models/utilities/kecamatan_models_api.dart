class KecamatanModelsAPI {
  KecamatanModelsAPI({required this.response});
  List<Response>? response;

  KecamatanModelsAPI.fromJson(Map<String, dynamic> json){
    response = json['response'] == null ? [] : List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.name,
    this.code,
    this.selected,
  });
  String? name;
  String? code;
  bool? selected;

  Response.fromJson(Map<String, dynamic> json){
    name = json['name'];
    code = json['code'];
    selected = json['selected'];
  }
}