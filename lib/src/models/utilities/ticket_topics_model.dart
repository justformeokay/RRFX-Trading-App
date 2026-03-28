class TicketTopicsModel {
  bool? status;
  String? message;
  List<String>? data;

  TicketTopicsModel({this.status, this.message, this.data});

  TicketTopicsModel.fromJson(Map<String, dynamic> json) {
    print("📌 TicketTopicsModel.fromJson called with: $json");
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? List<String>.from(json['data']) : [];
    print("✅ TicketTopicsModel parsed - data: $data");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}
