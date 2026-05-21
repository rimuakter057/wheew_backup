// widgets/group_message_app_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class GroupMessageAppBar extends StatelessWidget {
  final String roomId;
  final String groupName;
  final String groupImage;
  final List<GroupMessage> groupMembers;
  final ChatController controller;

  const GroupMessageAppBar({
    super.key,
    required this.roomId,
    required this.groupName,
    required this.groupImage,
    required this.groupMembers,
    required this.controller,
  });

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
          '${'leave_group_confirmation'.tr} "$groupName"?',
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
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey,
              ),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isLeavingGroup.value
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      controller.leaveGroup(
                        roomId: roomId,
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
                        fontSize: ResponsiveHelper.fontSize(14),
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
    return CustomContainer(
      margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
      vertical: ResponsiveHelper.padding(16),
      horizontal: ResponsiveHelper.padding(0),
      backgroundColor: AppColors.greyShade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Back + Avatar + Name ──────────────────────────
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: AppColors.black),
              ),
              CircleAvatar(
                radius: ResponsiveHelper.borderRadius(22),
                backgroundColor: AppColors.blue.withOpacity(0.2),
                backgroundImage: groupImage.isNotEmpty
                    ? NetworkImage(groupImage)
                    : null,
                child: groupImage.isEmpty
                    ? CircleAvatar(            radius: ResponsiveHelper.borderRadius(22),
                    backgroundImage:NetworkImage(AppConst.unknown)

                )


                    : null,
              ),
              SizedBox(width: ResponsiveHelper.spacing(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    '${groupMembers.length} ${'members'.tr}',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(12),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Popup Menu ────────────────────────────────────
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.black),
            onSelected: (value) {
              if (value == "AddMembers") {
                context.pushNamed(RouteName.addMemberScreen, extra: roomId);
              } else if (value == "SeeMembers") {
                context.pushNamed(
                  RouteName.groupMemberScreen,
                  extra: {'roomId': roomId, 'groupName': groupName},
                );
              } else if (value == "LeaveGroup") {
                _showLeaveGroupDialog(context);
              }
            },
            itemBuilder: (context) => [
              // ── See Members ──────────────────────────────
              PopupMenuItem<String>(
                value: "SeeMembers",
                child: Row(
                  children: [
                    Icon(Icons.group_outlined, color: AppColors.black),
                    const SizedBox(width: 8),
                    Text(
                      'see_members'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                enabled: false,
                height: 1,
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),

              // ── Add Members ──────────────────────────────
              PopupMenuItem<String>(
                value: "AddMembers",
                child: Row(
                  children: [
                    Icon(Icons.person_add_outlined, color: AppColors.black),
                    const SizedBox(width: 8),
                    Text(
                      'add_members'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                enabled: false,
                height: 1,
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),

              // ── Leave Group ──────────────────────────────
              PopupMenuItem<String>(
                value: "LeaveGroup",
                child: Row(
                  children: [
                    const Icon(Icons.exit_to_app_outlined, color: Colors.red),
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
    );
  }
}
