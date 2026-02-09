import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/model/chat_model.dart';
import 'package:platchatapp/feature/chat/model/message_response_model.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import '../../../core/service/socket_service.dart';
import 'chat_repository.dart';

class ChatController extends GetxController {
  ///==============================================================

  /// get all message list ================================================
  RxList<Messages> userMessageList = <Messages>[].obs;

  var isLoadingMessage = false.obs; // first page
  var isLoadingMoreMessage = false.obs; // pagination

  int pageCount = 1;
  final int limitCount = 10;
  int totalCount = 0;

  bool get hasMoreMessage => userMessageList.length < totalCount;

  //RxString? roomID;
  /// Room ID
  RxString roomID = "".obs;

  Future<void> fetchRoomMessage({String? roomId, bool refresh = false}) async {
  //  if (roomId != null) roomID?.value = roomId;

    // Update roomID if provided
    if (roomId != null && roomId.isNotEmpty) {
      roomID.value = roomId;
    }

    if (roomID.value.isEmpty) {
      debugPrint("❌ Room ID is empty, skipping fetch");
      return; // Skip API call if no room ID
    }


    debugPrint("================ RoomID=========== ${roomID?.value}");

    if (refresh) {
      pageCount = 1;
      totalCount = 0;
      userMessageList.clear();
    }

    if ((pageCount > 1 && isLoadingMoreMessage.value) ||
        (pageCount == 1 && isLoadingMessage.value))
      return;

    if (pageCount == 1) {
      isLoadingMessage.value = true;
    } else {
      isLoadingMoreMessage.value = true;
    }

    final uri = ApiUrl.getRoomMessage(
      roomId: roomId ?? '',
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
          msg.isMine = msg.isMine == true;
          userMessageList.add(msg);
        }
        pageCount++;
      }
    }

    isLoadingMessage.value = false;
    isLoadingMoreMessage.value = false;
  }




  ///socket========================

  final TextEditingController messageController = TextEditingController();

  sendNewEmitMessage({required String receiverId, required String message}) {
    final payload = {'receiver_id': receiverId, 'message': message};

    final completer = Completer<dynamic>();

    /// 🔹 Create optimistic local message
    final localTempMessage = Messages(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temp id
      receiverId: receiverId,
      message: message,
      createdAt: DateTime.now().toIso8601String(),
      isMine: true,
      isDelivered: false,
      type: 'manual',
    );

    /// 🔹 Add to UI immediately
    userMessageList.insert(0, localTempMessage);

    // userMessageList.add(localTempMessage);

    messageController.clear();

    AppSocket.emitWithAck(
      "message",
      payload,
      ack: (value) {
        // completer.complete(value);

        debugPrint(
          "============sendNewEmitMessage success=============== $value",
        );
      },
    );
  }

  Future<void> sendNewListenMessage() async {
    AppSocket.onEvent('message-sent', (value) {
      debugPrint(
        '====================== send new message============================ $value',);


      if (roomID.value.isNotEmpty) {
        fetchRoomMessage(roomId: roomID.value);

        fetchChatRooms();

        debugPrint(
          '====================== fetchRoomMessage send new message============================ $fetchRoomMessage',);



        debugPrint(
          '====================== fetchRoomMessage send new message============================ $fetchChatRooms',);

      }


    });
  }


  Future<void> newMessage() async {
    AppSocket.onEvent('message-sent', (value) {
      debugPrint(
        '====================== send new message============================ $value',);


      if (roomID.value.isNotEmpty) {
        fetchRoomMessage(roomId: roomID.value);

        fetchChatRooms();

        debugPrint(
          '====================== fetchRoomMessage send new message============================ $fetchRoomMessage',);



        debugPrint(
          '====================== fetchRoomMessage send new message============================ $fetchChatRooms',);

      }


    });
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
  int page = 1;
  final int limit = 10;
  int total = 0;
  // fetch chat rooms
  Future<void> fetchChatRooms({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      userChatList.clear();
    }
    if (isLoadingChat.value || isLoadingMore.value) return;

    final isFirstPage = page == 1;
    if (isFirstPage) {
      isLoadingChat.value = true;
    } else {
      isLoadingMore.value = true;
    }
    // GET request
    final uri = ApiUrl.getChatRooms(page: page, limit: limit);
    Response response = await ApiClient.getData(uri: uri);

    // decode JSON string to Map
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['rooms'] != null) {
      final data = UserChatModel.fromJson(body);
      total = data.total ?? 0;

      if (data.rooms != null) {
        userChatList.addAll(data.rooms!);
        page++;
      }
    } else {
      if (refresh) userChatList.clear();
    }
    isLoadingChat.value = false;
    isLoadingMore.value = false;
  }

  bool get hasMore => userChatList.length < total;

  ///=======================================================================

  ///==============search api section=========================================================
  final ChatRepository _repo = ChatRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<ChatModel> _chatList = [];
  List<ChatModel> get chatList => _chatList;

  List<ChatModel> _searchResults = [];
  List<ChatModel> get searchResults => _searchResults;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    getChatSearchList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> getChatSearchList() async {
    _isLoading = true;
    update();

    final Response response = await _repo.getChatList();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Fix: Check if data has 'chats' array or if it's user profile
      if (data['chats'] != null && data['chats'] is List) {
        _chatList = (data['chats'] as List)
            .map((chat) => ChatModel.fromJson(chat))
            .toList();
      } else {
        // This seems to be user profile, not chat list
        _chatList = [];
      }
    } else {
      _chatList = [];
    }

    _isLoading = false;
    update();
  }

  void searchUsers(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      update();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _isSearching = true;
    update();

    final Response response = await _repo.searchUsers(
      query: query,
      page: 1,
      limit: 10,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Fix: Navigate nested structure - users.users array
      if (data['users'] != null && data['users']['users'] != null) {
        _searchResults = (data['users']['users'] as List)
            .map((user) => ChatModel.fromJson(user))
            .toList();
      } else {
        _searchResults = [];
      }
    } else {
      _searchResults = [];
    }

    _isSearching = false;
    update();
  }

  getAllConversation({int? page = 1}) async {
    final payload = {"page": page.toString(), "limit": 10};
    AppSocket.emitWithAck(
      "fetch-chat-rooms",
      payload,
      ack: (value) {
        debugPrint('===>> fetch-chat-rooms===================>> $value');
      },
    );
  }

  ///=======================user chat list===================================================================
}
