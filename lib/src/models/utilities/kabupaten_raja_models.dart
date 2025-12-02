class KabupatenRajaModels {
  KabupatenRajaModels({
    required this.rajaongkir,
  });
  late final Rajaongkir rajaongkir;

  KabupatenRajaModels.fromJson(Map<String, dynamic> json){
    rajaongkir = Rajaongkir.fromJson(json['rajaongkir']);
  }
}

class Rajaongkir {
  Rajaongkir({
    this.query,
    this.status,
    this.results,
  });
  Query? query;
  Status? status;
  List<Results>? results;

  Rajaongkir.fromJson(Map<String, dynamic> json){
    query = Query.fromJson(json['query']);
    status = Status.fromJson(json['status']);
    results = List.from(json['results']).map((e)=>Results.fromJson(e)).toList();
  }
}

class Query {
  Query({
    required this.province,
  });
  late final String province;

  Query.fromJson(Map<String, dynamic> json){
    province = json['province'];
  }
}

class Status {
  Status({
    required this.code,
    required this.description,
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
    this.cityId,
    this.provinceId,
    this.province,
    this.type,
    this.cityName,
    this.postalCode,
  });
  String? cityId;
  String? provinceId;
  String? province;
  String? type;
  String? cityName;
  String? postalCode;

  Results.fromJson(Map<String, dynamic> json){
    cityId = json['city_id'];
    provinceId = json['province_id'];
    province = json['province'];
    type = json['type'];
    cityName = json['city_name'];
    postalCode = json['postal_code'];
  }
}