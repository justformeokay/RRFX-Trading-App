import 'dart:math' as math;
import '../../data/models/candle_model.dart';
import '../../data/models/indicator_model.dart';

/// Calculator for technical indicators
/// Optimized for performance with efficient algorithms
class IndicatorCalculator {
  /// Calculate Simple Moving Average (SMA)
  /// 
  /// SMA = Sum of prices over period / period
  static List<double?> calculateSMA({
    required List<CandleModel> candles,
    required int period,
    MAPriceType priceType = MAPriceType.close,
  }) {
    if (candles.isEmpty || period <= 0) return [];
    
    final values = List<double?>.filled(candles.length, null);
    
    if (candles.length < period) return values;
    
    // Calculate first SMA using full sum
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += _getPriceByType(candles[i], priceType);
    }
    values[period - 1] = sum / period;
    
    // Calculate rest using sliding window (O(1) per calculation)
    for (int i = period; i < candles.length; i++) {
      sum = sum - _getPriceByType(candles[i - period], priceType) 
               + _getPriceByType(candles[i], priceType);
      values[i] = sum / period;
    }
    
    return values;
  }
  
  /// Calculate Exponential Moving Average (EMA)
  /// 
  /// EMA = Price(today) * K + EMA(yesterday) * (1-K)
  /// where K = 2 / (period + 1)
  static List<double?> calculateEMA({
    required List<CandleModel> candles,
    required int period,
    MAPriceType priceType = MAPriceType.close,
  }) {
    if (candles.isEmpty || period <= 0) return [];
    
    final values = List<double?>.filled(candles.length, null);
    
    if (candles.length < period) return values;
    
    // Calculate multiplier
    final multiplier = 2.0 / (period + 1);
    
    // First EMA is SMA of first 'period' values
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += _getPriceByType(candles[i], priceType);
    }
    double ema = sum / period;
    values[period - 1] = ema;
    
    // Calculate rest using EMA formula
    for (int i = period; i < candles.length; i++) {
      final price = _getPriceByType(candles[i], priceType);
      ema = (price - ema) * multiplier + ema;
      values[i] = ema;
    }
    
    return values;
  }
  
  /// Calculate Weighted Moving Average (WMA)
  static List<double?> calculateWMA({
    required List<CandleModel> candles,
    required int period,
    MAPriceType priceType = MAPriceType.close,
  }) {
    if (candles.isEmpty || period <= 0) return [];
    
    final values = List<double?>.filled(candles.length, null);
    
    if (candles.length < period) return values;
    
    final divisor = (period * (period + 1)) / 2;
    
    for (int i = period - 1; i < candles.length; i++) {
      double sum = 0;
      for (int j = 0; j < period; j++) {
        final weight = j + 1;
        sum += _getPriceByType(candles[i - period + 1 + j], priceType) * weight;
      }
      values[i] = sum / divisor;
    }
    
    return values;
  }
  
  /// Calculate Smoothed Moving Average (SMMA)
  static List<double?> calculateSMMA({
    required List<CandleModel> candles,
    required int period,
    MAPriceType priceType = MAPriceType.close,
  }) {
    if (candles.isEmpty || period <= 0) return [];
    
    final values = List<double?>.filled(candles.length, null);
    
    if (candles.length < period) return values;
    
    // First SMMA is SMA
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += _getPriceByType(candles[i], priceType);
    }
    double smma = sum / period;
    values[period - 1] = smma;
    
    // Calculate rest using SMMA formula
    // SMMA = (SMMA(prev) * (period - 1) + Price) / period
    for (int i = period; i < candles.length; i++) {
      final price = _getPriceByType(candles[i], priceType);
      smma = (smma * (period - 1) + price) / period;
      values[i] = smma;
    }
    
    return values;
  }
  
  /// Calculate Bollinger Bands
  static ({List<double?> upper, List<double?> middle, List<double?> lower}) calculateBollingerBands({
    required List<CandleModel> candles,
    required int period,
    required double deviation,
    MAPriceType priceType = MAPriceType.close,
  }) {
    if (candles.isEmpty || period <= 0) {
      return (upper: [], middle: [], lower: []);
    }
    
    final upper = List<double?>.filled(candles.length, null);
    final middle = List<double?>.filled(candles.length, null);
    final lower = List<double?>.filled(candles.length, null);
    
    if (candles.length < period) {
      return (upper: upper, middle: middle, lower: lower);
    }
    
    // Calculate SMA for middle band
    final sma = calculateSMA(candles: candles, period: period, priceType: priceType);
    
    // Calculate standard deviation and bands
    for (int i = period - 1; i < candles.length; i++) {
      if (sma[i] == null) continue;
      
      // Calculate standard deviation
      double sumSquaredDiff = 0;
      for (int j = i - period + 1; j <= i; j++) {
        final price = _getPriceByType(candles[j], priceType);
        final diff = price - sma[i]!;
        sumSquaredDiff += diff * diff;
      }
      final stdDev = math.sqrt(sumSquaredDiff / period);
      
      middle[i] = sma[i];
      upper[i] = sma[i]! + (stdDev * deviation);
      lower[i] = sma[i]! - (stdDev * deviation);
    }
    
    return (upper: upper, middle: middle, lower: lower);
  }
  
  /// Calculate RSI (Relative Strength Index)
  static List<double?> calculateRSI({
    required List<CandleModel> candles,
    required int period,
  }) {
    if (candles.isEmpty || period <= 0) return [];
    
    final values = List<double?>.filled(candles.length, null);
    
    if (candles.length < period + 1) return values;
    
    // Calculate price changes
    final gains = <double>[];
    final losses = <double>[];
    
    for (int i = 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }
    
    // First average gain and loss
    double avgGain = 0;
    double avgLoss = 0;
    
    for (int i = 0; i < period; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
    }
    avgGain /= period;
    avgLoss /= period;
    
    // Calculate first RSI
    if (avgLoss == 0) {
      values[period] = 100;
    } else {
      final rs = avgGain / avgLoss;
      values[period] = 100 - (100 / (1 + rs));
    }
    
    // Calculate rest using smoothed averages
    for (int i = period; i < gains.length; i++) {
      avgGain = ((avgGain * (period - 1)) + gains[i]) / period;
      avgLoss = ((avgLoss * (period - 1)) + losses[i]) / period;
      
      if (avgLoss == 0) {
        values[i + 1] = 100;
      } else {
        final rs = avgGain / avgLoss;
        values[i + 1] = 100 - (100 / (1 + rs));
      }
    }
    
    return values;
  }
  
  /// Calculate MACD
  static ({List<double?> macd, List<double?> signal, List<double?> histogram}) calculateMACD({
    required List<CandleModel> candles,
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (candles.isEmpty) {
      return (macd: [], signal: [], histogram: []);
    }
    
    final macdValues = List<double?>.filled(candles.length, null);
    final signalValues = List<double?>.filled(candles.length, null);
    final histogramValues = List<double?>.filled(candles.length, null);
    
    // Calculate fast and slow EMAs
    final fastEMA = calculateEMA(candles: candles, period: fastPeriod);
    final slowEMA = calculateEMA(candles: candles, period: slowPeriod);
    
    // Calculate MACD line
    for (int i = slowPeriod - 1; i < candles.length; i++) {
      if (fastEMA[i] != null && slowEMA[i] != null) {
        macdValues[i] = fastEMA[i]! - slowEMA[i]!;
      }
    }
    
    // Calculate Signal line (EMA of MACD)
    final multiplier = 2.0 / (signalPeriod + 1);
    int signalStart = slowPeriod - 1 + signalPeriod - 1;
    
    if (signalStart < candles.length) {
      // First signal is SMA of MACD
      double sum = 0;
      int count = 0;
      for (int i = slowPeriod - 1; i < slowPeriod - 1 + signalPeriod && i < candles.length; i++) {
        if (macdValues[i] != null) {
          sum += macdValues[i]!;
          count++;
        }
      }
      
      if (count == signalPeriod) {
        double signal = sum / signalPeriod;
        signalValues[signalStart] = signal;
        histogramValues[signalStart] = macdValues[signalStart]! - signal;
        
        // Calculate rest
        for (int i = signalStart + 1; i < candles.length; i++) {
          if (macdValues[i] != null) {
            signal = (macdValues[i]! - signal) * multiplier + signal;
            signalValues[i] = signal;
            histogramValues[i] = macdValues[i]! - signal;
          }
        }
      }
    }
    
    return (macd: macdValues, signal: signalValues, histogram: histogramValues);
  }
  
  /// Get price based on price type
  static double _getPriceByType(CandleModel candle, MAPriceType type) {
    switch (type) {
      case MAPriceType.close:
        return candle.close;
      case MAPriceType.open:
        return candle.open;
      case MAPriceType.high:
        return candle.high;
      case MAPriceType.low:
        return candle.low;
      case MAPriceType.median:
        return (candle.high + candle.low) / 2;
      case MAPriceType.typical:
        return (candle.high + candle.low + candle.close) / 3;
      case MAPriceType.weighted:
        return (candle.high + candle.low + candle.close + candle.close) / 4;
    }
  }
  
  /// Calculate Moving Average based on type
  static List<double?> calculateMA({
    required List<CandleModel> candles,
    required MovingAverageType type,
    required int period,
    MAPriceType priceType = MAPriceType.close,
  }) {
    switch (type) {
      case MovingAverageType.sma:
        return calculateSMA(candles: candles, period: period, priceType: priceType);
      case MovingAverageType.ema:
        return calculateEMA(candles: candles, period: period, priceType: priceType);
      case MovingAverageType.wma:
        return calculateWMA(candles: candles, period: period, priceType: priceType);
      case MovingAverageType.smma:
        return calculateSMMA(candles: candles, period: period, priceType: priceType);
    }
  }
}
