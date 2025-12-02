bool isForexMarketHoliday(DateTime date) {
  // Cek jika hari Sabtu atau Minggu
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return true;
  }

  // Daftar hari libur internasional (format: YYYY-MM-DD)
  final List<String> holidayList = [
    "2025-01-01", // New Year
    "2025-12-25", // Christmas
    "2025-07-04", // US Independence Day
    "2025-11-27", // US Thanksgiving (contoh 2025)
  ];

  String formatted = "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  return holidayList.contains(formatted);
}
