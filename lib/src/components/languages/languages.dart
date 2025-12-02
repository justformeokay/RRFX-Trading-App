import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'package:rrfx/src/components/languages/english.dart';
import 'package:rrfx/src/components/languages/indonesia.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'id_ID': IndonesiaLanguage().indonesia,
    'en_US': English().usa,
  };
}