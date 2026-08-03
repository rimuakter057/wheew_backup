import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bottom_sheet_position_controller.dart';

/// Positions its content at [defaultBottom] using [left]/[right] and
/// animates it upward whenever a bottom sheet opened via
/// `showTrackedBottomSheet` is visible, keeping it [gap] above the sheet's
/// current (dynamic) height — switching horizontally to [openLeft]/[openRight]
/// while the sheet is open. Animates back to [defaultBottom]/[left]/[right]
/// once the sheet is dismissed.
///
/// Works for any bottom sheet — current or future — as long as it's shown
/// through `showTrackedBottomSheet` instead of `showModalBottomSheet`.
class BottomSheetAwarePositioned extends StatelessWidget {
  final double defaultBottom;
  final double gap;
  final double? left;
  final double? right;
  final double? openLeft;
  final double? openRight;
  final Duration duration;
  final Curve curve;

  /// Builds the content; [isSheetOpen] lets the caller adjust internal
  /// alignment (e.g. a Column's crossAxisAlignment) to match the horizontal
  /// position switch between the default and open states.
  final Widget Function(BuildContext context, bool isSheetOpen) builder;

  const BottomSheetAwarePositioned({
    super.key,
    required this.defaultBottom,
    required this.builder,
    this.gap = 16,
    this.left = 0,
    this.right = 0,
    this.openLeft,
    this.openRight,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final controller = BottomSheetPositionController.instance();

    return Obx(() {
      final sheetHeight = controller.currentHeight.value;
      final isSheetOpen = sheetHeight > 0;
      final bottom = isSheetOpen ? sheetHeight + gap : defaultBottom;
      final effectiveLeft = isSheetOpen ? (openLeft ?? left) : left;
      final effectiveRight = isSheetOpen ? (openRight ?? right) : right;

      return AnimatedPositioned(
        duration: duration,
        curve: curve,
        left: effectiveLeft,
        right: effectiveRight,
        bottom: bottom,
        child: builder(context, isSheetOpen),
      );
    });
  }
}
