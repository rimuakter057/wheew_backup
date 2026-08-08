import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/controller/group_controller.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class GroupMessageAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight + ResponsiveHelper.height(18));

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

  /// leave group==============================

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
          AppStrings.leaveGroup.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          '${AppStrings.leaveGroupConfirmation.tr} "$_currentGroupName"?',
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
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                color: AppColors.grey,
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
                  ? SizedBox(
                width: ResponsiveHelper.width(16),
                height: ResponsiveHelper.height(16),
                child: CircularProgressIndicator(
                  strokeWidth: ResponsiveHelper.borderWidth(2),
                  color: AppColors.red,
                ),
              )
                  : Text(
                AppStrings.leave.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(14),
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

  /// edit group=======================================
  void _showEditGroupDialog(BuildContext context) {
    groupController.groupNameController.text = _currentGroupName;
    groupController.groupImageFile.value = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.containerGradient,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(28)),
            ),
          ),
          padding: EdgeInsets.only(
            left: ResponsiveHelper.padding(24),
            right: ResponsiveHelper.padding(24),
            top: ResponsiveHelper.padding(12),
            bottom: MediaQuery.of(ctx).viewInsets.bottom + ResponsiveHelper.padding(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle bar
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(40),
                    height: ResponsiveHelper.height(4),
                    decoration: BoxDecoration(
                      color: AppColors.black26,
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(2)),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),

                // Title
                Text(
                  AppStrings.editGroupChat.tr,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSize(20),
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),

                // Profile Picture Picker
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      await groupController.pickGroupImage();
                    },
                    child: Obx(() {
                      final imageFile = groupController.groupImageFile.value;
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: ResponsiveHelper.width(45),
                            backgroundColor: AppColors.greyShade300,
                            backgroundImage: imageFile != null
                                ? FileImage(imageFile)
                                : (_currentGroupImage.isNotEmpty
                                ? NetworkImage(_buildImageUrl(_currentGroupImage))
                                : null) as ImageProvider?,
                            child: imageFile == null && _currentGroupImage.isEmpty
                                ? Icon(
                              Icons.group,
                              size: ResponsiveHelper.iconSize(45),
                              color: AppColors.greyShade500,
                            )
                                : null,
                          ),
                          // Small camera icon badge
                          Container(
                            padding: ResponsiveHelper.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: ResponsiveHelper.iconSize(16),
                              color: const Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),

                // Group Name Label
                Text(
                  AppStrings.groupName.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),

                // Group Name Input Field with Icon
                TextField(
                  controller: groupController.groupNameController,
                  style: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(15)),
                  decoration: InputDecoration(
                    hintText: AppStrings.groupNameHint.tr,
                    hintStyle: GoogleFonts.poppins(color: AppColors.greyShade500),
                    prefixIcon: Icon(
                      Icons.people_outline_rounded,
                      color: const Color(0xFF1565C0),
                      size: ResponsiveHelper.iconSize(20),
                    ),
                    filled: true,
                    fillColor: AppColors.white.withValues(alpha: 0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: ResponsiveHelper.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(28)),

                // Save & Change Button (CustomGradientButton)
                Obx(() {
                  final isUpdating = groupController.isUpdatingGroup.value;
                  return CustomGradientButton(
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
                    isLoading: isUpdating,
                    child: Text(
                      AppStrings.saveAndChange.tr,
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.fontSize(16),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: widget.preferredSize.height,
      title: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left,
              size: ResponsiveHelper.fontSize(28),
              color: AppColors.black,
            ),
          ),
          CircleAvatar(
            radius: ResponsiveHelper.borderRadius(20),
            backgroundColor: AppColors.blue.withOpacity(0.2),
            backgroundImage: _currentGroupImage.isNotEmpty
                ? NetworkImage(_buildImageUrl(_currentGroupImage))
                : null,
            child: _currentGroupImage.isEmpty
                ? CircleAvatar(
              radius: ResponsiveHelper.borderRadius(20),
              backgroundColor: AppColors.greyBorder,
              child: SvgPicture.asset(
                'assets/icons/group_chat.svg',
                width: ResponsiveHelper.borderRadius(20),
                height: ResponsiveHelper.borderRadius(20),
              ),
            )
                : null,
          ),
          SizedBox(width: ResponsiveHelper.spacing(10)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentGroupName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Obx(() {
                  final bool isTyping = widget.controller.isTyping.value;
                  return Text(
                    isTyping ? AppStrings.typing.tr : AppStrings.group.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(13),
                      fontWeight: FontWeight.w400,
                      color: isTyping ? AppColors.blue : AppColors.grey,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [

        PopupMenuButton<String>(
          padding: EdgeInsets.only(right: ResponsiveHelper.width(8)),
          icon: Icon(Icons.more_vert, color: AppColors.black),
          color: AppColors.transparent, // à¦†à¦¸à¦² color transparent-à¦‡ à¦¥à¦¾à¦•à¦¬à§‡, gradient Container à¦¦à¦¿à¦¯à¦¼à§‡ à¦¦à§‡à¦“à¦¯à¦¼à¦¾ à¦¹à¦¬à§‡
          // elevation: 6 added a second (Material default) drop shadow on
          // top of the Container's own boxShadow below — the double shadow
          // showed up as an unwanted grey halo around the popup.
          elevation: 0,
          offset: Offset(-ResponsiveHelper.width(36), ResponsiveHelper.height(40)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ResponsiveHelper.borderRadius(24)),
              bottomLeft: Radius.circular(ResponsiveHelper.borderRadius(24)),
              bottomRight: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
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
            PopupMenuItem<String>(
              padding: EdgeInsets.zero,
              enabled: false, // à¦ªà§à¦°à§‹ item à¦à¦° tap à¦¬à¦¨à§à¦§, à¦­à§‡à¦¤à¦°à§‡à¦° InkWell à¦—à§à¦²à§‹ à¦•à¦¾à¦œ à¦•à¦°à¦¬à§‡
              child: Container(
                width: 175,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: ResponsiveHelper.symmetric(vertical: 8, horizontal: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // â”€â”€ See Members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(
                          RouteName.groupMemberScreen,
                          extra: {'roomId': widget.roomId, 'groupName': _currentGroupName},
                        );
                      },
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CustomImage(
                              imageSrc: AssetsPath.seeMember,
                              imageColor: AppColors.blue,
                              width: ResponsiveHelper.iconSize(22),
                              height: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(12)),
                            Text(
                              AppStrings.seeMembers.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // â”€â”€ Add Members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(RouteName.addMemberScreen, extra: widget.roomId);
                      },
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CustomImage(
                              imageSrc: AssetsPath.addMember,
                              imageColor: AppColors.blue,
                              width: ResponsiveHelper.iconSize(22),
                              height: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(12)),
                            Text(
                              AppStrings.addMembers.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // â”€â”€ Edit Group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showEditGroupDialog(context);
                      },
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CustomImage(
                              imageSrc: AssetsPath.editGroup,
                              imageColor: AppColors.blue,
                              width: ResponsiveHelper.iconSize(22),
                              height: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(12)),
                            Text(
                              AppStrings.editGroup.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // â”€â”€ Leave Group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showLeaveGroupDialog(context);
                      },
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CustomImage(
                              imageSrc: AssetsPath.leaveGroupIcon,
                              imageColor: const Color(0xFFE53E3E),
                              width: ResponsiveHelper.iconSize(22),
                              height: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(12)),
                            Text(
                              AppStrings.leaveGroup.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFE53E3E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // PopupMenuButton<String>(
        //
        //   padding: EdgeInsets.only(right: ResponsiveHelper.width(8)),
        //   icon: Icon(Icons.more_vert, color: AppColors.black),
        //   color: AppColors.transparent,
        //   elevation: 6,
        // //  offset: Offset(0, ResponsiveHelper.height(40)), // icon-à¦à¦° à¦ à¦¿à¦• à¦¨à¦¿à¦šà§‡ à¦¬à¦¸à¦¬à§‡
        //   offset: Offset(-ResponsiveHelper.width(36), ResponsiveHelper.height(40)),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(ResponsiveHelper.borderRadius(24)),
        //       bottomLeft: Radius.circular(ResponsiveHelper.borderRadius(24)),
        //       bottomRight: Radius.circular(ResponsiveHelper.borderRadius(24)),
        //
        //
        //     ),
        //   ),
        //   onSelected: (value) {
        //     if (value == "AddMembers") {
        //       context.pushNamed(RouteName.addMemberScreen, extra: widget.roomId);
        //     } else if (value == "SeeMembers") {
        //       context.pushNamed(
        //         RouteName.groupMemberScreen,
        //         extra: {'roomId': widget.roomId, 'groupName': _currentGroupName},
        //       );
        //     } else if (value == "EditGroup") {
        //       _showEditGroupDialog(context);
        //     } else if (value == "LeaveGroup") {
        //       _showLeaveGroupDialog(context);
        //     }
        //   },
        //   itemBuilder: (context) => [
        //     // â”€â”€ See Members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        //     PopupMenuItem<String>(
        //       value: "SeeMembers",
        //       height: ResponsiveHelper.height(44),
        //       child: Row(
        //         children: [
        //       CustomImage(imageSrc: AssetsPath.seeMember),
        //           SizedBox(width: ResponsiveHelper.spacing(10)),
        //           Text(
        //             AppStrings.seeMembers.tr,
        //             style: GoogleFonts.poppins(
        //               fontSize: ResponsiveHelper.fontSize(14),
        //               color: AppColors.black,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //
        //     // â”€â”€ Add Members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        //     PopupMenuItem<String>(
        //       value: "AddMembers",
        //       height: ResponsiveHelper.height(44),
        //       child: Row(
        //         children: [
        //           CustomImage(imageSrc: AssetsPath.addMember),
        //           SizedBox(width: ResponsiveHelper.spacing(10)),
        //           Text(
        //             AppStrings.addMembers.tr,
        //             style: GoogleFonts.poppins(
        //               fontSize: ResponsiveHelper.fontSize(14),
        //               color: AppColors.black,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //
        //     // â”€â”€ Edit Group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        //     PopupMenuItem<String>(
        //       value: "EditGroup",
        //       height: ResponsiveHelper.height(44),
        //       child: Row(
        //         children: [
        //           CustomImage(imageSrc: AssetsPath.editGroup),
        //           SizedBox(width: ResponsiveHelper.spacing(10)),
        //           Text(
        //             AppStrings.editGroup.tr,
        //             style: GoogleFonts.poppins(
        //               fontSize: ResponsiveHelper.fontSize(14),
        //               color: AppColors.black,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //
        //     // â”€â”€ Leave Group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        //     PopupMenuItem<String>(
        //       value: "LeaveGroup",
        //       height: ResponsiveHelper.height(44),
        //       child: Row(
        //         children: [
        //           Icon(Icons.exit_to_app_outlined,
        //               size: ResponsiveHelper.iconSize(20),
        //               color: const Color(0xFFFF5722)),
        //           SizedBox(width: ResponsiveHelper.spacing(10)),
        //           Text(
        //             AppStrings.leaveGroup.tr,
        //             style: GoogleFonts.poppins(
        //               fontSize: ResponsiveHelper.fontSize(14),
        //               color: const Color(0xFFFF5722),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),

      ],
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: ResponsiveHelper.iconSize(20), color: color),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                color: color == const Color(0xFFFF5722) ? color : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

}


