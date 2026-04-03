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

  return false; // Default: hari trading normal
}
