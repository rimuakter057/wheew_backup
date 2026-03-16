class ApiUrl {
  // Base URL - Replace with your actual API base URL

  // Local url
  //static const String baseUrl = 'http://10.10.20.44:8003';

  // live url
  static const String baseUrl = 'http://13.50.99.165:8003';


  //http://13.50.99.165:8003
  static const baseSocketUrl = 'ws://13.50.99.165:8003';
  static const String imageUrl = "$baseUrl/";

  static String socketUrl({required String userId}) =>
      "$baseSocketUrl?userId=$userId";

  // Fixed endpoints to match your backend
  static const String register = '/auth/register';
  static const String login = '/auth/signin';
  static const String chatList = '/auth/me';
  // Chat rooms pagination
  static String getChatRooms({required int page, required int limit}) =>
      "/chat/rooms?page=$page&limit=$limit";

  static String getRoomMessage({
    required String roomId,
    required int page,
    required int limit,
  }) => "/chat/rooms/messages?roomId=$roomId&page=$page&limit=$limit";

  static const String searchUsers = '/users/search';
  static const String updateProfile = '/users/';

  static const String blockList = '/users/block-list';
  static const String unblock = '/users/unblock';
  static const String block = '/users/block';

  ///terms and privacy==========================

  static const String terms =
      "http://10.10.20.16:6010/terms-and-condition-public";
  static const String privacy = "http://10.10.20.16:6010/privacy-policy-public";

  ///forget section==================================

  static const String forget = "/users/forget-password";
  static const String verifyOtp = "/users/verify-otp";
  static const String reset = "/users/reset-password";
  static const String deleteAccount = "/users";
  static const String help = "/users/help-support";

  static const String profile = '/auth/me'; // ✅ same as chatList

}
