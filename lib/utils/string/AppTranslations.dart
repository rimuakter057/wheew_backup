import 'package:get/get.dart';
import 'english.dart';
import 'italian.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': english,
    'it_IT': italian,
  };
}
