import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

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
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8F0),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // index ট্র্যাকিং করার জন্য .asMap().entries ব্যবহার করা হয়েছে
          children: colorOptions.asMap().entries.map((entry) {
            final int index = entry.key; // এখানে index পাওয়া যাবে
            final Map<String, dynamic> c = entry.value;

            final bool isSelected = selectedColorName == c['name'];
            final Color color = c['color'] as Color;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: GestureDetector(
                onTap: () => onSelected(c['name'] as String),
                child: Tooltip(
                  message: c['name'] as String,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: ResponsiveHelper.iconSize(34),
                    height: ResponsiveHelper.iconSize(34),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                          : null,
                    ),
                    child: isSelected
                        ? Container(
                      width: ResponsiveHelper.iconSize(20),
                      height: ResponsiveHelper.iconSize(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        // এখানে index 0 হলে কালো রং, অন্যথায় সাদা রং হবে
                        color: index == 3 ? Colors.black87 : Colors.white,
                      ),
                    )
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}