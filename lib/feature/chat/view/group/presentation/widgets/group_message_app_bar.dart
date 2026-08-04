import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/controller/group_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
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
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel.tr,
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
                  ? SizedBox(
                width: ResponsiveHelper.width(16),
                height: ResponsiveHelper.height(16),
                child: CircularProgressIndicator(
                  strokeWidth: ResponsiveHelper.borderWidth(2),
                  color: Colors.red,
                ),
              )
                  : Text(
                AppStrings.leave.tr,
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

  /// edit group=======================================
  void _showEditGroupDialog(BuildContext context) {
    groupController.groupNameController.text = _currentGroupName;
    groupController.groupImageFile.value = null;

    showDialog(
      context: context,
      barrierDismissible: true, // বাইরে ক্লিক করলে যাতে বন্ধ হয়
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: ResponsiveHelper.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(28)), // ছবির মতো রাউন্ডেড কর্নার
            ),
            padding: ResponsiveHelper.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // টেক্সটগুলো বামে এলাইন করার জন্য
                children: [
                  // Top Indicator and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: ResponsiveHelper.width(32)), // ব্যালেন্স করার জন্য খালি স্পেস
                      // টপ গ্রে লাইন
                      Container(
                        width: ResponsiveHelper.width(40),
                        height: ResponsiveHelper.height(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(2)),
                        ),
                      ),
                      // ক্লোজ (X) বাটন
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: ResponsiveHelper.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: ResponsiveHelper.iconSize(18), color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),

                  // Title
                  Text(
                    AppStrings.editGroupChat.tr,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.fontSize(22),
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(24)),

                  // Profile Picture Label & Image Picker
                  Center(
                    child: Column(
                      children: [
                        Text(
                          AppStrings.profilePicture.tr,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(12)),
                        GestureDetector(
                          onTap: () async {
                            await groupController.pickGroupImage();
                          },
                          child: Obx(() {
                            final imageFile = groupController.groupImageFile.value;
                            return Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                // মেইন ইমেজ বর্ডার (ছবির ব্লু বর্ডার স্টাইল)
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF1976D2), width: ResponsiveHelper.borderWidth(2)),
                                  ),
                                  child: CircleAvatar(
                                    radius: ResponsiveHelper.width(45),
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: imageFile != null
                                        ? FileImage(imageFile)
                                        : (_currentGroupImage.isNotEmpty
                                        ? NetworkImage(_buildImageUrl(_currentGroupImage))
                                        : null)
                                    as ImageProvider?,
                                    child: imageFile == null && _currentGroupImage.isEmpty
                                        ? Icon(
                                      Icons.group,
                                      size: ResponsiveHelper.iconSize(45),
                                      color: Colors.grey.shade400,
                                    )
                                        : null,
                                  ),
                                ),
                                // ছোট ক্যামেরা/ছবি আইকন (সাদা ব্যাকগ্রাউন্ড ও গ্রে বর্ডার)
                                Container(
                                  padding: ResponsiveHelper.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade300, width: ResponsiveHelper.borderWidth(1)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: ResponsiveHelper.iconSize(14),
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(24)),

                  // Group Name Label
                  Text(
                    AppStrings.groupName.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),

                  // Group Name Text Field (ছবির মতো লাইট গ্রে ব্যাকগ্রাউন্ড)
                  TextField(
                    controller: groupController.groupNameController,
                    style: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(15)),
                    decoration: InputDecoration(
                      hintText: AppStrings.groupNameHint.tr,
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F8), // ছবির ভেতরের লাইট গ্রে কালার
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                        borderSide: BorderSide.none, // কোনো বর্ডার আউটলাইন থাকবে না
                      ),
                      contentPadding: ResponsiveHelper.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(32)),

                  // Save & Change Button (ছবির ব্লু বাটন)
                  Obx(() {
                    final isUpdating = groupController.isUpdatingGroup.value;
                    return SizedBox(
                      width: double.infinity, // ফুল উইডথ বাটন
                      height: ResponsiveHelper.height(54),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0), // ছবির মতো রয়েল ব্লু কালার
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(28)), // রাউন্ডেড বাটন
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
                            ? SizedBox(
                          width: ResponsiveHelper.width(24),
                          height: ResponsiveHelper.height(24),
                          child: CircularProgressIndicator(
                            strokeWidth: ResponsiveHelper.borderWidth(2.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          AppStrings.saveAndChange.tr,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
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
                      color: isTyping ? AppColors.blue : Colors.grey,
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
          color: Colors.transparent, // আসল color transparent-ই থাকবে, gradient Container দিয়ে দেওয়া হবে
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
              enabled: false, // পুরো item এর tap বন্ধ, ভেতরের InkWell গুলো কাজ করবে
              child: Container(
                width: 175,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: ResponsiveHelper.symmetric(vertical: 8, horizontal: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── See Members ──────────────────────────────
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

                    // ── Add Members ──────────────────────────────
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

                    // ── Edit Group ───────────────────────────────
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

                    // ── Leave Group ──────────────────────────────
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
        //   color: Colors.transparent,
        //   elevation: 6,
        // //  offset: Offset(0, ResponsiveHelper.height(40)), // icon-এর ঠিক নিচে বসবে
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
        //     // ── See Members ──────────────────────────────
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
        //     // ── Add Members ──────────────────────────────
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
        //     // ── Edit Group ───────────────────────────────
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
        //     // ── Leave Group ──────────────────────────────
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