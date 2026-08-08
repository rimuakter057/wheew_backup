//
// import 'package:flutter/material.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class CustomSnackbar {
//
//   /// âœ… SUCCESS
//   static void success({required BuildContext context,required String message}) {
//
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//
//         SnackBar(
//
//           content: Row(
//             children: [
//               const Icon(Icons.check_circle, color: AppColors.white),
//               const SizedBox(width: 10),
//               Expanded(child: Text(message)),
//             ],
//           ),
//
//           backgroundColor:AppColors.blueBox,
//
//           behavior: SnackBarBehavior.floating, // âœ… small letter
//
//           margin: const EdgeInsets.all(12),
//
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//
//           duration: const Duration(seconds: 2),
//
//         ),
//
//       );
//
//   }
//
//
//   /// âŒ ERROR
//   static void error({required BuildContext context,required String message}) {
//
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//
//         SnackBar(
//
//           content: Row(
//             children: [
//               const Icon(Icons.error, color: AppColors.white),
//               const SizedBox(width: 10),
//               Expanded(child: Text(message)),
//             ],
//           ),
//
//           backgroundColor: AppColors.red,
//
//           behavior: SnackBarBehavior.floating, // âœ… small letter
//
//           margin: const EdgeInsets.all(12),
//
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//
//           duration: const Duration(seconds: 3),
//
//         ),
//
//       );
//
//   }
//
// }






import 'package:flutter/material.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class CustomSnackbar {
  /// âœ… SUCCESS
  static void success({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.blueBox,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// âŒ ERROR
  static void error({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: AppColors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

