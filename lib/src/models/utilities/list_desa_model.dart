class ListDesaModel {
  ListDesaModel({
    this.response,
  });
  List<Response>? response;
  ListDesaModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.name,
    this.selected,
  });
  String? name;
  String? postalCode;
  bool? selected;
  
  Response.fromJson(Map<String, dynamic> json){
    name = json['name'];
    postalCode = json['postalCode'];
    selected = json['selected'];
  }
}