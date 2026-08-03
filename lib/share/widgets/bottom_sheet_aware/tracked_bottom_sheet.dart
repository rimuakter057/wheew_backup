import 'package:flutter/material.dart';

import 'bottom_overlay_height_reporter.dart';

/// Drop-in replacement for [showModalBottomSheet] that measures the sheet's
/// rendered height for as long as it's visible and publishes it to the
/// shared `BottomSheetPositionController`, clearing it again once the sheet
/// closes.
///
/// Use this instead of [showModalBottomSheet] for any bottom sheet that
/// should push floating UI (like `BottomSheetAwarePositioned`) out of its way.
Future<T?> showTrackedBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: shape,
    builder: (sheetContext) => BottomOverlayHeightReporter(
      child: builder(sheetContext),
    ),
  );
}
