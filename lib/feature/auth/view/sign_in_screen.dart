// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/google_sign_in.dart';
import 'package:platchatapp/feature/auth/view/widgets/custom_devider_or.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../helper/custom_image/custom_image.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/assets_path/assets_path.dart';
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

  // @override
  // void dispose() {
  //   authController.licenseController.dispose();
  //   authController.passwordController.dispose();
  //   super.dispose();
  // }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final rawIdentifier = authController.licenseController.text.trim();

      // license plate হোক বা nickname — backend-এ পাঠানোর আগে lowercase করে দেওয়া হচ্ছে
      final identifier = rawIdentifier.toLowerCase();

      bool success = await authController.login(
        context: context,
        identifier: identifier,
        password: authController.passwordController.text.trim(),
        rememberMe: true,
      );

      // if (success && mounted) {
      //  // context.goNamed(RouteName.chatList);
      // }
    }
  }

  @override
  void initState() {
    authController.isRememberMeLoadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppStrings.signIn.tr),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// Logo
                    /* Image.asset(
                      AssetsPath.signLogo,
                      width: ResponsiveHelper.width(120),
                    ),*/
                    // Lottie.asset(
                    //   'assets/animations/icon_animated.json',
                    //   width: ResponsiveHelper.iconSize(120),
                    //   fit: BoxFit.cover,
                    //   repeat: true,
                    // ),
                    //
                    CustomImage(
                      imageSrc: AssetsPath.appLogoUpdate,
                      width: ResponsiveHelper.iconSize(200),
                      height: ResponsiveHelper.iconSize(200),
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(18)),

                    /// Email or License ID
                    CustomTextField(
                      controller: authController.licenseController,
                      title: AppStrings.licensePlateOrNickName.tr,
                      hintText: AppStrings.enterLicensePlateOrNickName.tr,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? AppStrings.licensePlateOrNicknameRequired.tr
                          : null,
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(16)),

                    /// Password
                    CustomTextField(
                      controller: authController.passwordController,
                      title: AppStrings.password.tr,
                      hintText: AppStrings.enterYourPassword.tr,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.passwordIsRequired.tr;
                        }
                        if (value.length < 6) {
                          return AppStrings.passwordMust6Character.tr;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(10)),

                    // /// check box with remember me and forgot button
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: controller.isLoading
                    //         ? null
                    //         : () {
                    //       context.pushNamed(RouteName.forgotPassword);
                    //     },
                    //     child: Text(
                    //       AppStrings.forgotPassword.tr,
                    //       style: GoogleFonts.poppins(
                    //         color: AppColors.blue,
                    //         fontSize: ResponsiveHelper.fontSize(14),
                    //         fontWeight: FontWeight.w400,
                    //         decoration: TextDecoration.underline,
                    //         decorationColor: AppColors.blue
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Row(
                      children: [
                        /// Remember me section
                        Flexible(
                          child: Obx(() {
                            return Row(
                              children: [
                                Checkbox(
                                  value: controller.isRememberMe.value,
                                  onChanged: (value) {
                                    controller.isRememberMeToggle();
                                  },
                                  activeColor: AppColors.blue,
                                ),

                                Flexible(
                                  child: Text(
                                    AppStrings.rememberMe.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveHelper.fontSize(14),
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),

                        //  const Spacer(),

                        /// Forgot password
                        TextButton(
                          onPressed: () {
                            context.pushNamed(RouteName.forgotPassword);
                          },
                          child: Text(
                            AppStrings.forgotPassword.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.blue,
                              fontSize: ResponsiveHelper.fontSize(14),
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(20)),

                    /// Sign In Button
                    controller.isLoading
                        ? const CircularProgressIndicator()
                        : PrimaryButton(
                            title: AppStrings.signIn.tr,
                            onTap: _handleLogin,
                          ),
                    SizedBox(height: ResponsiveHelper.spacing(18)),

                    // CustomDividerOr(),
                    //
                    // SizedBox(height: ResponsiveHelper.spacing(28)),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     SocialButton(icon: AssetsPath.apple, onTap: () {}),
                    //
                    //     SizedBox(width: ResponsiveHelper.width(36)),
                    //     SocialButton(
                    //       icon: AssetsPath.google,
                    //       onTap: () async {
                    //         final account = await GoogleSignInService()
                    //             .signIn();
                    //
                    //         if (account != null) {
                    //           print("Login Success");
                    //         }
                    //       },
                    //     ),
                    //   ],
                    // ),

                    SizedBox(height: ResponsiveHelper.spacing(28)),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            //fontStyle: FontStyle.italic,
                          ),
                          children: [
                            TextSpan(text: AppStrings.doNotAccount.tr),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(RouteName.signUp);
                                },
                                child: Text(
                                  AppStrings.signUp.tr,
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

class SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const SocialButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveHelper.width(52),
        height: ResponsiveHelper.height(52),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          border: Border.all(color: AppColors.inputBorderColor),
        ),
        child: Center(
          child: CustomImage(
            imageSrc: icon,
            height: ResponsiveHelper.height(24),
            width: ResponsiveHelper.width(24),
          ),
        ),
      ),
    );
  }
}
