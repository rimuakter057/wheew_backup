
import 'package:platchatapp/utils/language/app_string.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart'; // নিশ্চিত করুন এই প্যাকেজটি pubspec.yaml এ আছে
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart'; // আপনার প্রজেক্ট পাথ অনুযায়ী পরিবর্তন করুন
//
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// import '../../../../core/service/storage_service.dart';
// import '../../../../utils/app_const/app_const.dart';
// import '../../../../utils/toast_message/toast_message.dart'; // আপনার কালার ক্লাসের পাথ দিন
//
// class PlateDialog {
//   static Future<void> show(
//       BuildContext context,
//       String plate,
//       Future<bool> Function(String plate) onVerify,
//       ) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppColors.white,
//         elevation: 5,
//         // রেসপন্সিভ বর্ডার রেডিয়াস
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
//         ),
//         // কনটেন্টের চারপাশের রেসপন্সিভ প্যাডিং
//         contentPadding: ResponsiveHelper.symmetric(horizontal: 24, vertical: 24),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//
//             Container(
//               padding: ResponsiveHelper.all(12),
//               decoration: const BoxDecoration(
//                 color: AppColors.softBrandColor, // সফট ব্লু/গ্রিন শেড
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_circle_outline_rounded,
//                 color: AppColors.successColor,
//                 size: ResponsiveHelper.iconSize(54), // রেসপন্সিভ আইকন সাইজ
//               ),
//             ),
//             SizedBox(height: ResponsiveHelper.spacing(20)),
//
//             // সাবটাইটেল টেক্সট
//             Text(
//               "Scanned Number",
//               style: GoogleFonts.poppins(
//                 fontSize: ResponsiveHelper.fontSize(14),
//                 color: AppColors.secondaryText,
//                 fontWeight: FontWeight.w500,
//                 letterSpacing: 0.5,
//               ),
//             ),
//             SizedBox(height: ResponsiveHelper.spacing(8)),
//
//             // প্লেট নম্বর (একটি কার্ড বা হাইলাইটেড বক্সের ভেতর রাখলে মডার্ন দেখায়)
//             Container(
//               width: double.infinity,
//               padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: AppColors.greyShade,
//                 borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//                 border: Border.all(
//                   color: AppColors.greyBorder,
//                   width: ResponsiveHelper.borderWidth(1),
//                 ),
//               ),
//               child: Text(
//                 plate,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   fontSize: ResponsiveHelper.titleFontSize(24),
//                   color: AppColors.black,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         // অ্যাকশন বাটনগুলো নিচে সুন্দরভাবে সাজানো হয়েছে
//         actionsPadding: ResponsiveHelper.symmetric(horizontal: 20, vertical: 16),
//         actions: [
//           Row(
//             children: [
//               // OK / Cancel বাটন (আউটলাইন স্টাইল)
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: AppColors.greyBorder),
//                     padding: ResponsiveHelper.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
//                     ),
//                   ),
//                   child: Text(
//                     "Cancel",
//                     style: GoogleFonts.poppins(
//                       fontSize: ResponsiveHelper.fontSize(16),
//                       color: AppColors.secondaryText,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // বাটনগুলোর মাঝের স্পেস
//               SizedBox(width: ResponsiveHelper.width(12)),
//
//               // Verify বাটন (সলিড মডার্ন ব্লু বাটন)
//               // Expanded(
//               //   child: ElevatedButton(
//               //     onPressed: () async {
//               //       // লোডার দেখানো
//               //       showDialog(
//               //         context: context,
//               //         barrierDismissible: false,
//               //         builder: (_) => const Center(
//               //           child: CircularProgressIndicator(
//               //             valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
//               //           ),
//               //         ),
//               //       );
//               //
//               //       final result = await onVerify(plate);
//               //
//               //       Navigator.pop(context); // ক্লোজ লোডার
//               //       Navigator.pop(context); // ক্লোজ প্লেট ডায়ালগ
//               //
//               //       debugPrint(result ? "SUCCESS" : "FAILED");
//               //     },
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: AppColors.blue,
//               //       foregroundColor: AppColors.white,
//               //       elevation: 0,
//               //       padding: ResponsiveHelper.symmetric(vertical: 14),
//               //       shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
//               //       ),
//               //     ),
//               //     child: Text(
//               //       "Verify",
//               //       style: GoogleFonts.poppins(
//               //         fontSize: ResponsiveHelper.fontSize(16),
//               //         color: AppColors.white,
//               //         fontWeight: FontWeight.w600,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//
//
//               // Expanded(
//               //   child: ElevatedButton(
//               //     onPressed: () async {
//               //       final bool isAlreadyVerified =
//               //           await SharePrefsHelper.getBool(AppConst.licenseNoVerified) ?? false;
//               //
//               //       if (isAlreadyVerified) {
//               //         // ✅ true হলে — ইউজারকে জানিয়ে দেওয়া, কোনো API কল হবে না
//               //         showSuccessToast(AppStrings.licenseAlreadyVerified.tr);
//               //         // মেসেজ: "আপনার লাইসেন্স প্লেট আগে থেকেই ভেরিফাইড করা আছে।"
//               //
//               //         if (context.mounted) {
//               //           Navigator.pop(context); // প্লেট ডায়ালগ বন্ধ করে দেওয়া
//               //         }
//               //         return;
//               //       }
//               //
//               //       // ❌ false হলে — বর্তমান verify flow চলবে
//               //       showDialog(
//               //         context: context,
//               //         barrierDismissible: false,
//               //         builder: (_) => const Center(
//               //           child: CircularProgressIndicator(
//               //             valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
//               //           ),
//               //         ),
//               //       );
//               //
//               //       final result = await onVerify(plate);
//               //
//               //       if (context.mounted) {
//               //         Navigator.pop(context); // ক্লোজ লোডার
//               //         Navigator.pop(context); // ক্লোজ প্লেট ডায়ালগ
//               //       }
//               //
//               //       debugPrint(result ? "SUCCESS" : "FAILED");
//               //     },
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: AppColors.blue,
//               //       foregroundColor: AppColors.white,
//               //       elevation: 0,
//               //       padding: ResponsiveHelper.symmetric(vertical: 14),
//               //       shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
//               //       ),
//               //     ),
//               //     child: Text(
//               //       "Verify",
//               //       style: GoogleFonts.poppins(
//               //         fontSize: ResponsiveHelper.fontSize(16),
//               //         color: AppColors.white,
//               //         fontWeight: FontWeight.w600,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//
//
//
//               Expanded(
//                 child: FutureBuilder<bool?>(
//                   future: SharePrefsHelper.getBool(AppConst.licenseNoVerified),
//                   builder: (context, snapshot) {
//                     final bool isVerified = snapshot.data ?? false;
//
//                     return ElevatedButton(
//                       onPressed: isVerified
//                           ? null // disable করে দেওয়া, ক্লিক করা যাবে না
//                           : () async {
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (_) => const Center(
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
//                             ),
//                           ),
//                         );
//
//                         final result = await onVerify(plate);
//
//                         if (context.mounted) {
//                           Navigator.pop(context);
//                           Navigator.pop(context);
//                         }
//
//                         debugPrint(result ? "SUCCESS" : "FAILED");
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isVerified ? AppColors.chargingGreen : AppColors.blue,
//                         foregroundColor: AppColors.white,
//                         disabledBackgroundColor: AppColors.chargingGreen,
//                         disabledForegroundColor: AppColors.white,
//                         elevation: 0,
//                         padding: ResponsiveHelper.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (isVerified) ...[
//                             const Icon(Icons.check_circle, color: AppColors.white, size: 18),
//                             const SizedBox(width: 6),
//                           ],
//                           Text(
//                             isVerified ? AppStrings.verified.tr : AppStrings.verify.tr,
//                             style: GoogleFonts.poppins(
//                               fontSize: ResponsiveHelper.fontSize(16),
//                               color: AppColors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
//
//
//








import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

import 'package:platchatapp/utils/color/app_colors.dart';

class PlateDialog {
  /// [plate] - স্ক্যান হওয়া প্লেট নাম্বার
  /// [onFetch] - by-plate API কল করে Map<String, dynamic>? রিটার্ন করবে
  static Future<void> show(
      BuildContext context,
      String plate,
      Future<Map<String, dynamic>?> Function(String plate) onFetch,
      ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
        ),
        contentPadding: ResponsiveHelper.symmetric(horizontal: 24, vertical: 24),
        content: FutureBuilder<Map<String, dynamic>?>(
          future: onFetch(plate),
          builder: (context, snapshot) {
            // ---------- LOADING STATE ----------
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: ResponsiveHelper.height(160),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(16)),
                    Text(
                      AppStrings.checkingPlate.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data;

            // ---------- ERROR / NOT FOUND STATE ----------
            if (data == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: ResponsiveHelper.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softBrandColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.red,
                      size: ResponsiveHelper.iconSize(54),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),
                  Text(
                    AppStrings.plateNotFound.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  Text(
                    plate,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(20)),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.greyBorder),
                        padding: ResponsiveHelper.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                        ),
                      ),
                      child: Text(
                        AppStrings.close.tr,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(16),
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ---------- SUCCESS STATE ----------
            final user = data['user'] as Map<String, dynamic>? ?? {};
            final bool isExistingChat = data['isExistingChat'] ?? false;
            final String nickName = user['nick_name'] ?? '';
            final String licenceId = user['licence_id'] ?? plate;
            final bool isBlocked = user['is_blocked'] ?? false;
            final num rating = user['rating'] ?? 0;
            final String? avatar = user['avatar'];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar / Icon
                CircleAvatar(
                  radius: ResponsiveHelper.iconSize(36),
                  backgroundColor: AppColors.softBrandColor,
                  backgroundImage: (avatar != null && avatar.isNotEmpty)
                      ? NetworkImage(avatar)
                      : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? Icon(
                    Icons.person_rounded,
                    color: AppColors.successColor,
                    size: ResponsiveHelper.iconSize(40),
                  )
                      : null,
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),

                // Nick name
                Text(
                  nickName.isNotEmpty ? nickName : AppStrings.unknownUser.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(18),
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(4)),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.amber, size: ResponsiveHelper.iconSize(18)),
                    SizedBox(width: ResponsiveHelper.width(4)),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),

                // Plate number box
                Container(
                  width: double.infinity,
                  padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.greyShade,
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                    border: Border.all(
                      color: AppColors.greyBorder,
                      width: ResponsiveHelper.borderWidth(1),
                    ),
                  ),
                  child: Text(
                    licenceId,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.titleFontSize(22),
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                if (isBlocked) ...[
                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  Container(
                    padding: ResponsiveHelper.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
                    ),
                    child: Text(
                      AppStrings.thisUserIsBlocked.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(13),
                        color: AppColors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: ResponsiveHelper.spacing(20)),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.greyBorder),
                          padding: ResponsiveHelper.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel.tr,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(16),
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.width(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBlocked
                            ? null
                            : () {
                          Navigator.pop(context);
                          // TODO: navigate to chat room with user/data
                          // e.g. context.push('/chat-room', extra: data);
                          debugPrint(isExistingChat
                              ? "Open existing chat"
                              : "Start new chat");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.greyBorder,
                          elevation: 0,
                          padding: ResponsiveHelper.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                          ),
                        ),
                        child: Text(
                          isExistingChat ? AppStrings.openChat.tr : AppStrings.startChat.tr,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(16),
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
















