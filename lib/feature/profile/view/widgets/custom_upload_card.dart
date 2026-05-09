import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

import '../../../../share/widgets/custom_image/custom_image.dart';

class CustomUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onUpload;

  const CustomUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // রেসপন্সিভ প্যাডিং এবং মার্জিন
      padding: ResponsiveHelper.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyBg,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
        border: Border.all(
          color: AppColors.greyBorder,
          width: ResponsiveHelper.borderWidth(1),
        ),
      ),
      child: Row(
        children: [

          // Container(
          //   padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade50,
          //     borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
          //   ),
          //   child: Icon(
          //     Icons.assignment_outlined, // ক্লিপবোর্ড আইকন
          //     size: ResponsiveHelper.iconSize(28),
          //     color: Colors.brown.shade400,
          //   ),
          // ),

          CustomImage(imageSrc:AssetsPath.insurance ),

          SizedBox(width: ResponsiveHelper.spacing(12)),

          // মাঝখানের টেক্সট সেকশন
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.bodySmall.copyWith(fontWeight: FontWeight.w600),),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.bodySmall.copyWith(color: Color(0xFF757575))
                ),
              ],
            ),
          ),

          // ডান পাশের আপলোড বাটন
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: Icon(
              Icons.file_upload_outlined,
              size: ResponsiveHelper.iconSize(16),
              color: Colors.white,
            ),
            label: Text(
              'Upload',
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueClient,
              elevation: 0,
              padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
              ),
              minimumSize: Size(0, ResponsiveHelper.buttonHeight(40)),
            ),
          ),
        ],
      ),
    );
  }
}