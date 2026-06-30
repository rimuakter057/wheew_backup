// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
//
// class DropPinButton extends StatelessWidget {
//   final VoidCallback onTap;
//
//   const DropPinButton({super.key, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         height: ResponsiveHelper.buttonHeight(52),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF3D72E8).withValues(alpha: 0.40),
//               blurRadius: 16,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child:Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding:  EdgeInsets.only(left:ResponsiveHelper.width(8)),
//               child: Container(
//                 width: ResponsiveHelper.width(28),
//                 height: ResponsiveHelper.height(28),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.25),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     'P',
//                     style: GoogleFonts.poppins(
//                       fontSize: ResponsiveHelper.fontSize(15),
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: ResponsiveHelper.spacing(10)),
//             Expanded(                          // ← এটা add করো
//               child: Text(
//                // 'drop_parking_pin'.tr.isNotEmpty ? 'drop_parking_pin'.tr : 'Drop Parking Pin',
//
//                 "Add Parking",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,   // ← center রাখতে চাইলে
//                 style: GoogleFonts.poppins(
//                   fontSize: ResponsiveHelper.fontSize(15),
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../utils/color/app_colors.dart';


class AddParkingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddParkingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(ResponsiveHelper.padding(30)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(20),
          vertical: ResponsiveHelper.padding(12),
        ),
        decoration: BoxDecoration(
          color: AppColors.paidBlue,
          borderRadius: BorderRadius.circular(ResponsiveHelper.padding(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.paidBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: AppColors.white,
              size: ResponsiveHelper.iconSize(24),
            ),
            SizedBox(width: ResponsiveHelper.padding(8)),
            Text(
             AppStrings.addParking.tr,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
