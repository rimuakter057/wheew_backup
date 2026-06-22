import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
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
    controller.fetchHelpSupport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.helpSupport.tr),
      body: Obx(() {
        if (controller.isLoadingHelp.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: context.bodyMedium.copyWith(color: AppColors.errorColor),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Padding(
          padding: ResponsiveHelper.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon at top
              Container(
                width: ResponsiveHelper.width(72),
                height: ResponsiveHelper.height(72),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headset_mic_outlined,
                  color: AppColors.blue,
                  size: ResponsiveHelper.width(34),
                ),
              ),

              SizedBox(height: ResponsiveHelper.height(20)),

              // Support text 1
              Text(
                "support_text1".tr,
                style: context.bodyLarge.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: ResponsiveHelper.height(16)),

              // Email button with card style
              GestureDetector(
                onTap: () => _launchEmail(controller.message.value),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.width(20),
                    vertical: ResponsiveHelper.height(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.blue.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.blue,
                        size: ResponsiveHelper.width(24),
                      ),
                      SizedBox(width: ResponsiveHelper.width(8)),
                      Flexible(
                        // ✅ added
                        child: Text(
                          controller.message.value,
                          style: context.bodyLarge.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3, // ✅ added
                          overflow: TextOverflow.ellipsis, // ✅ added
                        ),
                      ),
                    ],
                  ),
                ),
                /*Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.width(20),
                    vertical: ResponsiveHelper.height(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.blue.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.blue,
                        size: ResponsiveHelper.width(18),
                      ),
                      SizedBox(width: ResponsiveHelper.width(8)),
                      Text(
                        controller.message.value,
                        style: context.bodyLarge.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),*/
              ),

              SizedBox(height: ResponsiveHelper.height(16)),

              // Support text 2
              Text(
                "support_text2".tr,
                style: context.bodyLarge.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

Future<void> _launchEmail(String email) async {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return;

  final subject = Uri.encodeComponent('support_request'.tr);
  final mailto = 'mailto:${Uri.encodeComponent(trimmed)}?subject=$subject';
  final emailUri = Uri.parse(mailto);

  try {
    if (await canLaunchUrl(emailUri)) {
      final ok = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
    }
    throw StateError('launch_failed');
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: trimmed));
    Get.snackbar(
      'email_copied'.tr,
      '${'email_copied'.tr}: $trimmed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.blue.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
