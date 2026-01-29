import 'package:flutter/material.dart';
import 'package:platchatapp/feature/auth/view/terms_and_condition_screen.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/extension/string_extension.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool agree = false;

  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'sign_up'.tr,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            /// Nickname
            CustomTextField(
              controller: nicknameController,
              title: 'nick_name'.tr,
              hintText: 'nick_name_hint'.tr,
            ),

            const SizedBox(height: 16),

            /// License Number
            CustomTextField(
              controller: licenseController,
              title: 'license_number'.tr,
              hintText: 'license_hint'.tr,
            ),

            const SizedBox(height: 16),

            /// Password
            CustomTextField(
              controller: passwordController,
              title: 'password'.tr,
              hintText: 'password'.tr,
              isPassword: true,
            ),

            const SizedBox(height: 16),

            /// Confirm Password
            CustomTextField(
              controller: confirmPasswordController,
              title: 'confirm_password'.tr,
              hintText: 'confirm_password'.tr,
              isPassword: true,
            ),

            const SizedBox(height: 12),

            /// Agree terms
            /// Agree terms with clickable link
            Row(
              children: [
                Checkbox(
                  value: agree,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() => agree = value!);
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditionsScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        children: [
                          TextSpan(text: 'i_agree_to'.tr),
                          const TextSpan(text: ' '),
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

            /// Sign Up button
            PrimaryButton(
              title: 'continue'.tr,
              onTap: () {},
            ),

            const SizedBox(height: 20),

            /// Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or'.tr),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 20),

            /// Login redirect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('already_account'.tr),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'login'.tr,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nicknameController.dispose();
    licenseController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

}
