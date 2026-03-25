import 'package:flutter/material.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class OutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final double? borderWidth;

  const OutlineButton({
    super.key,
    required this.title,
    required this.onTap,
    this.borderColor = Colors.blue,
    this.textColor = Colors.blue,
    this.height = 52,
    this.borderRadius = 16,
    this.borderWidth = 1,
  });
  //
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.buttonHeight(height!),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(borderRadius!),
            ),
          ),
          side: BorderSide(
            color: borderColor!,
            width: ResponsiveHelper.borderWidth(borderWidth!),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: ResponsiveHelper.fontSize(16),
          ),
        ),
      ),
    );
  }
}
