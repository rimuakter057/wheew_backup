import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/color/app_colors.dart';
import '../align/custom_align_text.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    this.inputFormatters,
    this.onFieldSubmitted,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.cursorColor = AppColors.blue,
    this.inputTextStyle,
    this.textAlignVertical = TextAlignVertical.center,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.validator,
    this.hintText,
    this.hint, // Added for backward compatibility
    this.suffixIcon,
    this.prefix,
    this.suffixIconColor,
    this.isPassword = false,
    this.obscure = false, // Added for backward compatibility
    this.readOnly = false,
    this.maxLength,
    super.key,
    this.prefixIcon,
    this.onTap,
    this.isCollapsed,
    this.isDense,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.suffix,
    this.initialValue,
    this.fillColor,
    this.contentPadding,
    this.title,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Color cursorColor;
  final TextStyle? inputTextStyle;
  final TextAlignVertical? textAlignVertical;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? hintText;
  final String? hint; // Added for backward compatibility
  final EdgeInsetsGeometry? contentPadding;

  final Color? suffixIconColor;
  final Color? fillColor;

  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefix;
  final OutlineInputBorder? border;

  final OutlineInputBorder? focusedBorder;
  final OutlineInputBorder? enabledBorder;

  final bool isPassword;
  final bool obscure; // Added for backward compatibility
  final Widget? suffix;
  final bool readOnly;
  final int? maxLength;
  final bool? isCollapsed;
  final bool? isDense;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final String? title;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final ValueNotifier<bool> _obscureText = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _obscureText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if password should be obscured
    final bool shouldObscure = widget.isPassword || widget.obscure;

    // Use hint if hintText is not provided (backward compatibility)
    final String? displayHint = widget.hintText ?? widget.hint;

    return ValueListenableBuilder<bool>(
      valueListenable: _obscureText,
      builder: (context, obscureText, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) CustomAlignText(text: widget.title ?? ""),
            if (widget.title != null) Gap(ResponsiveHelper.spacing(8)),
            TextFormField(
              onTap: widget.onTap,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: widget.inputFormatters,
              onFieldSubmitted: widget.onFieldSubmitted,
              readOnly: widget.readOnly,
              controller: widget.controller,
              initialValue: widget.initialValue,
              focusNode: widget.focusNode,
              maxLength: widget.maxLength,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: widget.cursorColor,
              style: widget.inputTextStyle ??
                  GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(16)),
              onChanged: widget.onChanged,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              obscureText: shouldObscure ? obscureText : false,
              validator: widget.validator,
              decoration: InputDecoration(
                fillColor: widget.fillColor,
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.padding(12),
                      vertical: ResponsiveHelper.padding(16),
                    ),
                isCollapsed: widget.isCollapsed,
                isDense: widget.isDense,
                errorMaxLines: 2,
                errorStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(12)),
                hintText: displayHint,
                hintStyle: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(16)),
                filled: widget.fillColor != null,
                prefixIcon: widget.prefixIcon,
                prefix: widget.prefix,
                suffix: widget.suffix,
                suffixIcon: shouldObscure
                    ? GestureDetector(
                  onTap: toggle,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
                    child: obscureText
                        ? Icon(
                      Icons.visibility_off_outlined,
                      color: AppColors.secondaryText,
                      size: ResponsiveHelper.iconSize(20),
                    )
                        : Icon(
                      Icons.visibility_outlined,
                      color: AppColors.secondaryText,
                      size: ResponsiveHelper.iconSize(20),
                    ),
                  ),
                )
                    : widget.suffixIcon,
                suffixIconColor: widget.suffixIconColor,
                border: widget.border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: ResponsiveHelper.borderWidth(1),
                      ),
                    ),
                focusedBorder: widget.focusedBorder ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: ResponsiveHelper.borderWidth(2),
                      ),
                    ),
                enabledBorder: widget.enabledBorder ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: ResponsiveHelper.borderWidth(1),
                      ),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  void toggle() {
    _obscureText.value = !_obscureText.value;
  }
}