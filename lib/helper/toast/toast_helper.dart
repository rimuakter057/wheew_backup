import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../utils/enum/app_enum.dart';

class AppToast {
  static void _show({
    String? message,
    AppToastType type = AppToastType.info,
    Color? textColor,
    Color? backgroundColor,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 2),
  }) {
    final displayMessage = (message?.trim().isEmpty ?? true)
        ? "Something went wrong"
        : message!;

    final Color defaultBgColor =
        backgroundColor ??
        switch (type) {
          AppToastType.success => AppColors.green[600]!,
          AppToastType.error => AppColors.materialRed[600]!,
          AppToastType.warning => AppColors.orange[700]!,
          AppToastType.info => AppColors.materialBlue[600]!,
        };

    final Color effectiveTextColor = textColor ?? AppColors.white;

    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.snackbar(
      '',
      displayMessage,
      backgroundColor: defaultBgColor,
      colorText: effectiveTextColor,
      snackPosition: position,
      borderRadius: 10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      icon: switch (type) {
        AppToastType.success => const Icon(
          Icons.check_circle,
          color: AppColors.white,
        ),
        AppToastType.error => const Icon(Icons.error, color: AppColors.white),
        AppToastType.warning => const Icon(Icons.warning, color: AppColors.white),
        AppToastType.info => const Icon(Icons.info, color: AppColors.white),
      },
      shouldIconPulse: false,
      animationDuration: const Duration(milliseconds: 250),
    );
  }

  static void success({String? message}) =>
      _show(message: message, type: AppToastType.success);

  static void error({required String message}) =>
      _show(message: message, type: AppToastType.error);

  static void warning({required String message}) =>
      _show(message: message, type: AppToastType.warning);

  static void info({required String message}) =>
      _show(message: message, type: AppToastType.info);
}
