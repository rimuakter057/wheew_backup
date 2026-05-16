import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/controller/group_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchGroupMembers(roomId: widget.roomId);
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
          'Remove Member',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Remove "$memberName" from the group?',
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
                      'Remove',
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
                    Icon(Icons.person_add_outlined, color: AppColors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Add Members',
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
                    const Icon(Icons.exit_to_app_outlined, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Leave Group',
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
              'No members found',
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
                backgroundColor: AppColors.blueClient.withOpacity(0.2),
                backgroundImage: member.avatar.isNotEmpty
                    ? NetworkImage(member.avatar)
                    : null,
                child: member.avatar.isEmpty
                    ? Icon(Icons.person, color: AppColors.blueClient)
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
                        color: AppColors.blueClient.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(20),
                        ),
                      ),
                      child: Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(11),
                          color: AppColors.blueClient,
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
                                'Remove',
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
          'Leave Group',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to leave "${widget.groupName}"?',
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
                      'Leave',
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
