import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class CustomGradientButton extends StatelessWidget {
  final bool isLoading;
  final String? label;
  final VoidCallback? onPressed;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? child;

  // Custom styling
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? shadowColor;
  final bool keepGradientWhenDisabled;

  const CustomGradientButton({
    super.key,
    this.label,
    required this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
    this.prefixIcon,
    this.child,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.shadowColor, this.borderColor, this.keepGradientWhenDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isLoading || onPressed == null;

    final borderRadius = BorderRadius.circular(
      ResponsiveHelper.borderRadius(30),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shadowColor: shadowColor ?? const Color(0xFF587CA7),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Ink(
        width: double.infinity,
        padding: ResponsiveHelper.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: borderRadius,

          // Custom gradient, otherwise default gradient
          gradient: (!isButtonDisabled || keepGradientWhenDisabled)
              ? (backgroundColor != null
              ? null
              : gradient ?? AppColors.buttonGradient)
              : null,

          color: (!isButtonDisabled || keepGradientWhenDisabled)
              ? backgroundColor
              : AppColors.greyShade400,

          border:  Border(
            bottom: BorderSide(
              color:borderColor?? AppColors.darBlue,
              width: 1,
            ),
          ),
        ),
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          splashColor: AppColors.white24,
          child: Padding(
            padding: ResponsiveHelper.symmetric(horizontal: 4),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : child ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: 6),
                      ],
                      if (label != null)
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label!,
                              maxLines: 1,
                              style: TextStyle(
                                color: textColor ?? AppColors.white,
                                fontSize: ResponsiveHelper.fontSize(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      if (suffixIcon != null) ...[
                        const SizedBox(width: 6),
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
