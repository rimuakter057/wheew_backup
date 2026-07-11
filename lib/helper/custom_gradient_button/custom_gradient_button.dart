import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class CustomGradientButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isLoading || onPressed == null;

    final borderRadius =
    BorderRadius.circular(ResponsiveHelper.borderRadius(30));

    const Color color1 = Color(0xFF0C7DC9);
    const Color color2 = Color(0xFF014495);
    const Color shadowColor = Color(0xFF587CA7);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Ink(
        width: double.infinity,
        height: ResponsiveHelper.buttonHeight(54),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: isButtonDisabled
              ? null
              : const LinearGradient(
            colors: [
              color1,
              color2,
              color1,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: isButtonDisabled ? Colors.grey.shade400 : null,
          border: const Border(
            bottom: BorderSide(
              color: AppColors.darBlue,
              width: 1,
            ),
          ),
        ),
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          splashColor: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}