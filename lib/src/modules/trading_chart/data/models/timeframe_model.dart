/// Represents a chart timeframe
enum ChartTimeframe {
  m1('M1', 'M1', Duration(minutes: 1)),
  m5('M5', 'M5', Duration(minutes: 5)),
  m15('M15', 'M15', Duration(minutes: 15)),
  m30('M30', 'M30', Duration(minutes: 30)),
  h1('H1', '1H', Duration(hours: 1)),
  h4('H4', '4H', Duration(hours: 4)),
  d1('D1', 'D', Duration(days: 1)),
  w1('W1', 'W', Duration(days: 7)),
  mn('MN', 'MN', Duration(days: 30));

  /// Internal identifier
  final String id;
  
  /// Display label
  final String label;
  
  /// Duration of each candle
  final Duration duration;

  const ChartTimeframe(this.id, this.label, this.duration);

  /// Display name (alias for label)
  String get displayName => label;

  /// Duration in milliseconds
  int get milliseconds => duration.inMilliseconds;

  /// Duration in minutes
  int get minutes => duration.inMinutes;

  /// Returns timeframe from string id
  static ChartTimeframe fromId(String id) {
    return ChartTimeframe.values.firstWhere(
      (tf) => tf.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ChartTimeframe.h1,
    );
  }

  /// Returns timeframe from minutes
  static ChartTimeframe fromMinutes(int minutes) {
    return ChartTimeframe.values.firstWhere(
      (tf) => tf.minutes == minutes,
      orElse: () => ChartTimeframe.h1,
    );
  }

  /// Formats a timestamp according to this timeframe
  String formatTimestamp(DateTime dateTime) {
    switch (this) {
      case ChartTimeframe.m1:
      case ChartTimeframe.m5:
      case ChartTimeframe.m15:
      case ChartTimeframe.m30:
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      case ChartTimeframe.h1:
      case ChartTimeframe.h4:
        return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:00';
      case ChartTimeframe.d1:
        return '${dateTime.day}/${dateTime.month}';
      case ChartTimeframe.w1:
        return '${dateTime.day}/${dateTime.month}/${dateTime.year % 100}';
      case ChartTimeframe.mn:
        return '${_monthName(dateTime.month)} ${dateTime.year}';
    }
  }

  /// Gets short format for time axis
  String formatForAxis(DateTime dateTime, bool showDate) {
    switch (this) {
      case ChartTimeframe.m1:
      case ChartTimeframe.m5:
      case ChartTimeframe.m15:
      case ChartTimeframe.m30:
        if (showDate && dateTime.hour == 0 && dateTime.minute == 0) {
          return '${dateTime.day}/${dateTime.month}';
        }
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      case ChartTimeframe.h1:
      case ChartTimeframe.h4:
        if (showDate && dateTime.hour == 0) {
          return '${dateTime.day}/${dateTime.month}';
        }
        return '${dateTime.hour}:00';
      case ChartTimeframe.d1:
        if (dateTime.day == 1) {
          return _monthName(dateTime.month).substring(0, 3);
        }
        return '${dateTime.day}';
      case ChartTimeframe.w1:
        return '${dateTime.day}/${dateTime.month}';
      case ChartTimeframe.mn:
        if (dateTime.month == 1) {
          return '${dateTime.year}';
        }
        return _monthName(dateTime.month).substring(0, 3);
    }
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Calculates appropriate grid interval for this timeframe
  int get gridIntervalCandles {
    switch (this) {
      case ChartTimeframe.m1:
        return 60;  // 1 hour intervals
      case ChartTimeframe.m5:
        return 12;  // 1 hour intervals
      case ChartTimeframe.m15:
        return 4;   // 1 hour intervals
      case ChartTimeframe.m30:
        return 2;   // 1 hour intervals
      case ChartTimeframe.h1:
        return 24;  // 1 day intervals
      case ChartTimeframe.h4:
        return 6;   // 1 day intervals
      case ChartTimeframe.d1:
        return 7;   // 1 week intervals
      case ChartTimeframe.w1:
        return 4;   // 1 month intervals
      case ChartTimeframe.mn:
        return 12;  // 1 year intervals
    }
  }
}

/// Extension for timeframe list
extension TimeframeListExtension on List<ChartTimeframe> {
  /// Returns commonly used timeframes for quick selection
  static List<ChartTimeframe> get common => [
    ChartTimeframe.m1,
    ChartTimeframe.m5,
    ChartTimeframe.m15,
    ChartTimeframe.h1,
    ChartTimeframe.h4,
    ChartTimeframe.d1,
  ];

  /// Returns all available timeframes
  static List<ChartTimeframe> get all => ChartTimeframe.values;
}
