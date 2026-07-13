class ApiUrl {

  static const appUrl="https://play.google.com/store/apps/details?id=me.platechat.app&pcampaignid=web_share";

  // Base URL - Replace with your actual API base URL

  // Local url
  // static const String baseUrl = 'http://10.10.28.200:8003';
  // static const baseSocketUrl = 'ws://10.10.28.200:8003';

  // live url
  static const String baseUrl = 'http://13.50.99.165:8003';
   static const baseSocketUrl = 'ws://13.50.99.165:8003';

  //http://13.50.99.165:8003
  //static const baseSocketUrl = 'ws://13.50.99.165:8003';

  //live url
  //static const String baseUrl = 'http://13.50.99.165:8003';

  static const String imageUrl = "$baseUrl/";

  static String socketUrl({required String userId}) =>
      "$baseSocketUrl?userId=$userId";


  // Fixed endpoints to match your backend











  static String getNotifications({required int page, required int limit}) =>
      '/notifications/events?page=$page&limit=$limit';

  static String markNotificationRead({required String id}) =>
      '/notifications/events/$id/read';

  static String get markAllNotificationsRead =>
      '/notifications/read-all';

  static String deleteNotification({required String id}) =>
      '/notifications/events/$id';

  static String get deleteAllNotifications =>
      '/notifications/events';




  static const String register = '/auth/register';
  static const String login = '/auth/signin';
  static const String chatList = '/auth/me';
  // Chat rooms pagination
  static String getChatList({required int page, required int limit}) =>
      "/chat/rooms?page=$page&limit=$limit";
  static const String qrCard = "/users/qr-card";
  static String getInboxMessage({
    required String roomId,
    required int page,
    required int limit,
  }) => "/chat/rooms/messages?roomId=$roomId&page=$page&limit=$limit";

  //static const String searchUsers = '/users/search';
  static  String searchUsers({required String search}) => '/users/search?query=$search';

 // static const String updateProfile = '/users/';
  static const String updateProfile = '/users';

  static const String blockList = '/users/block-list';
  static const String unblock = '/users/unblock';
  static const String block = '/users/block';
  static const String uploadDocument = '/user-documents';
  static const String getDocument = '/user-documents';
  static String updateDocument({required String documentId}) =>
      '/user-documents/$documentId';

  ///terms and privacy==========================

  static const String terms = "http://13.50.99.165/terms-and-condition-public";
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
 // static const String createPin = "/parking-report";
  static const String addParking = '/parking-report/spot';
  static const String verifyLicense= '/users/verify-license';
  static const String vehicle= '/users/vehicle';
 // static const String showDetails = "/parking-report";
  static  String showMapDetails ({required double latitude,required double longitude,required int radius}) => "/parking-report/spot/nearby?latitude=$latitude&longitude=$longitude&radiusInMeters=$radius";
  static  String spotDetails ({required String spotId,}) => "/parking-report/spot/$spotId";

  static  String leaveSpot  = "/parking-report/spot/leave";
  static  String verifyPlate  = "/chat/rooms/by-plate";
  static String deleteMessage({required String messageId}) => "/chat/messages/$messageId";






  static const String profile = '/auth/me'; // ✅ same as chatList

  ///new feature

  static const String sendPreset = '/preset-message';

  /// POST create rating (body: ratee_id + rating).
  static const String sendRate = '/ratings';

  /// GET existing / PATCH update — path param is the other user's id (ratee).
  static String myRatingForRatee({required String rateeId}) =>
      '/ratings/my-rating/$rateeId';


  static String userProfile(String userId) => '/users/$userId/profile';

  static String getRating({required String id}) =>
      myRatingForRatee(rateeId: id);


  static String updatedRating({required String id}) =>
      myRatingForRatee(rateeId: id);
  static const String getQRCode = '/users/generate-code';
  static const String scanQr = '/users/scan-qr-code';

  static String usefulNumber({
    required double latitude,
    required double longitude,
    required int page,
    required int limit,
  }) =>
      '/useful-number/nearby?latitude=$latitude&longitude=$longitude&page=$page&limit=$limit';

  static const String presetMessage = '/preset-message';
  static const String createGroup = '/group/room';
  static String leaveGroup({required String roomId}) =>
      '/group/room/$roomId/leave';

  // ✅ page, limit support সহ
  static String getGroupMessage({

    required String roomId,
    int page = 1,
    int limit = 20,
  }) => '/group/room/$roomId/messages?page=$page&limit=$limit';

  static String addGroupMember({required String roomId}) =>
      '/group/room/$roomId/members';

  static String removeGroupMember({
    required String roomId,
    required String memberId,
  }) => '/group/room/$roomId/member/$memberId';

  static String searchGroupMember({required String roomId}) =>
      '/users/search?query=r&for=group&roomId=$roomId';

  static String updateGroup({required String roomId}) =>
      '/group/room/$roomId';


  static const String sendGroup = '/group/message/file';
  static const String sendUser = '/chat/message/file';

  // ── Postman Messaging - Uploads ───────────────────────────────
  static const String sendVoice = '/chat/message/voice';

  // ── Postman Messaging - Message Requests ──────────────────────
  static const String createMessageRequest = '/chat/message-requests';
  static const String getMessageRequestInbox = '/chat/message-requests/inbox';
  static const String getSentMessageRequests = '/chat/message-requests/sent';
  static String acceptMessageRequest(String requestId) => '/chat/message-requests/$requestId/accept';
  static String declineMessageRequest(String requestId) => '/chat/message-requests/$requestId/decline';

  // ── Postman Messaging - E2EE Device Keys ──────────────────────
  static const String registerE2EEDeviceKey = '/chat/e2ee/keys';
  static const String getE2EEDeviceKeys = '/chat/e2ee/keys';
  static const String deactivateE2EEDeviceKey = '/chat/e2ee/keys';

  // ── Postman Preset Messages CRUD ──────────────────────────────
  static const String createPresetMessage = '/preset-message';
  static const String listPresetMessages = '/preset-message';
  static String getPresetMessageById({required String id}) => '/preset-message/$id';
  static String updatePresetMessage({required String id}) => '/preset-message/$id';
  static String deletePresetMessage({required String id}) => '/preset-message/$id';
}
