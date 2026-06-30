import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/controller/group_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../utils/app_const/app_const.dart';

class GroupMemberScreen extends StatefulWidget {
  final String roomId;
  final String groupName;

  const GroupMemberScreen({
    super.key,
    required this.roomId,
    required this.groupName,
  });

  @override
  State<GroupMemberScreen> createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  final GroupController groupController = Get.put(GroupController());
  final ChatController controller = Get.put(ChatController());
  String currentUserId = '';

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     groupController.fetchGroupMembers(roomId: widget.roomId);
  //   });
  // }






  @override
  void initState() {
    super.initState();
    _loadUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchGroupMembers(roomId: widget.roomId);
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      currentUserId = prefs.getString(AppConst.userID) ?? '';
    });
  }












  void _showRemoveDialog(String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(16),
          ),
        ),
        title: Text(
          'remove_member'.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          '"$memberName" ${'remove_member_confirmation'.tr}?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: groupController.isRemovingMember.value
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await groupController.removeGroupMember(
                        roomId: widget.roomId,
                        memberId: memberId,
                        context: context,
                      );
                    },
              child: groupController.isRemovingMember.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : Text(
                'remove_member'.tr,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final currentUser = groupController.groupMemberList.firstWhereOrNull(
          (e) => e.userId == currentUserId,
    );

    bool isAdmin = groupController.groupMemberList.any(
          (e) =>
      e.userId == currentUserId &&
          e.groupRole == 'GROUP_ADMIN',
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text(
          widget.groupName,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        actions: [
          if (isAdmin)
          // ── Dropdown Menu ─────────────────────────────
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.black),
            onSelected: (value) {
              if (value == 'AddMembers') {
                context
                    .pushNamed(RouteName.addMemberScreen, extra: widget.roomId)
                    .then((_) {
                      // Add করার পর refresh
                      groupController.fetchGroupMembers(roomId: widget.roomId);
                    });
              } else if (value == 'LeaveGroup') {
                _showLeaveGroupDialog();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'AddMembers',
                child: Row(
                  children: [
                  //  Icon(Icons.person_add_outlined, color: AppColors.black),
                    CustomImage(imageSrc: "assets/icons/add_member.svg"),

                    const SizedBox(width: 8),
                    Text(
                      'add_members'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                enabled: false,
                height: 1,
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
              PopupMenuItem(
                value: 'LeaveGroup',
                child: Row(
                  children: [
              //      const Icon(Icons.exit_to_app_outlined, color: Colors.red),

                    CustomImage(imageSrc: "assets/icons/leave_group.svg"),
                    const SizedBox(width: 8),
                    Text(
                      'leave_group'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Obx(() {
        // ── Loading ──────────────────────────────────────
        if (groupController.isLoadingMembers.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Empty ────────────────────────────────────────
        if (groupController.groupMemberList.isEmpty) {
          return Center(
            child: Text(
              'no_members_found'.tr,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          );
        }

        // ── Member List ──────────────────────────────────
        return ListView.separated(
          padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
          itemCount: groupController.groupMemberList.length,
          separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100),
          itemBuilder: (context, index) {
            final member = groupController.groupMemberList[index];
            final isAdmin = member.groupRole == 'GROUP_ADMIN';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: ResponsiveHelper.borderRadius(22),
                backgroundColor: AppColors.blue.withOpacity(0.2),
                backgroundImage: member.avatar.isNotEmpty
                    ? NetworkImage(member.avatar)
                    : null,
                child: member.avatar.isEmpty
                    ? Icon(Icons.person, color: AppColors.blue)
                    : null,
              ),
              title: Text(
                member.nickName,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              subtitle: Text(
                member.licenceId,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: Colors.grey,
                ),
              ),
              trailing: isAdmin
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(10),
                        vertical: ResponsiveHelper.padding(4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(20),
                        ),
                      ),
                      child: Text(
                        'admin'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(11),
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'Remove') {
                          _showRemoveDialog(member.userId, member.nickName);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'Remove',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_remove_outlined,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'remove'.tr,
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),












            );
          },
        );
      }),
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(16),
          ),
        ),
        title: Text(
          'leave_group'.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          '${'leave_group_confirmation'.tr} "${widget.groupName}"?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'cancel'.tr,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isLeavingGroup.value
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      controller.leaveGroup(
                        roomId: widget.roomId,
                        context: context,
                        navigateBack: true,
                      );
                    },
              child: controller.isLeavingGroup.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : Text(
                'leave'.tr,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
