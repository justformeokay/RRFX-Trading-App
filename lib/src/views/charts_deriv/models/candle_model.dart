// candle_model.dart
import 'package:deriv_chart/deriv_chart.dart';

class CandleModel {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final int digits;
  final int tickVolume;

  CandleModel({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.digits,
    required this.tickVolume,
  });

  /// Parse dari API JSON (contoh response yang kamu kasih)
  /// {
  ///   "time": "2025-11-18T16:00:00",
  ///   "open": 0.9097,
  ///   "high": 0.91023,
  ///   "low": 0.90891,
  ///   "close": 0.9101,
  ///   "digits": 5,
  ///   "tickVolume": 883
  /// }
  factory CandleModel.fromJson(Map<String, dynamic> json) {
    // beberapa API mengirim time sebagai ISO string atau epoch (int)
    final dynamic timeRaw = json['time'];
    DateTime parsedTime;
    if (timeRaw is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(timeRaw).toUtc();
    } else if (timeRaw is String) {
      parsedTime = DateTime.parse(timeRaw).toUtc();
    } else {
      // fallback ke now agar tidak crash (sebaiknya handle lebih ketat)
      parsedTime = DateTime.now().toUtc();
    }

    return CandleModel(
      time: parsedTime,
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      digits: (json['digits'] is int) ? json['digits'] as int : (json['digits'] as num).toInt(),
      tickVolume: (json['tickVolume'] is int) ? json['tickVolume'] as int : (json['tickVolume'] as num).toInt(),
    );
  }

  /// Untuk menyimpan ke SQLite: gunakan millisecondsSinceEpoch (int)
  Map<String, dynamic> toDbMap() {
    return {
      'time': time.millisecondsSinceEpoch,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'digits': digits,
      'tickVolume': tickVolume,
    };
  }

  /// Parse dari record SQLite (time disimpan sebagai int milliseconds)
  factory CandleModel.fromDbMap(Map<String, dynamic> map) {
    final int t = map['time'] is int ? map['time'] as int : (map['time'] as num).toInt();
    return CandleModel(
      time: DateTime.fromMillisecondsSinceEpoch(t).toUtc(),
      open: (map['open'] as num).toDouble(),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
      digits: (map['digits'] is int) ? map['digits'] as int : (map['digits'] as num).toInt(),
      tickVolume: (map['tickVolume'] is int) ? map['tickVolume'] as int : (map['tickVolume'] as num).toInt(),
    );
  }

  /// Konversi ke Candle (deriv_chart) — memerlukan package deriv_chart
  Candle toDerivCandle() {
    return Candle(
      epoch: (time.millisecondsSinceEpoch / 1000).round(),
      open: open,
      high: high,
      low: low,
      close: close,
    );
  }

  /// Optional: copyWith agar mudah update
  CandleModel copyWith({
    DateTime? time,
    double? open,
    double? high,
    double? low,
    double? close,
    int? digits,
    int? tickVolume,
  }) {
    return CandleModel(
      time: time ?? this.time,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      digits: digits ?? this.digits,
      tickVolume: tickVolume ?? this.tickVolume,
    );
  }
}
