// ignore_for_file: unnecessary_null_comparison, invalid_use_of_protected_member

import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';
import 'dart:io';
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



import 'dart:collection';

class MultipartFieldsMap extends MapBase<String, String> {
  final List<MapEntry<String, String>> _entries = [];

  @override
  String? operator [](Object? key) {
    for (final entry in _entries) {
      if (entry.key == key) return entry.value;
    }
    return null;
  }

  @override
  void operator []=(String key, String value) {
    _entries.add(MapEntry(key, value));
  }

  @override
  void clear() => _entries.clear();

  @override
  Iterable<String> get keys => _entries.map((e) => e.key).toSet();

  @override
  String? remove(Object? key) {
    String? lastValue;
    _entries.removeWhere((entry) {
      if (entry.key == key) {
        lastValue = entry.value;
        return true;
      }
      return false;
    });
    return lastValue;
  }

  @override
  void forEach(void Function(String key, String value) action) {
    for (final entry in _entries) {
      action(entry.key, entry.value);
    }
  }
}

class CustomMultipartRequest extends http.MultipartRequest {
  final Map<String, String> _customFields = MultipartFieldsMap();

  CustomMultipartRequest(String method, Uri url) : super(method, url);

  @override
  Map<String, String> get fields => _customFields;
}

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
          message: update ? AppStrings.ratingUpdated.tr : AppStrings.ratingSubmitted.tr,
        );
      } else {
        String msg = AppStrings.ratingFailed.tr;
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
              .map((e) => PresetMessage.fromJson(e))
              .toList();
          print(
            '✅ [PRESET] Parsed from data["messages"]: ${presetMessages.value}',
          );
        }
        // Case 2: [ { "message": "..." } ]  (direct array)
        else if (data is List) {
          presetMessages.value = data
              .map((e) => PresetMessage.fromJson(e))
              .toList();
          print('✅ [PRESET] Parsed from direct List: ${presetMessages.value}');
        }
        // Case 3: { "data": [ { "message": "..." } ] }
        else if (data is Map && data['data'] != null) {
          final list = List<Map<String, dynamic>>.from(data['data']);
          presetMessages.value = list
              .map((e) => PresetMessage.fromJson(e))
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
  Object? _lastBoundSocket; // ⭐ Track specific socket instance to avoid redundant registrations and handle re-initialization

  void initSocketListeners() {
    final s = AppSocket.socket;
    if (s == null) {
      debugPrint('🔌 AppSocket.socket is null, skipping listener initialization');
      return;
    }
    _lastBoundSocket = s;

    // ✅ এই prints গুলো add করো
    debugPrint('🔌 Socket connected: ${s.connected}');
    debugPrint('🔌 Socket id: ${s.id}');
    debugPrint('🔌 Socket listeners initializing...');

    sendNewListenMessage();
    errorListenMessage();
    newMessage();
    listenMessageDelivered();
    listenTypingEvents();
    listenDeleteMessageEvents();

    debugPrint('✅ Socket listeners initialized');
  }

  /// Typing indicators state
  RxBool isTyping = false.obs;
  RxMap<String, bool> inboxTypingMap = <String, bool>{}.obs;

  /// get all message list ================================================
  final RxSet<String> deliveredMessageIds = <String>{}.obs;

  void _applyStoredStatus(Messages message) {
    if (message.id != null) {
      final idStr = message.id!.toString();
      if (deliveredMessageIds.contains(idStr)) {
        message.isDelivered = true;
      }
    }
  }

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
          for (final msg in data.messages!) {
            if (msg.isDeletedForEveryone == true) {


              continue;

            }
            msg.isMine = msg.isMine == true;
            userMessageList.add(msg);
          }
          pageCount++;
        }

        // ✅ Backend fetch হলে local UI-তেও unread badge সরিয়ে দিচ্ছি
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
               _applyStoredStatus(confirmed);
               userMessageList[tempIndex] = confirmed;
               userMessageList.refresh();
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
    AppSocket.socket?.off('message-sent');
    AppSocket.onEvent('message-sent', (value) {
      debugPrint('📥 [SOCKET] EVENT RECEIVED: "message-sent": $value');

      if (value != null) {
        try {
          final confirmed = Messages.fromJson(value);
          confirmed.isMine = true;
          _applyStoredStatus(confirmed);

          // Find the temp message with the same message text
          final tempIndex = userMessageList.indexWhere(
            (m) => (m.id?.startsWith('temp_') ?? false) && m.message == confirmed.message,
          );

          if (tempIndex != -1) {
            userMessageList[tempIndex] = confirmed;
            userMessageList.refresh();
            debugPrint('✅ Temp message replaced by "message-sent" event: ${confirmed.id}');
          } else {
            // If not found (maybe timing), let's check duplicate and insert it
            final alreadyExists = userMessageList.any((m) => m.id == confirmed.id);
            if (!alreadyExists && confirmed.chatRoomId?.toString() == roomID.value.toString()) {
              userMessageList.insert(0, confirmed);
              userMessageList.refresh();
              debugPrint('✅ Message inserted by "message-sent" event: ${confirmed.id}');
            }
          }

          if (value['chatRoom_id'] != null) {
            roomID.value = value['chatRoom_id'].toString();
          }
        } catch (e) {
          debugPrint("⚠️ message-sent event parse failed: $e");
        }
      }
    });
  }

  // ✅ Chat screen খুললে locally unread badge reset করো
  // (backend fetch-এই automatically is_read = true হয় — কোনো socket event দরকার নেই)

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

  void listenTypingEvents() {
    final s = AppSocket.socket;
    if (s == null) return;

    s.off('user-typing');
    s.off('user-stopped-typing');
    s.off('group-user-typing');
    s.off('group-user-stopped-typing');

    s.on('user-typing', (data) {
      debugPrint('⌨️ user-typing event received: $data');
      if (data is Map) {
        final rId = data['roomId']?.toString() ?? data['chatRoomId']?.toString();
        if (rId != null) {
          inboxTypingMap[rId] = true;
          if (rId == roomID.value || rId == groupRoomID.value) {
            isTyping.value = true;
          }
        }
      }
    });

    s.on('user-stopped-typing', (data) {
      debugPrint('⌨️ user-stopped-typing event received: $data');
      if (data is Map) {
        final rId = data['roomId']?.toString() ?? data['chatRoomId']?.toString();
        if (rId != null) {
          inboxTypingMap[rId] = false;
          if (rId == roomID.value || rId == groupRoomID.value) {
            isTyping.value = false;
          }
        }
      }
    });

    s.on('group-user-typing', (data) {
      debugPrint('⌨️ group-user-typing event received: $data');
      if (data is Map) {
        final rId = data['groupChatRoomId']?.toString() ?? data['roomId']?.toString();
        if (rId != null) {
          inboxTypingMap[rId] = true;
          if (rId == roomID.value || rId == groupRoomID.value) {
            isTyping.value = true;
          }
        }
      }
    });

    s.on('group-user-stopped-typing', (data) {
      debugPrint('⌨️ group-user-stopped-typing event received: $data');
      if (data is Map) {
        final rId = data['groupChatRoomId']?.toString() ?? data['roomId']?.toString();
        if (rId != null) {
          inboxTypingMap[rId] = false;
          if (rId == roomID.value || rId == groupRoomID.value) {
            isTyping.value = false;
          }
        }
      }
    });
  }

  void sendTyping({required String receiverId, required String roomId, required bool isGroup}) {
    if (roomId.isEmpty) return;
    if (isGroup) {
      AppSocket.sendEvent('group-typing', {
        'groupChatRoomId': roomId,
      });
      debugPrint('📤 Emitted group-typing for room: $roomId');
    } else {
      AppSocket.sendEvent('typing', {
        'receiverId': receiverId,
        'roomId': roomId,
      });
      debugPrint('📤 Emitted typing for receiver: $receiverId, room: $roomId');
    }
  }

  void sendStopTyping({required String receiverId, required String roomId, required bool isGroup}) {
    if (roomId.isEmpty) return;
    if (isGroup) {
      AppSocket.sendEvent('group-stop-typing', {
        'groupChatRoomId': roomId,
      });
      debugPrint('📤 Emitted group-stop-typing for room: $roomId');
    } else {
      AppSocket.sendEvent('stop-typing', {
        'receiverId': receiverId,
        'roomId': roomId,
      });
      debugPrint('📤 Emitted stop-typing for receiver: $receiverId, room: $roomId');
    }
  }

  void listenDeleteMessageEvents() {
    final s = AppSocket.socket;
    if (s == null) return;

    s.off('message-deleted');
    s.off('group-message-deleted');

    s.on('message-deleted', (data) {
      debugPrint('🗑️ message-deleted event received: $data');
      if (data is Map) {
        final String? msgId = data['messageId']?.toString();
        final String? rId = data['roomId']?.toString();
        if (msgId != null) {
          userMessageList.removeWhere((msg) => msg.id == msgId);
          userMessageList.refresh();
          _updateRoomLastMessageAfterDeletion(rId, msgId);
        }
      }
    });

    s.on('group-message-deleted', (data) {
      debugPrint('🗑️ group-message-deleted event received: $data');
      if (data is Map) {
        final String? msgId = data['messageId']?.toString();
        if (msgId != null) {
          groupMessageList.removeWhere((msg) => msg.id == msgId);
          groupMessageList.refresh();
        }
      }
    });
  }

  void _updateRoomLastMessageAfterDeletion(String? roomId, String deletedMsgId) {
    if (roomId == null || roomId.isEmpty) return;
    final idx = userChatList.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      final room = userChatList[idx];
      if (room.latestMessage?.id == deletedMsgId) {
        room.latestMessage?.message = 'Message deleted';
        userChatList[idx] = room;
        userChatList.refresh();
      }
    }
  }

  var isDeletingMessage = false.obs;

  Future<bool> deleteMessageApi({required String messageId, required BuildContext context}) async {
    isDeletingMessage.value = true;
    try {
      final response = await ApiClient.deleteData(
        uri: ApiUrl.deleteMessage(messageId: messageId),
      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        userMessageList.removeWhere((msg) => msg.id == messageId);
        userMessageList.refresh();
        groupMessageList.removeWhere((msg) => msg.id == messageId);
        groupMessageList.refresh();

        CustomSnackbar.success(
          context: context,
          message: 'Message deleted successfully',
        );
        return true;
      } else {
        String errMsg = 'Failed to delete message';
        try {
          errMsg = response['data']['message'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('deleteMessageApi error: $e');
      CustomSnackbar.error(context: context, message: 'An error occurred while deleting the message');
      return false;
    } finally {
      isDeletingMessage.value = false;
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


  Future<void> _handleIncomingMessage(Messages model) async {
    _applyStoredStatus(model);

    final String myId = await SharePrefsHelper.getString(AppConst.userID);
    model.isMine = model.senderId == myId;

    if (model.isMine == false && model.id != null) {
      // ✅ message-received: User 2 has received it — emit it to notify original sender
      AppSocket.socket?.emit('message-received', {
        'roomId': model.chatRoomId ?? roomID.value,
        'messageId': model.id,
        'messageIds': [model.id],
      });
      debugPrint('📨 message-received emitted with roomId: ${model.chatRoomId}');
    }

    // ✅ temp message replace check
    final tempIndex = userMessageList.indexWhere(
          (m) => (m.id?.startsWith('temp_') ?? false) && m.message == model.message,
    );
    if (tempIndex != -1) {
      userMessageList[tempIndex] = model;
      userMessageList.refresh();
      debugPrint('✅ Temp message replaced by broadcast');
      updateChatRoomInList(model);
      return;
    }

    // ✅ duplicate check
    final alreadyExists = userMessageList.any((m) => m.id == model.id);
    if (alreadyExists) {
      debugPrint('⚠️ Duplicate message ignored: ${model.id}');
      return;
    }

    if (model.chatRoomId?.toString() == roomID.value.toString()) {
      userMessageList.insert(0, model);
      debugPrint('✅ Added to message list');
    }

    if (model.isMine == false) {
      _playMessageSound();
    }

    updateChatRoomInList(model);
  }

  void _updateMessageDeliveryStatus(String messageId, bool isDelivered, {bool? isRead}) {
    debugPrint('ℹ️ [DEBUG] _updateMessageDeliveryStatus called for target ID: "$messageId" isDelivered=$isDelivered isRead=$isRead');
    debugPrint('ℹ️ [DEBUG] Messages in userMessageList: ${userMessageList.map((m) => '"${m.id}"').toList()}');

    if (isDelivered) {
      deliveredMessageIds.add(messageId);
    }

    bool updated = false;
    final index = userMessageList.indexWhere((m) => m.id?.toString() == messageId);
    debugPrint('ℹ️ [DEBUG] Index found: $index');

    if (index != -1) {
      // Found by real server ID — update directly
      final old = userMessageList[index];
      userMessageList[index] = Messages(
        id: old.id,
        chatRoomId: old.chatRoomId,
        senderId: old.senderId,
        receiverId: old.receiverId,
        message: old.message,
        type: old.type,
        // Use incoming isRead if provided, otherwise keep old value (don't downgrade)
        isRead: (isRead == true) ? true : old.isRead,
        isDelivered: isDelivered,
        createdAt: old.createdAt,
        updatedAt: old.updatedAt,
        sender: old.sender,
        receiver: old.receiver,
        isMine: old.isMine,
        fileUrl: old.fileUrl,
        fileName: old.fileName,
        fileSize: old.fileSize,
        encryptionType: old.encryptionType,
        encryptionVersion: old.encryptionVersion,
        senderKeyId: old.senderKeyId,
        receiverKeyId: old.receiverKeyId,
        nonce: old.nonce,
        fileMimeType: old.fileMimeType,
        durationSeconds: old.durationSeconds,
        waveform: old.waveform,
        isDeletedForEveryone: old.isDeletedForEveryone,
        deletedAt: old.deletedAt,
        deletedById: old.deletedById,
      );
      userMessageList.refresh();
      updated = true;
      debugPrint('✅ Chat screen message status updated: $messageId (delivered: $isDelivered, read: $isRead)');
    } else {
      // Race condition: message-delivered arrived before temp message was replaced with real ID.
      // Find the latest pending outgoing temp/sent message and mark it delivered.
      debugPrint('⚠️ Chat screen message with ID "$messageId" not found — applying to latest pending outgoing message.');
      final tempIndex = userMessageList.indexWhere(
        (m) => m.isMine == true && (m.id?.startsWith('temp_') ?? false),
      );
      if (tempIndex != -1) {
        final old = userMessageList[tempIndex];
        userMessageList[tempIndex] = Messages(
          id: old.id,
          chatRoomId: old.chatRoomId,
          senderId: old.senderId,
          receiverId: old.receiverId,
          message: old.message,
          type: old.type,
          isRead: (isRead == true) ? true : old.isRead,
          isDelivered: isDelivered,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
          sender: old.sender,
          receiver: old.receiver,
          isMine: old.isMine,
          fileUrl: old.fileUrl,
          fileName: old.fileName,
          fileSize: old.fileSize,
          encryptionType: old.encryptionType,
          encryptionVersion: old.encryptionVersion,
          senderKeyId: old.senderKeyId,
          receiverKeyId: old.receiverKeyId,
          nonce: old.nonce,
          fileMimeType: old.fileMimeType,
          durationSeconds: old.durationSeconds,
          waveform: old.waveform,
          isDeletedForEveryone: old.isDeletedForEveryone,
          deletedAt: old.deletedAt,
          deletedById: old.deletedById,
        );
        userMessageList.refresh();
        updated = true;
        debugPrint('✅ Applied to temp message fallback: ${old.id}');
      }
    }

    if (updated) {
      // Also update chat list if the delivered message is the latest one
      final roomIndex = userChatList.indexWhere((room) => room.latestMessage?.id?.toString() == messageId);
      if (roomIndex != -1) {
        userChatList[roomIndex].latestMessage?.isDelivered = isDelivered;
        if (isRead == true) userChatList[roomIndex].latestMessage?.isRead = true;
        userChatList.refresh();
        debugPrint('✅ Chat list room latestMessage status updated: $messageId');
      }
    }
  }

  Future<void> newMessage() async {
    AppSocket.socket?.off('new-message');

    AppSocket.socket?.on('new-message', (value) async {
      debugPrint('🔔 NEW-MESSAGE EVENT RECEIVED: $value');
      Messages model = Messages.fromJson(value);
      await _handleIncomingMessage(model);
    });
  }

  void listenMessageDelivered() {
    AppSocket.socket?.off('message-delivered');

    AppSocket.socket?.on('message-delivered', (value) async {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 [SOCKET] EVENT RECEIVED: "message-delivered"');
      debugPrint('Payload: $value');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      List<String> deliveredIds = [];
      bool isDelivered = true;
      bool? isRead;

      if (value is Map) {
        isDelivered = value['is_delivered'] ?? value['isDelivered'] ?? true;
        // Also capture isRead — server sends is_read:true when receiver was in chat screen
        final rawRead = value['is_read'] ?? value['isRead'];
        if (rawRead != null) isRead = rawRead as bool?;

        if (value['id'] != null) deliveredIds.add(value['id'].toString());
        if (value['messageId'] != null) deliveredIds.add(value['messageId'].toString());
        if (value['message_id'] != null) deliveredIds.add(value['message_id'].toString());
        if (value['messageIds'] != null) {
          final ids = value['messageIds'];
          if (ids is List) {
            deliveredIds.addAll(ids.map((e) => e.toString()));
          }
        }
      } else if (value is List) {
        for (final item in value) {
          if (item is Map) {
            final id = item['id'] ?? item['messageId'] ?? item['message_id'];
            if (id != null) deliveredIds.add(id.toString());
          } else if (item != null) {
            deliveredIds.add(item.toString());
          }
        }
      } else if (value is String) {
        deliveredIds.add(value);
      }

      // Deduplicate IDs (same ID can appear via both 'id' and 'messageId' fields)
      final uniqueIds = deliveredIds.toSet();
      for (final messageId in uniqueIds) {
        _updateMessageDeliveryStatus(messageId, isDelivered, isRead: isRead);
      }
    });
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
    // ✅ Already fetching হলে skip
    if (_isFetching) return;

    if (refresh) {
      page.value = 1;
      total = 0;
      userChatList.clear();
    }

    // ✅ আর data নেই তাহলে skip
    if (loadMore && !hasMore) return;

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
    String? imagePath,
  }) async {

    isCreatingGroup.value = true;
    try {
      final uri = ApiUrl.createGroup;
      Response response;

      final String myId = await SharePrefsHelper.getString(AppConst.userID);
      final List<String> finalMemberIds = List.from(memberIds);
      if (finalMemberIds.isEmpty && myId.isNotEmpty) {
        finalMemberIds.add(myId);
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        final url = Uri.parse(ApiUrl.baseUrl + uri);
        final token = await SharePrefsHelper.getString(AppConst.token);
        var request = CustomMultipartRequest('POST', url);

        request.headers['Accept'] = 'application/json';
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        request.fields['name'] = groupName;
        for (final memberId in finalMemberIds) {
          request.fields['memberIds'] = memberId;
        }

        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            imagePath,
          ));
        }

        final streamedResponse = await request.send();
        response = await Response.fromStream(streamedResponse);
      } else {
        response = await ApiClient.postData(
          uri: uri,
          body: {"name": groupName, "memberIds": finalMemberIds},
        );
      }

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
        AppStrings.userBlockedSuccessfully.tr,
        bgColor: Colors.green,
      );
    } else {
      print("Block failed: ${response.statusCode}");
      showSnackBar(context, AppStrings.failedToBlockUser.tr, bgColor: Colors.red);
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
        AppStrings.userUnblockedSuccessfully.tr,
        bgColor: Colors.green,
      );
    } else {
      debugPrint("Unblock failed: ${response.statusCode}");
      showSnackBar(context, AppStrings.failedToUnblockUser.tr, bgColor: Colors.red);
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

            if (msg.isDeletedForEveryone == true) {
              continue;
            }
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
          isMine: true, // ✅ Sender confirmation event is always my message
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
          groupMessageList.refresh();
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
        model.isMine = isMyMessage; // ✅ Explicitly set isMine based on sender ID

        if (model.groupChatRoomId?.toString() == groupRoomID.value.toString()) {
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
              groupMessageList.refresh();
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


















  // ── Voice message send ─────────────────────────────────────────
  Future<void> sendVoiceMessage({
    required String receiverId,
    required String filePath,
    required int durationSeconds,
    String? roomId,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎤 sendVoiceMessage CALLED');
    debugPrint('👤 receiverId: $receiverId');
    debugPrint('📁 filePath: $filePath');
    debugPrint('⏱️ durationSeconds: $durationSeconds');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      // Determine MIME type based on extension so the server accepts it as audio
      final ext = filePath.split('.').last.toLowerCase();
      final mimeType = (ext == 'mp3') ? MediaType('audio', 'mpeg')
          : (ext == 'ogg') ? MediaType('audio', 'ogg')
          : (ext == 'aac') ? MediaType('audio', 'aac')
          : MediaType('audio', 'mp4'); // default: .m4a → audio/mp4

      final file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mimeType,
      );

      final fields = <String, String>{
        'receiver_id': receiverId,
        'message': 'Voice note',
      };

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.sendVoice,
        method: 'POST',
        fields: fields,
        files: [file],
      );

      debugPrint('📥 sendVoiceMessage RESPONSE: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newMsg = Messages.fromJson(data);
        newMsg.isMine = true;
        _applyStoredStatus(newMsg);

        if (roomID.value.isEmpty && data['chatRoom_id'] != null) {
          roomID.value = data['chatRoom_id'].toString();
        }

        final alreadyExists = userMessageList.any((m) => m.id == newMsg.id);
        if (!alreadyExists && newMsg.chatRoomId?.toString() == roomID.value.toString()) {
          userMessageList.insert(0, newMsg);
        }
        updateChatRoomInListOptimistic(newMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ sendVoiceMessage ERROR: $e');
      debugPrint('StackTrace: $stackTrace');
    }
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
        _applyStoredStatus(newMsg);

        if (roomID.value.isEmpty && data['chatRoom_id'] != null) {
          roomID.value = data['chatRoom_id'].toString();
        }

        final alreadyExists = userMessageList.any((m) => m.id == newMsg.id);
        if (!alreadyExists && newMsg.chatRoomId?.toString() == roomID.value.toString()) {
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

  Future<void> sendGroupVoiceMessage({
    required String roomId,
    required String filePath,
    required int durationSeconds,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎤 sendGroupVoiceMessage CALLED');
    debugPrint('🏠 roomId: $roomId');
    debugPrint('📁 filePath: $filePath');
    debugPrint('⏱️ durationSeconds: $durationSeconds');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final ext = filePath.split('.').last.toLowerCase();
      final mimeType = (ext == 'mp3') ? MediaType('audio', 'mpeg')
          : (ext == 'ogg') ? MediaType('audio', 'ogg')
          : (ext == 'aac') ? MediaType('audio', 'aac')
          : MediaType('audio', 'mp4');

      final file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mimeType,
      );

      final fields = <String, String>{
        'groupChatRoomId': roomId,
        'message': 'Voice note',
      };

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.sendGroup,
        method: 'POST',
        fields: fields,
        files: [file],
      );

      debugPrint('📥 sendGroupVoiceMessage RESPONSE: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newMsg = GroupMessageResponseModel.fromJson(data);
        newMsg.isMine = true;

        final alreadyExists = groupMessageList.any((m) => m.id == newMsg.id);
        if (!alreadyExists && newMsg.groupChatRoomId?.toString() == groupRoomID.value.toString()) {
          groupMessageList.insert(0, newMsg);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ sendGroupVoiceMessage ERROR: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  // ── Message Request State & Variables ──────────────────────────────
  final RxList<dynamic> messageRequests = <dynamic>[].obs;
  final RxBool isLoadingRequests = false.obs;

  Future<void> fetchMessageRequestInbox({bool refresh = false}) async {
    if (refresh) {
      messageRequests.clear();
    }
    isLoadingRequests.value = true;
    try {
      final response = await ApiClient.getData(uri: ApiUrl.getMessageRequestInbox);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          messageRequests.value = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          messageRequests.value = decoded['data'];
        }
      } else {
        debugPrint('Failed to load message requests: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchMessageRequestInbox error: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<bool> createMessageRequest({
    required String receiverId,
    required String firstMessage,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.createMessageRequest,
        body: {'receiverId': receiverId, 'firstMessage': firstMessage},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = searchResults.indexWhere((u) => u.id == receiverId);
        if (index != -1) {
          final u = searchResults[index];
          u.isMessageRequestSent = true;
          u.messageRequest = {
            'status': 'PENDING',
            'receiverId': receiverId,
            'firstMessage': firstMessage,
          };
          searchResults[index] = u;
          searchResults.refresh();
        }
        CustomSnackbar.success(context: context, message: 'Message request sent successfully!');
        return true;
      } else {
        String errMsg = 'Failed to send message request';
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('createMessageRequest error: $e');
      CustomSnackbar.error(context: context, message: 'Failed to connect. Please try again.');
      return false;
    }
  }

  Future<bool> acceptMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.acceptMessageRequest(requestId),

        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(context: context, message: 'Request accepted!');
        fetchMessageRequestInbox(refresh: true);
        fetchChatList(refresh: true);
        return true;
      } else {
        String errMsg = 'Failed to accept message request';
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('acceptMessageRequest error: $e');
      CustomSnackbar.error(context: context, message: 'Failed to accept request.');
      return false;
    }
  }

  Future<bool> declineMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.declineMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(context: context, message: 'Request declined.');
        fetchMessageRequestInbox(refresh: true);
        return true;
      } else {
        String errMsg = 'Failed to decline message request';
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('declineMessageRequest error: $e');
      CustomSnackbar.error(context: context, message: 'Failed to decline request.');
      return false;
    }
  }
}
