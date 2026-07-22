// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/google_sign_in.dart';
import 'package:platchatapp/feature/auth/view/widgets/custom_devider_or.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../helper/custom_image/custom_image.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/assets_path/assets_path.dart';
import '../repository/auth_controller.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';

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

  OutlineInputBorder _fieldBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(28)),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: SafeArea(
          child: GetBuilder<AuthController>(
            builder: (controller) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(24),
                    vertical: ResponsiveHelper.padding(12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Back button
                        // GestureDetector(
                        //   onTap: () => Navigator.pop(context),
                        //   child: SizedBox(
                        //     width: ResponsiveHelper.width(40),
                        //     height: ResponsiveHelper.height(40),
                        //     child: Icon(
                        //       Icons.arrow_back,
                        //       size: ResponsiveHelper.iconSize(22),
                        //       color: AppColors.black,
                        //     ),
                        //   ),
                        // ),

                        SizedBox(height: ResponsiveHelper.spacing(48)),

                        /// Logo
                        CustomImage(
                          imageSrc: AssetsPath.appLogoUpdate,
                          width: ResponsiveHelper.iconSize(72),
                          height: ResponsiveHelper.iconSize(72),
                        ),

                        SizedBox(height: ResponsiveHelper.spacing(24)),

                        /// Headline
                        Text(
                          AppStrings.startYourJourney.tr,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.titleFontSize(38),
                            fontWeight: FontWeight.w400,
                            height: 1,
                            color: AppColors.primaryText,
                          ),
                        ),

                        SizedBox(height: ResponsiveHelper.spacing(28)),

                        /// Email or License ID
                        CustomTextField(
                          controller: authController.licenseController,
                          title: AppStrings.licensePlateOrNickName.tr,
                          hintText: AppStrings.enterLicensePlateOrNickName.tr,
                          fillColor: Colors.white.withOpacity(0.55),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.padding(16),
                            vertical: ResponsiveHelper.padding(16),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: ResponsiveHelper.width(40),
                            minHeight: ResponsiveHelper.height(16),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: ResponsiveHelper.padding(14),
                              right: ResponsiveHelper.padding(8),
                            ),
                            child: CustomImage(
                              imageSrc: AssetsPath.profileLogin,
                              width: ResponsiveHelper.iconSize(16),
                              height: ResponsiveHelper.iconSize(16),
                            ),
                          ),
                          border: _fieldBorder(Colors.transparent, 1),
                          enabledBorder: _fieldBorder(Colors.transparent, 1),
                          focusedBorder: _fieldBorder(AppColors.blue, 1.5),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? AppStrings.licensePlateOrNicknameRequired.tr
                              : null,
                        ),

                        SizedBox(height: ResponsiveHelper.spacing(18)),

                        /// Password
                        CustomTextField(
                          controller: authController.passwordController,
                          title: AppStrings.password.tr,
                          hintText: AppStrings.enterYourPassword.tr,
                          isPassword: true,
                          fillColor: Colors.white.withOpacity(0.55),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.padding(16),
                            vertical: ResponsiveHelper.padding(16),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: ResponsiveHelper.width(40),
                            minHeight: ResponsiveHelper.height(16),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: ResponsiveHelper.padding(14),
                              right: ResponsiveHelper.padding(8),
                            ),
                            child: CustomImage(
                              imageSrc: AssetsPath.passwordLogin,
                              width: ResponsiveHelper.iconSize(16),
                              height: ResponsiveHelper.iconSize(16),
                            ),
                          ),
                          border: _fieldBorder(Colors.transparent, 1),
                          enabledBorder: _fieldBorder(Colors.transparent, 1),
                          focusedBorder: _fieldBorder(AppColors.blue, 1.5),
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

                        SizedBox(height: ResponsiveHelper.spacing(6)),

                        Row(
                          children: [
                            /// Remember me section
                            Flexible(
                              child: Obx(() {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: ResponsiveHelper.width(24),
                                      height: ResponsiveHelper.height(24),
                                      child: Checkbox(
                                        value: controller.isRememberMe.value,
                                        onChanged: (value) {
                                          controller.isRememberMeToggle();
                                        },
                                        activeColor: AppColors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveHelper.borderRadius(5),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: ResponsiveHelper.width(8)),

                                    Flexible(
                                      child: Text(
                                        AppStrings.rememberMe.tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: ResponsiveHelper.fontSize(
                                            14,
                                          ),
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),

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
                            ? const Center(child: CircularProgressIndicator())
                            : CustomGradientButton(
                                label: AppStrings.continueText.tr,
                                onPressed: _handleLogin,
                              ),
                        SizedBox(height: ResponsiveHelper.spacing(24)),

                        CustomDividerOr(
                          dividerColor: AppColors.blueGrey,
                          textColor: AppColors.secondaryText,
                        ),

                        SizedBox(height: ResponsiveHelper.spacing(24)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(
                              icon: AssetsPath.apple,
                              onTap: () {},
                            ),

                            SizedBox(width: ResponsiveHelper.width(24)),
                            SocialButton(
                              icon: AssetsPath.google,
                              onTap: () async {
                                final account = await GoogleSignInService()
                                    .signIn();

                                if (account != null) {
                                  print("Login Success");
                                }
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: ResponsiveHelper.spacing(28)),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                color: AppColors.secondaryText,
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
                                      style: GoogleFonts.poppins(
                                        color: AppColors.blue,
                                        fontSize: ResponsiveHelper.fontSize(
                                          14,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.blue
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: ResponsiveHelper.spacing(16)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CustomImage(
            imageSrc: icon,
            height: ResponsiveHelper.height(22),
            width: ResponsiveHelper.width(22),
          ),
        ),
      ),
    );
  }
}
