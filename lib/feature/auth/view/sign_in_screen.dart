import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/utils/assets_path.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/extension/string_extension.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    licenseController.dispose();
    passwordController.dispose();
    super.dispose();
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

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveHelper.padding(20),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Avatar
             /* CircleAvatar(
                radius: ResponsiveHelper.width(60),
                backgroundColor: Colors.transparent, // Optional: if you want no background
                child: Image.asset(
                  AssetsPath.signLogo,
                  width: ResponsiveHelper.iconSize(60),
                  height: ResponsiveHelper.iconSize(70),
                ),
              ),*/
              Image.asset(
                AssetsPath.signLogo,
              ),

              const SizedBox(height: 40),

              /// Nickname
              CustomTextField(
                controller: licenseController,
                title: 'nick_name'.tr,
                hintText: 'nick_name_hint'.tr,
              ),

              const SizedBox(height: 16),

              /// Password
              CustomTextField(
                controller: passwordController,
                title: 'confirm_password'.tr,
                hintText: 'confirm_password'.tr,
                isPassword: true,
              ),

              const SizedBox(height: 10),

              /// Remember Me
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                  ),
                  Text('remember_me'.tr),
                  const Spacer(),
                  Text(
                    'forgot_password'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Sign In Button
              PrimaryButton(
                title: 'sign_in'.tr,
                onTap: () {
                  context.goNamed(RouteName.chatList);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}