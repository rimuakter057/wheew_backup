import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

// class ParkingConfirmationOverlay extends StatelessWidget {
//   final RxBool visible;
//   final VoidCallback onYes;
//   final VoidCallback onNo;
//
//   const ParkingConfirmationOverlay({
//     super.key,
//     required this.visible,
//     required this.onYes,
//     required this.onNo,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!visible.value) {
//         return const SizedBox.shrink();
//       }
//       return GestureDetector(
//         onTap: () => visible.value = false,
//         child: Container(
//           color: Colors.black.withValues(alpha: 0.4),
//           child: Align(
//             alignment: Alignment.bottomCenter,
//             child: GestureDetector(
//               onTap:
//                   () {}, // swallow taps so they don't fall through to the scrim
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: AppColors.containerGradient,
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(ResponsiveHelper.borderRadius(24)),
//                   ),
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: ResponsiveHelper.padding(24),
//                           vertical: ResponsiveHelper.padding(28),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Drag handle
//                             Container(
//                               width: ResponsiveHelper.width(40),
//                               height: ResponsiveHelper.height(4),
//                               margin: EdgeInsets.only(
//                                 bottom: ResponsiveHelper.spacing(16),
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.black.withValues(alpha: 0.15),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                             Container(
//                               padding: ResponsiveHelper.symmetric(
//                                 horizontal: ResponsiveHelper.width(20),
//                                 vertical: ResponsiveHelper.height(2),
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.blue,
//                                 borderRadius: BorderRadius.circular(
//                                   ResponsiveHelper.borderRadius(8),
//                                 ),
//                               ),
//                               child: Text(
//                                 "P",
//                                 style: context.bodyLarge.copyWith(
//                                   color: AppColors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: ResponsiveHelper.fontSize(36),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: ResponsiveHelper.spacing(24)),
//                             Text(
//                               AppStrings.parkingConfirmation.tr,
//                               style: context.bodyLarge.copyWith(
//                                 fontWeight: FontWeight.w700,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: ResponsiveHelper.spacing(12)),
//                             Text(
//                               AppStrings.areYouLeavingAParkingSpotRightNow.tr,
//                               style: context.bodySmall.copyWith(
//                                 color: AppColors.black.withValues(alpha: 0.5),
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: ResponsiveHelper.spacing(32)),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: CustomGradientButton(
//                                     onPressed: () {
//                                       visible.value = false;
//                                       onNo();
//                                     },
//                                     label: AppStrings.no.tr,
//                                     backgroundColor: AppColors.blueShadeConBg,
//                                     shadowColor: Colors.transparent,
//                                     textColor: AppColors.black,
//                                     borderColor: AppColors.white,
//                                   ),
//                                 ),
//
//                                 SizedBox(width: ResponsiveHelper.spacing(14)),
//
//                                 Expanded(
//                                   child: CustomGradientButton(
//                                     onPressed: () {
//                                       visible.value = false;
//                                       onYes();
//                                     },
//                                     label: AppStrings.yes.tr,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       Positioned(
//                         top: ResponsiveHelper.padding(12),
//                         right: ResponsiveHelper.padding(24),
//                         child: InkWell(
//                           onTap: () {
//                             visible.value = false;
//                           },
//                           borderRadius: BorderRadius.circular(20),
//                           child: Icon(
//                             Icons.close,
//                             size: ResponsiveHelper.iconSize(20),
//                             color: AppColors.black.withValues(alpha: 0.6),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }




class ParkingConfirmationDialog extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const ParkingConfirmationDialog({
    super.key,
    required this.onYes,
    required this.onNo,
  });

  static Future<void> show(
      BuildContext context, {
        required VoidCallback onYes,
        required VoidCallback onNo,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => ParkingConfirmationDialog(
        onYes: onYes,
        onNo: onNo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(24),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.containerGradient,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(24),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(24),
                vertical: ResponsiveHelper.padding(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: ResponsiveHelper.symmetric(
                      horizontal: ResponsiveHelper.width(20),
                      vertical: ResponsiveHelper.height(2),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(8),
                      ),
                    ),
                    child: Text(
                      "P",
                      style: context.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.fontSize(36),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(24)),

                  Text(
                    AppStrings.parkingConfirmation.tr,
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(12)),

                  Text(
                    AppStrings.areYouLeavingAParkingSpotRightNow.tr,
                    style: context.bodySmall.copyWith(
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(32)),

                  Row(
                    children: [
                      Expanded(
                        child: CustomGradientButton(
                          onPressed: () {
                           context.pop();
                            onNo();
                          },
                          label: AppStrings.no.tr,
                          backgroundColor: AppColors.blueShadeConBg,
                          shadowColor: Colors.transparent,
                          textColor: AppColors.black,
                          borderColor: AppColors.white,
                        ),
                      ),

                      SizedBox(
                        width: ResponsiveHelper.spacing(14),
                      ),

                      Expanded(
                        child: CustomGradientButton(
                          onPressed: () {
                        context.pop();
                            onYes();
                          },
                          label: AppStrings.yes.tr,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: ResponsiveHelper.padding(12),
              right: ResponsiveHelper.padding(16),
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.close,
                  size: ResponsiveHelper.iconSize(20),
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
