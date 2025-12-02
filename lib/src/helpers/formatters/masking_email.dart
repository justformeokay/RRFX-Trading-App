String maskEmail(String email) {
  if (!email.contains("@")) return email; // bukan email valid
  final parts = email.split("@");
  final name = parts[0];
  final domain = parts[1];

  // kalau nama < 3 huruf, kasih minimal masking
  if (name.length <= 3) {
    return "${name[0]}***@$domain";
  } else {
    return "${name.substring(0, 3)}***@$domain";
  }
}

String maskPhoneNumber(String phoneNumber) {
  if (phoneNumber.length <= 4) {
    return phoneNumber; // kalau terlalu pendek, tampilkan apa adanya
  }

  // Ambil 4 digit awal dan 2 digit akhir
  String start = phoneNumber.substring(0, phoneNumber.length >= 4 ? 4 : phoneNumber.length);
  String end = phoneNumber.length > 6 ? phoneNumber.substring(phoneNumber.length - 2) : "";

  // Jumlah bintang menyesuaikan panjang
  int maskLength = phoneNumber.length - (start.length + end.length);
  String masked = "*" * (maskLength > 0 ? maskLength : 0);

  return "$start$masked$end";
}

