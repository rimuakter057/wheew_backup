import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
