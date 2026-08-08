import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../../../core/router/routes_name.dart';
import '../../../../../core/service/api_url.dart';
import '../../../../../core/service/storage_service.dart';
import '../../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../../language/language_controller.dart';
import '../../../../../utils/app_const/app_const.dart';
import '../../../../../utils/assets_path/assets_path.dart';
import '../../../../../utils/color/app_colors.dart';
import '../../../../../utils/language/app_string.dart';
import '../../../../chat/view/message/controller/message_controller.dart';
import '../../../../faq/presentation/screens/faq_screen.dart';
import '../../../../notification/controller/notification_controller.dart';
import '../../../../privacy_policy/help_suppoor_screen.dart';
import '../../../../privacy_policy/privacy_policy_screen.dart';
import '../../../../terms_condition/web_view_screen.dart';
import '../../../repository/profile_controller.dart';
import '../share_link_dialog.dart';

/// â”€â”€ Account & Settings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Widget buildAccountSettingsItems({
  required BuildContext context,
  required ProfileController profileController,
  required LanguageController languageController,
}) {
  final List<Map<String, dynamic>> items = [
    {
      'icon': AssetsPath.personalInfo,
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
  ];

  return Column(
    children: [
      ..._buildItemTiles(items),
      _buildLanguageDropdown(
        context: context,
        languageController: languageController,
      ),
    ],
  );
}

/// â”€â”€ Support & Legal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Widget buildSupportLegalItems({required BuildContext context}) {
  final List<Map<String, dynamic>> items = [
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
      'icon': AssetsPath.share,
      'title': AppStrings.shareApp.tr,
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
      'icon': AssetsPath.blockedUsers,
      'title': AppStrings.blockedUser5.tr,
      'subtitle': AppStrings.blockedUsersSubtitle.tr,
      'onTap': () {
        context.pushNamed(RouteName.block);
      },
    },
  ];

  return Column(children: _buildItemTiles(items, showLastDivider: false));
}

/// â”€â”€ Account Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Widget buildAccountActionsItems({required BuildContext context}) {
  final List<Map<String, dynamic>> items = [
    {
      'icon': AssetsPath.delete,
      'title': AppStrings.delete.tr,
      'subtitle': AppStrings.deleteAccountSubtitle.tr,
      'iconColor': AppColors.errorColor,
      'titleColor': AppColors.errorColor,
      'onTap': () {
        context.pushNamed(RouteName.delete);
      },
    },
    {
      'icon': null,
      'materialIcon': Icons.logout,
      'title': AppStrings.logOut.tr,
      'subtitle': AppStrings.logOutSubtitle.tr,
      'iconColor': AppColors.errorColor,
      'titleColor': AppColors.black,
      'onTap': () => _handleLogout(context),
    },
  ];

  return Column(children: _buildItemTiles(items, showLastDivider: false));
}

Future<void> _handleLogout(BuildContext context) async {
  await SharePrefsHelper.remove(AppConst.token);
  await SharePrefsHelper.remove(AppConst.userID);
  await SharePrefsHelper.remove(AppConst.userData);
  await SharePrefsHelper.remove(AppConst.licenceId);
  await SharePrefsHelper.remove(AppConst.nickName);
  await SharePrefsHelper.remove(AppConst.avatar);
  await SharePrefsHelper.remove(AppConst.loginUser);
  await SharePrefsHelper.remove(AppConst.loginPass);
  await SharePrefsHelper.remove(AppConst.licenseNoVerified);
  await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);

  // Clear the previous account's notification/message-request badges so
  // the next login doesn't briefly show stale data before its own fetch lands.
  if (Get.isRegistered<NotificationController>()) {
    final notificationController = Get.find<NotificationController>();
    notificationController.notifications.clear();
    notificationController.unreadCount.value = 0;
  }
  if (Get.isRegistered<MessageController>()) {
    final messageController = Get.find<MessageController>();
    messageController.messageRequests.clear();
    messageController.totalRequestsCount.value = 0;
  }

  if (context.mounted) {
    context.goNamed(RouteName.welcome);
  }
}

List<Widget> _buildItemTiles(
  List<Map<String, dynamic>> items, {
  bool showLastDivider = true,
}) {
  return List.generate(items.length, (index) {
    final item = items[index];
    final bool isLast = index == items.length - 1;
    final Color iconColor = item['iconColor'] ?? const Color(0xFF005CB1);
    final Color titleColor = item['titleColor'] ?? AppColors.black87;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: item['icon'] != null
              ? SvgPicture.asset(
                  item['icon'],
                  width: ResponsiveHelper.iconSize(24),
                  height: ResponsiveHelper.iconSize(24),
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                )
              : Icon(
                  item['materialIcon'] as IconData,
                  color: iconColor,
                  size: ResponsiveHelper.iconSize(24),
                ),
          title: Text(
            item['title'],
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(16),
              color: titleColor,
            ),
          ),
          subtitle: Text(
            item['subtitle'],
            style: TextStyle(
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
        if (!isLast || showLastDivider)
          Divider(height: 1, color: AppColors.divider),
      ],
    );
  });
}

Widget _buildLanguageDropdown({
  required BuildContext context,
  required LanguageController languageController,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: SvgPicture.asset(
      AssetsPath.languageIcon,
      width: ResponsiveHelper.iconSize(24),
      height: ResponsiveHelper.iconSize(24),
      colorFilter: ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
    ),
    title: Text(
      AppStrings.language.tr,
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
              color: const Color(0xFF005CB1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(Icons.chevron_right, size: ResponsiveHelper.iconSize(20)),
      ],
    ),
    onTap: () => _showLanguageBottomSheet(context),
  );
}

void _showLanguageBottomSheet(BuildContext context) {
  final controller = Get.find<LanguageController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(
          ResponsiveHelper.borderRadius(20),
        ),
      ),
    ),
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveHelper.borderRadius(20),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: ResponsiveHelper.spacing(16),
          ),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(32),
                    height: ResponsiveHelper.height(4),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                SizedBox(
                  height: ResponsiveHelper.spacing(22),
                ),

                Text(
                  AppStrings.language.tr,
                  style: context.titleSmall.copyWith(
                    fontSize: ResponsiveHelper.fontSize(20),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height: ResponsiveHelper.spacing(16),
                ),

                ...controller.availableLanguageNames.map((language) {
                  final isSelected =
                  controller.isLanguageSelected(language);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveHelper.spacing(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(22),
                      ),
                      onTap: () async {
                        await controller.saveLanguage(language);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: ResponsiveHelper.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: isSelected?AppColors.blue:AppColors.white),
                          gradient: isSelected
                              ? AppColors.buttonGradient
                              : null,
                          color: isSelected
                              ? null
                              : AppColors.iceBlue,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.borderRadius(22),
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: AppColors.buttonGradientColor2
                                  .withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    language == 'English'
                                        ? 'English (UK)'
                                        : language,
                                    style: context.bodyMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ResponsiveHelper.spacing(4),
                                  ),
                                  Text(
                                    language == 'English'
                                        ? 'English'
                                        : 'Italiano',
                                    style: context.bodySmall.copyWith(
                                      color: isSelected
                                          ? AppColors.white.withValues(alpha: 0.7)
                                          : AppColors.black.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),


                SizedBox(
                  height: ResponsiveHelper.spacing(44),
                ),
              ],
            );
          }),
        ),
      );
    },
  );
}


