import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/map/presentation/screens/map_screen.dart';
import 'package:platchatapp/feature/parking/presentation/screens/parking_map_screen.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
import 'package:platchatapp/feature/parking/presentation/screens/save_parking_screen.dart';
import 'package:platchatapp/feature/profile/view/screens/profile_nav_screen.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_options_card.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
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
  bool _showScanOptions = false;

  @override
  void initState() {
    super.initState();
    mainNavIndex.value = 2;
    previousMainNavIndex.value = 2;
  }

  // Tabs 0-3 are built ONCE here and kept alive underneath via IndexedStack
  // (see build()) instead of being recreated by _bodyForIndex on every tab
  // switch. Rebuilding ParkingMapScreen from scratch each time destroyed and
  // recreated the native GoogleMap platform view, which is what produced the
  // grey "reloading" flash on every return to the Parking tab even though its
  // data was already cached locally — the map view itself had no memory of
  // ever having rendered before. Keeping the same four widget instances alive
  // means each screen's own state (and its GoogleMapController) persists
  // across switches, so re-entering a tab only redraws what's already there;
  // it does not reload.
  static const List<Widget> _persistentTabs = [
    MapScreen(),
    ParkingMapScreen(),
    ChatListScreen(),
    ProfileNavScreen(),
  ];

  // Scan (camera) and Save-Parking are NOT included above on purpose: Scan
  // holds a live camera feed that shouldn't stay resident in memory while
  // some other tab is showing, and Save-Parking isn't reachable from the
  // bottom nav at all (nothing ever sets mainNavIndex to 5) — both are built
  // fresh on demand, same as before.
  Widget? _transientBodyForIndex(int index) {
    switch (index) {
      case 4:
        return ScanScreen();
      case 5:
        return SaveParkingScreen();
      default:
        return null;
    }
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    if (Get.isRegistered<ParkingShowController>()) {
      Get.find<ParkingShowController>().clearSpotDetailsCard();
    }

    if (index == 4) {
      setState(() => _showScanOptions = true);
      return;
    }
    mainNavIndex.value = index;
  }

  void _closeScanOptions() {
    setState(() => _showScanOptions = false);
  }

  void _openOcrScanner() {
    _closeScanOptions();
    context.pushNamed(RouteName.ocrScanner);
  }

  void _openQrScanner() {
    _closeScanOptions();
    previousMainNavIndex.value = mainNavIndex.value;
    mainNavIndex.value = 4;
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return ValueListenableBuilder<int>(
      valueListenable: mainNavIndex,
      builder: (context, currentIndex, _) {
        final transientBody = _transientBodyForIndex(currentIndex);

        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFFD2DCF0),
          body: Stack(
            children: [
              // Always mounted, index clamped so it keeps showing whichever
              // persistent tab was last active while a transient screen
              // (Scan / Save-Parking) is on top — clamping just picks a safe
              // fallback to paint underneath, it doesn't affect what's
              // visible once the opaque transient screen covers it.
              IndexedStack(
                index: currentIndex.clamp(0, _persistentTabs.length - 1),
                children: _persistentTabs,
              ),
              ?transientBody,
              if (_showScanOptions)
                _ScanOptionsOverlay(
                  onClose: _closeScanOptions,
                  onOcrTap: _openOcrScanner,
                  onQrTap: _openQrScanner,
                ),
            ],
          ),
          bottomNavigationBar: currentIndex == 4
              ? null
              : Obx(() {
                  if (isPickingOnMap.value) return const SizedBox.shrink();

                  return _AppBottomNav(
                    currentIndex: currentIndex,
                    onTap: _onTap,
                  );
                }),
        );
      },
    );
  }
}


// --- Scan chooser overlay (OCR Scanner / Scan QR Code) ------------------------
// Lives inside the body Stack (not a modal route) so the floating bottom nav
// stays crisp on top while the current tab dims/blurs behind the card.

class _ScanOptionsOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onOcrTap;
  final VoidCallback onQrTap;

  const _ScanOptionsOverlay({
    required this.onClose,
    required this.onOcrTap,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: AppColors.black.withOpacity(0.35)),
            ),
          ),
          Positioned(
            left: ResponsiveHelper.width(20),
            right: ResponsiveHelper.width(20),
            bottom: ResponsiveHelper.height(110),
            child: ScanOptionsCard(
              onOcrTap: onOcrTap,
              onQrTap: onQrTap,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Bottom Navigation Bar ----------------------------------------------------

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
          vertical: ResponsiveHelper.padding(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (!showFindParkingButton.value) return const SizedBox.shrink();
              return Container(
                margin: EdgeInsets.only(
                  left: ResponsiveHelper.padding(2),
                  bottom: ResponsiveHelper.padding(8),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: ResponsiveHelper.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0C7DC9),
                          Color(0xFF014495),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF014495).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: ResponsiveHelper.width(22),
                          height: ResponsiveHelper.width(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'P',
                              style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveHelper.fontSize(11),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(6)),
                        Text(
                          AppStrings.findParkingSpot.tr,
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.fontSize(13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            Center(
              child: SizedBox(
                width: ResponsiveHelper.width(220),
                child: Card(
                margin: EdgeInsets.zero,
                elevation: 3,
                shadowColor: AppColors.black.withOpacity(0.08),
                color: const Color(0xFFACB9C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(36),
                  ),
                  side: BorderSide(
                    color: AppColors.white.withOpacity(0.6),
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
                          //parking-chat-profile
                          _NavItem(
                            icon: AssetsPath.pNav,
                            label: AppStrings.parking.tr,
                            index: 1,
                            currentIndex: currentIndex,
                            onTap: onTap,
                          ),

                          SizedBox(width: ResponsiveHelper.spacing(8)),
                          _NavItem(
                            icon: AssetsPath.chatNav,
                            label: AppStrings.chat.tr,
                            index: 2,
                            currentIndex: currentIndex,
                            onTap: onTap,
                          ),

                          SizedBox(width: ResponsiveHelper.spacing(8)),
                          _NavItem(
                            icon: AssetsPath.profileNav,
                            label: AppStrings.profile.tr,
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
          ),
      ],
    ),
      ),
    );
  }
}

// --- Regular Nav Item ---------------------------------------------------------

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
      // active item à¦à¦•à¦Ÿà§ à¦¬à§‡à¦¶à¦¿ à¦œà¦¾à¦¯à¦¼à¦—à¦¾ à¦¨à§‡à¦¬à§‡, à¦•à¦¿à¦¨à§à¦¤à§ à¦¨à¦¿à¦šà§‡ ConstrainedBox
      // à¦¦à¦¿à¦¯à¦¼à§‡ overflow à¦†à¦Ÿà¦•à¦¾à¦¨à§‹ à¦¹à¦¯à¦¼à§‡à¦›à§‡
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
                side: BorderSide(
                  color: isActive ? AppColors.darBlue : AppColors.blueShadeConBg,
                  width: 1,
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(27),
                  ),
                  gradient: isActive
                      ? LinearGradient(
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
                  child: ConstrainedBox(
                    // -- overflow fix: active/inactive à¦…à¦¨à§à¦¯à¦¾à¦¯à¦¼à§€ max width à¦¬à§‡à¦à¦§à§‡ à¦¦à§‡à¦“à¦¯à¦¼à¦¾ --
                    constraints: BoxConstraints(
                      maxWidth: isActive
                          ? ResponsiveHelper.width(120)
                          : ResponsiveHelper.width(48),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Color(0xFFBDC9D7)
                      ),
                      padding: ResponsiveHelper.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              icon,
                              width: ResponsiveHelper.iconSize(15),
                              height: ResponsiveHelper.iconSize(15),
                              colorFilter: ColorFilter.mode(
                                isActive ? AppColors.white : Color(0xFF1E252E),
                                BlendMode.srcIn,
                              ),
                            ),
                            if (isActive) ...[
                              SizedBox(width: ResponsiveHelper.spacing(8)),
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.poppins(
                                  color: AppColors.white,
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
            ),
          ),
        ),
      ),
    );
  }
}

// --- Scan Nav Item (Standalone Floating Black Button) -------------------------

class ScanNavItem extends StatelessWidget {
  final String icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ScanNavItem({
    super.key,
    required this.icon,
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

          gradient: LinearGradient(
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
              color: AppColors.black.withOpacity(0.3),
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
            color: AppColors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: ResponsiveHelper.iconSize(26),
            height: ResponsiveHelper.iconSize(26),
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

