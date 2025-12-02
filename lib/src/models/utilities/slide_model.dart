class SlideListModel {
  SlideListModel({
    required this.response,
  });
  late final List<Response> response;

  SlideListModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.picture,
    this.link,
  });
  String? id;
  String? picture;
  String? link;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    picture = json['picture'];
    link = json['link'];
  }
}