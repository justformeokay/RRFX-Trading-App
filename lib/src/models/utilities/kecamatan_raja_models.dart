class KecamatanRajaModels {
  KecamatanRajaModels({
    required this.rajaongkir,
  });
  late final Rajaongkir rajaongkir;

  KecamatanRajaModels.fromJson(Map<String, dynamic> json){
    rajaongkir = Rajaongkir.fromJson(json['rajaongkir']);
  }
}

class Rajaongkir {
  Rajaongkir({
    required this.query,
    required this.status,
    required this.results,
  });
  late final Query query;
  late final Status status;
  late final List<Results> results;

  Rajaongkir.fromJson(Map<String, dynamic> json){
    query = Query.fromJson(json['query']);
    status = Status.fromJson(json['status']);
    results = List.from(json['results']).map((e)=>Results.fromJson(e)).toList();
  }
}

class Query {
  Query({
    required this.city,
  });
  late final String city;

  Query.fromJson(Map<String, dynamic> json){
    city = json['city'];
  }
}

class Status {
  Status({
    required this.code,
    required this.description,
  });
  late final int code;
  late final String description;

  Status.fromJson(Map<String, dynamic> json){
    code = json['code'];
    description = json['description'];
  }
}

class Results {
  Results({
    this.subdistrictId,
    this.provinceId,
    this.province,
    this.cityId,
    this.city,
    this.type,
    this.subdistrictName,
    this.postalCode,
  });
  String? subdistrictId;
  String? provinceId;
  String? province;
  String? cityId;
  String? city;
  String? type;
  String? subdistrictName;
  String? postalCode;

  Results.fromJson(Map<String, dynamic> json){
    subdistrictId = json['subdistrict_id'];
    provinceId = json['province_id'];
    province = json['province'];
    cityId = json['city_id'];
    city = json['city'];
    type = json['type'];
    subdistrictName = json['subdistrict_name'];
    postalCode = json['postal_code'];
  }
}