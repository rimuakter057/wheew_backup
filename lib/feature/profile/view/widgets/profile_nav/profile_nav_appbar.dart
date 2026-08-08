import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';

import '../../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../../utils/color/app_colors.dart';
import '../../../../../utils/language/app_string.dart';

class ProfileNavAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProfileNavAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBlue,
      elevation: 0,
      title: Text(
        AppStrings.profile.tr,
        style: GoogleFonts.poppins(
          color: const Color(0xFF1A1D20),
          fontWeight: FontWeight.w600,

          fontSize: ResponsiveHelper.titleFontSize(18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            context.push(RoutePath.notification);
          },
          child: Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.padding(16),
            ),
            child: Obx(() {
              final notificationCtrl = Get.find<NotificationController>();
              final count = notificationCtrl.unreadCount.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: ResponsiveHelper.height(38),
                    width: ResponsiveHelper.height(38),
                    padding: ResponsiveHelper.all(7),
                    decoration:  BoxDecoration(
                      color: AppColors.white.withOpacity(0.5),
                      border: Border.all(color: AppColors.white),
                      shape: BoxShape.circle,
                    ),
                    child: CustomImage(
                      imageSrc: AssetsPath.notificationMap,
                      height: ResponsiveHelper.iconSize(16),
                      width: ResponsiveHelper.iconSize(16),
                      boxFit: BoxFit.contain,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration:  BoxDecoration(
                          gradient:AppColors.buttonGradient ,
                          border: Border.all(color: AppColors.white),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.white,
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
      ],
    );
  }
}

