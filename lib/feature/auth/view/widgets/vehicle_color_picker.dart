import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class VehicleColorPicker extends StatelessWidget {
  final List<Map<String, dynamic>> colorOptions;
  final String? selectedColorName;
  final ValueChanged<String> onSelected;

  const VehicleColorPicker({
    super.key,
    required this.colorOptions,
    required this.selectedColorName,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ResponsiveHelper.spacing(14),
      runSpacing: ResponsiveHelper.spacing(14),
      children: colorOptions.map((c) {
        final bool isSelected = selectedColorName == c['name'];
        final Color color = c['color'] as Color;

        return GestureDetector(
          onTap: () => onSelected(c['name'] as String),
          child: Tooltip(
            message: c['name'] as String,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: ResponsiveHelper.iconSize(38),
                  height: ResponsiveHelper.iconSize(38),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: isSelected ? AppColors.blue : Colors.white,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    bottom: -2,
                    left: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: ResponsiveHelper.iconSize(14),
                        height: ResponsiveHelper.iconSize(14),
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
