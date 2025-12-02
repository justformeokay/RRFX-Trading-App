class RegexFormatter {
  static String removeHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '');
  }

  static Map<String, String> getFlagsFromPairName(String pairName) {
    if (pairName.length < 5) {
      throw ArgumentError("String 'pairName' harus memiliki panjang minimal 5 karakter.");
    }

    String flagOne = pairName.substring(0, 2);
    String flagTwo = pairName.substring(3, 5);

    return {
      'flag_one': flagOne,
      'flag_two': flagTwo,
    };
  }

  static String decodeHtmlTextManual(String input) {
    return input
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"")
        .replaceAll("&amp;", "&")
        .replaceAll("&lt;", "<")
        .replaceAll("&gt;", ">");
  }
}