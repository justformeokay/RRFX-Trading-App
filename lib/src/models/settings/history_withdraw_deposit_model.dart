class HistoryWithdrawDepositModel {
  List<HistoryItem> response;

  HistoryWithdrawDepositModel({required this.response});

  factory HistoryWithdrawDepositModel.fromJson(List<dynamic> json) {
    return HistoryWithdrawDepositModel(
      response: json.map((e) => HistoryItem.fromJson(e)).toList(),
    );
  }
}

class HistoryItem {
  final String id;
  final String type;
  final String login;
  final String amount;
  final String amountReceived;
  final String status;
  final String datetime;

  HistoryItem({
    required this.id,
    required this.type,
    required this.login,
    required this.amount,
    required this.amountReceived,
    required this.status,
    required this.datetime,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      login: json['login'] ?? '',
      amount: json['amount'] ?? '',
      amountReceived: json['amount_received'] ?? '',
      status: json['status'] ?? '',
      datetime: json['datetime'] ?? '',
    );
  }
}
