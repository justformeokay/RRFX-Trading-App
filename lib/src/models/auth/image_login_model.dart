class ImageLoginModel {
  ImageLoginModel({
    this.response,
  });
  List<Response>? response;

  ImageLoginModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.picture,
  });
  String? id;
  String? picture;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    picture = json['picture'];
  }
}