import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';

import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'forgot_password'.tr,
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.padding(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveHelper.spacing(20)),

            Text(
              'forgot_password'.tr,
              style: TextStyle(
                fontSize: ResponsiveHelper.titleFontSize(20),
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            Text(
              "don't_worry_enter_your_email".tr,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(24)),

            CustomTextField(
              title: 'email'.tr,
              hintText: 'enter_your_email_here'.tr,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(50),
              child: PrimaryButton(
                title: 'send_otp'.tr,
                onTap: () {
                  context.goNamed(RouteName.otp);
                },
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),
          ],
        ),
      ),
    );
  }
}