// widgets/chat_list_app_bar.dart
// ── দায়িত্ব: AppBar — logo (Lottie + image) + create group circle button ──

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/screens/message_requests_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
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
// leading: GestureDetector(
//   onTap: onScanTap,
//   child: Center(
//           child: SvgPicture.asset(
//             AssetsPath.scanChat,
//                 height: ResponsiveHelper.iconSize(24),
//                   width:  ResponsiveHelper.iconSize(24),
//           ),
//         ),
// ),


      title: Image.asset(

        AssetsPath.wheew,

        width:ResponsiveHelper.iconSize(200),
        height: ResponsiveHelper.iconSize(50),

      ),
      





      actions: [
        GestureDetector(
          onTap: () {
            _showMessageRequestOptions(context);
          },
          child: Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.width(10),
            ),
            child: CircleAvatar(
              radius: ResponsiveHelper.iconSize(25),
              backgroundColor: AppColors.greyShade,
              child: const Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.blue,
                size: 20,
              ),
            ),
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

void _showMessageRequestOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                AppStrings.messageRequests.tr,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                  child: const Icon(Icons.inbox_outlined, color: AppColors.blue),
                ),
                title: Text(
                  AppStrings.receivedRequests.tr,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  AppStrings.requestsOthersSentToYou.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(RouteName.messageRequests);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                  child: const Icon(Icons.send_outlined, color: AppColors.blue),
                ),
                title: Text(
                  AppStrings.sentRequests.tr,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  AppStrings.requestsYouSentToOthers.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(RouteName.sendRequests);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}