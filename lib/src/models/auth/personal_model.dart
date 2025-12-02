class PersonalModels {
  PersonalModels({
    required this.status,
    required this.message,
    required this.response,
  });
  late final bool status;
  late final String message;
  late final Response response;

  PersonalModels.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    response = Response.fromJson(json['response']);
  }
}

class Response {
  Response({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.personalDetail,
  });
  late final String accessToken;
  late final String refreshToken;
  late final int expiresIn;
  late final PersonalDetail personalDetail;

  Response.fromJson(Map<String, dynamic> json){
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    expiresIn = json['expires_in'];
    personalDetail = PersonalDetail.fromJson(json['personal_detail']);
  }
}

class PersonalDetail {
  PersonalDetail({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.city,
    this.country,
    this.address,
    this.zip,
    this.tglLahir,
    this.tmptLahir,
    this.typeId,
    this.idNumber,
    this.urlPhoto,
    this.status,
    this.ver,
  });
  String? id;
  String? name;
  String? email;
  String? phone;
  String? gender;
  String? city;
  String? country;
  String? address;
  String? zip;
  String? tglLahir;
  String? tmptLahir;
  String? typeId;
  String? idNumber;
  String? urlPhoto;
  String? status;
  String? ver;

  PersonalDetail.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    gender = null;
    city = null;
    country = json['country'];
    address = null;
    zip = json['zip'];
    tglLahir = json['tgl_lahir'];
    tmptLahir = null;
    typeId = null;
    idNumber = null;
    urlPhoto = json['url_photo'];
    status = json['status'];
    ver = json['ver'];
  }
}