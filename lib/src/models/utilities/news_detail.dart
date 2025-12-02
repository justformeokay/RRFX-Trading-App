class NewsDetail {
  NewsDetail({
    required this.response,
  });
  late final Response response;

  NewsDetail.fromJson(Map<String, dynamic> json){
    response = Response.fromJson(json['response']);
  }
}

class Response {
  Response({
    this.id,
    this.title,
    this.type,
    this.message,
    this.author,
    this.tanggal,
    this.picture,
  });
  String? id;
  String? title;
  String? type;
  String? message;
  String? author;
  String? tanggal;
  String? picture;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    title = json['title'];
    type = json['type'];
    message = json['message'];
    author = json['author'];
    tanggal = json['tanggal'];
    picture = json['picture'];
  }
}