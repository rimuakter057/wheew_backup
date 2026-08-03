import 'package:flutter/material.dart';

import 'bottom_sheet_position_controller.dart';

/// Wraps any bottom-anchored widget — a modal bottom sheet's content, or an
/// inline overlay positioned near the screen bottom (e.g. a details card
/// shown via `Positioned` outside of a sheet) — and reports its rendered
/// height to the shared [BottomSheetPositionController] for as long as it
/// stays mounted, clearing itself automatically on dispose.
///
/// This lets [BottomSheetAwarePositioned] react identically to modal sheets
/// and inline overlays alike, including several visible at once, without
/// either side needing to know about the other.
class BottomOverlayHeightReporter extends StatefulWidget {
  final Widget child;

  /// Extra space to add on top of the measured widget height — e.g. a fixed
  /// `bottom` inset the caller already applies via its own `Positioned`.
  final double extraBottomOffset;

  const BottomOverlayHeightReporter({
    super.key,
    required this.child,
    this.extraBottomOffset = 0,
  });

  @override
  State<BottomOverlayHeightReporter> createState() =>
      _BottomOverlayHeightReporterState();
}

class _BottomOverlayHeightReporterState
    extends State<BottomOverlayHeightReporter> {
  final Object _id = Object();
  final GlobalKey _key = GlobalKey();
  late final BottomSheetPositionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BottomSheetPositionController.instance();
  }

  void _measure() {
    if (!mounted) return;
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    _controller.report(_id, renderBox.size.height + widget.extraBottomOffset);
  }

  @override
  void dispose() {
    // Don't call clear() synchronously: dispose() can run while Flutter's
    // element tree is locked (e.g. mid `finalizeTree`), and clear() notifies
    // an Obx listener that calls setState(). Doing that while locked throws
    // "widget tree was locked" and the rebuild request is silently dropped —
    // the dependent UI then never reverts until some unrelated rebuild
    // happens to occur later. Deferring to a post-frame callback runs it
    // once the tree is unlocked again.
    final controller = _controller;
    final id = _id;
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.clear(id));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
        return false;
      },
      child: SizeChangedLayoutNotifier(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
