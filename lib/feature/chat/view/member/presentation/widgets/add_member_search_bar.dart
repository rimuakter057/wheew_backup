import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Member',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(14),
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: ResponsiveHelper.height(8)),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(30),
              ),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name',
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
        ],
      ),
    );
  }
}