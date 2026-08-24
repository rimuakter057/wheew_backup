
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../utils/color/app_colors.dart';

/// Positions the map-type layers button inside a [Stack]. Use
/// [MapTypeLayersButton] directly when the button needs to sit inside
/// non-Stack flow layout (e.g. a [Column]).
class MapTypeDropdown extends StatelessWidget {
  final MapType selectedType;
  final ValueChanged<MapType> onChanged;

  const MapTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: ResponsiveHelper.padding(16),
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(68),
      child: MapTypeLayersButton(
        selectedType: selectedType,
        onChanged: onChanged,
      ),
    );
  }
}

/// The map-type layers button itself, with no positioning applied — safe to
/// place inside any layout (Stack, Column, Row, etc.).
class MapTypeLayersButton extends StatelessWidget {
  final MapType selectedType;
  final ValueChanged<MapType> onChanged;

  const MapTypeLayersButton({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMapTypeBottomSheet(context),
      child: Container(
        height: ResponsiveHelper.height(44),
        width: ResponsiveHelper.width(44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.layers_outlined,
          color:AppColors.black,
        ),
      ),
    );
  }

  void _showMapTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
      ),
      builder: (_) {
        MapType currentType = selectedType;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: ResponsiveHelper.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: ResponsiveHelper.width(50),
                        height: ResponsiveHelper.height(5),
                        decoration: BoxDecoration(
                          color: AppColors.greyShade300,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(20)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.mapType.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: AppColors.grey),
                        ),
                      ],
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(24)),

                    Row(
                      children: [
                        Expanded(
                          child: _mapTypeCard(
                            title: AppStrings.defaultMapType.tr,
                            icon: Icons.map_outlined,
                            value: MapType.normal,
                            selectedType: currentType,
                            onTap: (v) {
                              setModalState(() {
                                currentType = v;
                              });
                              onChanged(v);
                            },
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(10)),
                        Expanded(
                          child: _mapTypeCard(
                            title: AppStrings.hybrid.tr,
                            icon: Icons.map_outlined,
                            value: MapType.hybrid,
                            selectedType: currentType,
                            onTap: (v) {
                             setModalState(() {
                                currentType = v;
                              });
                              onChanged(v);
                            },
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(10)),
                        Expanded(
                          child: _mapTypeCard(
                            title: AppStrings.satellite.tr,
                            icon: Icons.satellite_alt_outlined,
                            value: MapType.satellite,
                            selectedType: currentType,
                            onTap: (v) {
                              setModalState(() {
                                currentType = v;
                              });
                              onChanged(v);
                            },
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(10)),
                        Expanded(
                          child: _mapTypeCard(
                            title: AppStrings.terrain.tr,
                            icon: Icons.terrain_outlined,
                            value: MapType.terrain,
                            selectedType: currentType,
                            onTap: (v) {
                              setModalState(() {
                                currentType = v;

                              });
                              onChanged(v);
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(10)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _mapTypeCard({
    required String title,
    required IconData icon,
    required MapType value,
    required MapType selectedType,
    required ValueChanged<MapType> onTap,
  }) {
    final bool selected = selectedType == value;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: ResponsiveHelper.height(80),
            // Fills the Expanded slot the caller wraps this in — scales
            // with screen width instead of a fixed size, so 4 cards in a
            // row never overlap or touch on narrower devices.
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
              border: Border.all(
                color: selected
                    ? const Color(0xFF185FA5)
                    : AppColors.transparent,
                width: ResponsiveHelper.borderWidth(2.5),
              ),
            ),
            // ðŸ‘‡ à¦ªà¦°à§‡ à¦à¦–à¦¾à¦¨à§‡ image upload à¦•à¦°à¦²à§‡ à¦à¦Ÿà¦¾ à¦¦à¦¿à¦¯à¦¼à§‡ replace à¦•à¦°à¦¬à§‡à¦¨:
            // child: ClipRRect(
            //   borderRadius: BorderRadius.circular(14),
            //   child: Image.asset('assets/images/map_default.png', fit: BoxFit.cover),
            // ),
            child: Icon(
              icon,
              size: ResponsiveHelper.iconSize(32),
              color: selected
                  ? const Color(0xFF185FA5)
                  : AppColors.greyShade500,
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(13),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? const Color(0xFF185FA5) : AppColors.greyShade700,
            ),
          ),
        ],
      ),
    );
  }
}


