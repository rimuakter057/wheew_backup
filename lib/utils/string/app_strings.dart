import 'english.dart';
import 'italian.dart';

class AppStrings {
  static String currentLanguage = 'en';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': english,
    'it': italian,
  };

  static String text(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }
}
