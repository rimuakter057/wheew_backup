import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/controller/group_controller.dart';
import 'package:platchatapp/feature/chat/view/group/model/group_member.dart';
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
          AppStrings.removeMember.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          '"$memberName" ${AppStrings.removeMemberConfirmation.tr}?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            color: AppColors.greyShade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.grey),
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
                        color: AppColors.red,
                      ),
                    )
                  : Text(
                AppStrings.removeMember.tr,
                      style: GoogleFonts.poppins(
                        color: AppColors.red,
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

    bool isAdmin = groupController.groupMemberList.any(
          (e) =>
      e.userId == currentUserId &&
          e.groupRole == 'GROUP_ADMIN',
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
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
          // â”€â”€ Dropdown Menu â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.black),
            onSelected: (value) {
              if (value == 'AddMembers') {
                context
                    .pushNamed(RouteName.addMemberScreen, extra: widget.roomId)
                    .then((_) {
                      // Add à¦•à¦°à¦¾à¦° à¦ªà¦° refresh
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
                      AppStrings.addMembers.tr,
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
                child: Divider(height: 1, color: AppColors.greyShade200),
              ),
              PopupMenuItem(
                value: 'LeaveGroup',
                child: Row(
                  children: [
              //      const Icon(Icons.exit_to_app_outlined, color: AppColors.red),

                    CustomImage(imageSrc: "assets/icons/leave_group.svg"),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.leaveGroup.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: AppColors.red,
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
        // â”€â”€ Loading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (groupController.isLoadingMembers.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // â”€â”€ Empty â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (groupController.groupMemberList.isEmpty) {
          return Center(
            child: Text(
              AppStrings.noMembersFound.tr,
              style: GoogleFonts.poppins(color: AppColors.grey),
            ),
          );
        }

        // ── Member List — admin(s) get their own card up top, the rest
        //    are grouped together under a "Group Members" section â”€â”€â”€â”€â”€â”€
        final admins = groupController.groupMemberList
            .where((m) => m.groupRole == 'GROUP_ADMIN')
            .toList();
        final others = groupController.groupMemberList
            .where((m) => m.groupRole != 'GROUP_ADMIN')
            .toList();

        return ListView(
          padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
          children: [
            for (final admin in admins) ...[
              _buildMemberCard([admin], canManage: isAdmin),
              SizedBox(height: ResponsiveHelper.spacing(20)),
            ],
            if (others.isNotEmpty) ...[
              Text(
                AppStrings.groupMembersTitle.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              _buildMemberCard(others, canManage: isAdmin),
            ],
          ],
        );
      }),
      ),
    );
  }

  // ── Grouped card — one or more member rows, divided by thin dividers.
  //    Same gradient card style as the Add Member screen. â”€â”€
  Widget _buildMemberCard(List<GroupMemberModel> members, {required bool canManage}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8EEF5),
            Color(0xFFD3DEE9),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(16)),
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            _buildMemberRow(members[i], canManage: canManage),
            if (i != members.length - 1)
              Divider(color: AppColors.greyShade200, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberRow(GroupMemberModel member, {required bool canManage}) {
    final isAdmin = member.groupRole == 'GROUP_ADMIN';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.padding(4),
      ),
      leading: CircleAvatar(
        radius: ResponsiveHelper.borderRadius(22),
        backgroundColor: AppColors.blue.withValues(alpha: 0.2),
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
          color: AppColors.grey,
        ),
      ),
      trailing: isAdmin
          ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(10),
                vertical: ResponsiveHelper.padding(4),
              ),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(20),
                ),
              ),
              child: Text(
                AppStrings.admin.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(11),
                  color: AppColors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : (canManage
              ? PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.grey),
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
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.remove.tr,
                            style: GoogleFonts.poppins(color: AppColors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null),
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
          AppStrings.leaveGroup.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          '${AppStrings.leaveGroupConfirmation.tr} "${widget.groupName}"?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            color: AppColors.greyShade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel.tr,
              style: GoogleFonts.poppins(color: AppColors.grey),
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
                        color: AppColors.red,
                      ),
                    )
                  : Text(
                AppStrings.leave.tr,
                      style: GoogleFonts.poppins(
                        color: AppColors.red,
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



