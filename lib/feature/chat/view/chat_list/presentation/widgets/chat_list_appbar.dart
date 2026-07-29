//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:platchatapp/core/router/route_path.dart';
// import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/share/widgets/custom_image/custom_image.dart';
// import 'package:platchatapp/utils/assets_path/assets_path.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
//   /// Create group button tap হলে এই callback call হয়
//   final VoidCallback onCreateGroupTap;
//   final VoidCallback onTapSearch;
//   final VoidCallback messageRequest;
//   final  VoidCallback onScanTap;
//
//    ChatListAppBar({
//     super.key,
//     required this.onCreateGroupTap,  required this.onScanTap, required this.onTapSearch, required this.messageRequest,
//   });
//
//   final NotificationController notificationController =
//   Get.find<NotificationController>();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: AppColors.lightBlue,
//       centerTitle: true,
// leading: Padding(
//   padding:  EdgeInsets.only(left:ResponsiveHelper.padding(12)),
//   child: GestureDetector(
//     onTap: onScanTap,
//     child: IconBgContainer(
//       icon:  AssetsPath.scannerTop,
//     ),
//   ),
// ),
//
//
//       // title: Image.asset(
//       //
//       //   AssetsPath.wheew,
//       //
//       //   width:ResponsiveHelper.iconSize(200),
//       //   height: ResponsiveHelper.iconSize(50),
//       //
//       // ),
//       //
//
//
//
//
//
//       actions: [
//
// ///search=========================
//         GestureDetector(
//             onTap: onTapSearch,
//             child: IconBgContainer(icon: AssetsPath.searchNav,)),
//         ///notification=======================
//         // GestureDetector(
//         //   onTap: () => context.push(RoutePath.notification),
//         //   child: Padding(
//         //     padding: EdgeInsets.only(
//         //       right: ResponsiveHelper.width(10),
//         //     ),
//         //     child: Obx(() {
//         //       final count = notificationController.unreadCount.value;
//         //       return Stack(
//         //         clipBehavior: Clip.none,
//         //         children: [
//         //           CircleAvatar(
//         //             radius: ResponsiveHelper.iconSize(18),
//         //             backgroundColor: AppColors.greyShade,
//         //             child: const Icon(
//         //               Icons.notifications_none_rounded,
//         //               color: AppColors.blue,
//         //               size: 20,
//         //             ),
//         //           ),
//         //           if (count > 0)
//         //             Positioned(
//         //               top: -2,
//         //               right: -2,
//         //               child: Container(
//         //                 padding: const EdgeInsets.all(4),
//         //                 decoration: const BoxDecoration(
//         //                   color: Color(0xFF2F80ED),
//         //                   shape: BoxShape.circle,
//         //                 ),
//         //                 child: Text(
//         //                   '$count',
//         //                   style: const TextStyle(
//         //                     fontSize: 8,
//         //                     color: Colors.white,
//         //                     fontWeight: FontWeight.bold,
//         //                   ),
//         //                 ),
//         //               ),
//         //             ),
//         //         ],
//         //       );
//         //     }),
//         //   ),
//         // ),
//         ///message request==================================
//         SizedBox(width: ResponsiveHelper.width(4),),
//         GestureDetector(
//             onTap: messageRequest,
//             child: IconBgContainer(icon: AssetsPath.messageRequest,)),
//
//
//         ///group=====================================
//
//         // GestureDetector(
//         //   onTap: onCreateGroupTap,
//         //   child: Padding(
//         //     padding: EdgeInsets.only(
//         //       right: ResponsiveHelper.width(10),
//         //     ),
//         //     child: CircleAvatar(
//         //       radius: ResponsiveHelper.iconSize(25),
//         //       backgroundColor: AppColors.greyShade,
//         //       child: CustomImage(
//         //         imageSrc: AssetsPath.group,
//         //         height: ResponsiveHelper.iconSize(25),
//         //         width: ResponsiveHelper.iconSize(25),
//         //       ),
//         //     ),
//         //   ),
//         // ),
//
//
// SizedBox(width: ResponsiveHelper.width(4),),
//         Padding(
//           padding:  EdgeInsets.only(right:12),
//           child: GestureDetector(
//               onTap: onCreateGroupTap,
//               child: IconBgContainer(icon: AssetsPath.group,)),
//         ),
//
//
//
//       ],
//
//
//
//
//     );
//   }
//
//   /// AppBar এর height ঠিক রাখার জন্য
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
// class IconBgContainer extends StatelessWidget {
//   const IconBgContainer({
//     super.key, required this.icon,
//   });
//
//   final String icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: ResponsiveHelper.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.greyBg,
//        border: Border.all(color: AppColors.white),
//        shape: BoxShape.circle,
//       ),
//       child: Center(
//               child: SvgPicture.asset(
//                icon,
//                     height: ResponsiveHelper.iconSize(18),
//                       width:  ResponsiveHelper.iconSize(18),
//               ),
//             ),
//     );
//   }
// }













import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_image/custom_image.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCreateGroupTap;
  final VoidCallback onTapSearch;
  final VoidCallback messageRequest;
  final VoidCallback onScanTap;

  ChatListAppBar({
    super.key,
    required this.onCreateGroupTap,
    required this.onScanTap,
    required this.onTapSearch,
    required this.messageRequest,
  });

  final NotificationController notificationController =
  Get.find<NotificationController>();
  final MessageController messageController = Get.find<MessageController>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBlue,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.only(left: ResponsiveHelper.padding(12)),
        child: GestureDetector(
          onTap: onScanTap,
          child: IconBgContainer(
            icon: AssetsPath.scannerTop,
          ),
        ),
      ),
      actions: [
        /// search
        GestureDetector(
          onTap: onTapSearch,
          child: IconBgContainer(icon: AssetsPath.searchNav),
        ),

        SizedBox(width: ResponsiveHelper.width(4)),

        /// message request — এখন count badge app bar icon-এর উপরেই দেখাবে
        /// message request
        GestureDetector(
          onTap: messageRequest,
          child: Obx(() {
            final count = messageController.totalRequestsCount.value;
            return IconBgContainer(
              icon: AssetsPath.messageRequest,
              badgeCount: count,
            );
          }),
        ),

        SizedBox(width: ResponsiveHelper.width(4)),

        /// group — "+" overlay
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onCreateGroupTap,
            child: IconBgContainer(
              icon: AssetsPath.group,
              showAddOverlay: true,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class IconBgContainer extends StatelessWidget {
  const IconBgContainer({
    super.key,
    required this.icon,
    this.badgeCount,
    this.showAddOverlay = false,
  });

  final String icon;

  /// Notification-style number badge
  final int? badgeCount;

  /// দেখাবে কিনা blue "+" circle (group icon-এর জন্য)
  final bool showAddOverlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: ResponsiveHelper.all(8),
          decoration: BoxDecoration(
            color: AppColors.greyBg,
            border: Border.all(color: AppColors.white),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              height: ResponsiveHelper.iconSize(18),
              width: ResponsiveHelper.iconSize(18),
            ),
          ),
        ),

        /// Count badge — icon container-এর কোণায় (edge-এর উপর বসে থাকবে)
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount! > 99 ? '99+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),

        /// "+" overlay — blue circle + white border, icon-এর edge এ বসানো
        if (showAddOverlay)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.add,
                size: ResponsiveHelper.iconSize(12),
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}