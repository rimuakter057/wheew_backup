class ApiUrl {
  // Base URL - Replace with your actual API base URL
  static const String baseUrl = 'http://10.10.20.44:8003';
  static String socketUrl({required String userId}) => "$baseUrl?userId=$userId";

  // Fixed endpoints to match your backend
  static const String register = '/auth/register';
  static const String login = '/auth/signin';
  static const String chatList = '/auth/me';
  static const String searchUsers = '/users/search';
  static const String updateProfile = '/users/';

}