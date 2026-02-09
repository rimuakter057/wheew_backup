// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool agree = false;
  String? selectedDesignation;

  @override
  void dispose() {
    nicknameController.dispose();
    licenseController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'sign_up'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.fontSize(18),
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
                    ? 'Nickname is required'
                    : null,
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Designation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Designation',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  DropdownButtonFormField2<String>(
                    value: selectedDesignation,
                    hint: Text(
                      'Select',
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
                          'Owner',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'occasional_driver',
                        child: Text(
                          'Occasional Driver',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedDesignation = value),
                    validator: (value) =>
                        value == null ? 'Please select designation' : null,
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
                hintText: 'license_hint'.tr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'License number is required';
                  } else if (value.trim().length < 7) {
                    return 'License number must be at least 7 characters';
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
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
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
                    return 'Confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(12)),

              /// Agree Terms
              Row(
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
                    child: GestureDetector(
                      onTap: () => context.pushNamed(RouteName.terms),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(13),
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(text: 'i_agree_to'.tr + ' '),
                            TextSpan(
                              text: 'terms_and_conditions'.tr,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveHelper.fontSize(13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.spacing(20)),

              /// Continue Button
              PrimaryButton(
                title: 'continue'.tr,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    showErrorSnackBar('Please fill all fields');
                    return;
                  }

                  if (!agree) {
                    showWarningSnackBar('Please accept terms');
                    return;
                  }

                  showLoadingDialog(
                    message: 'Creating account...',
                    context: context,
                  );

                  try {
                    final response = await AuthRepository().register(
                      licenceId: licenseController.text.trim(),
                      nickName: nicknameController.text.trim(),
                      password: passwordController.text.trim(),
                      confirmPassword: confirmPasswordController.text.trim(),
                      designation: selectedDesignation!,
                    );

                    hideLoadingDialog(context);

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      showSuccessToast('Registration successful!');
                      if (context.mounted) {
                        context.go(RoutePath.chatList);
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
