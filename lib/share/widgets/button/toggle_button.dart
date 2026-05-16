import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import '../../../language/language_controller.dart';
import '../../../utils/assets_path/assets_path.dart';
import '../custom_image/custom_image.dart';

class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    return Obx(() {
      final bool isItalian =
          controller.currentLocale.value.languageCode == 'it';

      return Container(
        height: 52,
        padding:  ResponsiveHelper.symmetric(horizontal: 6),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleFlag(
              iconPath: AssetsPath.italy,
              isSelected: isItalian,
              onTap: () => controller.saveLanguage('Italiano'),
            ),
            const SizedBox(width: 8),
            _CircleFlag(
              iconPath: AssetsPath.uk,
              isSelected: !isItalian,
              onTap: () => controller.saveLanguage('English'),
            ),
          ],
        ),
      );
    });
  }
}

class _CircleFlag extends StatelessWidget {
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _CircleFlag({
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ImageType imageType = iconPath.endsWith('svg')
        ? ImageType.svg
        : ImageType.png;

    // Outer size (border included)
    final double size = isSelected
        ? ResponsiveHelper.iconSize(32.2)
        : ResponsiveHelper.iconSize(26.6);
    final double borderWidth = isSelected ? 2 : 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFF1976D2), width: borderWidth)
              : null,
        ),
        // 🔥 Flag fills inside border exactly
        child: ClipOval(
          child: CustomImage(
            imageSrc: iconPath,
            imageType: imageType,
            fit: BoxFit.cover, // no spacing
          ),
        ),
      ),
    );
  }
}

