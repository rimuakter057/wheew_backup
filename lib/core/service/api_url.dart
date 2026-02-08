class ApiUrl {
  // Base URL - Replace with your actual API base URL
  static const String baseUrl = 'http://10.10.20.44:8003';
  static const String imageUrl = "$baseUrl/";


  static String socketUrl({required String userId}) => "$baseUrl?userId=$userId";

  // Fixed endpoints to match your backend
  static const String register = '/auth/register';
  static const String login = '/auth/signin';
  static const String chatList = '/auth/me';
  // Chat rooms pagination
  static String getChatRooms({required int page, required int limit}) =>
      "/chat/rooms?page=$page&limit=$limit";

  static String getRoomMessage({required String roomId,required int page, required int limit}) =>
      "/chat/rooms/messages?roomId=$roomId&page=$page&limit=$limit";


  static const String searchUsers = '/users/search';
  static const String updateProfile = '/users/';

}