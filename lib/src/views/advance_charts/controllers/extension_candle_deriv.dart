
import 'package:deriv_chart/deriv_chart.dart';
import 'package:rrfx/src/views/advance_charts/models/advance_candle_model.dart';

extension CandleMapper on AdvanceCandleModel {
  Candle toCandle() {
    return Candle(
      epoch: epoch,
      open: open,
      high: high,
      low: low,
      close: close,
    );
  }
}
