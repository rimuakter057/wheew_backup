import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class VehicleSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  const VehicleSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isLoading || onPressed == null;
    final borderRadius = BorderRadius.circular(ResponsiveHelper.borderRadius(30));

    final Color color1 = const Color(0xFF0C7DC9);
    final Color color2 = const Color(0xFF014495);
    final Color shadowColor = const Color(0xFF587CA7);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shadowColor:shadowColor,
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
              : LinearGradient(
            colors: [
              color1,
              color2,
              color1,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: isButtonDisabled ? Colors.grey.shade400 : null,
          border: Border(

            // top:  BorderSide(
            //   color: AppColors.topBorderBlue,
            //   width: 1.5,
            // ),
            bottom:  BorderSide(
              color: AppColors.darBlue,
              width: 1.5,
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
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}