import 'package:get/get.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/charts_deriv/models/candle_model.dart';

class MarketRepository {
  final client = GetConnect();

  Future<List<CandleModel>> fetchHistory({
    required String symbol,
    required String timeframe,
    required String account,
    required String accessToken,
  }) async {
    final res = await client.get(
      '${GlobalVariable.mainURL}/market/price-history',
      query: {
        'account': account,
        'timeframe': timeframe,
        'symbol': symbol,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final List data = res.body['response'];
    return data.map((e) => CandleModel.fromJson(e)).toList();
  }
}
