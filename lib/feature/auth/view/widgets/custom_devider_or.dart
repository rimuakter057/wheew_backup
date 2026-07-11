import 'package:flutter/material.dart';

class CustomDividerOr extends StatelessWidget {
  final String text;
  final Color dividerColor;
  final Color textColor;

  const CustomDividerOr({
    super.key,
    this.text = "OR",
    this.dividerColor = const Color(0xFFD9D9D9),
    this.textColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}