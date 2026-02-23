import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleFlag(
              iconPath: AssetsPath.italy,
              isSelected: isItalian,
              onTap: () => controller.saveLanguage('Italian'),
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
    final double size = isSelected ? 46 : 38;
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
/*
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleFlag(
              iconPath: AssetsPath.italy,
              isSelected: isItalian,
              onTap: () => controller.saveLanguage('Italian'),
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
    final ImageType imageType =
    iconPath.endsWith('svg') ? ImageType.svg : ImageType.png;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: isSelected ? 64 : 56, // 🔥 size difference
        width: isSelected ? 64 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
          isSelected ? const Color(0xFF1976D2) : Colors.transparent,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: isSelected ? 26 : 22, // 🔥 flag icon scale
            width: isSelected ? 26 : 22,
            child: CustomImage(
              imageSrc: iconPath,
              imageType: imageType,
            ),
          ),
        ),
      ),
    );
  }
}
*/

/*class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    return Obx(() {
      final bool isItalian =
          controller.currentLocale.value.languageCode == 'it';

      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.transparent, // light background like screenshot
          borderRadius: BorderRadius.circular(2), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleFlag(
              iconPath: AssetsPath.italy,
              isSelected: isItalian,
              onTap: () => controller.saveLanguage('Italian'),
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
    final ImageType imageType =
    iconPath.endsWith('svg') ? ImageType.svg : ImageType.png;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFF1976D2) // Primary Blue
              : Colors.transparent,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),
        child: Center(
          child: CustomImage(
            imageSrc: iconPath,
            imageType: imageType,
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }
}*/
/*
class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    return Obx(() {
      final bool isItalian =
          controller.currentLocale.value.languageCode == 'it';

      return Container(
        height: ResponsiveHelper.buttonHeight(52),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(16),
          ),
          border: Border.all(
            color: Colors.blue,
            width: ResponsiveHelper.borderWidth(1),
          ),
        ),
        child: Row(
          children: [
            /// Italian Button
            Expanded(
              child: GestureDetector(
                onTap: () => controller.saveLanguage('Italian'),
                child: _ToggleItem(
                  iconPath: AssetsPath.italy,
                  isSelected: isItalian,
                ),
              ),
            ),

            /// English Button
            Expanded(
              child: GestureDetector(
                onTap: () => controller.saveLanguage('English'),
                child: _ToggleItem(
                  iconPath: AssetsPath.uk,
                  isSelected: !isItalian,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleItem extends StatelessWidget {
  final String iconPath;
  final bool isSelected;

  const _ToggleItem({required this.iconPath, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final ImageType imageType = iconPath.endsWith('svg')
        ? ImageType.svg
        : ImageType.png;

    return AnimatedContainer(
      key: ValueKey(isSelected),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(12),
        ),
      ),
      child: Center(
        child: CustomImage(
          imageSrc: iconPath,
          imageType: imageType,
          height: 28,
          width: 28,
        ),
      ),
    );
  }
}
*/

/*
class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    return Obx(() {
      final bool isItalian =
          controller.currentLocale.value.languageCode == 'it';

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue),
        ),
        child: Row(
          children: [
            /// Italian Button
            Expanded(
              child: GestureDetector(
                onTap: () => controller.saveLanguage('Italian'),
                child: _ToggleItem(title: 'Italian', isSelected: isItalian),
              ),
            ),

            /// English Button
            Expanded(
              child: GestureDetector(
                onTap: () => controller.saveLanguage('English'),
                child: _ToggleItem(title: 'English', isSelected: !isItalian),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _ToggleItem({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: ValueKey(isSelected),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
*/
