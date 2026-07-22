import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class AddMemberSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const AddMemberSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(14),
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.searchByName.tr,
            hintStyle: TextStyle(
              fontSize: ResponsiveHelper.fontSize(14),
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: ResponsiveHelper.iconSize(20),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.padding(14),
            ),
          ),
        ),
      ),
    );
  }
}