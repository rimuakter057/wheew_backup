import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_path.dart';
import '../../../core/router/routes_name.dart';
import '../../../core/service/api_checker.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/controller/auth_controller.dart';
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
        title: Text('sign_up'.tr, style: const TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 30),
              /// Nickname
              CustomTextField(
                controller: nicknameController,
                title: 'nick_name'.tr,
                hintText: 'nick_name_hint'.tr,
                validator: (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'Nickname is required'
                    : null,
              ),

              const SizedBox(height: 16),
              /// Designation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Designation',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField2<String>(
                    value: selectedDesignation,
                    hint: const Text('Select'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.blue, width: 1.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.blue, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      DropdownMenuItem(
                          value: 'occasional_driver',
                          child: Text('Occasional Driver')),
                    ],
                    onChanged: (value) => setState(() => selectedDesignation = value),
                    validator: (value) =>
                    value == null ? 'Please select designation' : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ],
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              /// License Number
              CustomTextField(
                controller: licenseController,
                title: 'license_number'.tr,
                hintText: 'license_hint'.tr,
                validator: (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'License number is required'
                    : null,
              ),

              const SizedBox(height: 16),
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

              const SizedBox(height: 16),
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
              //const SizedBox(height: 16),

              /* /// Email (Recovery)
              CustomTextField(
                controller: emailController,
                title: 'Email for Recovery password'.tr,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),*/

              const SizedBox(height: 12),
              /// Agree Terms
              Row(
                children: [
                  Checkbox(
                      value: agree,
                      activeColor: Colors.green,
                      onChanged: (value) =>
                          setState(() => agree = value ?? false)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.pushNamed(RouteName.terms),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: ResponsiveHelper.titleFontSize(13),
                              color: Colors.black),
                          children: [
                            TextSpan(text: 'i_agree_to'.tr + ' '),
                            TextSpan(
                              text: 'terms_and_conditions'.tr,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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

                  // ✅ Pass context to showLoadingDialog
                  showLoadingDialog(
                    message: 'Creating account...',
                    context: context,  // 👈 Add this
                  );

                  try {
                    final response = await AuthRepository().register(
                      licenceId: licenseController.text.trim(),
                      nickName: nicknameController.text.trim(),
                      password: passwordController.text.trim(),
                      confirmPassword: confirmPasswordController.text.trim(),
                      designation: selectedDesignation!,
                    );

                    hideLoadingDialog(context); // 👈 Pass context

                    if (response.statusCode == 200 || response.statusCode == 201) {
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar('Please fill all fields');
      return;
    }

    if (!agree) {
      showErrorSnackBar('Please accept terms');
      return;
    }

    final success = await authController.registerAndLogin(
      context: context,
      licenceId: licenseController.text.trim(),
      nickName: nicknameController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      designation: selectedDesignation!,
    );

    if (success && context.mounted) {
      showSuccessToast('Registration successful!');
      context.goNamed(RouteName.signIn);
    }
  }

  void showWarningSnackBar(String s) {}
}
