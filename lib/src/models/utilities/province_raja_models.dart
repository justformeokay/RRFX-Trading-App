class ProvinceRajaModels {
  ProvinceRajaModels({
    required this.rajaongkir,
  });
  late final Rajaongkir rajaongkir;

  ProvinceRajaModels.fromJson(Map<String, dynamic> json){
    rajaongkir = Rajaongkir.fromJson(json['rajaongkir']);
  }
}

class Rajaongkir {
  Rajaongkir({
    this.query,
    this.status,
    this.results,
  });
  List<dynamic>? query;
  Status? status;
  List<Results>? results;

  Rajaongkir.fromJson(Map<String, dynamic> json){
    query = List.castFrom<dynamic, dynamic>(json['query']);
    status = Status.fromJson(json['status']);
    results = List.from(json['results']).map((e)=>Results.fromJson(e)).toList();
  }
}

class Status {
  Status({
    this.code,
    this.description,
  });
  int? code;
  String? description;

  Status.fromJson(Map<String, dynamic> json){
    code = json['code'];
    description = json['description'];
  }
}

class Results {
  Results({
    required this.provinceId,
    required this.province,
  });
  String? provinceId;
  String? province;

  Results.fromJson(Map<String, dynamic> json){
    provinceId = json['province_id'];
    province = json['province'];
  }
}