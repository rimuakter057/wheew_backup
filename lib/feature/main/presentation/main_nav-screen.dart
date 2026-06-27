import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/map/presentation/screens/map_screen.dart';
import 'package:platchatapp/feature/notification/presentation/screens/notification_screen.dart';
import 'package:platchatapp/feature/profile/view/screens/profile_nav_screen.dart';
import 'package:platchatapp/feature/scan/presentation/screens/scan_screen.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/main.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../chat/view/chat_list/presentation/screens/chat_list_screen.dart';
import '../../ocr/presentation/screens/ocr_screen.dart';
import '../../search/presentation/screens/serach_screen.dart';


class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  /// Only the visible tab is built. [IndexedStack] kept Scanner + Map (camera + SurfaceView)
  /// mounted together and flooded logcat with `BufferQueueProducer` / `ImageReader` frames.

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 0:
        return const ChatListScreen();
      case 1:
      //  return const SearchListScreen();
        return NotificationScreen();
      case 2:
        return ScanScreen();


       // return Scaffold(backgroundColor: Colors.white,);
      case 3:
        return const MapScreen();
      case 4:
        return ProfileNavScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // void _onTap(int index) {
  //   HapticFeedback.lightImpact();
  //   setState(() => _currentIndex = index);
  // }

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
          backgroundColor: const Color(0xFFF5F7FA),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: ResponsiveHelper.height(72),
          child: Row(
            children: [
              _NavItem(
                icon: AssetsPath.chatNav,
                label: 'chat'.tr,
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),

              _NavItem(
                icon: AssetsPath.notificationNav,
                label:AppStrings.notification.tr,
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),

              ScanNavItem(
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),




              _NavItem(
                icon: AssetsPath.mapNav,
                label: 'map'.tr,
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: AssetsPath.profileNav,
                label: 'profile'.tr,
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
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
    final bool isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: ResponsiveHelper.width(40),
                height: ResponsiveHelper.height(32),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF3D72E8).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: ResponsiveHelper.iconSize(22),
                    height: ResponsiveHelper.iconSize(22),
                    colorFilter: ColorFilter.mode(
                      isActive
                          ? const Color(0xFF3D72E8)
                          : const Color(0xFF9EA8BB),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(2)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(10),
                  fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF3D72E8)
                      : const Color(0xFF9EA8BB),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Center Scan Nav Item ─────────────────────────────────────────────────────
// class ScanNavItem extends StatelessWidget {
//   final int index;
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const ScanNavItem({
//     super.key,
//     required this.index,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isActive = index == currentIndex;
//
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onTap(index),
//         behavior: HitTestBehavior.opaque,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               AssetsPath.scanNav,
//               width: ResponsiveHelper.iconSize(28),
//               height: ResponsiveHelper.iconSize(28),
//               colorFilter: ColorFilter.mode(
//                 isActive
//                     ? const Color(0xFF3D72E8)
//                     : const Color(0xFF9EA8BB),
//                 BlendMode.srcIn,
//               ),
//             ),
//             SizedBox(height: ResponsiveHelper.spacing(2)),
//             Text(
//               'scan'.tr,
//               style: GoogleFonts.poppins(
//                 fontSize: ResponsiveHelper.fontSize(10),
//                 fontWeight:
//                 isActive ? FontWeight.w600 : FontWeight.w400,
//                 color: isActive
//                     ? const Color(0xFF3D72E8)
//                     : const Color(0xFF9EA8BB),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


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
    final bool isActive = index == currentIndex;
    final Color color =
    isActive ? const Color(0xFF3D72E8) : const Color(0xFF9EA8BB);

    return Expanded(
      child: GestureDetector(
       onTap: () => onTap(index),
    //     onTap: (){
    //
    //
    //
    //     },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetsPath.scanNav,
              //AssetsPath.pNav,
              width: ResponsiveHelper.iconSize(60),
              height: ResponsiveHelper.iconSize(60),
            ),
             SizedBox(height: ResponsiveHelper.spacing(6)),
            // Text(
            //   'scan'.tr,
            //   style: GoogleFonts.poppins(
            //     fontSize: ResponsiveHelper.fontSize(10),
            //     fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            //     color: color,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}