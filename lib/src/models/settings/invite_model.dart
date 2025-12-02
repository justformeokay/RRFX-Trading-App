class InviteLinkModel {
  Data? data;

  InviteLinkModel({this.data});

  InviteLinkModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<General>? general;
  List<Spesific>? spesific;

  Data({this.general, this.spesific});

  Data.fromJson(Map<String, dynamic> json) {
    general = json['general'] != null
        ? List.from(json['general']).map((e) => General.fromJson(e)).toList()
        : [];
    spesific = json['spesific'] != null
        ? List.from(json['spesific']).map((e) => Spesific.fromJson(e)).toList()
        : [];
  }
}

class General {
  String? name;
  String? link;

  General({this.name, this.link});

  General.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    link = json['link'];
  }
}

class Spesific {
  String? name;
  String? link;

  Spesific({this.name, this.link});

  Spesific.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    link = json['link'];
  }
}
