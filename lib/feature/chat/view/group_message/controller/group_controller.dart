import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/repository/add_member_repo.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group_message/model/group_member.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

class GroupController extends GetxController {


  ///search member============================


  final AddMemberRepository _repository = AddMemberRepository();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxList<SearchMemberModel> searchResults = <SearchMemberModel>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // ─── Selected Members ────────────────────────────────────────────────────────
  final RxSet<String> selectedIds = <String>{}.obs; // otherUser id

  // ─── Internal ────────────────────────────────────────────────────────────────
  Timer? _debounce;
  late String _roomId;

  // ─── Init ─────────────────────────────────────────────────────────────────────
  void init(String roomId) {
    _roomId = roomId;
    // Screen খুললেই default list load করো
    _search('');
  }

  // ─── Search (debounced 400ms) ─────────────────────────────────────────────────
  void onSearchChanged(String query) {
    searchQuery.value = query.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query.trim());
    });
  }

  Future<void> _search(String query) async {
    isSearching.value = true;
    try {
      final results = await _repository.searchGroupMember(
        roomId: _roomId,
        query: query,
      );
      searchResults.assignAll(results);
    } finally {
      isSearching.value = false;
    }
  }

  // ─── Selection ───────────────────────────────────────────────────────────────
  void toggleSelect(String userId) {
    if (selectedIds.contains(userId)) {
      selectedIds.remove(userId);
    } else {
      selectedIds.add(userId);
    }
  }

  bool isSelected(String userId) => selectedIds.contains(userId);






///=========================
 final ChatController  chatController=Get.find<ChatController>();

  // ── Group Members ─────────────────────────────────────
  RxList<GroupMemberModel> groupMemberList = <GroupMemberModel>[].obs;
  RxBool isLoadingMembers = false.obs;
  RxBool isRemovingMember = false.obs;

  Future<void> fetchGroupMembers({required String roomId}) async {
    isLoadingMembers.value = true;
    try {
      final response = await ApiClient.getData(
        uri: '/chat/rooms',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final List rooms = data['rooms'] ?? [];

        // ✅ roomId দিয়ে সঠিক room খুঁজে বের করো
        final room = rooms.firstWhere(
              (r) => r['id'] == roomId,
          orElse: () => null,
        );

        if (room != null) {
          final List members = room['group_members'] ?? [];
          groupMemberList.value = members
              .map((e) => GroupMemberModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('fetchGroupMembers error: $e');
    } finally {
      isLoadingMembers.value = false;
    }
  }


  Future<bool> removeGroupMember({
    required String roomId,
    required String memberId,
    required BuildContext context,
  }) async {
    isRemovingMember.value = true;
    try {
      final response = await ApiClient.deleteData(
        uri: ApiUrl.removeGroupMember(roomId: roomId, memberId: memberId),
      );
      final statusCode = response['statusCode'];
      if (statusCode == 200 || statusCode == 201) {
        // ✅ Local list থেকে সরাও
        groupMemberList.removeWhere((m) => m.userId == memberId);
        CustomSnackbar.success(context: context, message: 'Member removed successfully');
             chatController.fetchChatList(refresh: true);


        return true;
      } else {
        final message = response['data']?['message'] ?? 'Could not remove member';
        CustomSnackbar.error(context: context, message: message);
        return false;
      }
    } catch (e) {
      debugPrint('removeGroupMember error: $e');
      CustomSnackbar.error(context: context, message: 'Failed to remove member');
      return false;
    } finally {
      isRemovingMember.value = false;
    }
  }

}