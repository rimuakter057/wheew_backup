import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../utils/extension/base_extension.dart';


class CustomAlignText extends StatelessWidget {
  const CustomAlignText({
    super.key,
    this.alignment = Alignment.centerLeft,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.style,
    this.maxLine,
    this.textAlign
  });

  final Alignment alignment;
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextStyle? style;
  final int? maxLine;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        text,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLine,
        style: style??GoogleFonts.poppins(
          fontWeight: fontWeight ?? FontWeight.w400,
          fontSize: fontSize??ResponsiveHelper.fontSize(14),
          color: color??AppColors.textBlack,
        ),
      ),
    );
  }
}
