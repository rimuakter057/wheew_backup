import 'package:flutter/material.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Vehicle Color picker — circle swatches (VehicleInfoScreen এর ডিজাইন অনুযায়ী)
class VehicleColorPicker extends StatelessWidget {
  final ProfileController controller;

  const VehicleColorPicker({super.key, required this.controller});

  static const List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Bianco', 'color': Color(0xFFF4F4F2)},
    {'name': 'Nero', 'color': Color(0xFF1B1B1D)},
    {'name': 'Grigio', 'color': Color(0xFF6E7074)},
    {'name': 'Blu', 'color': Color(0xFF2C3E5C)},
    {'name': 'Rosso', 'color': Color(0xFFB11724)},
    {'name': 'Bianco2', 'color': Colors.white},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedColor = controller.vehicleColorController.text;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(14),
        vertical: ResponsiveHelper.padding(12),
      ),
      decoration: BoxDecoration(
        color: controller.isEditing
            ? AppColors.white
            : AppColors.greyShade.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
        border: Border.all(color: AppColors.greyShade),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _colorOptions.map((c) {
          final bool isSelected = selectedColor == c['name'];
          return GestureDetector(
            onTap: controller.isEditing
                ? () {
              controller.vehicleColorController.text = c['name'];
              controller.update(['vehicle_fields']);
            }
                : null,
            child: Tooltip(
              message: c['name'],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c['color'],
                  border: Border.all(
                    color: isSelected ? AppColors.blue : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                      : [],
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: c['name'] == 'Bianco' || c['name'] == 'Bianco2'
                      ? AppColors.blue
                      : Colors.white,
                  size: 18,
                )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}