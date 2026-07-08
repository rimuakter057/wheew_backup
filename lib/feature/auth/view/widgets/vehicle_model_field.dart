import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/country_list.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class VehicleModelDropdown extends StatelessWidget {
  final String selectedModel;
  final ValueChanged<String> onSelected;

  const VehicleModelDropdown({
    super.key,
    required this.selectedModel,
    required this.onSelected,
  });

  InputDecoration _decoration() {
    return InputDecoration(
      labelText: AppStrings.vehicleModel.tr,
      labelStyle: TextStyle(
        fontSize: ResponsiveHelper.fontSize(14),
        color: Colors.grey[600],
      ),

      prefixIcon: const Icon(Icons.directions_car_filled_rounded, color: Colors.grey, size: 22),
      filled: true,
      fillColor: Color(0xFFDDE2ED),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(20),
        vertical: ResponsiveHelper.padding(16),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(150, 0),
      constraints: BoxConstraints(
        minWidth: ResponsiveHelper.height(200),
        maxWidth: ResponsiveHelper.width(220),
        maxHeight: ResponsiveHelper.height(450),
        minHeight: ResponsiveHelper.height(350),
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        return vehicleModels.map((model) {
          return PopupMenuItem<String>(
            value: model,
            child: Text(
              model,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      child: InputDecorator(
        decoration: _decoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedModel.isEmpty ? "Enter vehicle model" : selectedModel, // ইমেজের টেক্সটের সাথে মিল রাখা হয়েছে
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(14),
                  color: selectedModel.isEmpty ? Colors.grey : Colors.black87,
                  fontWeight: selectedModel.isEmpty ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            // এখানে থাকা dropdown আইকনটি সম্পূর্ণ রিমুভ করে দেওয়া হয়েছে,
            // ফলে আইকন দেখাবে না কিন্তু পুরো বক্সে ক্লিক করলেই ড্রপডাউন ওপেন হবে।
          ],
        ),
      ),
    );
  }
}