import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';

  static final Map<String, Locale> availableLanguages = {
    'English': const Locale('en', 'US'),
    'Italian': const Locale('it', 'IT'),
  };

  var selectedLanguage = 'Italian'.obs;
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
      final savedLanguage = prefs.getString(_languageKey) ?? 'Italian'; // 👈 Italian default

      selectedLanguage.value = savedLanguage;
      currentLocale.value = _getLocaleFromLanguage(savedLanguage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.updateLocale(currentLocale.value);
      });

      debugPrint('Language loaded: $savedLanguage');
      debugPrint('Locale set to: ${currentLocale.value}');
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      selectedLanguage.value = 'Italian'; // 👈 Italian default
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
      Get.snackbar(
        'Error'.tr,
        'Failed to change language'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Locale _getLocaleFromLanguage(String language) {
    return availableLanguages[language] ?? const Locale('it', 'IT'); // 👈 Italian fallback
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

/*
class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';

  // Available languages for the app
  static final Map<String, Locale> availableLanguages = {
    'English': const Locale('en', 'US'),
    'Italian': const Locale('it', 'IT'),
  };

  // Language and locale variables
  var selectedLanguage = 'Italian'.obs;
  var currentLocale = const Locale('it', 'IT').obs;

  @override
  void onInit() {
    super.onInit();
    // You can keep loadSavedLanguage() here or use initializeLocale() from main()
    loadSavedLanguage();
  }

  // ADD THIS METHOD: Initialize locale (can be called from main())
  Future<void> initializeLocale() async {
    await loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? 'English';
      //final savedLanguage = prefs.getString(_languageKey) ?? 'Italian';

      selectedLanguage.value = savedLanguage;
      currentLocale.value = _getLocaleFromLanguage(savedLanguage);

      // Update GetX locale - Add delay to ensure widget tree is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.updateLocale(currentLocale.value);
      });

      debugPrint('Language loaded: $savedLanguage');
      debugPrint('Locale set to: ${currentLocale.value}');
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      // Set default values in case of error
      selectedLanguage.value = 'English';
      currentLocale.value = const Locale('en', 'US');
    }
  }

  Future<void> saveLanguage(String language) async {
    try {
      // Validate language
      if (!availableLanguages.containsKey(language)) {
        debugPrint('Invalid language: $language');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);

      // Update the observable values
      selectedLanguage.value = language;
      currentLocale.value = _getLocaleFromLanguage(language);

      // CRITICAL: Update GetX locale - this triggers app-wide language change
      await Get.updateLocale(currentLocale.value);

      // Force UI to rebuild
      update();

      debugPrint('Language saved and updated: $language');
      debugPrint('Current locale: ${currentLocale.value}');
    } catch (e) {
      debugPrint('Error saving language: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to change language'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Convert language name to Locale
  Locale _getLocaleFromLanguage(String language) {
    return availableLanguages[language] ?? const Locale('en', 'US');
  }

  // Get available languages list
  List<String> get availableLanguageNames {
    return availableLanguages.keys.toList();
  }

  // Helper method to get current language code for debugging
  String get currentLanguageCode {
    return currentLocale.value.languageCode;
  }

  // Check if a language is currently selected
  bool isLanguageSelected(String language) {
    return selectedLanguage.value == language;
  }

  // Get the display name for the current language
  String get currentLanguageDisplay {
    return selectedLanguage.value;
  }
}
*/
