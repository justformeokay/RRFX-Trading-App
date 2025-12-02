class NewsModel {
  NewsModel({
    required this.response,
  });

  late final List<Response> response;

  NewsModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['response'] as List? ?? [];
    response = rawList.map((e) => Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.title,
    this.type,
    this.message,
    this.highlight,
    this.author,
    this.tanggal,
    this.picture,
  });

  String? id;
  String? title;
  String? type;
  String? message;
  String? author;
  bool? highlight;
  String? tanggal;
  String? picture;

  Response.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title']?.toString();
    type = json['type']?.toString();
    message = json['message']?.toString();
    author = json['author']?.toString();
    tanggal = json['tanggal']?.toString();
    picture = json['picture']?.toString();

    // Aman untuk key yang mungkin tidak ada
    highlight = (json.containsKey('highlight'))
        ? (json['highlight'] == true || json['highlight'] == 1)
        : false;
  }
}
