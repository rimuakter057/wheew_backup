import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../share/widgets/custom_text_field.dart';
import '../../../share/widgets/primary_button.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),



            const SizedBox(height: 40),

            const CustomTextField(hint: "License Number or Nickname"),
            const SizedBox(height: 16),
            const CustomTextField(
              hint: "Password",
              obscure: true,
              suffix: Icon(Icons.visibility_off),
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
            PrimaryButton(title: "Sign In", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
