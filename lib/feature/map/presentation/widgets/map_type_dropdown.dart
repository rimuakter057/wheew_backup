

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

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
      right: ResponsiveHelper.padding(20),
      top: ResponsiveHelper.padding(120),
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
        padding: ResponsiveHelper.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.layers_outlined,
          color: Color(0xFF185FA5),
        ),
      ),
    );
  }

  void _showMapTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(20)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Map type",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(24)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _mapTypeCard(
                          title: "Default",
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
                        _mapTypeCard(
                          title: "Hybrid",
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
                        _mapTypeCard(
                          title: "Satellite",
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
                        _mapTypeCard(
                          title: "Terrain",
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
        children: [
          Container(
            height: ResponsiveHelper.height(80),
            width: ResponsiveHelper.width(80),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
              border: Border.all(
                color: selected
                    ? const Color(0xFF185FA5)
                    : Colors.transparent,
                width: ResponsiveHelper.borderWidth(2.5),
              ),
            ),
            // 👇 পরে এখানে image upload করলে এটা দিয়ে replace করবেন:
            // child: ClipRRect(
            //   borderRadius: BorderRadius.circular(14),
            //   child: Image.asset('assets/images/map_default.png', fit: BoxFit.cover),
            // ),
            child: Icon(
              icon,
              size: ResponsiveHelper.iconSize(32),
              color: selected
                  ? const Color(0xFF185FA5)
                  : Colors.grey.shade500,
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(13),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? const Color(0xFF185FA5) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
