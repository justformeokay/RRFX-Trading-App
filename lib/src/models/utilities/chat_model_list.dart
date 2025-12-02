class MessagesModel {
  MessagesModel({
    this.response,
  });
  List<Response>? response;

  MessagesModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.id,
    this.from,
    this.type,
    this.contentType,
    this.content,
    this.date,
    this.time,
  });
  String? id;
  String? from;
  String? type;
  String? contentType;
  String? content;
  String? date;
  String? time;

  Response.fromJson(Map<String, dynamic> json){
    id = json['id'];
    from = json['from'];
    type = json['type'];
    contentType = json['content_type'];
    content = json['content'];
    date = json['date'];
    time = json['time'];
  }
}