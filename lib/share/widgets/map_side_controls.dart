import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';

/// ──────────────────────────────────────────────────────────────────────────
/// Reusable right-side floating controls column for map screens.
///
/// Contains (top → bottom):
///  • Map-type selector button (opens a bottom-sheet)
///  • Current-location button
///
/// Usage:
/// ```dart
/// MapSideControls(
///   selectedMapType: _selectedMapType,
///   onMapTypeChanged: (type) => setState(() => _selectedMapType = type),
///   onLocationTap: () => _goToMyLocation(),
///   topOffset: 110,   // optional — distance from top (default 110)
///   rightOffset: 30,  // optional — distance from right edge (default 30)
/// )
/// ```
/// ──────────────────────────────────────────────────────────────────────────
class MapSideControls extends StatelessWidget {
  /// The currently selected map type (drives the MapTypeDropdown highlight).
  final MapType selectedMapType;

  /// Called when the user picks a new map type.
  final ValueChanged<MapType> onMapTypeChanged;

  /// Called when the user taps the current-location button.
  final VoidCallback onLocationTap;

  /// Distance from the top of the screen (defaults to 8px below MapTopBar's notification bell).
  final double? topOffset;

  /// Distance from the right edge of the screen (default 16 to align with MapTopBar).
  final double rightOffset;

  const MapSideControls({
    super.key,
    required this.selectedMapType,
    required this.onMapTypeChanged,
    required this.onLocationTap,
    this.topOffset,
    this.rightOffset = 16,
  });

  @override
  Widget build(BuildContext context) {
    final double calculatedTop = topOffset != null
        ? ResponsiveHelper.padding(topOffset!)
        : MediaQuery.of(context).padding.top + ResponsiveHelper.padding(68);

    return Positioned(
      right: ResponsiveHelper.padding(rightOffset),
      top: calculatedTop,
      child: Container(
        padding: ResponsiveHelper.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.32),
          borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(68)),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(68)),
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.src),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Map-type layers button ─────────────────────────
                MapTypeLayersButton(
                  selectedType: selectedMapType,
                  onChanged: onMapTypeChanged,
                ),

                SizedBox(height: ResponsiveHelper.height(4)),

                // ── Current-location button ───────────────────────
                GestureDetector(
                  onTap: onLocationTap,
                  child: Container(
                    height: ResponsiveHelper.height(44),
                    width: ResponsiveHelper.width(44),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color:AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
