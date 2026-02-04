import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/text_field/custom_text_field.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Code'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            CustomTextField(title: 'New password'),
            const SizedBox(height: 16),
            CustomTextField(title: 'Confirm password'),
            const Spacer(),
            PrimaryButton(
              title: 'Save',
              onTap: () {
                context.goNamed(RouteName.signIn);
              },
            ),
          ],
        ),
      ),
    );
  }
}
