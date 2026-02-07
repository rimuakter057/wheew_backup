import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';

import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot password',
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.padding(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveHelper.spacing(20)),

            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: ResponsiveHelper.titleFontSize(20),
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            Text(
              "Don't worry enter your registered email",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(24)),

            CustomTextField(
              title: 'Email',
              hintText: 'Enter your email here',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(50),
              child: PrimaryButton(
                title: 'Send OTP',
                onTap: () {
                  context.goNamed(RouteName.otp);
                },
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),
          ],
        ),
      ),
    );
  }
}