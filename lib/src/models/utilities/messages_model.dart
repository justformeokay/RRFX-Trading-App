/// TICKET MODEL UNTUK DAFTAR TICKET
class ListOfTicketsModel {
  ListOfTicketsModel({
    this.response,
  });
  List<Response>? response;

  ListOfTicketsModel.fromJson(Map<String, dynamic> json){
    response = List.from(json['response']).map((e)=>Response.fromJson(e)).toList();
  }
}

class Response {
  Response({
    this.code,
    this.subject,
    this.status,
    this.createdAt,
    this.closedAt,
  });
  String? code;
  String? subject;
  String? status;
  String? createdAt;
  String? closedAt;

  Response.fromJson(Map<String, dynamic> json){
    code = json['code'];
    subject = json['subject'];
    status = json['status'];
    createdAt = json['created_at'];
    closedAt = json['closed_at'];
  }
}