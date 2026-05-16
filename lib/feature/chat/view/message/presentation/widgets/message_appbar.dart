// widgets/message_app_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/color/app_colors.dart';



class MessageAppBar extends StatelessWidget {
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;
  final ChatController chatController;
  final VoidCallback onRateTap;
  final VoidCallback onProfileTap; // ✅ add করো

  const MessageAppBar({
    super.key,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.receiverId,
    required this.chatController,
    required this.onRateTap, required this.onProfileTap,
  });

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
          // ── Back + Avatar + Name ────────────────────────
          Row(
            children: [
              IconButton(
                onPressed: () {
                  chatController.page.value = 1;
                  chatController.fetchChatList(refresh: false);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: AppColors.black),
              ),
              CircleAvatar(
                radius: ResponsiveHelper.borderRadius(22),
                backgroundImage: NetworkImage(
                  ImageHandler.imagesHandle(
                    otherUserAvatar,
                    isProfile: true,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(12)),
              Text(
                otherUserName,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          // ── Popup Menu ──────────────────────────────────
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.black),
            onSelected: (value) async {
              if (value == "Block") {
                chatController.block(receiverId, context);
                chatController.isBlockedByMe.value = true;
              } else if (value == "Unblock") {
                chatController.unBlock(receiverId, context);
                chatController.isBlockedByMe.value = false;
              } else if (value == "Rate") {
                onRateTap();
              }  else if (value == "ViewProfile") {
                onProfileTap();
              }
            },
            itemBuilder: (context) => [
              // View Profile
              PopupMenuItem<String>(
                value: "ViewProfile",
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        color: AppColors.black),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    Text('view_profile'.tr),
                  ],
                ),
              ),
              // Rate
              PopupMenuItem<String>(
                value: "Rate",
                child: Row(
                  children: [
                    Icon(Icons.star_rate_outlined, color: Colors.black),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    Text('rate_user'.tr),
                  ],
                ),
              ),
              // Block / Unblock
              PopupMenuItem<String>(
                value: chatController.isBlockedByMe.value
                    ? "Unblock"
                    : "Block",
                child: Obx(
                      () => Row(
                    children: [
                      Icon(
                        chatController.isBlockedByMe.value
                            ? Icons.lock_open
                            : Icons.block,
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(8)),
                      Text(
                        chatController.isBlockedByMe.value
                            ? "unblock".tr
                            : "block_".tr,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}