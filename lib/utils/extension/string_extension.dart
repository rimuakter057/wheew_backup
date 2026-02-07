import '../string/app_strings.dart';

extension LocalizationExtension on String {
  String get tr => AppStrings.text(this);
}
