import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../helper/custom_image/custom_image.dart';
import '../../../language/language_controller.dart';
import '../../../utils/assets_path/assets_path.dart';

class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    return Obx(() {
      final bool isItalian = controller.currentLocale.value.languageCode == 'it';

      return _GlassDropdown(
        isItalian: isItalian,
        onSelectItalian: () => controller.saveLanguage('Italiano'),
        onSelectEnglish: () => controller.saveLanguage('English'),
      );
    });
  }
}

class _GlassDropdown extends StatelessWidget {
  final bool isItalian;
  final VoidCallback onSelectItalian;
  final VoidCallback onSelectEnglish;

  const _GlassDropdown({
    required this.isItalian,
    required this.onSelectItalian,
    required this.onSelectEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      isItalian: isItalian,
      onTap: () => _showLanguageMenu(context),
    );
  }

  void _showLanguageMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      color: const Color(0xFF4A90D9).withOpacity(0.55), // same glass-blue tint
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18)),
        side: BorderSide(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height + 6,
        offset.dx + button.size.width,
        0,
      ),
      items: [
        _menuItem(value: 'en', label: 'English', isSelected: !isItalian),
        _menuItem(value: 'it', label: 'Italiano', isSelected: isItalian),
      ],
    ).then((value) {
      if (value == 'it') onSelectItalian();
      if (value == 'en') onSelectEnglish();
    });
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          CustomImage(
            imageSrc: AssetsPath.global,
            imageType: ImageType.svg,
            width: ResponsiveHelper.iconSize(18),

          ),
          SizedBox(width: ResponsiveHelper.width(10)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(14),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: Colors.black,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check, size: ResponsiveHelper.iconSize(16), color: Colors.white),
          ],
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final bool isItalian;
  final VoidCallback onTap;

  const _PillButton({required this.isItalian, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: ResponsiveHelper.height(40),
            padding: ResponsiveHelper.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImage(
                  imageSrc: AssetsPath.global,
                  imageType: ImageType.svg,
                  width: ResponsiveHelper.iconSize(18),
                  height: ResponsiveHelper.iconSize(18),

                ),
                SizedBox(width: ResponsiveHelper.width(6)),
                Text(
                  isItalian ? "Ita" : "Eng",
                  style: TextStyle(
                      color: AppColors.black,
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.width(4)),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: ResponsiveHelper.iconSize(18),
                  color: AppColors.black
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}