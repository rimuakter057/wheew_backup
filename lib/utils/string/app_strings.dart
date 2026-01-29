import 'english.dart';
import 'bangla.dart';

class AppStrings {
  static String currentLanguage = 'en';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'bn': bn,
  };

  static String text(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }
}
