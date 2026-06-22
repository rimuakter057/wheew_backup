import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.otpToken,
    required this.email,
  });
  final String otpToken;
  final String email;
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool obscurePassword = true;
  final AuthController controller = AuthController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmedPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint(
      "==============================${widget.email}========================${widget.otpToken}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.resetCode.tr),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            CustomTextField(
              title: AppStrings.newPassRequired.tr,
              controller: newPasswordController,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              title: AppStrings.confirmPassword.tr,
              controller: confirmedPasswordController,
            ),

            const Spacer(),

            PrimaryButton(
              title: AppStrings.save.tr,
              onTap: () async {
                // ✅ Validation
                if (newPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.newPassRequired.tr)),
                  );
                  return;
                }

                if (confirmedPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.confirmedPassRequired.tr)),
                  );
                  return;
                }

                if (newPasswordController.text !=
                    confirmedPasswordController.text) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AppStrings.passNotMatch.tr)));
                  return;
                }

                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AppStrings.passwordMust6Character.tr)));
                  return;
                }

                // ✅ Call reset API
                bool success = await controller.resetOtp(
                  email: widget.email,
                  password: newPasswordController.text,
                  token: widget.otpToken,
                  context: context,
                );

                if (success) {
                  context.pushNamed(RouteName.signIn); // navigate to Sign In
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
