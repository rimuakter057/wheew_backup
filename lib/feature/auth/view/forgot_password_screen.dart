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
        title: const Text('Forgot password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.padding(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: ResponsiveHelper.titleFontSize(20),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Don't worry enter your registered email",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            CustomTextField(
              title: 'Email',
              hintText: 'Enter your email here',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(50),
              child: /*ElevatedButton(
                onPressed: () {
                  // go to verification screen
                },
                child: const Text('Send OTP'),
              ),*/
              PrimaryButton(title:'Send OTP', onTap: (){
                context.goNamed(RouteName.otp);
              }),
            ),
          ],
        )
      ),
    );
  }
}
