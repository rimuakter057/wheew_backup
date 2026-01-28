import 'package:flutter/material.dart';
import '../../../share/widgets/custom_text_field.dart';
import '../../../share/widgets/primary_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const CustomTextField(hint: "Nick Name"),
            const SizedBox(height: 16),
            const CustomTextField(hint: "License Number"),
            const SizedBox(height: 16),
            const CustomTextField(hint: "Password", obscure: true),
            const SizedBox(height: 16),
            const CustomTextField(hint: "Confirm Password", obscure: true),

            const SizedBox(height: 10),

            Row(
              children: const [
                Checkbox(value: true, onChanged: null),
                Text("Agree with terms & conditions"),
              ],
            ),

            const SizedBox(height: 20),
            PrimaryButton(title: "Sign Up", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
