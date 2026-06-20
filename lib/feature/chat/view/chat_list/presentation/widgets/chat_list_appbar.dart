// widgets/chat_list_app_bar.dart
// ── দায়িত্ব: AppBar — logo (Lottie + image) + create group circle button ──

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_image/custom_image.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Create group button tap হলে এই callback call হয়
  final VoidCallback onCreateGroupTap;

  final  VoidCallback onPlateScanTap;

  const ChatListAppBar({
    super.key,
    required this.onCreateGroupTap,  required this.onPlateScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      centerTitle: true,

     // leadingWidth: ResponsiveHelper.width(130),

      leading: GestureDetector(
        onTap: onPlateScanTap,
        child: Padding(
          padding: EdgeInsets.only(left: ResponsiveHelper.width(12)),
          child:       CustomImage(imageSrc: "assets/icons/scan_ocr.png",
              sizeWidth:64,

          ),

        ),
      ),


      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            AssetsPath.homeJson,
            width: ResponsiveHelper.iconSize(28),
            height: ResponsiveHelper.iconSize(28),
            fit: BoxFit.cover,
            repeat: true,
          ),
          SizedBox(width: ResponsiveHelper.spacing(6)),
          CustomImage(
            imageSrc: AssetsPath.chatList,
            height: ResponsiveHelper.height(28),
            fit: BoxFit.contain,
          ),
        ],
      ),

      // ── Right: Create group circle button ────────────────
      actions: [
        GestureDetector(
          onTap: onCreateGroupTap,
          child: Padding(
            padding:
            EdgeInsets.only(right: ResponsiveHelper.width(16)),
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