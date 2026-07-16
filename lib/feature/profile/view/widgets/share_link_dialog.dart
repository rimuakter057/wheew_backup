import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart'; // নিশ্চিত হয়ে নিও এই পাথটি ঠিক আছে কিনা
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:share_plus/share_plus.dart';

class ShareLinkDialog extends StatelessWidget {
  final String shareUrl;
  final String? shareMessage;

   ShareLinkDialog({
    super.key,
    this.shareUrl = ApiUrl.appUrl,
    this.shareMessage ,
  });

  @override
  Widget build(BuildContext context) {
 

    return Dialog(
      insetPadding: ResponsiveHelper.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(20),
        ),
      ),
      child: Container(
        color: AppColors.backgroundColor, // ব্যাকগ্রাউন্ড হোয়াইট সেট করা হলো
        width: ResponsiveHelper.isTablet
            ? ResponsiveHelper.maxContentWidth
            : double.infinity,
        padding: ResponsiveHelper.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.shareLink.tr,
                    style: context.bodyLarge?.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: ResponsiveHelper.iconSize(24),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(16)),
          
              /// Share Icon
              Container(
                width: ResponsiveHelper.width(80),
                height: ResponsiveHelper.height(80),
                decoration: const BoxDecoration(
                  color: AppColors.softBrandColor, // হালকা ব্র্যান্ড কালার ব্যবহার করা হয়েছে
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_rounded,
                  size: ResponsiveHelper.iconSize(40),
                  color: AppColors.blue, // মেইন ব্লু কালার
                ),
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(16)),
          
              /// Title
              Text(
                AppStrings.shareWithFriends.tr,
                style: context.bodyLarge?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(8)),
          
              /// Subtitle
              Text(
                AppStrings.shareThisLinkInviteFriends.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(13),
                  color: AppColors.secondaryText,
                ),
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(20)),
          
              /// Link Box
              Container(
                padding: ResponsiveHelper.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greyBg, // গ্রে ব্যাকগ্রাউন্ড
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(12),
                  ),
                  border: Border.all(
                    color: AppColors.greyBorder, // হালকা গ্রে বর্ডার
                    width: ResponsiveHelper.borderWidth(1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shareUrl,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(13),
                          color: AppColors.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
          
                    SizedBox(width: ResponsiveHelper.spacing(8)),
          
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: shareUrl),
                        );
          
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            backgroundColor: AppColors.blue, // স্ন্যাকবার কালার ব্লু করা হলো
                            content: Text(
                              AppStrings.linkCopied.tr,
                              style: TextStyle(color: AppColors.white),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        size: ResponsiveHelper.iconSize(20),
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(20)),
          
              /// Share Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.buttonHeight(50),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareLink();
                  },
                  icon: Icon(
                    Icons.share_rounded,
                    size: ResponsiveHelper.iconSize(20),
                    color: AppColors.white,
                  ),
                  label: Text(
                    AppStrings.share.tr,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(15),
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue, // বাটনের ব্যাকগ্রাউন্ড ব্লু
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareLink() {
    Share.share(
      '$shareMessage\n\n$shareUrl',
      subject: AppStrings.appInvitation.tr,
    );
  }
}