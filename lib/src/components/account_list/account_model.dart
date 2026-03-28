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
  
  // Deposit & Withdrawal limits
  final String? minDeposit;
  final String? maxDeposit;
  final String? minTopup;
  final String? minWithdrawal;
  final String? maxWithdrawal;

  // Tambahkan properti lain yang relevan di sini
  final String? cddType;
  final double? limitMargin;
  final double? residualLimit;

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
    this.minDeposit,
    this.maxDeposit,
    this.minTopup,
    this.minWithdrawal,
    this.maxWithdrawal,
    this.cddType,
    this.limitMargin,
    this.residualLimit,
  });
  

  factory AccountDetailModel.fromJson(Map<String, dynamic> json) {
    return AccountDetailModel(
      id: json['id']?.toString(),
      login: json['login']?.toString(),
      type: json['type']?.toString(),
      namaTipeAkun: json['nama_tipe_akun']?.toString(),
      balance: json['balance']?.toString(),
      currency: json['currency']?.toString(),
      marginFree: json['margin_free']?.toString(),
      accountCurrency: json['account_currency']?.toString(),
      marginFreePercent: _toDouble(json['margin_free_percent']),
      totalDepositUsd: json['total_deposit_usd']?.toString(),
      totalWithdrawalUsd: json['total_withdrawal_usd']?.toString(),
      pnl: json['pnl']?.toString(),
      equity: json['equity']?.toString(),
      margin: json['margin']?.toString(),
      minDeposit: json['min_deposit']?.toString(),
      maxDeposit: json['max_deposit']?.toString(),
      minTopup: json['min_topup']?.toString(),
      minWithdrawal: json['min_withdrawal']?.toString(),
      maxWithdrawal: json['max_withdrawal']?.toString(),
      cddType: json['cdd_type']?.toString(),
      limitMargin: _toDouble(json['limit_margin']),
      residualLimit: _toDouble(json['residual_limit']),
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
      'equity': equity,
      'min_deposit': minDeposit,
      'max_deposit': maxDeposit,
      'min_topup': minTopup,
      'min_withdrawal': minWithdrawal,
      'max_withdrawal': maxWithdrawal,
      'cdd_type': cddType,
      'limit_margin': limitMargin,
      'residual_limit': residualLimit,
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