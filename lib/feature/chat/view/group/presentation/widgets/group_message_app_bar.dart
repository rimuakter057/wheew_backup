import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/controller/group_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/core/service/api_url.dart';

class GroupMessageAppBar extends StatefulWidget {
  final String roomId;
  final String groupName;
  final String groupImage;
  final ChatController controller;

  const GroupMessageAppBar({
    super.key,
    required this.roomId,
    required this.groupName,
    required this.groupImage,
    required this.controller,
  });

  @override
  State<GroupMessageAppBar> createState() => _GroupMessageAppBarState();
}

class _GroupMessageAppBarState extends State<GroupMessageAppBar> {
  final GroupController groupController = Get.put(GroupController());
  late String _currentGroupName;
  late String _currentGroupImage;

  @override
  void initState() {
    super.initState();
    _currentGroupName = widget.groupName;
    _currentGroupImage = widget.groupImage;
  }

  String _buildImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().isEmpty) return '';
    final imgStr = rawImage.toString();
    if (imgStr.startsWith('http')) return imgStr;
    final cleanPath = imgStr.replaceAll('\\', '/');
    return '${ApiUrl.baseUrl}/$cleanPath';
  }

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
          '${'leave_group_confirmation'.tr} "$_currentGroupName"?',
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
              onPressed: widget.controller.isLeavingGroup.value
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      widget.controller.leaveGroup(
                        roomId: widget.roomId,
                        context: context,
                        navigateBack: true,
                      );
                    },
              child: widget.controller.isLeavingGroup.value
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

  void _showEditGroupDialog(BuildContext context) {
    groupController.groupNameController.text = _currentGroupName;
    groupController.groupImageFile.value = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Group Info',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Group Image Picker
                GestureDetector(
                  onTap: () async {
                    await groupController.pickGroupImage();
                  },
                  child: Obx(() {
                    final imageFile = groupController.groupImageFile.value;
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile)
                              : (_currentGroupImage.isNotEmpty
                                  ? NetworkImage(_buildImageUrl(_currentGroupImage))
                                  : null) as ImageProvider?,
                          child: imageFile == null && _currentGroupImage.isEmpty
                              ? const Icon(
                                  Icons.group,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 20),
                // Group Name text field
                TextField(
                  controller: groupController.groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
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
            Obx(() {
              final isUpdating = groupController.isUpdatingGroup.value;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isUpdating
                    ? null
                    : () async {
                        final result = await groupController.updateGroup(
                          roomId: widget.roomId,
                          context: context,
                        );
                        if (result != null && ctx.mounted) {
                          setState(() {
                            _currentGroupName =
                                groupController.groupNameController.text.trim();
                            // Update image URL if returned from the API
                            final newImage = result['image'] ??
                                result['avatar'] ??
                                result['room']?['image'] ??
                                result['room']?['avatar'];
                            if (newImage != null) {
                              _currentGroupImage = newImage.toString();
                            }
                          });
                          Navigator.pop(ctx);
                        }
                      },
                child: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        'Update',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            }),
          ],
        );
      },
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
                backgroundImage: _currentGroupImage.isNotEmpty
                    ? NetworkImage(_buildImageUrl(_currentGroupImage))
                    : null,
                child: _currentGroupImage.isEmpty
                    ? CircleAvatar(
                        radius: ResponsiveHelper.borderRadius(22),
                        backgroundImage: NetworkImage(AppConst.unknown),
                      )
                    : null,
              ),
              SizedBox(width: ResponsiveHelper.spacing(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentGroupName,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
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
                context.pushNamed(RouteName.addMemberScreen, extra: widget.roomId);
              } else if (value == "SeeMembers") {
                context.pushNamed(
                  RouteName.groupMemberScreen,
                  extra: {'roomId': widget.roomId, 'groupName': _currentGroupName},
                );
              } else if (value == "EditGroup") {
                _showEditGroupDialog(context);
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

              // ── Edit Group ───────────────────────────────
              PopupMenuItem<String>(
                value: "EditGroup",
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: AppColors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Group',
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
