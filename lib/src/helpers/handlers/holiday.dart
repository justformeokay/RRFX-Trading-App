bool isForexHoliday([DateTime? date]) {
  final now = date ?? DateTime.now().toUtc(); // Gunakan UTC agar sesuai pasar global
  final weekday = now.weekday; // 1 = Monday, ..., 7 = Sunday

  // Tutup pasar di akhir pekan
  if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
    return true;
  }

  // Daftar tanggal libur Forex tetap
  final holidays = <String>[
    '01-01', // New Year’s Day
    '25-12', // Christmas Day
    '26-12', // Boxing Day
  ];

  final today = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}';
  if (holidays.contains(today)) {
    return true;
  }

  // Cek libur yang berubah tiap tahun, misal Good Friday
  final goodFriday = _getGoodFriday(now.year);
  if (_isSameDay(now, goodFriday)) {
    return true;
  }

  return false; // Default: hari trading normal
}

/// 🔹 Helper untuk cek apakah 2 tanggal sama (tanpa jam)
bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 🔹 Hitung tanggal Good Friday (dua hari sebelum Easter Sunday)
DateTime _getGoodFriday(int year) {
  // Algoritma Gauss untuk menghitung tanggal Easter
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  final easter = DateTime.utc(year, month, day);
  return easter.subtract(const Duration(days: 2)); // Good Friday
}
