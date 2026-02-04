/*
import 'dart:convert';
import 'package:get/get.dart' hide Response;
import 'package:http/src/response.dart';
import '../../feature/chat/repository/chat_repository.dart';
import '../model/chat_model.dart';

class ChatController extends GetxController {
  final ChatRepository _repo = ChatRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ChatModel> _chatList = [];
  List<ChatModel> get chatList => _chatList;

  @override
  void onInit() {
    super.onInit();
    getChatList();
  }

  Future<void> getChatList() async {
    _isLoading = true;
    update();

    final Response response = await _repo.getChatList();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _chatList = (data['chats'] as List)  // Adjust based on your API response
          .map((chat) => ChatModel.fromJson(chat))
          .toList();
    } else {
      _chatList = [];
    }
    _isLoading = false;
    update();
  }
}*/
/*
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import '../../feature/chat/repository/chat_repository.dart';
import '../model/chat_model.dart';

class ChatController extends GetxController {
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
    getChatList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> getChatList() async {
    _isLoading = true;
    update();

    final Response response = await _repo.getChatList();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _chatList = (data['chats'] as List)
          .map((chat) => ChatModel.fromJson(chat))
          .toList();
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
      _searchResults = (data['users'] as List)  // Adjust based on your API
          .map((user) => ChatModel.fromJson(user))
          .toList();
    } else {
      _searchResults = [];
    }

    _isSearching = false;
    update();
  }
}
*/







import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import '../../feature/chat/repository/chat_repository.dart';
import '../model/chat_model.dart';

class ChatController extends GetxController {
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
    getChatList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> getChatList() async {
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
}