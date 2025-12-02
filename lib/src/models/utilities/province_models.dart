class ProvinceModels {
  ProvinceModels({
    required this.error,
    required this.msg,
    required this.data,
  });
  late final bool error;
  late final String msg;
  late final Data data;

  ProvinceModels.fromJson(Map<String, dynamic> json){
    error = json['error'];
    msg = json['msg'];
    data = Data.fromJson(json['data']);
  }
}

class Data {
  Data({
    this.name,
    this.iso3,
    this.iso2,
    this.states,
  });
  String? name;
  String? iso3;
  String? iso2;
  List<States>? states;

  Data.fromJson(Map<String, dynamic> json){
    name = json['name'];
    iso3 = json['iso3'];
    iso2 = json['iso2'];
    states = List.from(json['states']).map((e)=>States.fromJson(e)).toList();
  }
}

class States {
  States({
    this.name,
    this.stateCode,
  });
  String? name;
  String? stateCode;

  States.fromJson(Map<String, dynamic> json){
    name = json['name'];
    stateCode = json['state_code'];
  }
}