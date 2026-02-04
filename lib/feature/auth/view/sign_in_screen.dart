import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/controller/auth_controller.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/extension/string_extension.dart';

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
  bool rememberMe = false;

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
      );

      if (success && mounted) {
        context.goNamed(RouteName.chatList);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('sign_in'.tr),
      ),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    /// Logo
                    Image.asset(AssetsPath.signLogo),

                    const SizedBox(height: 40),

                    /// Email or License ID
                    CustomTextField(
                      controller: licenseController,
                      title: 'Email or License ID',
                      hintText: 'Enter email or license ID',
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Email or License ID is required'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    /// Password
                    CustomTextField(
                      controller: passwordController,
                      title: 'Password',
                      hintText: 'Enter your password',
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

                    const SizedBox(height: 10),

                    /// Remember Me & Forgot Password
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: controller.isLoading
                              ? null
                              : (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text('remember_me'.tr),
                        const Spacer(),
                        TextButton(
                          onPressed: controller.isLoading
                              ? null
                              : () {
                            context.pushNamed(RouteName.forgotPassword);
                          },
                          child: Text(
                            'forgot_password'.tr,
                            style: const TextStyle(color: Color(0xFFA5D6A7)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Sign In Button
                    controller.isLoading
                        ? const CircularProgressIndicator()
                        : PrimaryButton(
                      title: 'sign_in'.tr,
                      onTap: _handleLogin,
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