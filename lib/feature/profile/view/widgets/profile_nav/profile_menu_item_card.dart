import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../../../core/router/routes_name.dart';
import '../../../../../core/service/api_url.dart';
import '../../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../../language/language_controller.dart';
import '../../../../../utils/assets_path/assets_path.dart';
import '../../../../../utils/color/app_colors.dart';
import '../../../../../utils/language/app_string.dart';
import '../../../../faq/presentation/screens/faq_screen.dart';
import '../../../../privacy_policy/help_suppoor_screen.dart';
import '../../../../privacy_policy/privacy_policy_screen.dart';
import '../../../../terms_condition/web_view_screen.dart';
import '../../../repository/profile_controller.dart';
import '../share_link_dialog.dart';

Widget buildMenuItems({
  required BuildContext context,
  required ProfileController profileController,
  required LanguageController languageController,
}) {
  final List<Map<String, dynamic>> items = [
    {
      'icon': AssetsPath.profile,
      'title': AppStrings.profile.tr,
      'subtitle': AppStrings.personalInformationSubtitle.tr,
      'onTap': () async {
        await context.pushNamed(RouteName.profile);
        profileController.reloadProfile();
      },
    },
    {
      'icon': AssetsPath.usefulNumber,
      'title': AppStrings.usefulNumber.tr,
      'subtitle': AppStrings.usefulNumbersSubtitle.tr,
      'onTap': () {
        context.pushNamed(RouteName.usefulMemberScreen);
      },
    },
    {
      'icon': AssetsPath.terms,
      'title': AppStrings.termsAndConditions.tr,
      'subtitle': AppStrings.termsAndConditionsSubtitle.tr,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WebViewScreen(url: ApiUrl.terms)),
        );
      },
    },
    {
      'icon': AssetsPath.privacy,
      'title': AppStrings.privacyPolicy.tr,
      'subtitle': AppStrings.privacyPolicySubtitle.tr,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrivacyPolicyScreen(url: ApiUrl.privacy),
          ),
        );
      },
    },
    {
      'icon': AssetsPath.help,
      'title': AppStrings.helpSupport.tr,
      'subtitle': AppStrings.helpSupportSubtitle.tr,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HelpSupportScreen()),
        );
      },
    },
    {
      'icon': AssetsPath.faq,
      'title': AppStrings.faq.tr,
      'subtitle': AppStrings.faqSubtitle.tr,
      'onTap': () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => FaqScreen()));
      },
    },
    {
      'icon': AssetsPath.share,
      'title': AppStrings.shareLink.tr,
      'subtitle': AppStrings.shareLinkSubtitle.tr,
      'onTap': () {
        showDialog(
          context: context,
          builder: (_) => ShareLinkDialog(
            shareUrl:
                'https://play.google.com/store/apps/details?id=me.platechat.app&pcampaignid=web_share',
            shareMessage: AppStrings.tryAmazingApp.tr,
          ),
        );
      },
    },
    {
      'icon': AssetsPath.blocked,
      'title': AppStrings.blockedUser5.tr,
      'subtitle': AppStrings.blockedUsersSubtitle.tr,
      'onTap': () {
        context.pushNamed(RouteName.block);
      },
    },
    {
      'icon': AssetsPath.remove,
      'title': AppStrings.delete.tr,
      'subtitle': AppStrings.deleteAccountSubtitle.tr,
      'onTap': () {
        context.pushNamed(RouteName.delete);
      },
    },
  ];

  return Column(
    children: [
      ...items.map(
        (item) => Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                item['icon'],
                width: ResponsiveHelper.iconSize(24),
                height: ResponsiveHelper.iconSize(24),
                colorFilter: const ColorFilter.mode(
                  // Color(0xFF445C92),
                  Color(0xFF005CB1),
                  BlendMode.srcIn,
                ),
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(16),
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                item['subtitle'],
                style: context.bodyLarge.copyWith(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: AppColors.black.withOpacity(0.6),
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.black.withOpacity(0.6),
              ),
              onTap: item['onTap'],
            ),
            Divider(height: 1, color: AppColors.divider),
          ],
        ),
      ),
      _buildLanguageDropdown(
        context: context,
        languageController: languageController,
      ),
    ],
  );
}

Widget _buildLanguageDropdown({
  required BuildContext context,
  required LanguageController languageController,
}) {
  return Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.translate,
          size: ResponsiveHelper.iconSize(24),
          color: AppColors.blue,
        ),
        title: Text(
          'language'.tr,
          style: context.titleSmall.copyWith(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          AppStrings.changeAppLanguage.tr,
          style: context.bodyLarge.copyWith(
            fontSize: ResponsiveHelper.fontSize(12),
            color: AppColors.black.withOpacity(0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Text(
                languageController.currentLanguageDisplay,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: Color(0xFF005CB1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: ResponsiveHelper.iconSize(20)),
          ],
        ),
        onTap: () => _showLanguageBottomSheet(context),
      ),
    ],
  );
}

void _showLanguageBottomSheet(BuildContext context) {
  final controller = Get.find<LanguageController>();

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ResponsiveHelper.borderRadius(20)),
      ),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(16)),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: ResponsiveHelper.spacing(8)),
              Text(
                'language'.tr,
                style: context.titleSmall.copyWith(
                  fontSize: ResponsiveHelper.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              ...controller.availableLanguageNames.map((language) {
                final isSelected = controller.isLanguageSelected(language);

                return ListTile(
                  title: Text(language),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () async {
                    await controller.saveLanguage(language);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }),
            ],
          );
        }),
      );
    },
  );
}
