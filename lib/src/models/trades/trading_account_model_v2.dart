class TradingAccountModelV2 {
  String? id;
  String? login;
  String? type;
  String? namaTipeAkun;
  String? rate;
  String? marginFree;
  double? marginFreePercent;
  String? balance;
  String? leverage;
  String? pnl;
  String? currency;
  String? totalDepositIdr;
  String? totalDepositUsd;
  String? totalWithdrawalIdr;
  String? totalWithdrawalUsd;
  String? minDeposit;
  String? minTopup;
  String? minWithdrawal;
  String? maxWithdrawal;

  TradingAccountModelV2({
    this.id,
    this.login,
    this.type,
    this.namaTipeAkun,
    this.rate,
    this.marginFree,
    this.marginFreePercent,
    this.balance,
    this.leverage,
    this.pnl,
    this.currency,
    this.totalDepositIdr,
    this.totalDepositUsd,
    this.totalWithdrawalIdr,
    this.totalWithdrawalUsd,
    this.minDeposit,
    this.minTopup,
    this.minWithdrawal,
    this.maxWithdrawal,
  });

  factory TradingAccountModelV2.fromJson(Map<String, dynamic> json) {
    return TradingAccountModelV2(
      id: json['id']?.toString(),
      login: json['login']?.toString(),
      type: json['type']?.toString(),
      namaTipeAkun: json['nama_tipe_akun']?.toString(),
      rate: json['rate']?.toString(),
      marginFree: json['margin_free']?.toString(),
      marginFreePercent: (json['margin_free_percent'] is num)
          ? json['margin_free_percent'].toDouble()
          : double.tryParse(json['margin_free_percent']?.toString() ?? '0'),
      balance: json['balance']?.toString(),
      leverage: json['leverage']?.toString(),
      pnl: json['pnl']?.toString(),
      currency: json['currency']?.toString(),
      totalDepositIdr: json['total_deposit_idr']?.toString(),
      totalDepositUsd: json['total_deposit_usd']?.toString(),
      totalWithdrawalIdr: json['total_withdrawal_idr']?.toString(),
      totalWithdrawalUsd: json['total_withdrawal_usd']?.toString(),
      minDeposit: json['min_deposit']?.toString(),
      minTopup: json['min_topup']?.toString(),
      minWithdrawal: json['min_withdrawal']?.toString(),
      maxWithdrawal: json['max_withdrawal']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'type': type,
      'nama_tipe_akun': namaTipeAkun,
      'rate': rate,
      'margin_free': marginFree,
      'margin_free_percent': marginFreePercent,
      'balance': balance,
      'leverage': leverage,
      'pnl': pnl,
      'currency': currency,
      'total_deposit_idr': totalDepositIdr,
      'total_deposit_usd': totalDepositUsd,
      'total_withdrawal_idr': totalWithdrawalIdr,
      'total_withdrawal_usd': totalWithdrawalUsd,
      'min_deposit': minDeposit,
      'min_topup': minTopup,
      'min_withdrawal': minWithdrawal,
      'max_withdrawal': maxWithdrawal,
    };
  }
}
