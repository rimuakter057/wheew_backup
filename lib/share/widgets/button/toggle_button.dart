import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../language/language_controller.dart';

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
