import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.forgotPassword.tr,


      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: ResponsiveHelper.spacing(20)),
            Text(
              AppStrings.forgotPassword.tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.titleFontSize(18),
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            Text(
              AppStrings.dontWorryEnterYourEmail
                  .tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                color: AppColors.grey,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(24)),

            CustomTextField(
              title: AppStrings.email.tr,
              hintText: AppStrings.pleaseEnterValidEmail.tr,
              controller: emailController,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(50),
              child: PrimaryButton(
                title: AppStrings.sendOtp.tr,

                onTap: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.emailIsRequired.tr)),
                    );

                    return;
                  }

                  bool success = await controller.sendOtp(
                    email: emailController.text,
                    context: context,
                  );

                  if (success) {
                    context.pushNamed(
                      RouteName.otp,
                      extra: emailController.text.trim(),
                    );

                    emailController.clear();
                  }
                },
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),
          ],
        ),
        ),
      ),
    );
  }
}

