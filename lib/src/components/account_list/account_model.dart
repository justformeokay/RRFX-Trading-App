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
  String? balance;
  final String? currency;
  String? marginFree;

  final String? accountCurrency;
  double? marginFreePercent;
  final String? totalDepositUsd;
  final String? totalWithdrawalUsd;
  final String? pnl;

  String? equity;
  String? margin;
  // Tambahkan properti lain yang relevan di sini

  AccountDetailModel({
    this.id,
    this.login,
    this.type,
    this.namaTipeAkun,
    this.balance,
    this.currency,
    this.accountCurrency,
    this.marginFreePercent,
    this.totalDepositUsd,
    this.totalWithdrawalUsd,
    this.marginFree,
    this.pnl,
    this.equity,
    this.margin,
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
      accountCurrency: json['account_currency'] as String?,
      marginFreePercent: _toDouble(json['margin_free_percent']),
      totalDepositUsd: json['total_deposit_usd'] as String?,
      totalWithdrawalUsd: json['total_withdrawal_usd'] as String?,
      pnl: json['pnl'] as String?,
      equity: json['equity'] as String?,
      margin: json['margin'] as String?,
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
      'margin': margin,
      'account_currency': accountCurrency,
      'margin_free_percent': marginFreePercent,
      'total_deposit_usd': totalDepositUsd,
      'total_withdrawal_usd': totalWithdrawalUsd,
      'pnl': pnl,
      'equity': equity
    };
  }
}

double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }