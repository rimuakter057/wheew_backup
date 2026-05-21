import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/color/app_colors.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final String Function(T)? labelBuilder;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final Color? fillColor;
  final String? errorText;
  final bool enabled;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    this.labelBuilder,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.fillColor,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final message = "Field Is Required";

    String? Function(T?)? validation = (isRequired
        ? (val) => (val == null) ? message : null
        : null);
    final validationFunction = validator ?? validation;

    final bool hasError = errorText != null && errorText!.isNotEmpty;

    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.padding(16),
          horizontal: ResponsiveHelper.padding(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(15),
          ),
          borderSide: BorderSide(
            color: hasError ? AppColors.errorColor : AppColors.blue,
            width: ResponsiveHelper.borderWidth(1.2),
          ),
        ),
        filled: true,
        fillColor: fillColor ?? AppColors.white,
        errorText: errorText,
        errorStyle: TextStyle(
          color: AppColors.errorColor,
          fontSize: ResponsiveHelper.fontSize(12),
        ),
      ),
      hint: Text(
        hintText,
        style: TextStyle(
          color: AppColors.secondaryText,
          fontSize: ResponsiveHelper.fontSize(14),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder?.call(item) ?? item.toString(),
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: ResponsiveHelper.fontSize(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validationFunction,
      style: TextStyle(
        color: AppColors.secondaryText,
        fontSize: ResponsiveHelper.fontSize(14),
        fontWeight: FontWeight.w400,
      ),
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.only(right: ResponsiveHelper.padding(8)),
      ),
      iconStyleData: IconStyleData(
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.black),
        iconSize: ResponsiveHelper.iconSize(24),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: ResponsiveHelper.height(300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical: ResponsiveHelper.padding(10),
        ),
      ),
    );
  }
}
