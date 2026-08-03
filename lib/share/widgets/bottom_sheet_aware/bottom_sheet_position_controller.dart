import 'package:get/get.dart';

/// Tracks the height of whichever bottom-anchored overlay(s) are currently
/// visible — modal bottom sheets opened via `showTrackedBottomSheet`, or
/// inline overlays wrapped in `BottomOverlayHeightReporter`.
///
/// Each reporter registers under its own id and reports independently, so
/// overlapping overlays (e.g. a selected-report card plus a modal sheet)
/// are both accounted for — [currentHeight] is always the tallest one
/// currently visible, and falls back to 0 once none remain. This makes the
/// behavior automatic for any bottom-anchored overlay added in the future,
/// current or overlapping.
class BottomSheetPositionController extends GetxController {
  final Map<Object, double> _heights = <Object, double>{};

  /// The tallest currently-registered overlay height, or 0 when none are
  /// visible. Plain [RxDouble] so [Obx] consumers subscribe unambiguously.
  final RxDouble currentHeight = 0.0.obs;

  void report(Object id, double height) {
    _heights[id] = height;
    _recompute();
  }

  void clear(Object id) {
    if (_heights.remove(id) != null) {
      _recompute();
    }
  }

  void _recompute() {
    currentHeight.value =
        _heights.isEmpty ? 0.0 : _heights.values.reduce((a, b) => a > b ? a : b);
  }

  static BottomSheetPositionController instance() {
    return Get.isRegistered<BottomSheetPositionController>()
        ? Get.find<BottomSheetPositionController>()
        : Get.put(BottomSheetPositionController(), permanent: true);
  }
}
