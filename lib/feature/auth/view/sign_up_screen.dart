// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../core/router/route_path.dart';
import '../../../core/router/routes_name.dart';
import '../../../core/service/api_checker.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/auth_controller.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../repository/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.find<AuthController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool agree = false;
  bool agreeTerms = false; // required
  bool? agreeOtherTerms; // optional (nullable)

  String? selectedDesignation;

  @override
  void dispose() {
    nicknameController.dispose();
    licenseController.dispose();
    passwordController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, size: ResponsiveHelper.iconSize(24)),
        ),
        title: Text(
          'sign_up'.tr,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: ResponsiveHelper.fontSize(18),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveHelper.spacing(30)),

              /// Nickname
              CustomTextField(
                controller: nicknameController,
                title: 'nick_name'.tr,
                hintText: 'nick_name_hint'.tr,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'nickname_is_required'.tr
                    : null,
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Designation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'select_designation'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  DropdownButtonFormField2<String>(
                    value: selectedDesignation,
                    hint: Text(
                      'select'.tr,
                      style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(12),
                        vertical: ResponsiveHelper.padding(16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: ResponsiveHelper.borderWidth(1.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: ResponsiveHelper.borderWidth(2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: ResponsiveHelper.borderWidth(1.5),
                        ),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'owner',
                        child: Text(
                          'owner'.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'occasional_driver',
                        child: Text(
                          'occasional_driver'.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedDesignation = value),
                    validator: (value) =>
                        value == null ? 'please_select_designation'.tr : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: ResponsiveHelper.height(160),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: ResponsiveHelper.height(48),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(16),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// License Number
              CustomTextField(
                controller: licenseController,
                title: 'license_number'.tr,
                hintText: 'type_here'.tr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'License number is required';
                  } else if (value.trim().length < 7) {
                    return 'license_number_must_be'.tr;
                  }
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),
              /*CustomTextField(
                title: 'email'.tr,
                hintText: 'email_only_for_recover_password'.tr,
              )*/
              CustomTextField(
                controller: emailController,
                title: 'email'.tr,
                hintText: 'email_only_for_recover_password'.tr,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "Enter valid email";
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Password
              CustomTextField(
                controller: passwordController,
                title: 'password'.tr,
                hintText: 'password'.tr,
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

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                title: 'confirm_password'.tr,
                hintText: 'confirm_password'.tr,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'confirm_your_password'.tr;
                  }
                  if (value != passwordController.text) {
                    return 'password_do_not_match'.tr;
                  }
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(12)),

              /// Agree Terms
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ResponsiveHelper.width(24),
                    height: ResponsiveHelper.height(24),
                    child: Checkbox(
                      value: agree,
                      activeColor: Colors.green,
                      onChanged: (value) =>
                          setState(() => agree = value ?? false),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'i_agree_to'.tr + ' ',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),



              TextSpan(
                text: 'terms_and_conditions'.tr,
                style: GoogleFonts.poppins(
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: ResponsiveHelper.fontSize(14),
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Privacy Policy link open
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebViewScreen(
                            url: ApiUrl.terms
                        ),
                      ),
                    );
                  },
              ),









              TextSpan(
                text: ' and ',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: 'privacy_policy'.tr,
                style: GoogleFonts.poppins(
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: ResponsiveHelper.fontSize(14),
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Privacy Policy link open
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivacyPolicyScreen(
                          url: ApiUrl.privacy
                        ),
                      ),
                    );
                  },
              ),
            ],
          ),
        ),
      ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),

              // /// Other Terms
              // // Other Terms (Optional)
              // Row(
              //   children: [
              //     SizedBox(
              //       width: ResponsiveHelper.width(24),
              //       height: ResponsiveHelper.height(24),
              //       child: Checkbox(
              //         value: agreeOtherTerms ?? false,
              //         tristate: true, // allows null
              //         activeColor: Colors.green,
              //         onChanged: (value) =>
              //             setState(() => agreeOtherTerms = value),
              //       ),
              //     ),
              //     SizedBox(width: ResponsiveHelper.spacing(8)),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => context.pushNamed(RouteName.terms),
              //         child: RichText(
              //           text: TextSpan(
              //             style: TextStyle(
              //               fontSize: ResponsiveHelper.fontSize(13),
              //               color: Colors.black,
              //             ),
              //             children: [
              //               TextSpan(text: 'i_agree_to1'.tr + ' '),
              //               TextSpan(
              //                 text: 'agree_terms1'.tr,
              //                 style: TextStyle(
              //                   color: Colors.blue,
              //                   decoration: TextDecoration.underline,
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: ResponsiveHelper.fontSize(13),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: ResponsiveHelper.spacing(20)),

              /// Continue Button
              PrimaryButton(
                title: 'continue'.tr,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    showErrorSnackBar('please_fill_all_fields'.tr);
                    return;
                  }

                  if (!agree) {
                    showWarningSnackBar('please accept terms'.tr);
                    return;
                  }

                  showLoadingDialog(
                    message: 'creating_account'.tr,
                    context: context,
                  );

                  try {
                    final response = await AuthRepository().register(
                      licenceId: licenseController.text.trim(),
                      nickName: nicknameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      confirmPassword: confirmPasswordController.text.trim(),
                      designation: selectedDesignation!,
                    );

                    hideLoadingDialog(context);

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      showSuccessToast('registration_successful!'.tr);
                      if (context.mounted) {
                        context.go(RoutePath.signIn);
                      }
                    } else {
                      if (context.mounted) {
                        ApiChecker.checkApi(response, context);
                      }
                    }
                  } catch (e) {
                    hideLoadingDialog(context);
                    showErrorSnackBar('Error: $e');
                  }
                },
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: 'already_account1'.tr),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteName.signIn);
                          },
                          child: Text(
                            "sign_in".tr,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(14),
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600,
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
  }

  // void _handleSignUp() async {
  //   if (!_formKey.currentState!.validate()) {
  //     showErrorSnackBar('Please fill all fields');
  //     return;
  //   }

  //   if (!agree) {
  //     showErrorSnackBar('Please accept terms');
  //     return;
  //   }

  //   final success = await authController.registerAndLogin(
  //     context: context,
  //     licenceId: licenseController.text.trim(),
  //     nickName: nicknameController.text.trim(),
  //     password: passwordController.text.trim(),
  //     confirmPassword: confirmPasswordController.text.trim(),
  //     designation: selectedDesignation!,
  //   );

  //   if (success && context.mounted) {
  //     showSuccessToast('Registration successful!');
  //     context.goNamed(RouteName.signIn);
  //   }
  // }

  void showWarningSnackBar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }
}
