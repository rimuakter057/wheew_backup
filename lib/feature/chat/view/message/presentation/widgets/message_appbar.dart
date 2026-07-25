// // widgets/message_app_bar.dart
//
// import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart' hide Config;
// import 'package:platchatapp/core/router/route_path.dart';
// import 'package:platchatapp/core/router/routes_name.dart';
// import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
// import 'package:platchatapp/feature/main/data/main_nav_.dart';
// import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
// import 'package:platchatapp/helper/image_handler/image_handler.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// import '../../../../../../core/router/routes.dart';
//
//
//
// class MessageAppBar extends StatelessWidget {
//   final String otherUserName;
//   final String? otherUserAvatar;
//   final String receiverId;
//   final ChatController chatController;
//   final VoidCallback onRateTap;
//   final VoidCallback onProfileTap; // ✅ add করো
//
//   const MessageAppBar({
//     super.key,
//     required this.otherUserName,
//     required this.otherUserAvatar,
//     required this.receiverId,
//     required this.chatController,
//     required this.onRateTap, required this.onProfileTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomContainer(
//       margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
//       vertical: ResponsiveHelper.padding(16),
//       horizontal: ResponsiveHelper.padding(0),
//       backgroundColor: AppColors.greyShade,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // ── Back + Avatar + Name ────────────────────────
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () async{
//                   chatController.page.value = 1;
//                   chatController.fetchChatList(refresh: false);
//
//                   mainNavIndex.value = 2;
//
//                  Navigator.pop(context);
//
//                 },
//                 icon: Icon(Icons.arrow_back, color: AppColors.black),
//               ),
//               CircleAvatar(
//                 radius: ResponsiveHelper.borderRadius(22),
//                 backgroundImage: NetworkImage(
//                   ImageHandler.imagesHandle(
//                     otherUserAvatar,
//                     isProfile: true,
//                   ),
//                 ),
//               ),
//               SizedBox(width: ResponsiveHelper.spacing(12)),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     otherUserName,
//                     style: GoogleFonts.poppins(
//                       fontSize: ResponsiveHelper.fontSize(16),
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.black,
//                     ),
//                   ),
//                   Obx(() {
//                     final bool isTyping = chatController.isTyping.value;
//                     return Text(
//                       isTyping ? AppStrings.typing.tr : AppStrings.online.tr,
//                       style: GoogleFonts.poppins(
//                         fontSize: ResponsiveHelper.fontSize(12),
//                         fontWeight: FontWeight.w400,
//                         color: isTyping ? AppColors.blue : Colors.grey,
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ],
//           ),
//
//           // ── Popup Menu ──────────────────────────────────
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert, color: AppColors.black),
//             onSelected: (value) async {
//               if (value == "Block") {
//                 chatController.block(receiverId, context);
//                 chatController.isBlockedByMe.value = true;
//               } else if (value == "Unblock") {
//                 chatController.unBlock(receiverId, context);
//                 chatController.isBlockedByMe.value = false;
//               } else if (value == "Rate") {
//                 onRateTap();
//               }  else if (value == "ViewProfile") {
//                 onProfileTap();
//               }
//             },
//             itemBuilder: (context) => [
//               // View Profile
//               PopupMenuItem<String>(
//                 value: "ViewProfile",
//                 child: Row(
//                   children: [
//                     Icon(Icons.person_outline_rounded,
//                         color: AppColors.black),
//                     SizedBox(width: ResponsiveHelper.spacing(8)),
//                     Text(AppStrings.viewProfile.tr),
//                   ],
//                 ),
//               ),
//               // Rate
//               PopupMenuItem<String>(
//                 value: "Rate",
//                 child: Row(
//                   children: [
//                     Icon(Icons.star_rate_outlined, color: Colors.black),
//                     SizedBox(width: ResponsiveHelper.spacing(8)),
//                     Text(AppStrings.rateUser.tr),
//                   ],
//                 ),
//               ),
//               // Block / Unblock
//               PopupMenuItem<String>(
//                 value: chatController.isBlockedByMe.value
//                     ? "Unblock"
//                     : "Block",
//                 child: Obx(
//                       () => Row(
//                     children: [
//                       Icon(
//                         chatController.isBlockedByMe.value
//                             ? Icons.lock_open
//                             : Icons.block,
//                       ),
//                       SizedBox(width: ResponsiveHelper.spacing(8)),
//                       Text(
//                         chatController.isBlockedByMe.value
//                             ? AppStrings.unblock.tr
//                             : AppStrings.blocked.tr,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


// widgets/message_app_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../../../../core/router/routes.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;
  final ChatController chatController;
  final VoidCallback onRateTap;
  final VoidCallback onProfileTap;

  const MessageAppBar({
    super.key,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.receiverId,
    required this.chatController,
    required this.onRateTap,
    required this.onProfileTap,
  });

  // ✅ AppBar হিসেবে ব্যবহার করতে PreferredSize দরকার
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 18);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF1F5F9),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: preferredSize.height,
      title: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              chatController.page.value = 1;
              chatController.fetchChatList(refresh: false);
              mainNavIndex.value = 2;
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
            backgroundImage: NetworkImage(
              ImageHandler.imagesHandle(
                otherUserAvatar,
                isProfile: true,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.spacing(10)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Obx(() {
                  final bool isTyping = chatController.isTyping.value;
                  final bool isOnline =
                      chatController.onlineUsersMap[receiverId] ?? false;
                  final String statusText = isTyping
                      ? AppStrings.typing.tr
                      : (isOnline ? AppStrings.online.tr : AppStrings.offline.tr);
                  return Text(
                    statusText,
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
          padding: EdgeInsets.zero,
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
            } else if (value == "ViewProfile") {
              onProfileTap();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: "ViewProfile",
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: AppColors.black),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  Text(AppStrings.viewProfile.tr),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: "Rate",
              child: Row(
                children: [
                  Icon(Icons.star_rate_outlined, color: Colors.black),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  Text(AppStrings.rateUser.tr),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: chatController.isBlockedByMe.value ? "Unblock" : "Block",
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
                          ? AppStrings.unblock.tr
                          : AppStrings.blocked.tr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
      ],
    );
  }
}