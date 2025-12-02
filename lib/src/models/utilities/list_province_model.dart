class ListProvinsiModel {
  ListProvinsiModel({
    required this.response,
  });
  List<Response>? response;
  
  ListProvinsiModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    required this.name,
    required this.selected,
  });
  String? name;
  bool? selected;
  
  Response.fromJson(Map<String, dynamic> json){
    name = json['name'];
    selected = json['selected'];
  }
}