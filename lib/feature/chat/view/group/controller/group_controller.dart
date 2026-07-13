import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/model/user_profile_model.dart';
import 'package:platchatapp/feature/chat/model/view_user_profile_model.dart';
import 'package:platchatapp/feature/chat/repository/add_member_repo.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
// ✅ এটা দাও
import 'package:platchatapp/feature/chat/view/group/model/group_member.dart';

class GroupController extends GetxController {
  // --- Group Update Fields ---
  final Rx<File?> groupImageFile = Rx<File?>(null);
  final RxBool isUpdatingGroup = false.obs;
  final groupNameController = TextEditingController();

  Future<void> pickGroupImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked != null) {
        groupImageFile.value = File(picked.path);
      }
    } catch (e) {
      debugPrint('pickGroupImage error: $e');
    }
  }

///update group==================================
  Future<Map<String, dynamic>?> updateGroup({
    required String roomId,
    required BuildContext context,
  }) async {
    final newName = groupNameController.text.trim();
    if (newName.isEmpty) {
      CustomSnackbar.error(context: context, message: 'Group name cannot be empty');
      return null;
    }

    isUpdatingGroup.value = true;

    try {
      final List<http.MultipartFile> files = [];

      if (groupImageFile.value != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'image',
            groupImageFile.value!.path,
          ),
        );
      }

      /// DEBUG PRINT
      final uri = ApiUrl.updateGroup(roomId: roomId);
      debugPrint("🚀 UPDATE GROUP API HIT:");
      debugPrint("➡️ URL: $uri");
      debugPrint("➡️ METHOD: PUT");
      debugPrint("➡️ NAME: $newName");
      debugPrint("➡️ HAS IMAGE: ${groupImageFile.value != null}");

      final response = await ApiClient.multipartRequest(
        uri: uri,
        method: 'PATCH',
        fields: {
          'name': newName,
        },
        files: files.isNotEmpty ? files : null,
      );

      debugPrint("📩 RESPONSE STATUS: ${response.statusCode}");
      debugPrint("📩 RESPONSE BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(context: context, message: 'Group updated successfully');
        groupImageFile.value = null;
        chatController.fetchChatList(refresh: true);
        return data;
      } else {
        final message = data['message'] ?? 'Failed to update group';
        CustomSnackbar.error(context: context, message: message);
        return null;
      }
    } catch (e) {
      debugPrint('updateGroup error: $e');
      CustomSnackbar.error(context: context, message: 'An error occurred while updating group');
      return null;
    } finally {
      isUpdatingGroup.value = false;
    }
  }
///view other user profile=====================================================
  final RxBool isLoadingProfile = false.obs;

  final Rx<ViewUserProfileModel?> viewedProfile = Rx<ViewUserProfileModel?>(null);

  Future<void> fetchUserProfile(String userId) async {
    isLoadingProfile.value = true;
    viewedProfile.value = null;

    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.userProfile(userId),
      );

      if (response.statusCode == 200) {
        viewedProfile.value = ViewUserProfileModel.fromJson(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoadingProfile.value = false;
    }
  }



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
    selectedIds.clear();   // ✅ add করো
    searchResults.clear(); // ✅ add করো
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

///remove===================================
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

  @override
  void onClose() {
    groupNameController.dispose();
    super.onClose();
  }
}
