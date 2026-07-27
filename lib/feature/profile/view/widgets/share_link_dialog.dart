import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart'; // নিশ্চিত হয়ে নিও এই পাথটি ঠিক আছে কিনা
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
          ResponsiveHelper.borderRadius(24),
        ),
      ),
      child: Container(
        color: AppColors.backgroundColor,
        width: ResponsiveHelper.isTablet
            ? ResponsiveHelper.maxContentWidth
            : double.infinity,
        padding: ResponsiveHelper.all(24),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: ResponsiveHelper.spacing(4)),

                  /// Share Icon
                  SvgPicture.asset(
                    AssetsPath.shareLinkBadge,
                    width: ResponsiveHelper.width(72),
                    height: ResponsiveHelper.height(72),
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

                  SizedBox(height: ResponsiveHelper.spacing(6)),

                  /// Subtitle
                  Text(
                    AppStrings.shareThisLinkInviteFriends.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(13),
                      color: AppColors.secondaryText,
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(22)),

                  /// Link Box
                  Container(
                    padding: ResponsiveHelper.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            shareUrl,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(13),
                              color: AppColors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(8)),
                        GestureDetector(
                          onTap: () => _copyLink(context),
                          child: Container(
                            padding: ResponsiveHelper.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.borderRadius(8),
                              ),
                              border: Border.all(
                                color: AppColors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.copy_rounded,
                              size: ResponsiveHelper.iconSize(16),
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(20)),

                  /// "Or" divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.greyBorder),
                      ),
                      Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 12),
                        child: Text(
                          AppStrings.or.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(12),
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.greyBorder),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(20)),

                  /// Social platform buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        asset: AssetsPath.facebookLogo,
                        onTap: _openFacebook,
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(16)),
                      _SocialButton(
                        asset: AssetsPath.whatsapp,
                        onTap: _openWhatsapp,
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(16)),
                      _SocialButton(
                        asset: AssetsPath.instagram,
                        onTap: () => _openInstagram(context),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(16)),
                      _SocialButton(
                        asset: AssetsPath.xLogo,
                        onTap: _openX,
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: ResponsiveHelper.iconSize(22),
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _shareText =>
      '${shareMessage != null ? '$shareMessage\n\n' : ''}$shareUrl';

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.blue,
        content: Text(
          AppStrings.linkCopied.tr,
          style: TextStyle(color: AppColors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchOrFallback(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      Share.share(_shareText, subject: AppStrings.appInvitation.tr);
    }
  }

  void _openFacebook() {
    _launchOrFallback(
      Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}',
      ),
    );
  }

  void _openWhatsapp() {
    _launchOrFallback(
      Uri.parse('https://wa.me/?text=${Uri.encodeComponent(_shareText)}'),
    );
  }

  void _openX() {
    _launchOrFallback(
      Uri.parse(
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(_shareText)}',
      ),
    );
  }

  // Instagram has no web intent for pre-filled share text — copy the link
  // and hand off to the app itself (or the generic share sheet as fallback).
  Future<void> _openInstagram(BuildContext context) async {
    _copyLink(context);
    final launched = await launchUrl(
      Uri.parse('instagram://app'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      Share.share(_shareText, subject: AppStrings.appInvitation.tr);
    }
  }
}

class _SocialButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _SocialButton({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        asset,
        width: ResponsiveHelper.width(48),
        height: ResponsiveHelper.height(48),
      ),
    );
  }
}
