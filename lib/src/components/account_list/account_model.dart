class AccountModel {
  final List<AccountDetailModel> realAccounts;
  final List<AccountDetailModel> demoAccounts;

  AccountModel({
    required this.realAccounts,
    required this.demoAccounts,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    // Pastikan JSON diakses dengan aman
    var responseJson = json['response'] as Map<String, dynamic>? ?? {};

    // Mengurai daftar akun real
    List<dynamic> realList = responseJson['real'] as List<dynamic>? ?? [];
    List<AccountDetailModel> real = realList
        .map((i) => AccountDetailModel.fromJson(i as Map<String, dynamic>))
        .toList();

    // Mengurai daftar akun demo
    List<dynamic> demoList = responseJson['demo'] as List<dynamic>? ?? [];
    List<AccountDetailModel> demo = demoList
        .map((i) => AccountDetailModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return AccountModel(
      realAccounts: real,
      demoAccounts: demo,
    );
  }

  // Getter untuk mendapatkan semua akun (Real diikuti Demo)
  List<AccountDetailModel> get allAccounts {
    return [...realAccounts, ...demoAccounts];
  }
}

class AccountDetailModel {
  final String? id;
  final String? login;
  final String? type; // 'demo' atau 'real'
  final String? namaTipeAkun;
  final String? balance;
  final String? currency;
  final String? marginFree;
  final String? equity;
  // Tambahkan properti lain yang relevan di sini

  AccountDetailModel({
    this.id,
    this.login,
    this.type,
    this.namaTipeAkun,
    this.balance,
    this.currency,
    this.marginFree,
    this.equity
  });

  factory AccountDetailModel.fromJson(Map<String, dynamic> json) {
    return AccountDetailModel(
      id: json['id'] as String?,
      login: json['login'] as String?,
      type: json['type'] as String?,
      namaTipeAkun: json['nama_tipe_akun'] as String?,
      balance: json['balance'] as String?,
      currency: json['currency'] as String?,
      marginFree: json['margin_free'] as String?,
      equity: json['equity'] as String?,
      // Inisialisasi properti lain dari API response
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'type': type,
      'nama_tipe_akun': namaTipeAkun,
      'balance': balance,
      'currency': currency,
      'margin_free': marginFree,
      'equity': equity
    };
  }
}