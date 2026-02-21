import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';

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
      appBar: CustomAppBar(title: 'forgot_password'.tr),

      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveHelper.spacing(20)),

            Text(
              'forgot_password'.tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.titleFontSize(18),
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            Text(
              "don't_worry_enter_your_email".tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(24)),

            CustomTextField(
              title: 'email'.tr,
              hintText: 'enter_your_email_here'.tr,
              controller: emailController,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(50),
              child: PrimaryButton(
                title: 'send_otp'.tr,


                onTap: () async {

                  if (emailController.text.isEmpty) {

                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text("email_required".tr),
                      ),
                    );

                    return;
                  }

                  bool success = await controller.sendOtp(
                    email: emailController.text,
                    context: context,
                  );

                  if (success) {

                    context.pushNamed(RouteName.otp,
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
    );
  }
}
