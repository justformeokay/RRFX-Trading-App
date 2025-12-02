class CityModels {
  CityModels({
    required this.error,
    required this.msg,
    required this.data,
  });
  late final bool error;
  late final String msg;
  late final List<String> data;

  CityModels.fromJson(Map<String, dynamic> json){
    error = json['error'];
    msg = json['msg'];
    data = List.castFrom<dynamic, String>(json['data']);
  }
}