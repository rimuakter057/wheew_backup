import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/map/presentation/screens/map_screen.dart';
import 'package:platchatapp/feature/notification/presentation/screens/notification_screen.dart';
import 'package:platchatapp/feature/parking/presentation/screens/parking_show_screen.dart';
import 'package:platchatapp/feature/profile/view/screens/profile_nav_screen.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/main.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../utils/color/app_colors.dart';
import '../../../chat/view/chat_list/presentation/screens/chat_list_screen.dart';
import '../../../scan/presentation/screens/scan_screen.dart';


class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 0:
        return const MapScreen();

      case 1:
        return ParkingShowScreen();
      case 2:
        return const ChatListScreen();

      case 3:
        return ProfileNavScreen();
      case 4:
        return ScanScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    mainNavIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return ValueListenableBuilder<int>(
      valueListenable: mainNavIndex,
      builder: (context, currentIndex, _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFFD2DCF0),
          body: _bodyForIndex(currentIndex),
          bottomNavigationBar: _AppBottomNav(
            currentIndex: currentIndex,
            onTap: _onTap,
          ),
        );
      },
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical: ResponsiveHelper.padding(12),
        ),
        child: Row(
          children: [

            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.08),
                color: const Color(0xFFACB9C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(36),
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: ResponsiveHelper.height(72),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 15,
                      sigmaY: 15,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(6),
                      ),
                      child: Row(
                        children: [
                          //home-p-chat-profile-scan
                          _NavItem(
                            icon: AssetsPath.homeNav,
                            label: "home",
                            index: 0,
                            currentIndex: currentIndex,
                            onTap: onTap,
                          ),

                          _NavItem(
                            icon: AssetsPath.pNav,
                            label: "P",
                            index: 1,
                            currentIndex: currentIndex,
                            onTap: onTap,
                          ),

                          _NavItem(
                            icon: AssetsPath.chatNav,
                            label: 'chat'.tr,
                            index: 2,
                            currentIndex: currentIndex,
                            onTap: onTap,
                          ),
                          _NavItem(
                            icon: AssetsPath.profileNav,
                            label: 'profile'.tr,
                            index: 3,
                            currentIndex: currentIndex,
                            onTap: onTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: ResponsiveHelper.spacing(12)),

            ScanNavItem(
              index: 4,
              currentIndex: currentIndex,
              onTap: onTap,
            ),

          ],
        ),
      ),
    );
  }
}

// ─── Regular Nav Item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;

    return Expanded(
      flex: isActive ? 2 : 1,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Card(
              elevation: isActive ? 20 : 10,
              shadowColor: Color(0xFF587CA7),
              color: isActive ? null : AppColors.blueShadeConBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(25),
                ),
                side:  BorderSide(
                  color:isActive? AppColors.darBlue:AppColors.blueShadeConBg,
                  width: 1,
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(27),
                  ),
                  gradient: isActive
                      ?  LinearGradient(
                    colors: [
                AppColors.gradientOne,
                      AppColors.gradientTwo,
                      AppColors.gradientOne,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                      : null,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(27),
                  ),
                  onTap: () => onTap(index),
                  child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
               // color: Color(0xFFBDC9D7)
              ),
                    padding: ResponsiveHelper.symmetric(
                      horizontal: 12,
                      vertical: 12
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          icon,
                          width: ResponsiveHelper.iconSize(15),
                          height: ResponsiveHelper.iconSize(15),
                          colorFilter: ColorFilter.mode(
                            isActive ? Colors.white : Color(0xFF1E252E),
                            BlendMode.srcIn,
                          ),
                        ),
                        if (isActive) ...[
                          SizedBox(width: ResponsiveHelper.spacing(8)),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: ResponsiveHelper.fontSize(12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}

// ─── Scan Nav Item (Standalone Floating Black Button) ─────────────────────────

class ScanNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ScanNavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: ResponsiveHelper.width(64),
        height: ResponsiveHelper.height(64),
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient:  LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
             Color(0xff3F4142),

              Color(0xff1F1F1F),
            ],
          ),
          boxShadow: [
            BoxShape.circle == BoxShape.circle
                ? BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
                : const BoxShadow(),
            if (isActive)
              BoxShadow(
                color: Color(0xFF696E7B),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
           AssetsPath.scanCommon, // আপনার QR/Scan আইকন পাথটি এখানে নিশ্চিত করুন
            width: ResponsiveHelper.iconSize(26),
            height: ResponsiveHelper.iconSize(26),
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}