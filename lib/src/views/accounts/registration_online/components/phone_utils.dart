// utils/phone_utils.dart

/// Extracts the E.164 country calling code and the national number from an input string.
/// Returns a Map with keys:
///  - 'raw' : cleaned original string (starts with '+')
///  - 'countryCode' : like "+62"
///  - 'nationalNumber' : the rest after removing country code (digits only)
///  - 'success' : bool
Map<String, dynamic> extractPhoneCode(String? input) {
  // 1) normalize input
  if (input == null) return {'success': false};
  String s = input.trim();

  // convert leading 00 to +
  if (s.startsWith('00')) {
    s = '+${s.substring(2)}';
  }

  // keep only digits and leading '+'
  s = s.replaceAll(RegExp(r'[^0-9+]'), '');

  // must start with +
  if (!s.startsWith('+')) {
    // if no plus, we can optionally try assume local number -> return failure
    return {'success': false, 'message': 'No leading + or 00 found', 'raw': s};
  }

  // drop the '+' for matching digits
  final digits = s.substring(1);

  // 2) known country calling codes (E.164) - check longest first (3 -> 2 -> 1)
  // This set contains the common/official country calling codes. If you want completeness,
  // you can expand this set with other codes from ITU list.
  final Set<String> codes = {
    // 1-digit
    '1','7',
    // 2-digit (some examples)
    '20','27','30','31','32','33','34','36','39','40','41','43','44','45','46','47','48','49',
    '51','52','53','54','55','56','57','58',
    '60','61','62','63','64','65','66',
    '81','82','84','86',
    '90','91','92','93','94','95','98',
    // 3-digit and many country codes (non-exhaustive but broad)
    '211','212','213','216','218','220','221','222','223','224','225','226','227','228','229',
    '230','231','232','233','234','235','236','237','238','239','240','241','242','243','244',
    '245','246','248','249','250','251','252','253','254','255','256','257','258','260','261',
    '262','263','264','265','266','267','268','269','290','291','297','298','299','350','351',
    '352','353','354','355','356','357','358','359','370','371','372','373','374','375','376',
    '377','378','379','380','381','382','383','385','386','387','389','420','421','423','500',
    '501','502','503','504','505','506','507','508','509','590','591','592','593','594','595',
    '596','597','598','599','670','672','673','674','675','676','677','678','679','680','681',
    '682','683','685','686','687','688','689','690','691','692','850','852','853','855','856',
    '870','871','872','873','874','875','876','877','878','879','880','881','882','883','884',
    '885','886','888','960','961','962','963','964','965','966','967','968','970','971','972',
    '973','974','975','976','977','979','992','993','994','995','996','997','998'
  };

  // try 3, 2, 1 digits
  String? matchedCode;
  for (int len = 3; len >= 1; len--) {
    if (digits.length >= len) {
      final prefix = digits.substring(0, len);
      if (codes.contains(prefix)) {
        matchedCode = prefix;
        break;
      }
    }
  }

  if (matchedCode == null) {
    return {
      'success': false,
      'message': 'No matching country code found',
      'raw': s,
    };
  }

  final countryCode = '+$matchedCode';
  final national = digits.substring(matchedCode.length);

  return {
    'success': true,
    'raw': s,
    'countryCode': countryCode,
    'nationalNumber': national,
  };
}
