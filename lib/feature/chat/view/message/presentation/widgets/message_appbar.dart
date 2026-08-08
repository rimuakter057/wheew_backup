// // widgets/message_app_bar.dart
//
// import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
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
//   final VoidCallback onProfileTap; // âœ… add à¦•à¦°à§‹
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
//           // -- Back + Avatar + Name ------------------------
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
//                         color: isTyping ? AppColors.blue : AppColors.grey,
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ],
//           ),
//
//           // -- Popup Menu ----------------------------------
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
//                     Icon(Icons.star_rate_outlined, color: AppColors.black),
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
  final String? licenceId;
  final bool? isVerified;

  const MessageAppBar({

    super.key,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.receiverId,
    required this.chatController,
    required this.onRateTap,
    required this.onProfileTap,
    this.licenceId,
    this.isVerified,
  });

  // âœ… AppBar à¦¹à¦¿à¦¸à§‡à¦¬à§‡ à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à¦¤à§‡ PreferredSize à¦¦à¦°à¦•à¦¾à¦°
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 18);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF1F5F9),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        otherUserName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(15),
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    if (isVerified == true) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        color: AppColors.blue,
                        size: ResponsiveHelper.iconSize(16),
                      ),
                    ],
                  ],
                ),
                if (licenceId != null && licenceId!.isNotEmpty)
                  Text(
                    licenceId!,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(12),
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyShade600,
                    ),
                  )
                else
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
                        fontSize: ResponsiveHelper.fontSize(12),
                        fontWeight: FontWeight.w400,
                        color: isTyping ? AppColors.blue : AppColors.greyShade600,
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
          color: AppColors.transparent,
          elevation: 0,
          offset: Offset(0, ResponsiveHelper.height(40)),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              padding: EdgeInsets.zero,
              enabled: false,
              child: Container(
                width: 170,
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
                    // -- View Profile ------------------------------
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onProfileTap();
                      },
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CustomImage(
                              imageSrc: AssetsPath.viewProfile,
                              imageColor: AppColors.blu,
                              width: ResponsiveHelper.iconSize(22),
                              height: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(12)),
                            Text(
                              AppStrings.viewProfile.tr,
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

               InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onRateTap();
                      },
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CustomImage(
                              imageSrc: AssetsPath.rateUser,
                              imageColor: AppColors.blue,
                              width: ResponsiveHelper.iconSize(22),
                              height: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(12)),
                            Text(
                              AppStrings.rateUser.tr,
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

                Obx(
                      () => InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (chatController.isBlockedByMe.value) {
                            chatController.unBlock(receiverId, context);
                            chatController.isBlockedByMe.value = false;
                          } else {
                            chatController.block(receiverId, context);
                            chatController.isBlockedByMe.value = true;
                          }
                        },
                        child: Padding(
                          padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              chatController.isBlockedByMe.value
                                  ? Icon(
                                      Icons.lock_open_rounded,
                                      color: AppColors.blue,
                                      size: ResponsiveHelper.iconSize(22),
                                    )
                                  : CustomImage(
                                      imageSrc: AssetsPath.blockedIcon,
                                      imageColor: AppColors.blue,
                                      width: ResponsiveHelper.iconSize(22),
                                      height: ResponsiveHelper.iconSize(22),
                                    ),
                              SizedBox(width: ResponsiveHelper.spacing(12)),
                              Text(
                                chatController.isBlockedByMe.value
                                    ? AppStrings.unblock.tr
                                    : AppStrings.blockUserAction.tr,
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


