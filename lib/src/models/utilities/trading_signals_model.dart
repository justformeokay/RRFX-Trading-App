class TradingSignalsModel {
  TradingSignalsModel({
    this.result,
    this.message,
  });
  String? result;
  List<Message>? message;

  TradingSignalsModel.fromJson(Map<String, dynamic> json){
    result = json['result'];
    message = List.from(json['message']).map((e)=>Message.fromJson(e)).toList();
  }
}

class Message {
  Message({
    this.symbol,
    this.timeframe,
    this.analysis,
  });
  String? symbol;
  String? timeframe;
  Analysis? analysis;

  Message.fromJson(Map<String, dynamic> json){
    symbol = json['symbol'];
    timeframe = json['timeframe'];
    analysis = json['analysis'] != null ? Analysis.fromJson(json['analysis']) : null;
  }
}

class Analysis {
  Analysis({
    this.indicators,
    this.signals,
    this.recommendation,
    this.lastUpdate,
    this.currentPrice,
    this.tradingSuggestions,
  });
  Indicators? indicators;
  Signals? signals;
  String? recommendation;
  String? lastUpdate;
  CurrentPrice? currentPrice;
  TradingSuggestions? tradingSuggestions;

  Analysis.fromJson(Map<String, dynamic> json){
    indicators = json['indicators'] != null ? Indicators.fromJson(json['indicators']) : null;
    signals = json['signals'] != null ? Signals.fromJson(json['signals']) : null;
    recommendation = json['recommendation'];
    lastUpdate = json['last_update'];
    currentPrice = json['current_price'] != null ? CurrentPrice.fromJson(json['current_price']) : null;
    tradingSuggestions = json['trading_suggestions'] != null ? TradingSuggestions.fromJson(json['trading_suggestions']) : null;
  }
}

class Indicators {
  Indicators({
    this.movingAverages,
    this.rsi,
    this.macd,
    this.bollingerBands,
  });
  MovingAverages? movingAverages;
  dynamic rsi;
  Macd? macd;
  BollingerBands? bollingerBands;

  Indicators.fromJson(Map<String, dynamic> json){
    movingAverages = json['moving_averages'] != null ? MovingAverages.fromJson(json['moving_averages']) : null;
    rsi = json['rsi'];
    macd = json['macd'] != null ? Macd.fromJson(json['macd']) : null;
    bollingerBands = json['bollinger_bands'] != null ? BollingerBands.fromJson(json['bollinger_bands']) : null;
  }
}

class MovingAverages {
  MovingAverages({
    this.sma_10,
    this.sma_20,
    this.sma_50,
    this.priceVsSma50,
  });
  dynamic sma_10;
  dynamic sma_20;
  dynamic sma_50;
  dynamic priceVsSma50;

  MovingAverages.fromJson(Map<String, dynamic> json){
    sma_10 = json['sma_10'];
    sma_20 = json['sma_20'];
    sma_50 = json['sma_50'];
    priceVsSma50 = json['price_vs_sma50'];
  }
}

class Macd {
  Macd({
    this.macdLine,
    this.signalLine,
    this.histogram,
  });
  dynamic macdLine;
  dynamic signalLine;
  dynamic histogram;

  Macd.fromJson(Map<String, dynamic> json){
    macdLine = json['macd_line'];
    signalLine = json['signal_line'];
    histogram = json['histogram'];
  }
}

class BollingerBands {
  BollingerBands({this.upper, this.middle, this.lower, this.pricePosition});
  dynamic upper;
  dynamic middle;
  dynamic lower;
  dynamic pricePosition;

  BollingerBands.fromJson(Map<String, dynamic> json){
    upper = json['upper'];
    middle = json['middle'];
    lower = json['lower'];
    pricePosition = json['price_position'];
  }
}

class Signals {
  Signals({
    this.maCross,
    this.maTrend,
    this.rsi,
    this.macd,
    this.bollinger,
  });
  String? maCross;
  String? maTrend;
  String? rsi;
  String? macd;
  String? bollinger;

  Signals.fromJson(Map<String, dynamic> json){
    maCross = json['ma_cross'];
    maTrend = json['ma_trend'];
    rsi = json['rsi'];
    macd = json['macd'];
    bollinger = json['bollinger'];
  }
}

class CurrentPrice {
  CurrentPrice({
    this.bid,
    this.ask,
    this.spread,
  });
  dynamic bid;
  dynamic ask;
  int? spread;

  CurrentPrice.fromJson(Map<String, dynamic> json){
    bid = json['bid'];
    ask = json['ask'];
    spread = json['spread'];
  }
}

class TradingSuggestions {
  TradingSuggestions({
    this.stopLoss,
    this.takeProfit,
    this.volatility,
    this.keyLevels,
    this.riskReward,
  });
  dynamic stopLoss;
  TakeProfit? takeProfit;
  Volatility? volatility;
  KeyLevels? keyLevels;
  RiskReward? riskReward;

  TradingSuggestions.fromJson(Map<String, dynamic> json){
    stopLoss = json['stop_loss'];
    takeProfit = json['take_profit'] != null ? TakeProfit.fromJson(json['take_profit']) : null;
    volatility = json['volatility'] != null ? Volatility.fromJson(json['volatility']) : null;
    keyLevels = json['key_levels'] != null ? KeyLevels.fromJson(json['key_levels']) : null;
    riskReward = json['risk_reward'] != null ? RiskReward.fromJson(json['risk_reward']) : null;
  }
}

class TakeProfit {
  TakeProfit({
    this.atrBased,
    this.keyLevel,
    this.fibonacci,
  });
  dynamic atrBased;
  dynamic keyLevel;
  dynamic fibonacci;

  TakeProfit.fromJson(Map<String, dynamic> json){
    atrBased = json['atr_based'];
    keyLevel = json['key_level'];
    fibonacci = json['fibonacci'];
  }
}

class Volatility {
  Volatility({
    this.atr,
    this.dailyRange,
  });
  dynamic atr;
  dynamic dailyRange;

  Volatility.fromJson(Map<String, dynamic> json){
    atr = json['atr'];
    dailyRange = json['daily_range'];
  }
}

class KeyLevels {
  KeyLevels({
    this.recentHigh,
    this.recentLow,
    this.swingHigh,
    this.swingLow,
  });
  dynamic recentHigh;
  dynamic recentLow;
  dynamic swingHigh;
  dynamic swingLow;

  KeyLevels.fromJson(Map<String, dynamic> json){
    recentHigh = json['recent_high'];
    recentLow = json['recent_low'];
    swingHigh = json['swing_high'];
    swingLow = json['swing_low'];
  }
}

class RiskReward {
  RiskReward({
    this.atrBased,
    this.keyLevel,
    this.fibonacci,
  });
  dynamic atrBased;
  dynamic keyLevel;
  dynamic fibonacci;

  RiskReward.fromJson(Map<String, dynamic> json){
    atrBased = json['atr_based'];
    keyLevel = json['key_level'];
    fibonacci = json['fibonacci'];
  }
}