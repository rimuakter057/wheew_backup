// ignore_for_file: unnecessary_null_comparison, invalid_use_of_protected_member

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/feature/chat/model/message_response_model.dart'
    hide Sender;
import 'package:get/get.dart' hide Response;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/model/block_model.dart';
import 'package:platchatapp/feature/chat/model/chat_model.dart';
import 'package:platchatapp/feature/chat/model/group_message_response_model.dart';
import 'package:platchatapp/feature/chat/model/rating_response_model.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import '../../../core/service/socket_service.dart';
import '../../../utils/app_const/app_const.dart';
import '../../profile/repository/user_model.dart';
import '../model/preset_message.dart';
import 'chat_repository.dart';
import 'package:http/http.dart' as http;


class ChatController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playMessageSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/message_chime.wav'));
    } catch (e) {
      debugPrint('Error playing message sound: $e');
    }
  }

  var isAddingMember = false.obs;

  Future<bool> addGroupMember({
    required String groupRoomId,
    required List<String> memberIds,
    required BuildContext context,
  }) async
  {
    if (memberIds.isEmpty) return false;
    isAddingMember.value = true;

    try {
      // ✅ একটাই call, সব memberIds array হিসেবে পাঠাও
      final response = await ApiClient.postData(
        uri: ApiUrl.addGroupMember(roomId: groupRoomId),
        body: {'memberIds': memberIds},
      );

      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        CustomSnackbar.success(
          context: context,
          message: 'Member added successfully',
        );
        fetchChatList(refresh: true);
        return true;
      } else {
        String errorMessage = 'Member could not be added';
        try {
          final decoded = jsonDecode(response.body);
          errorMessage = decoded['message'] ?? decoded['error'] ?? errorMessage;
        } catch (_) {}

        CustomSnackbar.error(context: context, message: errorMessage);
        return false;
      }
    } catch (e) {
      debugPrint('addGroupMember error: $e');
      CustomSnackbar.error(
        context: context,
        message: 'Failed to add member. Try again.',
      );
      return false;
    } finally {
      isAddingMember.value = false;
    }
  }

  /// User rating (GET /ratings/my-rating/:rateeId, POST /ratings, PATCH same path)

  RxBool isSubmittingRating = false.obs;
  RxBool isLoadingMyRating = false.obs;
  final Rxn<ChatRatingResponse> myRatingForRatee = Rxn<ChatRatingResponse>();
  String? _lastRatingFetchRateeId;

  /// Load my rating for this chat partner (if any).
  Future<void> fetchMyRating(String rateeId) async {
    if (rateeId.isEmpty) return;
    _lastRatingFetchRateeId = rateeId;
    isLoadingMyRating.value = true;
    myRatingForRatee.value = null;
    try {
      final uri = ApiUrl.myRatingForRatee(rateeId: rateeId);
      final response = await ApiClient.getData(uri: uri);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final map = _unwrapRatingMap(decoded);
        if (map != null) {
          myRatingForRatee.value = ChatRatingResponse.fromJson(map);
        }
      }
    } catch (e) {
      debugPrint('⭐ [RATING] fetchMyRating error: $e');
    } finally {
      isLoadingMyRating.value = false;
    }
  }

  Map<String, dynamic>? _unwrapRatingMap(dynamic decoded) {
    if (decoded is Map) {
      final m = Map<String, dynamic>.from(decoded);
      if (m['rating'] != null || m['ratee_id'] != null || m['id'] != null) {
        return m;
      }
      final data = m['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
    }
    return null;
  }

  bool _hasExistingRatingFor(String rateeId) {
    final r = myRatingForRatee.value;
    if (r == null || r.id.isEmpty) return false;
    return r.rateeId == rateeId;
  }

  /// Create (POST) or update (PATCH) rating. PATCH body is only `{ "rating": n }`.
  Future<void> submitRating({
    required String rateeId,
    required double rating,
    required BuildContext context,
  }) async
  {
    final stars = rating.round().clamp(1, 5);
    try {
      isSubmittingRating.value = true;

      final bool update =
          _lastRatingFetchRateeId == rateeId && _hasExistingRatingFor(rateeId);

      late final Response response;
      if (update) {
        response = await ApiClient.patchData(
          uri: ApiUrl.myRatingForRatee(rateeId: rateeId),
          body: {'rating': stars},
        );
      } else {
        response = await ApiClient.postData(
          uri: ApiUrl.sendRate,
          body: {'ratee_id': rateeId, 'rating': stars},
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          try {
            final map = _unwrapRatingMap(jsonDecode(response.body));
            if (map != null) {
              myRatingForRatee.value = ChatRatingResponse.fromJson(map);
            }
          } catch (_) {}
        }
        if (context.mounted) Navigator.pop(context);

        CustomSnackbar.success(
          context: context,
          message: update ? 'rating_updated'.tr : 'rating_submitted'.tr,
        );
      } else {
        String msg = 'rating_failed'.tr;
        try {
          final m = jsonDecode(response.body);
          if (m is Map && m['message'] != null) msg = '${m['message']}';
        } catch (_) {}

        CustomSnackbar.error(context: context, message: msg);
      }
    } catch (e) {
      debugPrint('💥 [RATING] Error: $e');

      CustomSnackbar.error(context: context, message: e.toString());
    } finally {
      isSubmittingRating.value = false;
    }
  }

  ///preset message=========================================

  // RxList<String> presetMessages = <String>[].obs;
  // RxBool isPresetLoading = false.obs;
  //
  // Future<void> fetchPresetMessages() async {
  //   try {
  //     isPresetLoading.value = true;
  //
  //     print('🔄 [PRESET] Fetching preset messages...');
  //
  //     final response = await ApiClient.getData(uri: ApiUrl.presetMessage);
  //
  //     print('📡 [PRESET] Status Code: ${response.statusCode}');
  //     print('📡 [PRESET] Raw Body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //
  //       print('📦 [PRESET] Decoded data type: ${data.runtimeType}');
  //       print('📦 [PRESET] Decoded data: $data');
  //
  //       // ── এখানে তোমার JSON structure অনুযায়ী parse করো ──
  //       // Case 1: { "messages": [ { "message": "..." } ] }
  //       if (data is Map && data['messages'] != null) {
  //         final list = List<Map<String, dynamic>>.from(data['messages']);
  //         presetMessages.value = list
  //             .map((e) => e['message'].toString())
  //             .toList();
  //         print(
  //           '✅ [PRESET] Parsed from data["messages"]: ${presetMessages.value}',
  //         );
  //       }
  //       // Case 2: [ { "message": "..." } ]  (direct array)
  //       else if (data is List) {
  //         presetMessages.value = data
  //             .map((e) => e['message'].toString())
  //             .toList();
  //         print('✅ [PRESET] Parsed from direct List: ${presetMessages.value}');
  //       }
  //       // Case 3: { "data": [ { "message": "..." } ] }
  //       else if (data is Map && data['data'] != null) {
  //         final list = List<Map<String, dynamic>>.from(data['data']);
  //         presetMessages.value = list
  //             .map((e) => e['message'].toString())
  //             .toList();
  //         print('✅ [PRESET] Parsed from data["data"]: ${presetMessages.value}');
  //       } else {
  //         print('❌ [PRESET] Unknown structure! Cannot parse.');
  //       }
  //
  //       print('📊 [PRESET] Total preset count: ${presetMessages.length}');
  //     } else {
  //       print('❌ [PRESET] Failed! Status: ${response.statusCode}');
  //     }
  //   } catch (e, stack) {
  //     print('💥 [PRESET] Exception: $e');
  //     print('💥 [PRESET] StackTrace: $stack');
  //   } finally {
  //     isPresetLoading.value = false;
  //     print(
  //       '🏁 [PRESET] Loading done. isPresetLoading = ${isPresetLoading.value}',
  //     );
  //     if (kDebugMode) {
  //       print('🏁 [PRESET] presetMessages = ${presetMessages.value}');
  //     }
  //   }
  // }

  ///preset message=========================================

  RxList<PresetMessage> presetMessages = <PresetMessage>[].obs;
  RxBool isPresetLoading = false.obs;

  Future<void> fetchPresetMessages() async
  {
    try {
      isPresetLoading.value = true;

      print('🔄 [PRESET] Fetching preset messages...');

      final response = await ApiClient.getData(uri: ApiUrl.presetMessage);

      print('📡 [PRESET] Status Code: ${response.statusCode}');
      print('📡 [PRESET] Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('📦 [PRESET] Decoded data type: ${data.runtimeType}');
        print('📦 [PRESET] Decoded data: $data');

        // Case 1: { "messages": [ { "message": "..." } ] }
        if (data is Map && data['messages'] != null) {
          final list = List<Map<String, dynamic>>.from(data['messages']);
          presetMessages.value = list
              .map((e) => PresetMessage(
            message: e['message'].toString(),
            messageIt: e['message_it']?.toString() ?? '',
          ))
              .toList();
          print(
            '✅ [PRESET] Parsed from data["messages"]: ${presetMessages.value}',
          );
        }
        // Case 2: [ { "message": "..." } ]  (direct array)
        else if (data is List) {
          presetMessages.value = data
              .map((e) => PresetMessage(
            message: e['message'].toString(),
            messageIt: e['message_it']?.toString() ?? '',
          ))
              .toList();
          print('✅ [PRESET] Parsed from direct List: ${presetMessages.value}');
        }
        // Case 3: { "data": [ { "message": "..." } ] }
        else if (data is Map && data['data'] != null) {
          final list = List<Map<String, dynamic>>.from(data['data']);
          presetMessages.value = list
              .map((e) => PresetMessage(
            message: e['message'].toString(),
            messageIt: e['message_it']?.toString() ?? '',
          ))
              .toList();
          print('✅ [PRESET] Parsed from data["data"]: ${presetMessages.value}');
        } else {
          print('❌ [PRESET] Unknown structure! Cannot parse.');
        }

        print('📊 [PRESET] Total preset count: ${presetMessages.length}');
      } else {
        print('❌ [PRESET] Failed! Status: ${response.statusCode}');
      }
    } catch (e, stack) {
      print('💥 [PRESET] Exception: $e');
      print('💥 [PRESET] StackTrace: $stack');
    } finally {
      isPresetLoading.value = false;
      print(
        '🏁 [PRESET] Loading done. isPresetLoading = ${isPresetLoading.value}',
      );
      if (kDebugMode) {
        print('🏁 [PRESET] presetMessages = ${presetMessages.value}');
      }
    }
  }


  ///==============================================================
  bool _listenersInitialized = false; // ⭐ Add this



  void initSocketListeners() {
    if (_listenersInitialized) return;
    _listenersInitialized = true;

    sendNewListenMessage();
    errorListenMessage();
    newMessage(); // ✅ এখানে একবার call করো

    debugPrint('✅ Socket listeners initialized');
  }

  /// get all message list ================================================
  RxList<Messages> userMessageList = <Messages>[].obs;

  var isLoadingMessage = false.obs; // first page
  var isLoadingMoreMessage = false.obs; // pagination

  int pageCount = 1;
  final int limitCount = 20;
  int totalCount = 0;

  bool get hasMoreMessage => userMessageList.length < totalCount;

  //RxString? roomID;
  /// Room ID
  RxString roomID = "".obs;

  Future<void> fetchInboxMessage({String? roomId, bool refresh = false}) async {
    // ✅ roomId update
    if (roomId != null && roomId.isNotEmpty) {
      roomID.value = roomId;
    }

    if (roomID.value.isEmpty) {
      debugPrint("❌ Room ID is empty, skipping fetch");
      return;
    }

    // ✅ Refresh হলে ONLY তখন clear করো
    if (refresh) {
      pageCount = 1;
      totalCount = 0;
      userMessageList.clear(); // ✅ শুধু refresh এ clear
    }

    // ✅ Already loading থাকলে skip
    if (pageCount == 1 && isLoadingMessage.value) return;
    if (pageCount > 1 && isLoadingMoreMessage.value) return;

    // ✅ আর data নেই তাহলে skip
    if (pageCount > 1 && !hasMoreMessage) return;

    // Loading state set
    if (pageCount == 1) {
      isLoadingMessage.value = true;
    } else {
      isLoadingMoreMessage.value = true;
    }

    try {
      final uri = ApiUrl.getInboxMessage(
        roomId: roomID.value, // ✅ roomID.value ব্যবহার করো, parameter নয়
        page: pageCount,
        limit: limitCount,
      );

      Response response = await ApiClient.getData(uri: uri);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['messages'] != null) {
        final data = MessageResponseModel.fromJson(body);
        totalCount = data.total ?? 0;

        if (data.messages != null && data.messages!.isNotEmpty) {
          // ✅ addAll করো, clear করো না!
          for (final msg in data.messages!) {
            msg.isMine = msg.isMine == true;
            userMessageList.add(msg); // ✅ শুধু add, clear নয়
          }
          pageCount++;
        }

        // ✅ Backend fetch হলে server automatically is_read = true করে দেয়
        // তাই local UI-তেও সাথে সাথে unread badge সরিয়ে দিচ্ছি
        _resetUnreadLocally(roomID.value);
      }
    } catch (e) {
      debugPrint("❌ Fetch error: $e");
    } finally {
      isLoadingMessage.value = false;
      isLoadingMoreMessage.value = false;
    }
  }

  ///socket========================

  final TextEditingController messageController = TextEditingController();

  // void sendNewEmitMessage({
  //   required String receiverId,
  //   required String message,
  //   String? roomId, // ✅ নতুন parameter
  // })
  // {
  //   final payload = {
  //     'receiver_id': receiverId,
  //     'message': message,
  //     if (roomId != null && roomId.isNotEmpty) 'room_id': roomId,
  //   };
  //
  //   final localTempMessage = Messages(
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     receiverId: receiverId,
  //     senderId: '',
  //     message: message,
  //     createdAt: DateTime.now().toIso8601String(),
  //     isMine: true,
  //     isDelivered: false,
  //     type: 'TEXT',
  //     chatRoomId: roomID.value,
  //   );
  //
  //   userMessageList.insert(0, localTempMessage);
  //   updateChatRoomInListOptimistic(localTempMessage);
  //   messageController.clear();
  //
  //   AppSocket.emitWithAck(
  //     "message",
  //     payload,
  //     ack: (value) {
  //       debugPrint("✅ Message sent successfully: $value");
  //
  //       if (value != null && value['chatRoom_id'] != null) {
  //         final newRoomId = value['chatRoom_id'].toString();
  //
  //         roomID.value = newRoomId;
  //
  //         fetchChatList(refresh: true);
  //       }
  //     },
  //   );
  // }


  void sendNewEmitMessage({
    required String receiverId,
    required String message,
    String? roomId,
  }) {
    final payload = {
      'receiver_id': receiverId,
      'message': message,
      if (roomId != null && roomId.isNotEmpty) 'room_id': roomId,
    };

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}'; // ✅ temp_ prefix যেন আলাদা করে চেনা যায়

    final localTempMessage = Messages(
      id: tempId,
      receiverId: receiverId,
      senderId: '',
      message: message,
      createdAt: DateTime.now().toIso8601String(),
      isMine: true,
      isDelivered: false,
      type: 'TEXT',
      chatRoomId: roomID.value,
    );

    userMessageList.insert(0, localTempMessage);
    updateChatRoomInListOptimistic(localTempMessage);
    messageController.clear();

    AppSocket.emitWithAck(
      "message",
      payload,
      ack: (value) {
        debugPrint("✅ Message sent successfully: $value");

        if (value != null) {
          // ✅ temp message কে real server message দিয়ে replace করো
          final tempIndex = userMessageList.indexWhere((m) => m.id == tempId);
          if (tempIndex != -1) {
            try {
              final confirmed = Messages.fromJson(value);
              confirmed.isMine = true;
              userMessageList[tempIndex] = confirmed;
            } catch (e) {
              debugPrint("⚠️ ack parse failed: $e");
            }
          }

          if (value['chatRoom_id'] != null) {
            roomID.value = value['chatRoom_id'].toString();
            fetchChatList(refresh: true);
          }
        }
      },
    );
  }


  void updateChatRoomInListOptimistic(Messages newMessage) {
    final roomIndex = userChatList.indexWhere(
      (room) => room.id == newMessage.chatRoomId,
    );

    if (roomIndex != -1) {
      List<Rooms> tempList = List.from(userChatList);
      final room = tempList[roomIndex];

      room.latestMessage = LatestMessage(
        id: newMessage.id,
        chatRoomId: newMessage.chatRoomId,
        senderId: newMessage.senderId,
        receiverId: newMessage.receiverId,
        message: newMessage.message,
        type: newMessage.type,
        isRead: false,     // receiver-এর কাছে এখনো unread
        isDelivered: false,
        createdAt: newMessage.createdAt,
        updatedAt: newMessage.updatedAt,
        isMine: true,      // ✅ নিজের message হিসেবে mark — badge দেখাবে না
      );

      tempList.removeAt(roomIndex);
      tempList.insert(0, room);
      userChatList.value = tempList;

      debugPrint('✅ Chat list updated after sending message');
    }
  }

  Future<void> sendNewListenMessage() async {
    AppSocket.onEvent('message-sent', (value) {
      debugPrint('📤 Message sent confirmation: $value');
      // Optional: Server confirmation পেলে কিছু করতে চাইলে
    });
  }

  // ✅ Chat screen খুললে locally unread badge reset করো
  // (backend fetch-এই automatically is_read = true হয় — কোনো socket event দরকার নেই)
  void markMessagesAsRead({required String roomId}) {
    if (roomId.isEmpty) return;
    _resetUnreadLocally(roomId);
  }

  // ┉┉ Internal helper ┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉
  void _resetUnreadLocally(String roomId) {
    if (roomId.isEmpty) return;
    final idx = userChatList.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      userChatList[idx].unreadCount = 0;
      userChatList[idx].latestMessage?.isRead = true;
      userChatList.refresh(); // GetX UI trigger
      debugPrint('✅ Local unread reset for room: $roomId');
    }
  }

  ///new message==========================



  // Future<void> newMessage() async {
  //   // ✅ আগের listener সরাও, তারপর নতুন লাগাও
  //   AppSocket.socket?.off('new-message');
  //
  //   AppSocket.socket?.on('new-message', (value) {
  //     debugPrint('🔔 NEW MESSAGE RECEIVED: $value');
  //
  //     Messages model = Messages.fromJson(value);
  //
  //     // ✅ ID দিয়ে duplicate চেক
  //     final alreadyExists = userMessageList.any((m) => m.id == model.id);
  //     if (alreadyExists) {
  //       debugPrint('⚠️ Duplicate message ignored: ${model.id}');
  //       return;
  //     }
  //
  //     if (model.chatRoomId == roomID.value) {
  //       userMessageList.insert(0, model);
  //       debugPrint('✅ Added to message list');
  //     }
  //
  //     updateChatRoomInList(model);
  //   });
  // }


  Future<void> newMessage() async {
    AppSocket.socket?.off('new-message');

    AppSocket.socket?.on('new-message', (value) {
      debugPrint('🔔 NEW MESSAGE RECEIVED: $value');
      Messages model = Messages.fromJson(value);

      // ✅ আগে temp message থাকলে কিনা চেক করো (sender নিজে পেলে)
      final tempIndex = userMessageList.indexWhere(
            (m) => (m.id?.startsWith('temp_') ?? false) && m.message == model.message,
      );
      if (tempIndex != -1) {
        userMessageList[tempIndex] = model;
        debugPrint('✅ Temp message replaced by broadcast');
        updateChatRoomInList(model);
        return;
      }

      // ✅ real ID দিয়ে duplicate চেক
      final alreadyExists = userMessageList.any((m) => m.id == model.id);
      if (alreadyExists) {
        debugPrint('⚠️ Duplicate message ignored: ${model.id}');
        return;
      }

      if (model.chatRoomId == roomID.value) {
        userMessageList.insert(0, model);
        debugPrint('✅ Added to message list');
      }

      // ✅ Other user reply করলে = সে আমার message পড়েছে
      // তাই আমার সব sent message isRead = true করে দাও (নীল ✓✓)
      if (model.isMine == false && model.chatRoomId == roomID.value) {
        _markMySentMessagesAsRead();
        _playMessageSound();
      } else if (model.isMine == false) {
        _playMessageSound();
      }

      updateChatRoomInList(model);
    });
  }

  // ✅ আমি যে room-এ আছি সেখানে other user reply করলে
  // আমার সব sent message-এর isRead = true করো → নীল ✓✓
  void _markMySentMessagesAsRead() {
    bool changed = false;
    for (int i = 0; i < userMessageList.length; i++) {
      if (userMessageList[i].isMine == true &&
          userMessageList[i].isRead != true) {
        userMessageList[i].isRead = true;
        changed = true;
      }
    }
    if (changed) {
      userMessageList.refresh(); // GetX UI trigger → bubble তে নীল tick
      debugPrint('✅ My sent messages marked as read (they replied)');
    }
  }


  void updateChatRoomInList(Messages newMessage) {
    final roomIndex = userChatList.indexWhere(
      (room) => room.id == newMessage.chatRoomId,
    );

    if (roomIndex != -1) {
      userChatList[roomIndex].latestMessage = LatestMessage(
        id: newMessage.id,
        chatRoomId: newMessage.chatRoomId,
        senderId: newMessage.senderId,
        receiverId: newMessage.receiverId,
        message: newMessage.message,
        type: newMessage.type,
        isRead: newMessage.isRead,
        isDelivered: newMessage.isDelivered,
        createdAt: newMessage.createdAt,
        updatedAt: newMessage.updatedAt,
        isMine: newMessage.isMine,
      );

      if (newMessage.isMine == false && newMessage.chatRoomId != roomID.value) {
        userChatList[roomIndex].unreadCount =
            (userChatList[roomIndex].unreadCount ?? 0) + 1;
      }

      final updatedRoom = userChatList[roomIndex];
      final newList = [updatedRoom];

      for (int i = 0; i < userChatList.length; i++) {
        if (i != roomIndex) {
          newList.add(userChatList[i]);
        }
      }

      userChatList.value = newList;

      debugPrint('✅ UI should update now');
    } else {
      fetchChatList(refresh: true);
    }
  }

  Future<void> errorListenMessage() async {
    AppSocket.onEvent('exception', (value) {
      debugPrint(
        '====================== error message   $value============================ ',
      );
    });
  }

  ///=======================================================================

  ///get all user chat list========================================================

  RxList<Rooms> userChatList = <Rooms>[].obs;
  var isLoadingChat = false.obs;
  var isLoadingMore = false.obs;
  RxInt page = 1.obs;
  final int limit = 25;
  int total = 0;

  bool _isFetching = false; // ✅ simple bool, reactive না

  Future<void> fetchChatList({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (refresh) {
      page.value = 1;
      total = 0;
      userChatList.clear();
      _isFetching = false;
    }

    // ✅ আর data নেই তাহলে skip
    if (loadMore && !hasMore) return;

    // ✅ Already fetching হলে skip
    if (_isFetching) return;
    _isFetching = true;

    if (page.value == 1) {
      isLoadingChat.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final uri = ApiUrl.getChatList(page: page.value, limit: limit);
      Response response = await ApiClient.getData(uri: uri);
      final body = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200 && body['rooms'] != null) {
        final data = UserChatModel.fromJson(body);
        total = data.total ?? 0;

        if (data.rooms != null && data.rooms!.isNotEmpty) {
          if (page.value == 1) {
            // ✅ প্রথম page এ replace করো (refresh এর জন্য)
            userChatList.value = List<Rooms>.from(data.rooms!);
          } else {
            // ✅ পরের page এ শুধু add করো — replace করো না!
            userChatList.addAll(data.rooms!);
          }
          page.value++; // ✅ page.value++ করো, page++ নয়
        }
      } else {
        if (refresh) userChatList.clear();
      }
    } catch (e) {
      debugPrint('fetchChatList error: $e');
    } finally {
      isLoadingChat.value = false;
      isLoadingMore.value = false;
      _isFetching = false;
    }
  }

  bool get hasMore => userChatList.length < total;

  ///create group==========================================================
  var isCreatingGroup = false.obs;

  Future<bool> createGroup({
    required String groupName,
    List<String> memberIds = const [],
  }) async {

    isCreatingGroup.value = true;
    try {
      final uri = ApiUrl.createGroup;
      Response response = await ApiClient.postData(
        uri: uri,
        body: {"name": groupName, "memberIds": memberIds},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Group created: $groupName');
        await fetchChatList(refresh: true);
        return true;          // ← success
      } else {
        debugPrint('❌ Group create failed: ${response.body}');
        return false;         // ← failed
      }
    } catch (e) {
      debugPrint('createGroup error: $e');
      return false;           // ← error
    } finally {
      isCreatingGroup.value = false;
    }
  }

  ///get block list==============================================================

  RxList<BlockModel> userBlockList = <BlockModel>[].obs;
  var isLoadingBlockList = false.obs;

  Future<void> fetchBlockList({bool refresh = false}) async {
    debugPrint("fetchBlockList called");

    if (refresh) {
      userBlockList.clear();
    }

    isLoadingBlockList.value = true;

    final uri = ApiUrl.blockList;

    Response response = await ApiClient.getData(uri: uri);

    debugPrint("status code: ${response.statusCode}");
    debugPrint("body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      userBlockList.value = (body['blockList'] as List)
          .map((e) => BlockModel.fromJson(e))
          .toList();

      debugPrint("list length: ${userBlockList.length}");
    }

    isLoadingBlockList.value = false;
  }

  ///==============search api section=========================================================

  // Variables add karein controller mein
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  final RxList searchResults = [].obs;
  Timer? _debounce;

  // Search method
  void searchUsers(String query) {
    // Debounce - 500ms wait karo type karne ke baad
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      hasSearched.value = false;
      searchResults.clear();
      isSearching.value = false;
      update();
      return;
    }

    isSearching.value = true;
    hasSearched.value = true;
    update();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _fetchSearchResults(query.trim());
    });
  }

  Future<void> _fetchSearchResults(String query) async {
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.searchUsers(search: query),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List users = data['users'] ?? []; // ✅ 'users' key
        searchResults.value = users.map((e) => UserModel.fromJson(e)).toList();
      } else {
        searchResults.clear();
      }
    } catch (e) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
      update();
    }
  }

  // Dispose mein cancel karein
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  ///=======================user chat list===================================================================

  ///block block=====================================================
  RxBool isBlockedByMe = false.obs;
  RxBool isBlockedMe = false.obs;
  var isLoadingBlock = false.obs;

  Future<void> block(String id, BuildContext context) async {
    isLoadingBlock.value = true;

    final body = {"userId": id};

    final response = await ApiClient.patchData(uri: ApiUrl.block, body: body);

    isLoadingBlock.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User blocked successfully");
      showSnackBar(
        context,
        "user_blocked_successfully".tr,
        bgColor: Colors.green,
      );
    } else {
      print("Block failed: ${response.statusCode}");
      showSnackBar(context, "failed_to_block_user".tr, bgColor: Colors.red);
    }
  }

  ///unblock user================

  Future<void> unBlock(String id, BuildContext context) async {
    final body = {"userId": id};

    final response = await ApiClient.patchData(uri: ApiUrl.unblock, body: body);

    isLoadingBlockList.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("User unblocked successfully");

      // ✅ block list থেকে remove
      userBlockList.removeWhere((block) => block.blockedUserId == id);

      // ✅ chat list এর isBlockedByMe status update
      final roomIndex = userChatList.indexWhere(
        (room) => room.otherUser?.id == id,
      );

      if (roomIndex != -1) {
        final updatedRoom = userChatList[roomIndex];
        updatedRoom.isBlockedByMe = false; // ✅ status false

        userChatList[roomIndex] = updatedRoom; // ✅ GetX detect করবে
        userChatList.refresh(); // ✅ force UI update
      }

      // ✅ isBlockedByMe global state ও update
      isBlockedByMe.value = false;

      showSnackBar(
        context,
        "user_unblocked_successfully".tr,
        bgColor: Colors.green,
      );
    } else {
      debugPrint("Unblock failed: ${response.statusCode}");
      showSnackBar(context, "failed_to_unblock_user".tr, bgColor: Colors.red);
    }
  }

  void showSnackBar(BuildContext context, String message, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor ?? Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  ///group========================================================================group

  // ── Group Message State ─────────────────────────────────────────
  RxList<GroupMessageResponseModel> groupMessageList =
      <GroupMessageResponseModel>[].obs;

  var isLoadingGroupMessage = false.obs;
  var isLoadingMoreGroupMessage = false.obs;

  int groupPageCount = 1;
  final int groupLimitCount = 20;
  int groupTotalCount = 0;

  RxString groupRoomID = "".obs;

  bool get hasMoreGroupMessage => groupMessageList.length < groupTotalCount;

  /// ── Fetch Group Messages ────────────────────────────────────────
  Future<void> fetchGroupMessages({
    required String roomId,
    bool refresh = false,
  }) async {
    // ✅ roomId update
    if (roomId != null && roomId.isNotEmpty) {
      groupRoomID.value = roomId;
    }

    if (groupRoomID.value.isEmpty) {
      debugPrint("❌ Group Room ID is empty, skipping fetch");
      return;
    }

    // ✅ Refresh হলে reset করো
    if (refresh) {
      groupPageCount = 1;
      groupTotalCount = 0;
      groupMessageList.clear();
    }

    // ✅ Already loading থাকলে skip
    if (groupPageCount == 1 && isLoadingGroupMessage.value) return;
    if (groupPageCount > 1 && isLoadingMoreGroupMessage.value) return;

    // ✅ আর data নেই তাহলে skip
    if (groupPageCount > 1 && !hasMoreGroupMessage) return;

    // Loading state set
    if (groupPageCount == 1) {
      isLoadingGroupMessage.value = true;
    } else {
      isLoadingMoreGroupMessage.value = true;
    }

    try {
      // ✅ roomId int হিসেবে পাঠাও — API url অনুযায়ী
      final uri = ApiUrl.getGroupMessage(
        roomId: groupRoomID.value, // ← সরাসরি String
        page: groupPageCount,
        limit: groupLimitCount,
      );
      Response response = await ApiClient.getData(uri: uri);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['messages'] != null) {
        final data = GroupMessageListResponse.fromJson(body);
        groupTotalCount = data.total ?? 0;

        if (data.messages != null && data.messages!.isNotEmpty) {
          for (final msg in data.messages!) {
            groupMessageList.add(msg);
          }
          groupPageCount++;
        }
      }
    } catch (e) {
      debugPrint("❌ fetchGroupMessages error: $e");
    } finally {
      isLoadingGroupMessage.value = false;
      isLoadingMoreGroupMessage.value = false;
    }
  }



  void sendGroupMessage({required String roomId, required String message}) {
    if (message.trim().isEmpty) return;

    // ✅ temp_ prefix দিয়ে রাখুন — server confirmed হলে replace হবে
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final localMsg = GroupMessageResponseModel(
      id: tempId, // ← temp ID
      groupChatRoomId: roomId,
      senderId: '',
      message: message,
      type: 'TEXT',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      isMine: true,
      sender: null,
    );

    groupMessageList.insert(0, localMsg);
    messageController.clear();

    AppSocket.socket?.emit('send-group-message', {
      'groupChatRoomId': roomId,
      'message': message,
    });
  }

  ///listen group message listen=================
  void listenGroupMessages() {
    AppSocket.socket?.off('send-group-message');
    AppSocket.socket?.off('group-new-message');

    debugPrint('🔌 Socket connected: ${AppSocket.socket?.connected}');
    debugPrint('🔌 Socket id: ${AppSocket.socket?.id}');
    debugPrint('🏠 Current groupRoomID: ${groupRoomID.value}');

    // ✅ sender confirmation
    AppSocket.socket?.on('send-group-message', (value) {
      debugPrint('✅ My group message confirmed: $value');
      try {
        final confirmed = GroupMessageResponseModel(
          id: value['id'],
          groupChatRoomId: value['groupChatRoom_id'],
          senderId: value['sender_id'],
          message: value['message'],
          type: value['type'],
          createdAt: value['createdAt'],
          updatedAt: value['updatedAt'],
          isMine: value['is_mine'],
          sender: value['sender'] != null
              ? GroupSender(
                  id: value['sender']['id'],
                  nickName: value['sender']['nick_name'],
                  avatar: value['sender']['avatar'],
                )
              : null,
        );

        final tempIndex = groupMessageList.indexWhere(
          (m) =>
              (m.id?.startsWith('temp_') ?? false) &&
              m.message == confirmed.message,
        );
        debugPrint('🔍 Temp index found: $tempIndex');
        if (tempIndex != -1) {
          groupMessageList[tempIndex] = confirmed;
          debugPrint('✅ Temp message replaced with confirmed');
        }
      } catch (e) {
        debugPrint('❌ send-group-message parse error: $e');
      }
    });


    AppSocket.socket?.on('group-new-message', (value) async {
      try {
        final GroupMessageResponseModel model =
            GroupMessageResponseModel.fromJson(value);

        final String myId = await SharePrefsHelper.getString(AppConst.userID);
        final bool isMyMessage = model.senderId == myId;

        if (model.groupChatRoomId == groupRoomID.value) {
          debugPrint('👤 myId: $myId');
          debugPrint('📨 senderId: ${model.senderId}');
          debugPrint('🔍 isMyMessage: $isMyMessage');

          if (isMyMessage) {
            final tempIndex = groupMessageList.indexWhere(
              (m) =>
                  (m.id?.startsWith('temp_') ?? false) &&
                  m.message == model.message,
            );
            if (tempIndex != -1) {
              groupMessageList[tempIndex] = model;
              debugPrint('✅ Temp replaced');
            }
            return;
          }

          // ✅ অন্যের message
          final alreadyExists = groupMessageList.any((m) => m.id == model.id);
          if (!alreadyExists) {
            groupMessageList.insert(0, model);
            debugPrint('✅ Others message added');
          }
        }

        if (!isMyMessage) {
          _playMessageSound();
        }

        updateGroupChatRoomInList(model);
      } catch (e) {
        debugPrint('❌ listenGroupMessages error: $e');
      }
    });
  }

  /// ── Update Chat List after Group Message ───────────────────────
  void updateGroupChatRoomInList(GroupMessageResponseModel newMessage) {
    final int roomIndex = userChatList.indexWhere(
      (room) => room.id == newMessage.groupChatRoomId,
    );

    if (roomIndex != -1) {
      final Rooms room = userChatList[roomIndex];

      // ✅ latest message update
      room.latestMessage = LatestMessage(
        id: newMessage.id,
        groupChatRoomId: newMessage.groupChatRoomId,
        senderId: newMessage.senderId,
        message: newMessage.message,
        type: newMessage.type,
        createdAt: newMessage.createdAt,
        updatedAt: newMessage.updatedAt,
        isMine: newMessage.isMine,
        sender: newMessage.sender != null
            ? Sender(
                id: newMessage.sender!.id,
                nickName: newMessage.sender!.nickName,
                avatar: newMessage.sender!.avatar,
              )
            : null,
      );

      // ✅ নিজের message না হলে unread বাড়াও
      if (newMessage.isMine == false &&
          newMessage.groupChatRoomId != groupRoomID.value) {
        room.unreadCount = (room.unreadCount ?? 0) + 1;
      }

      // ✅ room কে list এর উপরে নিয়ে আসো
      final List<Rooms> newList = [room];
      for (int i = 0; i < userChatList.length; i++) {
        if (i != roomIndex) newList.add(userChatList[i]);
      }
      userChatList.value = newList;

      debugPrint('✅ Group chat list updated');
    } else {
      // ✅ room list এ নেই — refresh করো
      fetchChatList(refresh: true);
    }
  }

  /// Screen open হলে call হয় — socket emit করে
  void joinGroup({required String roomId}) {
    final payload = {'groupChatRoomId': roomId};
    AppSocket.socket?.emit('join-group-chat', payload);
    debugPrint('✅ Joined group room: $roomId');
  }

  /// ── Leave Group ─────────────────────────────────────────────
  // Leave button press করলে call হয়
  var isLeavingGroup = false.obs;

  void leaveGroup({
    required String roomId,
    required BuildContext context,
    bool navigateBack = true,
  }) async {
    isLeavingGroup.value = true;

    final response = await ApiClient.deleteData(
      uri: ApiUrl.leaveGroup(roomId: roomId),
    );

    isLeavingGroup.value = false;

    if (response['statusCode'] == 200 || response['statusCode'] == 201) {
      // ✅ Chat list থেকে remove
      userChatList.removeWhere((room) => room.id == roomId);

      // ✅ Group state clear
      groupMessageList.clear();
      groupRoomID.value = '';

      // ✅ Screen pop
      if (navigateBack && context.mounted) {
        Navigator.pop(context);
      }

      CustomSnackbar.success(
        context: context,
        message: "Successfully  Leave This Group",
      );
    } else {
      final message =
          response['message'] ?? response['message'] ?? 'Something went wrong';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  // Voice intent এর জন্য — direct search, debounce ছাড়া

  final ChatRepository _repo = ChatRepository();
  Future<List<SearchModel>> searchUsersForVoice(String query) async {
    if (query.isEmpty) return [];

    final Response response = await _repo.searchUsers(
      query: query,
      page: 1,
      limit: 10,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['users'] != null) {
        return (data['users'] as List)
            .map((user) => SearchModel.fromJson(user))
            .toList();
      }
    }
    return [];
  }


















  Future<void> sendMediaMessage({
    required String receiverId,
    required String filePath,
    String? roomId,
    String? caption,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 sendMediaMessage CALLED');
    debugPrint('👤 receiverId: $receiverId');
    debugPrint('📁 filePath: $filePath');
    debugPrint('🏠 roomId: $roomId');
    debugPrint('💬 caption: $caption');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final file = await http.MultipartFile.fromPath('file', filePath);
      debugPrint('✅ MultipartFile created: ${file.filename}');

      final fields = <String, String>{
        'receiver_id': receiverId,
        if (caption != null && caption.isNotEmpty) 'message': caption,
        if (roomId != null && roomId.isNotEmpty) 'room_id': roomId,
      };

      debugPrint('📦 Fields: $fields');

      // final response = await ApiClient.multipartRequest(
      //   uri: ApiUrl.sendUser,
      //   method: 'POST',
      //   fields: fields,
      //   files: [file],
      // );

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.sendUser,
        method: 'POST',
        fields: fields,
        files: [file],
      );

      debugPrint('📥 sendMediaMessage RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

// ✅ নতুন অংশ — response থেকে সরাসরি message বানিয়ে list এ ঢোকাও
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newMsg = Messages.fromJson(data);
        newMsg.isMine = true; // server response এ is_mine আসছে না, manually সেট করো

        if (roomID.value.isEmpty && data['chatRoom_id'] != null) {
          roomID.value = data['chatRoom_id'].toString();
        }

        if (newMsg.chatRoomId == roomID.value) {
          userMessageList.insert(0, newMsg);
        }
        updateChatRoomInListOptimistic(newMsg);
      }

      debugPrint('📥 sendMediaMessage RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, stackTrace) {
      debugPrint('❌ sendMediaMessage ERROR: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  Future<void> sendGroupMediaMessage({
    required String roomId,
    required String filePath,
    String? caption,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 sendGroupMediaMessage CALLED');
    debugPrint('🏠 roomId: $roomId');
    debugPrint('📁 filePath: $filePath');
    debugPrint('💬 caption: $caption');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final file = await http.MultipartFile.fromPath('file', filePath);
      debugPrint('✅ MultipartFile created: ${file.filename}');

      final fields = <String, String>{
        'groupChatRoomId': roomId,
        if (caption != null && caption.isNotEmpty) 'message': caption,
      };

      debugPrint('📦 Fields: $fields');

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.sendGroup,
        method: 'POST',
        fields: fields,
        files: [file],
      );

      debugPrint('📥 sendGroupMediaMessage RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, stackTrace) {
      debugPrint('❌ sendGroupMediaMessage ERROR: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }



}
