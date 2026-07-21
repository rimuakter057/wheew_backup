// widgets/chat_list_app_bar.dart
// ── দায়িত্ব: AppBar — logo (Lottie + image) + create group circle button ──

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_image/custom_image.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Create group button tap হলে এই callback call হয়
  final VoidCallback onCreateGroupTap;

  final  VoidCallback onScanTap;

   ChatListAppBar({
    super.key,
    required this.onCreateGroupTap,  required this.onScanTap,
  });

  final NotificationController notificationController =
  Get.find<NotificationController>();


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      centerTitle: true,
leading: GestureDetector(
  onTap: onScanTap,
  child: Center(
          child: SvgPicture.asset(
            AssetsPath.scanChat,
                height: ResponsiveHelper.iconSize(24),
                  width:  ResponsiveHelper.iconSize(24),
          ),
        ),
),


      title: Image.asset(

        AssetsPath.wheew,

        width:ResponsiveHelper.iconSize(200),
        height: ResponsiveHelper.iconSize(50),

      ),
      





      actions: [
        GestureDetector(
          onTap: () => context.push(RoutePath.notification),
          child: Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.width(10),
            ),
            child: Obx(() {
              final count = notificationController.unreadCount.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: ResponsiveHelper.iconSize(18),
                    backgroundColor: AppColors.greyShade,
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.blue,
                      size: 20,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F80ED),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
        GestureDetector(
          onTap: onCreateGroupTap,
          child: Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.width(10),
            ),
            child: CircleAvatar(
              radius: ResponsiveHelper.iconSize(25),
              backgroundColor: AppColors.greyShade,
              child: CustomImage(
                imageSrc: AssetsPath.group,
                height: ResponsiveHelper.iconSize(25),
                width: ResponsiveHelper.iconSize(25),
              ),
            ),
          ),
        ),

      ],




    );
  }

  /// AppBar এর height ঠিক রাখার জন্য
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}