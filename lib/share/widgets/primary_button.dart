import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PrimaryButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
