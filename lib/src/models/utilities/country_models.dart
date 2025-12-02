class CountryModels {
  CountryModels({
    required this.error,
    required this.msg,
    required this.data,
  });
  late final bool error;
  late final String msg;
  late final List<Data> data;

  CountryModels.fromJson(Map<String, dynamic> json){
    error = json['error'];
    msg = json['msg'];
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
  }
}

class Data {
  Data({
    this.name,
    this.capital,
    this.iso2,
    this.iso3,
  });
  String? name;
  String? capital;
  String? iso2;
  String? iso3;

  Data.fromJson(Map<String, dynamic> json){
    name = json['name'];
    capital = json['capital'];
    iso2 = json['iso2'];
    iso3 = json['iso3'];
  }
}