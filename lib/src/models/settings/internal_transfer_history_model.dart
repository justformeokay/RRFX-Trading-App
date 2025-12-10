class InternalTransferHistoryModel {
  InternalTransferHistoryModel({
    required this.response,
  });
  late final List<InternalTransferHistoryResponse> response;

  InternalTransferHistoryModel.fromJson(Map<String, dynamic> json) {
    response = List.from(json['response'])
        .map((e) => InternalTransferHistoryResponse.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['response'] = response.map((e) => e.toJson()).toList();
    return data;
  }
}

class InternalTransferHistoryResponse {
  InternalTransferHistoryResponse({
    this.code,
    this.from,
    this.ticketFrom,
    this.to,
    this.ticketTo,
    this.amount,
    this.datetime,
  });

  String? code;
  String? from;
  String? ticketFrom;
  String? to;
  String? ticketTo;
  String? amount;
  String? datetime;

  InternalTransferHistoryResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    from = json['from'];
    ticketFrom = json['ticket_from'];
    to = json['to'];
    ticketTo = json['ticket_to'];
    amount = json['amount'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['from'] = from;
    data['ticket_from'] = ticketFrom;
    data['to'] = to;
    data['ticket_to'] = ticketTo;
    data['amount'] = amount;
    data['datetime'] = datetime;
    return data;
  }
}
