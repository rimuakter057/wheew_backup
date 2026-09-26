import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

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
//           color: AppColors.black.withValues(alpha: 0.4),
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
//                                     shadowColor: AppColors.transparent,
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

class ParkingConfirmationDialog extends StatefulWidget {
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
      barrierColor: AppColors.black.withValues(alpha: 0.45),
      builder: (_) => ParkingConfirmationDialog(
        onYes: onYes,
        onNo: onNo,
      ),
    );
  }

  @override
  State<ParkingConfirmationDialog> createState() =>
      _ParkingConfirmationDialogState();
}

class _ParkingConfirmationDialogState extends State<ParkingConfirmationDialog> {
  bool _isPrivate = false;

  static const String _privateCarSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M14.2 6.2C14.2 5.2 15 4.5 16 4.5C17 4.5 17.8 5.2 17.8 6.2V7H14.2V6.2Z" stroke="#1E5BBF" stroke-width="1.6" stroke-linejoin="round"/>
  <path d="M11.8 5.2C11 5.9 11 7.1 11.8 7.8" stroke="#1E5BBF" stroke-width="1.4" stroke-linecap="round"/>
  <path d="M20.2 5.2C21 5.9 21 7.1 20.2 7.8" stroke="#1E5BBF" stroke-width="1.4" stroke-linecap="round"/>
  <path d="M9.5 13.5L11.5 7.8C11.8 7.2 12.4 6.8 13.1 6.8H18.9C19.6 6.8 20.2 7.2 20.5 7.8L22.5 13.5" stroke="#1E5BBF" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M6 14.5C6 13.7 6.7 13 7.5 13H24.5C25.3 13 26 13.7 26 14.5V19.5C26 20.3 25.3 21 24.5 21H7.5C6.7 21 6 20.3 6 19.5V14.5Z" stroke="#1E5BBF" stroke-width="1.6" stroke-linejoin="round"/>
  <path d="M6.5 13.5H25.5" stroke="#1E5BBF" stroke-width="1.4"/>
  <ellipse cx="8.8" cy="16.5" rx="1.6" ry="1.2" stroke="#1E5BBF" stroke-width="1.3"/>
  <ellipse cx="23.2" cy="16.5" rx="1.6" ry="1.2" stroke="#1E5BBF" stroke-width="1.3"/>
  <path d="M13 18.5H19" stroke="#1E5BBF" stroke-width="1.4" stroke-linecap="round"/>
  <rect x="5.2" y="20.5" width="2.4" height="4" rx="1" fill="#1E5BBF"/>
  <rect x="24.4" y="20.5" width="2.4" height="4" rx="1" fill="#1E5BBF"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(26),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(28),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(22),
                vertical: ResponsiveHelper.padding(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: ResponsiveHelper.spacing(6)),

                  // Parking 'P' badge
                  Container(
                    width: ResponsiveHelper.width(58),
                    height: ResponsiveHelper.height(58),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E5BBF),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(16),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "P",
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveHelper.fontSize(32),
                        height: 1.1,
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(18)),

                  // Title
                  Text(
                    AppStrings.areYouLookingForAParkingSpace.tr,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(19),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(8)),

                  // Subtitle
                  Text(
                    AppStrings.letNearbyDriversKnowLeavingSpot.tr,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(22)),

                  // Private parking space toggle row
                  Row(
                    children: [
                      // Outline car icon with beacon
                      SvgPicture.string(
                        _privateCarSvg,
                        width: ResponsiveHelper.width(28),
                        height: ResponsiveHelper.height(28),
                      ),

                      SizedBox(width: ResponsiveHelper.spacing(10)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.privateParkingSpace.tr,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(2)),
                            Text(
                              AppStrings.privateSpotsArentVisibleToOthers.tr,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(11.5),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: ResponsiveHelper.spacing(8)),

                      Transform.scale(
                        scale: 0.82,
                        child: CupertinoSwitch(
                          value: _isPrivate,
                          activeTrackColor: const Color(0xFF1E5BBF),
                          inactiveTrackColor: const Color(0xFF8E95A2),
                          thumbColor: AppColors.white,
                          onChanged: (val) {
                            setState(() {
                              _isPrivate = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(26)),

                  // Action buttons: No & Yes
                  Row(
                    children: [
                      // No Button
                      Expanded(
                        child: SizedBox(
                          height: ResponsiveHelper.height(48),
                          child: ElevatedButton(
                            onPressed: () {
                              context.pop();
                              widget.onNo();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFE5ECF4),
                              foregroundColor: const Color(0xFF374151),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.borderRadius(26),
                                ),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              AppStrings.no.tr,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: ResponsiveHelper.spacing(14)),

                      // Yes Button
                      Expanded(
                        child: Container(
                          height: ResponsiveHelper.height(48),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF0C69D4),
                                Color(0xFF004CB7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(26),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF004CB7)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              context.pop();
                              widget.onYes();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.transparent,
                              shadowColor: AppColors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.borderRadius(26),
                                ),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              AppStrings.yes.tr,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(16),
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Close button (top right)
            Positioned(
              top: ResponsiveHelper.padding(14),
              right: ResponsiveHelper.padding(14),
              child: InkWell(
                onTap: () {
                  context.pop();
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: ResponsiveHelper.iconSize(20),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


