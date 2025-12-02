class ListKabupatenModel {
  ListKabupatenModel({
    this.response,
  });
  List<Response>? response;
  ListKabupatenModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.name,
    this.selected,
  });
  String? name;
  bool? selected;
  
  Response.fromJson(Map<String, dynamic> json){
    name = json['name'];
    selected = json['selected'];
  }
}