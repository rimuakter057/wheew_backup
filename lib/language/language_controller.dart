import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/custom_snack_bar/custom_snack_bar.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';

  static final Map<String, Locale> availableLanguages = {
    'English': const Locale('en', 'US'),
    'Italiano': const Locale('it', 'IT'),
  };

  var selectedLanguage = 'Italiano'.obs;
  var currentLocale = const Locale('it', 'IT').obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }

  Future<void> initializeLocale() async {
    await loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage =
          prefs.getString(_languageKey) ?? 'Italiano'; // 👈 Italian default

      selectedLanguage.value = savedLanguage;
      currentLocale.value = _getLocaleFromLanguage(savedLanguage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.updateLocale(currentLocale.value);
      });

      debugPrint('Language loaded: $savedLanguage');
      debugPrint('Locale set to: ${currentLocale.value}');
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      selectedLanguage.value = 'Italiano'; // 👈 Italian default
      currentLocale.value = const Locale('it', 'IT'); // 👈 Italian default
    }
  }

  Future<void> saveLanguage(String language) async {
    try {
      if (!availableLanguages.containsKey(language)) {
        debugPrint('Invalid language: $language');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);

      selectedLanguage.value = language;
      currentLocale.value = _getLocaleFromLanguage(language);

      await Get.updateLocale(currentLocale.value);

      update();

      debugPrint('Language saved and updated: $language');
      debugPrint('Current locale: ${currentLocale.value}');
    } catch (e) {
      debugPrint('Error saving language: $e');


      //
      // CustomSnackbar.error(
      //   context: context,
      //   message:AppStrings.failedToChangeLanguage.tr,
      // );

    }
  }

  Locale _getLocaleFromLanguage(String language) {
    return availableLanguages[language] ??
        const Locale('it', 'IT'); // 👈 Italian fallback
  }

  List<String> get availableLanguageNames {
    return availableLanguages.keys.toList();
  }

  String get currentLanguageCode {
    return currentLocale.value.languageCode;
  }

  bool isLanguageSelected(String language) {
    return selectedLanguage.value == language;
  }

  String get currentLanguageDisplay {
    return selectedLanguage.value;
  }
}

