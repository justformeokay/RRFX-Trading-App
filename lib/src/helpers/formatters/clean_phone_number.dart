String cleanPhoneNumber(String input) {
  String number = input.trim();

  // Hilangkan prefix +62 atau 62
  if (number.startsWith("+62")) {
    number = number.substring(3);
  } else if (number.startsWith("62")) {
    number = number.substring(2);
  }

  // Pastikan 0 di depan juga dihapus kalau ada
  if (number.startsWith("0")) {
    number = number.substring(1);
  }

  return number;
}


String cleanPhoneNumberAllCountry(String input, String countryCode) {
  String number = input.trim();

  // Hilangkan prefix kode negara
  if (number.startsWith(countryCode)) {
    number = number.substring(countryCode.length);
  }

  // Hilangkan 0 paling depan (opsional, tergantung backend butuh atau tidak)
  if (number.startsWith("0")) {
    number = number.substring(1);
  }

  return number;
}
