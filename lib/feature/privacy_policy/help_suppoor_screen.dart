
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';


class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    controller.fetchHelpSupport();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: CustomAppBar(title: "help_support".tr),
      body: Obx(() {
        if (controller.isLoadingHelp.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
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

        return Center(
          child: Padding(
            padding:  ResponsiveHelper.all(24),
            child: Text(
              controller.message.value,
              style: context.bodyMedium.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }
}