class ApiUrl {
  // Base URL - Replace with your actual API base URL

  // Local url
  static const String baseUrl = 'http://10.10.20.44:8003';
  static const baseSocketUrl = 'ws://10.10.20.44:8003';

  // live url
  // static const String baseUrl = 'http://13.50.99.165:8003';
  // static const baseSocketUrl = 'ws://13.50.99.165:8003';

  //http://13.50.99.165:8003

  static const String imageUrl = "$baseUrl/";

  static String socketUrl({required String userId}) =>
      "$baseSocketUrl?userId=$userId";

  // Fixed endpoints to match your backend
  static const String register = '/auth/register';
  static const String login = '/auth/signin';
  static const String chatList = '/auth/me';
  // Chat rooms pagination
  static String getChatList({required int page, required int limit}) =>
      "/chat/rooms?page=$page&limit=$limit";

  static String getInboxMessage({
    required String roomId,
    required int page,
    required int limit,
  }) => "/chat/rooms/messages?roomId=$roomId&page=$page&limit=$limit";

  static const String searchUsers = '/users/search';
  static const String updateProfile = '/users/';

  static const String blockList = '/users/block-list';
  static const String unblock = '/users/unblock';
  static const String block = '/users/block';
  static const String uploadDocument = '/user-documents';
  static const String getDocument = '/user-documents';
  static  String updateDocument({required String documentId}) => '/user-documents/$documentId';

  ///terms and privacy==========================

  static const String terms =
      "http://13.50.99.165/terms-and-condition-public";
  static const String privacy = "http://13.50.99.165/privacy-policy-public";

  // http://13.50.99.165/privacy-policy-public
  // http://13.50.99.165/terms-and-condition-public



  ///forget section==================================

  static const String forget = "/users/forget-password";
  static const String verifyOtp = "/users/verify-otp";
  static const String reset = "/users/reset-password";
  static const String deleteAccount = "/users";
  static const String help = "/users/help-support";
  static const String createPin = "/parking-report";
  static const String parkingReport = '/parking-report';

  static const String profile = '/auth/me'; // ✅ same as chatList


///new feature


  static const String sendPreset = '/preset-message';
  /// POST create rating (body: ratee_id + rating).
  static const String sendRate = '/ratings';
  /// GET existing / PATCH update — path param is the other user's id (ratee).
  static String myRatingForRatee({required String rateeId}) =>
      '/ratings/my-rating/$rateeId';

  @Deprecated('Use myRatingForRatee')
  static String getRating({required String id}) => myRatingForRatee(rateeId: id);

  @Deprecated('Use myRatingForRatee')
  static String updatedRating({required String id}) =>
      myRatingForRatee(rateeId: id);
  static const String getQRCode = '/users/generate-code';
  static const String scanQr = '/users/scan-qr-code';
  static const String showDetails = "/parking-report";
  static  String usefulNumber({required double latitude,required double longitude,required int page,required int limit}) => '/useful-number/nearby?latitude=$latitude&longitude=$longitude&page=$page&limit=$limit';

  static const String presetMessage = '/preset-message';
  static const String createGroup = '/group/room';

  // ✅ page, limit support সহ
  static String getGroupMessage({
    required String roomId,
    int page = 1,
    int limit = 20,
  }) => '/group/room/$roomId/messages?page=$page&limit=$limit';

}
