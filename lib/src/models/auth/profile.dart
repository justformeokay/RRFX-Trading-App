class ProfileModel {
  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.city,
    required this.country,
    required this.address,
    required this.zip,
    required this.tglLahir,
    required this.tmptLahir,
    required this.typeId,
    required this.idNumber,
    required this.urlPhoto,
    required this.status,
    required this.ver,
  });

  late final String? name;
  late final String? email;
  late final String? phone;
  late final String? gender;
  late final String? city;
  late final String? country;
  late final String? address;
  late final String? zip;
  late final String? tglLahir;
  late final String? tmptLahir;
  late final String? typeId;
  late final String? idNumber;
  late final String? urlPhoto;
  late final String? status;
  late final String? ver;

  ProfileModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    gender = json['gender'];
    city = json['city'];
    country = json['country'];
    address = json['address'];
    zip = json['zip'];
    tglLahir = json['tgl_lahir'];
    tmptLahir = json['tmpt_lahir'];
    typeId = json['type_id'];
    idNumber = json['id_number'];
    urlPhoto = json['url_photo'];
    status = json['status'];
    ver = json['ver'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'city': city,
      'country': country,
      'address': address,
      'zip': zip,
      'tgl_lahir': tglLahir,
      'tmpt_lahir': tmptLahir,
      'type_id': typeId,
      'id_number': idNumber,
      'url_photo': urlPhoto,
      'status': status,
      'ver': ver,
    };
  }
}