
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/helper/common_container/common_container.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../../utils/language/app_string.dart';
import '../widgets/profile_nav/profile_header.dart';
import '../widgets/profile_nav/profile_menu_item_card.dart';
import '../widgets/profile_nav/profile_nav_appbar.dart';

class ProfileNavScreen extends StatefulWidget {
  const ProfileNavScreen({super.key});

  @override
  State<ProfileNavScreen> createState() => _ProfileNavScreenState();
}

class _ProfileNavScreenState extends State<ProfileNavScreen> {
  final LanguageController languageController = Get.find<LanguageController>();
  final ScanController scanController = Get.put(ScanController());
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController(), permanent: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!profileController.isEditing) {
        profileController.reloadProfile();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: ProfileNavAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: GetBuilder<ProfileController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.maxContentWidth,
                  ),
                  padding: ResponsiveHelper.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///profile card====================
                      ProfileHeaderCard(
                        controller: controller,

                        scanController: scanController,
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(24)),

                      /// Account & Settings =======================
                      _sectionTitle(context, AppStrings.accountAndSettings.tr),
                      SizedBox(height: ResponsiveHelper.spacing(12)),
                      CommonContainer(
                        bgColor: Color(0xFFD8E0EB),
                        child: buildAccountSettingsItems(
                          context: context,
                          profileController: profileController,
                          languageController: languageController,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(24)),

                      /// Support & Legal ==========================
                      _sectionTitle(context, AppStrings.supportAndLegal.tr),
                      SizedBox(height: ResponsiveHelper.spacing(12)),
                      CommonContainer(
                        bgColor: Color(0xFFD8E0EB),
                        child: buildSupportLegalItems(context: context),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(24)),

                      /// Account Actions ==========================
                      _sectionTitle(context, AppStrings.accountActions.tr),
                      SizedBox(height: ResponsiveHelper.spacing(12)),
                      CommonContainer(
                        bgColor: Color(0xFFD8E0EB),
                        child: buildAccountActionsItems(context: context),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(140)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.bodyLarge.copyWith(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

}




