import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/auth_controller.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthController authController = Get.find<AuthController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    licenseController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      bool success = await authController.login(
        context: context,
        identifier: licenseController.text.trim(),
        password: passwordController.text.trim(),
        rememberMe: true, // Always save login for auto-login
      );

      // if (success && mounted) {
      //  // context.goNamed(RouteName.chatList);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title:    'sign_in'.tr,),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveHelper.spacing(40)),

                    /// Logo
                    Image.asset(
                      AssetsPath.signLogo,
                      width: ResponsiveHelper.width(200),
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(40)),

                    /// Email or License ID
                    CustomTextField(
                      controller: licenseController,
                      title: 'license_plate_or_nick_name'.tr,
                      hintText: 'enter_license_plate_or_nick_name'.tr,
                      validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Email or License ID is required'
                          : null,
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(16)),

                    /// Password
                    CustomTextField(
                      controller: passwordController,
                      title: 'password'.tr,
                      hintText: 'enter_your_password'.tr,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'password_is_required'.tr;
                        }
                        if (value.length < 6) {
                          return 'password_must_6_character'.tr;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(10)),

                    /// Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.isLoading
                            ? null
                            : () {
                          context.pushNamed(RouteName.forgotPassword);
                        },
                        child: Text(
                          'forgot_password'.tr,
                          style: TextStyle(
                            color: const Color(0xFFA5D6A7),
                            fontSize: ResponsiveHelper.fontSize(14),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(20)),

                    /// Sign In Button
                    controller.isLoading
                        ? const CircularProgressIndicator()
                        : PrimaryButton(
                      title: 'sign_in'.tr,
                      onTap: _handleLogin,
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(8)),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            //fontStyle: FontStyle.italic,
                          ),
                          children: [
                            TextSpan(text: 'do_not_account'.tr),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(RouteName.signUp);
                                },
                                child: Text(
                                  "sign_up".tr,
                                  style: TextStyle(
                                    color: AppColors.blue,
                                    //decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                    //fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}