import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';


void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
}) {
  if (message != null && message.isNotEmpty) {
    if (getXSnackBar) {
      Get.showSnackbar(
        GetSnackBar(
          backgroundColor: isError ? Colors.red : Colors.green,
          message: message,
          duration: const Duration(seconds: 3),
          snackStyle: SnackStyle.FLOATING,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    } else {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.horizontal,
            margin: EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
            backgroundColor: isError ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            content: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(message, style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

/// Toast message (simple notifications)
void toastMessage({required String message, bool isError = false}) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: isError ? Colors.red : Colors.green,
    textColor: Colors.white,
    gravity: ToastGravity.BOTTOM,
    toastLength: Toast.LENGTH_LONG,
  );
}

// ==================== HELPER FUNCTIONS ====================

/// Show success snackbar
void showSuccessSnackBar(String message, {bool getXSnackBar = false}) {
  showCustomSnackBar(message, isError: false, getXSnackBar: getXSnackBar);
}

/// Show error snackbar
void showErrorSnackBar(String message, {bool getXSnackBar = false}) {
  showCustomSnackBar(message, isError: true, getXSnackBar: getXSnackBar);
}

/// Show success toast
void showSuccessToast(String message) {
  toastMessage(message: message, isError: false);
}

/// Show error toast
void showErrorToast(String message) {
  toastMessage(message: message, isError: true);
}

// ==================== LOADING & CONFIRMATION ====================

/// Show loading dialog - VERSION 1: With BuildContext (RECOMMENDED)
void showLoadingDialog({String? message, BuildContext? context}) {
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  } else {
    // Fallback: Try GetX if context is null
    if (Get.context != null) {
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      debugPrint('Warning: Both context and Get.context are null');
    }
  }
}

/// Hide loading dialog
void hideLoadingDialog([BuildContext? context]) {
  if (context != null && Navigator.canPop(context)) {
    Navigator.pop(context);
  } else if (Get.isDialogOpen == true) {
    Get.back();
  }
}

/// Show confirmation dialog
Future<bool> showConfirmationDialog({
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  BuildContext? context,
}) async {
  // Try provided context first, then Get.context
  final dialogContext = context ?? Get.context;

  if (dialogContext == null) {
    debugPrint(
      'Warning: Cannot show confirmation dialog, no context available',
    );
    return false;
  }

  final result = await showDialog<bool>(
    context: dialogContext,
    builder: (context) => AlertDialog(
      title: Text(title, style: TextStyle(fontSize: 16)),
      content: Text(message, style: TextStyle(fontSize: 14)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Show warning snackbar
void showWarningSnackBar(String message, {bool getXSnackBar = false}) {
  if (getXSnackBar) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: Colors.orange,
        message: message,
        duration: const Duration(seconds: 3),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
        icon: Icon(Icons.warning_amber_outlined, color: Colors.white, size: 24),
      ),
    );
  } else {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          margin: EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text(message, style: TextStyle(fontSize: 14))),
            ],
          ),
        ),
      );
    }
  }
}

/// Show info snackbar
void showInfoSnackBar(String message, {bool getXSnackBar = false}) {
  if (getXSnackBar) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: Colors.blue,
        message: message,
        duration: const Duration(seconds: 3),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
        icon: Icon(Icons.info_outline, color: Colors.white, size: 24),
      ),
    );
  } else {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          margin: EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(message, style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
