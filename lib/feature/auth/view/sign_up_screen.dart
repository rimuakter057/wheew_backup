// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../core/router/route_path.dart';
import '../../../core/router/routes_name.dart';
import '../../../core/service/api_checker.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/auth_controller.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../repository/auth_repository.dart';
import '../repository/country_list.dart';

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
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool agree = false;
  bool agreeTerms = false; // required
  bool? agreeOtherTerms; // optional (nullable)

  String? selectedDesignation;
  String? selectedCountry;


  @override
  void dispose() {
    nicknameController.dispose();
    licenseController.dispose();
    passwordController.dispose();
    emailController.dispose();
    countryController.dispose();
    cityController.dispose();
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
          AppStrings.signUp.tr,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: ResponsiveHelper.fontSize(18),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: ResponsiveHelper.spacing(30)),

              /// Nickname
              CustomTextField(
                controller: nicknameController,
                title:AppStrings.nickName.tr,
                hintText: AppStrings.typeHere1.tr,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.toLowerCase());
                  }),
                ],

                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.nicknameIsRequired.tr
                    : null,
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Designation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
              AppStrings.selectDesignation.tr,
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
                        AppStrings.select.tr,
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
                title:    AppStrings.licenseNumber.tr,
                hintText:    AppStrings.typeHere.tr,

                // validator: (value) {
                //   if (value == null || value.trim().isEmpty) {
                //     return 'License number is required';
                //   } else if (value.trim().length < 7) {
                //     return 'license_number_must_be'.tr;
                //   }
                //   return null;
                // },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'license_number_required'.tr;
                  }

                  final text = value.trim();

                  // Check total length
                  if (text.length < 6 || text.length > 7) {
                    return 'license_number_must_be'.tr;
                  }

                  // Count letters and numbers
                  final letterCount = RegExp(
                    r'[A-Za-z]',
                  ).allMatches(text).length;

                  final numberCount = RegExp(r'[0-9]').allMatches(text).length;

                  if (letterCount < 3 || numberCount < 3) {
                    return 'licence_validator'.tr;
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
                title: 'email'.tr + " (" + 'only_for_recovery'.tr + ")",
                hintText: 'type_here1'.tr,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "email_is_required".tr;
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "enter_valid_email".tr;
                  }
                  return null;
                },
              ),



              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Country
              // CustomTextField(
              //   controller: countryController,
              //   title: 'country'.tr,
              //   hintText: AppStrings.typeHere.tr,
              //   validator: (value) => (value == null || value.trim().isEmpty)
              //       ? 'country_is_required'.tr
              //       : null,
              // ),










              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'country'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  DropdownButtonFormField2<String>(
                    value: selectedCountry,
                    isExpanded: true,
                    hint: Text(
                      'select'.tr,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(16),
                      ),
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(12),
                        vertical: ResponsiveHelper.padding(16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    items: countries
                        .map(
                          (country) => DropdownMenuItem(
                        value: country,
                        child: Text(country, style: context.bodySmall,),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                        countryController.text = value ?? '';
                      });
                    },
                    validator: (value) =>
                    value == null ? 'country_is_required'.tr : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),




              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// City
              CustomTextField(
                controller: cityController,
                title: 'city'.tr,
                hintText: AppStrings.typeHere.tr,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'city_is_required'.tr
                    : null,
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
                  } else if (value.trim().length < 6) {
                    return 'password_must_be_6_characters'.tr;
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
                  } else if (value.trim().length < 6) {
                    return 'password_must_be_6_characters'.tr;
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
                        style: TextStyle(fontSize: 14, color: Colors.black),
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
                            text:    AppStrings.termsAndConditions.tr,
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
                                    builder: (_) =>
                                        WebViewScreen(url: ApiUrl.terms),
                                  ),
                                );
                              },
                          ),

                          TextSpan(
                            text:   AppStrings.and.tr,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:   AppStrings.privacyPolicy.tr,
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
                                      url: ApiUrl.privacy,
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

              SizedBox(height: ResponsiveHelper.spacing(20)),


              PrimaryButton(
                title: 'continue'.tr,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    showErrorSnackBar('please_fill_all_fields'.tr);
                    return;
                  }

                  if (selectedDesignation == null) {
                    showErrorSnackBar('please_select_designation'.tr);
                    return;
                  }

                  if (!agree) {
                    showWarningSnackBar('please accept terms'.tr);
                    return;
                  }

                  showLoadingDialog(message: 'creating_account'.tr, context: context);

                  try {
                    final response = await AuthRepository().register(
                      licenceId: licenseController.text.trim(),
                      nickName: nicknameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      confirmPassword: confirmPasswordController.text.trim(),
                      designation: selectedDesignation!,
                      country: selectedCountry ?? '',
                      city: cityController.text.trim(),
                    );

                    developer.log(
                      'Register Result -> code: ${response.statusCode}, body: ${response.body}',
                      name: 'SIGNUP',
                    );

                    // dialog বন্ধ করুন response আসার পরপরই, context চেক করার আগে
                    if (context.mounted) hideLoadingDialog(context);

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      // if (context.mounted) {
                      //   showSuccessToast('registration_successful'.tr);
                      //  // context.go(RoutePath.signIn);
                      //   context.go(RoutePath.vehicle);
                      // }

                      final data = jsonDecode(response.body); // 🔥 IMPORTANT

                      final token = data['token']; // or data['data']['token'] depending on API

                      if (token != null && token.isNotEmpty) {
                        await SharePrefsHelper.setString(AppConst.token, token);
                      }

                      if (context.mounted) {
                        showSuccessToast('registration_successful'.tr);
                        context.go(RoutePath.vehicle);
                      }


                    } else {
                      if (context.mounted) {
                        ApiChecker.checkApi(response);
                      }
                    }
                  }catch (e, st) {
                    developer.log('Register Exception: $e', name: 'SIGNUP');
                    developer.log('StackTrace: $st', name: 'SIGNUP');

                    if (context.mounted) {
                      hideLoadingDialog(context);

                      String userMessage;

                      if (e is TimeoutException) {

                        CustomSnackbar.error(message:"server_not_responding_check_connection", context: context);
                        userMessage = 'server_not_responding_check_connection'.tr;
                        // বাংলা ফলব্যাক: 'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। আপনার ইন্টারনেট/নেটওয়ার্ক চেক করুন।'
                      } else if (e is SocketException) {
                        userMessage = 'no_internet_connection_check_network'.tr;
                        CustomSnackbar.error(message:"no_internet_connection_check_network", context: context);
                        // 'ইন্টারনেট কানেকশন নেই অথবা সার্ভার আনরিচেবল।'
                      } else if (e is FormatException) {
                        userMessage = 'unexpected_server_response'.tr;
                        CustomSnackbar.error(message:"unexpected_server_respons", context: context);
                      } else {
                        userMessage = '${'something_went_wrong'.tr}';
                      }

                      showErrorSnackBar(userMessage);
                    }
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
