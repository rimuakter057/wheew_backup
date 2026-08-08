import 'package:platchatapp/utils/color/app_colors.dart';
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class CustomBackgroundContainer extends StatelessWidget {
//   final Widget child;
//
//   const CustomBackgroundContainer({Key? key, required this.child}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(32.0), // à¦•à¦¨à§à¦Ÿà§‡à¦‡à¦¨à¦¾à¦°à§‡à¦° à¦°à¦¾à¦‰à¦¨à§à¦¡à§‡à¦¡ à¦•à¦°à§à¦¨à¦¾à¦°
//       child: BackdropFilter(
//         // à¦¬à§à¦¯à¦¾à¦•à¦—à§à¦°à¦¾à¦‰à¦¨à§à¦¡ à¦¬à§à¦²à¦¾à¦° à¦•à¦°à¦¾à¦° à¦œà¦¨à§à¦¯ (Frosted Glass Effect)
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(24.0),
//           decoration: BoxDecoration(
//             // à¦¹à¦¾à¦²à¦•à¦¾ à¦¸à¦¾à¦¦à¦¾à¦Ÿà§‡ à¦“ à¦¸à§à¦¬à¦šà§à¦› à¦¬à§à¦¯à¦¾à¦•à¦—à§à¦°à¦¾à¦‰à¦¨à§à¦¡ à¦•à¦¾à¦²à¦¾à¦°
//             color: Color(0xFFCDD6E5),
//             borderRadius: BorderRadius.circular(32.0),
//       border: Border.all(color: AppColors.white.withOpacity(0.6), width: 1.5),
//
//             // à¦¹à¦¾à¦²à¦•à¦¾ à¦¶à§à¦¯à¦¾à¦¡à§‹ à¦‡à¦«à§‡à¦•à§à¦Ÿ
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: child, // à¦à¦° à¦­à§‡à¦¤à¦°à§‡ à¦†à¦ªà¦¨à¦¾à¦° Vehicle Model à¦à¦¬à¦‚ Colors à¦à¦° à¦‰à¦‡à¦œà§‡à¦Ÿà¦—à§à¦²à§‹ à¦¬à¦¸à¦¬à§‡
//         ),
//       ),
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBackgroundContainer extends StatelessWidget {
  final Widget child;

  const CustomBackgroundContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32.0);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 10,
          shadowColor: AppColors.black.withOpacity(0.1),
          color: const Color(0xFFCDD6E5),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            // à¦­à§à¦²à¦Ÿà¦¿ à¦à¦–à¦¾à¦¨à§‡ à¦¸à¦‚à¦¶à§‹à¦§à¦¨ à¦•à¦°à¦¾ à¦¹à§Ÿà§‡à¦›à§‡: Border.all à¦à¦° à¦¬à¦¦à¦²à§‡ BorderSide à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à¦¾ à¦¹à§Ÿà§‡à¦›à§‡
            side: BorderSide(
              color: AppColors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
