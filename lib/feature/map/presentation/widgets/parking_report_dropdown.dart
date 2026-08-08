//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:platchatapp/core/router/routes_name.dart';
// import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:platchatapp/utils/language/app_string.dart'; // AppColors import
//
// class ParkingReportDropdown extends StatelessWidget {
//   final Map<String, dynamic> report;
//   final VoidCallback onClose;
//
//   const ParkingReportDropdown({
//     super.key,
//     required this.report,
//     required this.onClose,
//   });
//
//
//   String _parkingCostText() => (report['parking_cost'] ?? '-').toString();
//
//   String _boolFlag(dynamic value) => value == true ? AppStrings.yes.tr : AppStrings.no.tr;
//
//   Color _getStatusColor() {
//     if (report['disabled_facility'] == true) return AppColors.disableOrange;
//     if (report['electric_charging'] == true) return AppColors.chargingGreen;
//     final cost = report['parking_cost']?.toString().trim().toUpperCase();
//     final isPaid = cost != null && cost != '' && cost != '0' && cost != 'FREE';
//     return isPaid ? AppColors.paidBlue : AppColors.freeWhite;
//   }
//
//   /// Status Label Text
//   String _getPinLabel() {
//     if (report['disabled_facility'] == true) return AppStrings.disabledParking.tr;
//     if (report['electric_charging'] == true) return AppStrings.electricCharging2.tr;
//     final cost = report['parking_cost']?.toString().trim().toUpperCase();
//     final isPaid = cost != null && cost != '' && cost != '0' && cost != 'FREE';
//     return isPaid ? AppStrings.paidParking.tr : AppStrings.freeParking.tr;
//   }
//
//   /// Free parking à¦¹à¦²à§‡ icon/text à¦•à¦¾à¦²à§‹ à¦¦à§‡à¦–à¦¾à¦¬à§‡ à¦•à¦¾à¦°à¦£ background white
//   bool get _isFree {
//     if (report['disabled_facility'] == true) return false;
//     if (report['electric_charging'] == true) return false;
//     final cost = report['parking_cost']?.toString().trim().toUpperCase();
//     return cost == null || cost == '' || cost == '0' || cost == 'FREE';
//   }
//
//   /// -- Open in-app navigation (real route drawn on our own map) --
//   void _openNavigation(BuildContext context) {
//     final dynamic rawLat = report['latitude'];
//     final dynamic rawLng = report['longitude'];
//
//     final double? destLat = rawLat is num
//         ? rawLat.toDouble()
//         : double.tryParse(rawLat?.toString() ?? '');
//     final double? destLng = rawLng is num
//         ? rawLng.toDouble()
//         : double.tryParse(rawLng?.toString() ?? '');
//
//     if (destLat == null || destLng == null) {
//       CustomSnackbar.error(
//         context: context,
//         message: AppStrings.failedToLeave.tr,
//       );
//       return;
//     }
//
//     context.pushNamed(
//       RouteName.inAppNavigation,
//       extra: {'destination': LatLng(destLat, destLng)},
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor();
//     final pinLabel = _getPinLabel();
//
//     // Free à¦¹à¦²à§‡ icon à¦“ badge text à¦•à¦¾à¦²à§‹ à¦¦à§‡à¦–à¦¾à¦¬à§‡ (white bg-à¦¤à§‡ contrast à¦à¦° à¦œà¦¨à§à¦¯)
//     final Color iconAndBadgeTextColor = _isFree ? const Color(0xFF1E293B) : statusColor;
//
//     const Color cardBgColor = AppColors.white;
//     const Color titleColor = Color(0xFF0F172A);
//     final Color borderColor = _isFree
//         ? const Color(0xFFE2E8F0) // Free à¦¹à¦²à§‡ light slate border
//         : statusColor.withOpacity(0.3);
//
//     const Color textDark = Color(0xFF1E293B);
//     const Color textSecondary = Color(0xFF64748B);
//
//     return Container(
//       margin: ResponsiveHelper.symmetric(horizontal: 16, vertical: 8),
//       padding: ResponsiveHelper.all(16),
//       decoration: BoxDecoration(
//         color: cardBgColor,
//         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
//         border: Border.all(
//           color: borderColor,
//           width: ResponsiveHelper.borderWidth(1.5),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF0F172A).withOpacity(0.15),
//             blurRadius: ResponsiveHelper.spacing(30),
//             spreadRadius: 2,
//             offset: Offset(0, ResponsiveHelper.spacing(10)),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ///cross button================
//               InkWell(
//                 borderRadius: BorderRadius.circular(100),
//                 onTap: onClose,
//                 child: Container(
//                   padding: ResponsiveHelper.all(8),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFF1F5F9),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.close_rounded,
//                     color: const Color(0xFF475569),
//                     size: ResponsiveHelper.iconSize(16),
//                   ),
//                 ),
//               ),
//               SizedBox(width: ResponsiveHelper.spacing(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       AppStrings.mapSelectedReport.tr,
//                       style: TextStyle(
//                         color: titleColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: ResponsiveHelper.titleFontSize(16),
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                     SizedBox(height: ResponsiveHelper.spacing(2)),
//                     Container(
//                       padding: ResponsiveHelper.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//
//                         color: _isFree
//                             ? const Color(0xFFF1F5F9)
//                             : statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
//                         // Free à¦¹à¦²à§‡ border à¦¦à¦¿à¦²à§‡ badge à¦†à¦²à¦¾à¦¦à¦¾ à¦¬à§‹à¦à¦¾ à¦¯à¦¾à¦¯à¦¼
//                         border: _isFree
//                             ? Border.all(color: const Color(0xFFE2E8F0))
//                             : null,
//                       ),
//                       child: Text(
//                         pinLabel,
//                         style: TextStyle(
//                           color: iconAndBadgeTextColor,
//                           fontSize: ResponsiveHelper.fontSize(11),
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               /// leave Button
//
//
//               Column(
//                 children: [
//                   // GestureDetector(
//                   //   onTap: () async {
//                   //     final spotId = controller.selectedReport.value?['id']?.toString();
//                   //     if (spotId == null) return;
//                   //
//                   //     final success = await controller.leaveSpot(spotId);
//                   //
//                   //     if (success) {
//                   //       CustomSnackbar.success(context: context, message: AppStrings.leaveSuccess.tr);
//                   //       controller.clearSelectedReport();
//                   //       // map refresh à¦•à¦°à¦¤à§‡ à¦šà¦¾à¦‡à¦²à§‡ fetchParkingReport à¦†à¦¬à¦¾à¦° call à¦•à¦°à§‹
//                   //     } else {
//                   //       CustomSnackbar.error(context: context, message: AppStrings.failedToLeave.tr);
//                   //     }
//                   //   },
//                   //   child: Obx(() => Container(
//                   //     padding: ResponsiveHelper.symmetric(
//                   //       horizontal: ResponsiveHelper.spacing(12),
//                   //       vertical: ResponsiveHelper.spacing(6),
//                   //     ),
//                   //     decoration: BoxDecoration(
//                   //       color: _isFree
//                   //           ? const Color(0xFFF1F5F9)
//                   //           : statusColor.withOpacity(0.12),
//                   //       borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
//                   //       border: Border.all(color: statusColor.withOpacity(0.3)),
//                   //     ),
//                   //     child: controller.isLeaving.value
//                   //         ? SizedBox(
//                   //       width: ResponsiveHelper.width(14),
//                   //       height: ResponsiveHelper.height(14),
//                   //       child: CircularProgressIndicator(strokeWidth: ResponsiveHelper.borderWidth(2)),
//                   //     )
//                   //         : Row(
//                   //       mainAxisSize: MainAxisSize.min,
//                   //       children: [
//                   //         Icon(Icons.logout_rounded,
//                   //             size: ResponsiveHelper.iconSize(14),
//                   //             color: iconAndBadgeTextColor),
//                   //         SizedBox(width: ResponsiveHelper.spacing(4)),
//                   //         Text(AppStrings.leave.tr,
//                   //             style: context.bodyMedium.copyWith(
//                   //               color: iconAndBadgeTextColor,
//                   //               fontWeight: FontWeight.w600,
//                   //             )),
//                   //       ],
//                   //     ),
//                   //   )),
//                   // ),
//                   //
//                   // // IconButton(
//                   // //   onPressed: () => _openNavigation(context),
//                   // //   icon: Icon(
//                   // //     Icons.navigation_outlined,
//                   // //     color: AppColors.paidBlue,
//                   // //   ),
//                   // // ),
//
//                   SizedBox(height: ResponsiveHelper.spacing(12)),
//
//                   GestureDetector(
//                     onTap: () => _openNavigation(context),
//                     child: Container(
//                       padding: EdgeInsets.all(ResponsiveHelper.spacing(4)),
//                       decoration: BoxDecoration(
//                         color: AppColors.paidBlue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
//                         border: Border.all(color: AppColors.paidBlue.withOpacity(0.3)),
//
//                       ),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Get Directions",
//                             style: TextStyle(
//                               color: AppColors.paidBlue,
//                               fontWeight: FontWeight.w600,
//                               fontSize: ResponsiveHelper.fontSize(13),
//                             ),
//                           ),
//
//                           Icon(
//                                 Icons.navigation_outlined,
//                                 color: AppColors.paidBlue,
//                               ),
//                         ],
//                       ),
//
//                     ),
//                   ),
//
//
//
//                 ],
//               ),
//
//
//
//             ],
//           ),
//
//           SizedBox(height: ResponsiveHelper.spacing(16)),
//
//           // Info Box
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8FAFC),
//               borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
//               border: Border.all(color: const Color(0xFFE2E8F0)),
//             ),
//             padding: ResponsiveHelper.all(14),
//             child: Column(
//               children: [
//                 _buildInfoRow(
//                   icon: Icons.payments_rounded,
//                   iconColor: AppColors.paidBlue,
//                   key: 'map_parking_cost',
//                   value: _parkingCostText(),
//                   textDark: textDark,
//                   textSecondary: textSecondary,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(10)),
//                   child: Divider(color: const Color(0xFFE2E8F0), height: ResponsiveHelper.height(1)),
//                 ),
//                 _buildInfoRow(
//                   icon: Icons.electric_car_rounded,
//                   iconColor: AppColors.chargingGreen,
//                   key: 'map_electric_charging',
//                   value: _boolFlag(report['electric_charging']),
//                   textDark: textDark,
//                   textSecondary: textSecondary,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(10)),
//                   child: Divider(color: const Color(0xFFE2E8F0), height: ResponsiveHelper.height(1)),
//                 ),
//                 _buildInfoRow(
//                   icon: Icons.accessible_rounded,
//                   iconColor: AppColors.disableOrange,
//                   key: 'map_disabled_facility',
//                   value: _boolFlag(report['disabled_facility']),
//                   textDark: textDark,
//                   textSecondary: textSecondary,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow({
//     required IconData icon,
//     required Color iconColor,
//     required String key,
//     required String value,
//     required Color textDark,
//     required Color textSecondary,
//   }) {
//     final bool isNo = value.toLowerCase() == 'no';
//     final Color valueColor = isNo ? const Color(0xFFEF4444) : textDark;
//
//     return Row(
//       children: [
//         Container(
//           padding: ResponsiveHelper.all(6),
//           decoration: BoxDecoration(
//             color: iconColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
//           ),
//           child: Icon(icon, color: iconColor, size: ResponsiveHelper.iconSize(18)),
//         ),
//         SizedBox(width: ResponsiveHelper.spacing(12)),
//         Expanded(
//           child: Text(
//             key.tr,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: textSecondary,
//               fontSize: ResponsiveHelper.fontSize(13),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         SizedBox(width: ResponsiveHelper.spacing(8)),
//         Text(
//           value,
//           style: TextStyle(
//             color: valueColor,
//             fontWeight: FontWeight.w700,
//             fontSize: ResponsiveHelper.fontSize(13),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// extension ColorDarken on Color {
//   Color withDarkness(double amount) {
//     assert(amount >= 0.0 && amount <= 1.0);
//     final hsl = HSLColor.fromColor(this);
//     final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
//     return hslDark.toColor();
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'parking_location_card.dart';

class ParkingReportDropdown extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onClose;

  const ParkingReportDropdown({
    super.key,
    required this.report,
    required this.onClose,
  });

  // ============================================================
  // API DATA + STATIC FALLBACK
  // ============================================================

  String get displayTitle {
    return report['name']?.toString() ??
        report['title']?.toString() ??
        'Green Park Mall';
  }

  String get displaySubtitle {
    return report['address']?.toString() ??
        report['description']?.toString() ??
        'Side Parking';
  }

  String get displayDistance {
    final dm = report['distanceMeters'];
    if (dm != null) {
      final meters = (dm is num) ? dm.toInt() : int.tryParse(dm.toString());
      if (meters != null) {
        return meters >= 1000
            ? '${(meters / 1000).toStringAsFixed(1)} km away'
            : '$meters m away';
      }
    }
    return report['distance']?.toString() ?? '';
  }

  // rating == null â†’ show '0.0' with a grey star (see [ratingColor]).
  // reviewCount, when > 0, is appended as "4.5 (12)".
  String get displayRating {
    final dynamic ratingVal = report['rating'];
    final String ratingText = ratingVal == null
        ? '0.0'
        : (ratingVal is num
            ? ratingVal.toStringAsFixed(1)
            : ratingVal.toString());

    final dynamic reviewCountVal = report['reviewCount'];
    final int? reviewCount = reviewCountVal is num
        ? reviewCountVal.toInt()
        : int.tryParse(reviewCountVal?.toString() ?? '');

    if (reviewCount != null && reviewCount > 0) {
      return '$ratingText ($reviewCount)';
    }
    return ratingText;
  }

  Color get ratingColor =>
      report['rating'] == null ? AppColors.greyText : AppColors.blue;

  // totalSpots == null â†’ show 0.
  String get displaySpots {
    final dynamic totalSpots = report['totalSpots'];
    final int spots = totalSpots is num
        ? totalSpots.toInt()
        : (int.tryParse(totalSpots?.toString() ?? '') ??
            int.tryParse(report['available_spots']?.toString() ?? '') ??
            int.tryParse(report['spots_left']?.toString() ?? '') ??
            0);
    return '$spots spots';
  }

  // ============================================================
  // PARKING COST
  // ============================================================

  bool get _isFree {
    final cost = (report['parkingCost'] ?? report['parking_cost'])
        ?.toString()
        .trim()
        .toUpperCase();

    return cost == null ||
        cost.isEmpty ||
        cost == '0' ||
        cost == 'FREE';
  }

  // paid + parkingFee present â†’ show the fee; otherwise fall back to 'Paid'.
  String get displayPrice {
    if (_isFree) return 'Free';
    final dynamic fee = report['parkingFee'];
    final num? feeNum = fee is num ? fee : num.tryParse(fee?.toString() ?? '');
    if (feeNum != null) {
      final String feeText =
          feeNum % 1 == 0 ? feeNum.toInt().toString() : feeNum.toString();
      return '\$$feeText';
    }
    return 'Paid';
  }

  String get costStatusLabel => _isFree ? 'Free' : 'Paid';

  Color get costStatusColor =>
      _isFree ? AppColors.successColor : AppColors.paidBlue;

  List<String> get _areaTypes {
    final dynamic raw = report['parkingAreaTypes'];
    if (raw is List) {
      return raw.map((e) => e.toString().toUpperCase()).toList();
    }
    return const [];
  }

  String? get displayTag {
    if (_areaTypes.contains('ELECTRIC_CHARGING')) return 'Electric';
    if (_areaTypes.contains('DISABLED_FACILITY')) return 'Disabled';
    return null;
  }

  IconData? get displayTagIcon {
    if (_areaTypes.contains('ELECTRIC_CHARGING')) return Icons.electric_car_rounded;
    if (_areaTypes.contains('DISABLED_FACILITY')) return Icons.accessible_rounded;
    return null;
  }

  Color? get displayTagColor {
    if (_areaTypes.contains('ELECTRIC_CHARGING')) return AppColors.chargingGreen;
    if (_areaTypes.contains('DISABLED_FACILITY')) return AppColors.disableOrange;
    return null;
  }

  // ============================================================
  // EXISTING NAVIGATION LOGIC
  // ============================================================

  void _openNavigation(BuildContext context) {
    final dynamic rawLat = report['centerLat'] ?? report['latitude'];
    final dynamic rawLng = report['centerLng'] ?? report['longitude'];

    final double? destLat = rawLat is num
        ? rawLat.toDouble()
        : double.tryParse(rawLat?.toString() ?? '');

    final double? destLng = rawLng is num
        ? rawLng.toDouble()
        : double.tryParse(rawLng?.toString() ?? '');

    if (destLat == null || destLng == null) {
      CustomSnackbar.error(
        context: context,
        message: AppStrings.failedToLeave.tr,
      );
      return;
    }

    context.pushNamed(
      RouteName.inAppNavigation,
      extra: {
        'destination': LatLng(destLat, destLng),
      },
    );
  }

  // ignore: unused_element
  void _onSavePark(BuildContext context) async {
    final dynamic rawLat = report['centerLat'] ?? report['latitude'];
    final dynamic rawLng = report['centerLng'] ?? report['longitude'];

    final double? lat = rawLat is num
        ? rawLat.toDouble()
        : double.tryParse(rawLat?.toString() ?? '');
    final double? lng = rawLng is num
        ? rawLng.toDouble()
        : double.tryParse(rawLng?.toString() ?? '');

    if (lat == null || lng == null) return;

    if (Get.isRegistered<ParkingReportController>()) {
      final ctrl = Get.find<ParkingReportController>();
      final String costRaw =
          (report['parkingCost'] ?? report['parking_cost'])?.toString().toUpperCase() ?? '';
      final String parkingType = costRaw == 'PAID' ? 'PAID' : 'FREE';

      final success = await ctrl.saveMyParking(
        latitude: lat,
        longitude: lng,
        parkingType: parkingType,
      );
      if (success) {
        onClose();

        CustomSnackbar.success(
          context: context,
          message: AppStrings.parkingSpotSaved.tr,
        );
      } else {
        CustomSnackbar.error(
          context: context,
          message: ctrl.submitMessage.value.isNotEmpty
              ? ctrl.submitMessage.value
              : AppStrings.failedToSaveParkingSpot.tr,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParkingLocationCard(
      title: displayTitle,
      subtitle: displaySubtitle,
      badgeLabel: displayTag ?? 'Standard',
      badgeIcon: displayTagIcon ?? Icons.local_parking_rounded,
      badgeIconAsset: displayTag == null ? AssetsPath.standardIcon : null,
      badgeColor: displayTagColor ?? AppColors.paidBlue,
      distanceLabel: displayDistance,
      ratingLabel: displayRating,
      leftStatLabel: displaySpots,
      rightStatLabel: displayPrice,
      rightStatIcon: _isFree ? Icons.money_off_rounded : Icons.monetization_on_outlined,
      onNavigate: () => _openNavigation(context),
      onSavePark: null,
    );
  }
}

