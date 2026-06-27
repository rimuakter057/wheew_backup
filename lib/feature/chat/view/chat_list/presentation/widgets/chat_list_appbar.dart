// widgets/chat_list_app_bar.dart
// ── দায়িত্ব: AppBar — logo (Lottie + image) + create group circle button ──

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/router/routes_name.dart';
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

     // leadingWidth: ResponsiveHelper.width(130),

      // leading: GestureDetector(
      //   onTap: onScanTap,
      //   child: Padding(
      //     padding: EdgeInsets.only(left: ResponsiveHelper.width(12)),
      //     child:       CustomImage(imageSrc: AssetsPath.scanCommon,
      //
      //       height: ResponsiveHelper.height(24),
      //       width: ResponsiveHelper.height(24),
      //       boxFit: BoxFit.contain,
      //     ),
      //
      //   ),
      // ),


      //leading: IconButton(onPressed: onScanTap, icon: Icon(Icons.document_scanner_outlined,color: AppColors.blue,)),

      leading: GestureDetector(
        onTap: onScanTap,

        child: Container(
          margin: EdgeInsets.only(left: ResponsiveHelper.width(12)),
          width: ResponsiveHelper.iconSize(60),
          height:ResponsiveHelper.iconSize(60),
          decoration: BoxDecoration(
            color: AppColors.greyBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
            //  'assets/icons/searching-car.png',
              AssetsPath.searchCar,
              width:ResponsiveHelper.iconSize(30),
              height: ResponsiveHelper.iconSize(30),

            ),
          ),
        ),
      ),


      title: Image.asset(

        AssetsPath.wheew,
        width:ResponsiveHelper.iconSize(200),
        height: ResponsiveHelper.iconSize(50),

      ),
      
      // title: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     Lottie.asset(
      //       AssetsPath.homeJson,
      //       width: ResponsiveHelper.iconSize(28),
      //       height: ResponsiveHelper.iconSize(28),
      //       fit: BoxFit.cover,
      //       repeat: true,
      //     ),
      //     SizedBox(width: ResponsiveHelper.spacing(6)),
      //     CustomImage(
      //       imageSrc: AssetsPath.chatList,
      //       height: ResponsiveHelper.height(28),
      //       fit: BoxFit.contain,
      //     ),
      //   ],
      // ),





      actions: [

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
        // Obx(
        //       () => GestureDetector(
        //     onTap: () {
        //       context.pushNamed(RouteName.notification);
        //     },
        //     child: Padding(
        //       padding: EdgeInsets.only(
        //         right: ResponsiveHelper.width(16),
        //       ),
        //       child: Stack(
        //         clipBehavior: Clip.none,
        //         children: [
        //           Icon(
        //             Icons.notifications_outlined,
        //             color: AppColors.blue,
        //             size: ResponsiveHelper.iconSize(32),
        //           ),
        //
        //           if (notificationController.unreadCount.value > 0)
        //             Positioned(
        //               right: -2,
        //               top: -1,
        //               child: Container(
        //                 padding: const EdgeInsets.symmetric(
        //                   horizontal: 5,
        //                   vertical: 2,
        //                 ),
        //                 decoration: BoxDecoration(
        //                   color: AppColors.blue,
        //                   borderRadius: BorderRadius.circular(20),
        //                 ),
        //                 constraints: const BoxConstraints(
        //                   minWidth: 18,
        //                   minHeight: 18,
        //                 ),
        //                 child: Text(
        //                   notificationController.unreadCount.value > 9
        //                       ? "9+"
        //                       : notificationController.unreadCount.value.toString(),
        //                   textAlign: TextAlign.center,
        //                   style: const TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 10,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],




    );
  }

  /// AppBar এর height ঠিক রাখার জন্য
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}