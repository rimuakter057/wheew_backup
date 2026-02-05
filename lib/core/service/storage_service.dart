import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save credentials
  static Future<void> saveCredentials({
    required String identifier,
    required String password,
  }) async {
    await _prefs?.setString('saved_identifier', identifier);
    await _prefs?.setString('saved_password', password);
    await _prefs?.setBool('remember_me', true);
  }

  // Get saved credentials
  static Map<String, String?> getSavedCredentials() {
    return {
      'identifier': _prefs?.getString('saved_identifier'),
      'password': _prefs?.getString('saved_password'),
    };
  }

  // Check if remember me is enabled
  static bool isRememberMeEnabled() {
    return _prefs?.getBool('remember_me') ?? false;
  }

  // Clear saved credentials
  static Future<void> clearCredentials() async {
    await _prefs?.remove('saved_identifier');
    await _prefs?.remove('saved_password');
    await _prefs?.setBool('remember_me', false);
  }

  // Save token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  // Get token
  static String? getToken() {
    return _prefs?.getString('auth_token');
  }

  // Save user data
  static Future<void> saveUserData({
    required String userId,
    required String nickName,
    required String licenceId,
    String? avatar,
    String? role,
  }) async {
    await _prefs?.setString('user_id', userId);
    await _prefs?.setString('nick_name', nickName);
    await _prefs?.setString('licence_id', licenceId);
    if (avatar != null) await _prefs?.setString('avatar', avatar);
    if (role != null) await _prefs?.setString('role', role);
  }

  // Get user data
  static Map<String, String?> getUserData() {
    return {
      'user_id': _prefs?.getString('user_id'),
      'nick_name': _prefs?.getString('nick_name'),
      'licence_id': _prefs?.getString('licence_id'),
      'avatar': _prefs?.getString('avatar'),
      'role': _prefs?.getString('role'),
    };
  }

  // Clear all data (for logout)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _prefs?.getString('auth_token') != null;
  }
}