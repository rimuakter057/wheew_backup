import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'reset_code'.tr),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            CustomTextField(title: 'new_password'.tr),
            const SizedBox(height: 16),
            CustomTextField(title: 'confirm_password'.tr),
            const Spacer(),
            PrimaryButton(
              title: 'save'.tr,
              onTap: () {
                context.pushNamed(RouteName.signIn);
              },
            ),
          ],
        ),
      ),
    );
  }
}
