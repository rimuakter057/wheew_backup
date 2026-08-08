import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class MapTopBar extends StatelessWidget {
  /// Called when the search pill is tapped.
  final VoidCallback? onSearchTap;

  /// Optional controller — lets the parent pre-fill search hint text.
  final TextEditingController? searchController;

  /// Left / right padding from screen edge (defaults match ParkingShowScreen).
  final double horizontalPadding;

  const MapTopBar({
    super.key,
    this.onSearchTap,
    this.searchController,
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(16),
      left: ResponsiveHelper.padding(horizontalPadding),
      right: ResponsiveHelper.padding(horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -- Search pill --------------------------------------------
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSearchTap,
              child: Builder(
                builder: (context) {
                  final double barHeight = ResponsiveHelper.padding(50);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(barHeight / 2),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(barHeight / 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AbsorbPointer(
                          absorbing: true,
                          child: TextField(
                            readOnly: true,
                            controller: searchController,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(14),
                            ),
                            decoration: InputDecoration(
                              hintText: AppStrings.searchHere.tr,
                              hintStyle: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(14),
                                color: AppColors.grey,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.black,
                                size: ResponsiveHelper.iconSize(20),
                              ),
                              suffixIcon: Icon(
                                Icons.tune,
                                color: AppColors.black,
                                size: ResponsiveHelper.iconSize(20),
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  ResponsiveHelper.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: ResponsiveHelper.spacing(8)),

          // -- Notification bell --------------------------------------
          _NotificationBellButton(),
        ],
      ),
    );
  }
}

/// Notification bell with unread-count badge.
/// Navigates to the notification route on tap.
class _NotificationBellButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RoutePath.notification),
      child: Obx(() {
        final notificationCtrl = Get.find<NotificationController>();
        final count = notificationCtrl.unreadCount.value;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              height: ResponsiveHelper.width(42),
              width: ResponsiveHelper.width(42),
              padding: ResponsiveHelper.all(10),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CustomImage(
                  imageSrc: AssetsPath.notificationMap,
                  height: ResponsiveHelper.height(18),
                  width: ResponsiveHelper.width(18),
                  boxFit: BoxFit.contain,
                ),
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
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.white, width: 1.5),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}


