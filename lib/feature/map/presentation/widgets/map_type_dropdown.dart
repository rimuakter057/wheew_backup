

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

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
      top: ResponsiveHelper.padding(80),
      child: GestureDetector(
        onTap: () => _showMapTypeBottomSheet(context),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  void _showMapTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        MapType currentType = selectedType;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Map type",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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

                    const SizedBox(height: 10),
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
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? const Color(0xFF185FA5)
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            // 👇 পরে এখানে image upload করলে এটা দিয়ে replace করবেন:
            // child: ClipRRect(
            //   borderRadius: BorderRadius.circular(14),
            //   child: Image.asset('assets/images/map_default.png', fit: BoxFit.cover),
            // ),
            child: Icon(
              icon,
              size: 32,
              color: selected
                  ? const Color(0xFF185FA5)
                  : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? const Color(0xFF185FA5) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}