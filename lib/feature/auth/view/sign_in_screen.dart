import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/extension/string_extension.dart';


class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
          title: Text('sign in'.tr),
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
        
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
        
              const SizedBox(height: 40),

              /// Nickname
              CustomTextField(
                controller: licenseController,
                title: 'nick_name'.tr,
                hintText: 'nick_name_hint'.tr,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                title: 'confirm_password'.tr,
                hintText: 'confirm_password'.tr,
                isPassword: true,
              ),
        
              const SizedBox(height: 10),
        
              Row(
                children: const [
                  Checkbox(value: true, onChanged: null),
                  Text("Remember me"),
                  Spacer(),
                  Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
                ],
              ),
        
              const SizedBox(height: 20),
              PrimaryButton(title: "Sign In", onTap: () {
                context.goNamed(RouteName.chatList);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
