import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../helper/custom_gradient_button/custom_gradient_button.dart';
import '../../../../utils/color/app_colors.dart';

/// Bottom Find-Parking / Exit-Parking button row on ParkingMapScreen. Both
class ParkingMapBottomActions extends StatefulWidget {
  final bool isSearching;
  final bool isTransitioningSearch;
  final VoidCallback onFindParkingTap;
  final VoidCallback onExitParkingTap;

  const ParkingMapBottomActions({
    super.key,
    required this.isSearching,
    required this.isTransitioningSearch,
    required this.onFindParkingTap,
    required this.onExitParkingTap,
  });

  @override
  State<ParkingMapBottomActions> createState() =>
      _ParkingMapBottomActionsState();
}

class _ParkingMapBottomActionsState extends State<ParkingMapBottomActions>
    with SingleTickerProviderStateMixin {
  // Blink for the "Stop Searching" button while a search is active, so the
  // user has an ambient cue they're still in search mode without having to
  // read the label. Deliberately NOT the old full-screen glow approach (a
  // CustomPaint repainting the whole map every frame) — this only fades the
  // opacity of one small, already-composited button, which the GPU handles
  // for effectively free. Kept off the map/marker code path entirely, so it
  // has no effect on that performance work.
  late final AnimationController _blinkController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _syncBlink();
  }

  @override
  void didUpdateWidget(covariant ParkingMapBottomActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSearching != widget.isSearching) _syncBlink();
  }

  void _syncBlink() {
    if (widget.isSearching) {
      _blinkController.repeat(reverse: true);
    } else {
      _blinkController.stop();
      _blinkController.value = 0;
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: ResponsiveHelper.bottomNavOffset(context),
      left: ResponsiveHelper.padding(20),
      right: ResponsiveHelper.padding(20),
      child: Row(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: widget.isSearching
                  ? _blinkController.drive(Tween(begin: 1.0, end: 0.55))
                  : const AlwaysStoppedAnimation(1.0),
              child: CustomGradientButton(
                onPressed: widget.onFindParkingTap,
                isLoading: widget.isTransitioningSearch,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.isSearching) ...[
                      CustomImage(
                        imageSrc: AssetsPath.pNav,
                        width: ResponsiveHelper.iconSize(16),
                        height: ResponsiveHelper.iconSize(16),
                      ),
                      SizedBox(width: ResponsiveHelper.width(4)),
                    ],
                    Flexible(
                      child: Text(
                        widget.isSearching
                            ? AppStrings.stopSearching.tr
                            : AppStrings.findParkingSpot.tr,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontSize: ResponsiveHelper.fontSize(10),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.width(12)),
          Expanded(
            child: CustomGradientButton(
              gradient: AppColors.redGradient,
              onPressed: widget.onExitParkingTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImage(
                    imageSrc: AssetsPath.pNav,
                    width: ResponsiveHelper.iconSize(16),
                    height: ResponsiveHelper.iconSize(16),
                  ),
                  SizedBox(width: ResponsiveHelper.width(4)),
                  Flexible(
                    child: Text(
                      AppStrings.exitParking.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: ResponsiveHelper.fontSize(10),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
