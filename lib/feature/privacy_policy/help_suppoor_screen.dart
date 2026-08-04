import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.fetchHelpSupport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: AppStrings.helpSupport.tr,
         bgColor: AppColors.lightBlue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: Obx(() {
          if (controller.isLoadingHelp.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: context.bodyMedium.copyWith(
                  color: AppColors.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: Padding(
                padding: ResponsiveHelper.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Support Icon
                  CustomImage(imageSrc: AssetsPath.helpSupport),
                    SizedBox(
                      height: ResponsiveHelper.height(18),
                    ),

                    /// Title
                    Text(
                      "Contact us at",
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveHelper.height(20),
                    ),

                    /// Email Button
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () =>
                          _launchEmail(controller.message.value),
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: ResponsiveHelper.width(230),
                          maxWidth: ResponsiveHelper.width(320),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.width(22),
                          vertical: ResponsiveHelper.height(14),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.45),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withOpacity(.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.blue,
                              size: ResponsiveHelper.width(20),
                            ),
                            // SizedBox(
                            //   width: ResponsiveHelper.width(4),
                            // ),
                            Expanded(
                              child: Text(
                                controller.message.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.bodyLarge.copyWith(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveHelper.height(18),
                    ),

                    /// Description
                    Text(
                      AppStrings.supportText2.tr,
                      textAlign: TextAlign.center,
                      style: context.bodyLarge.copyWith(
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w400,

                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

Future<void> _launchEmail(String email) async {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return;

  final subject = Uri.encodeComponent(AppStrings.supportRequest.tr);
  final emailUri = Uri.parse(
    'mailto:${Uri.encodeComponent(trimmed)}?subject=$subject',
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) return;
    }

    throw Exception();
  } catch (_) {
    await Clipboard.setData(
      ClipboardData(text: trimmed),
    );

    Get.snackbar(
      AppStrings.emailCopied.tr,
      trimmed,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.blue,
      colorText: Colors.white,
    );
  }
}