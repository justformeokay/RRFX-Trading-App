class AccountModel {
  final String id;
  final String login;
  final String type;
  final String namaTipeAkun;
  final String balance;
  final String currency;

  AccountModel({
    required this.id,
    required this.login,
    required this.type,
    required this.namaTipeAkun,
    required this.balance,
    required this.currency,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'],
        login: json['login'],
        type: json['type'],
        namaTipeAkun: json['nama_tipe_akun'],
        balance: json['balance'],
        currency: json['currency'],
      );
}
