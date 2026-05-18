import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart'; // AppColors import

class ParkingReportDropdown extends StatelessWidget {
  final ParkingReportController controller;
  final Map<String, dynamic> report;
  final VoidCallback onClose;

  const ParkingReportDropdown({
    super.key,
    required this.controller,
    required this.report,
    required this.onClose,
  });

  /// Core Status Color based on report data
  Color _getStatusColor() {
    if (report['disabled_facility'] == true) {
      return AppColors.disableOrange;
    }
    if (report['electric_charging'] == true) {
      return AppColors.chargingGreen;
    }
    final cost = report['parking_cost'];
    final isPaid = cost != null && cost != 0 && cost != '0' && cost != '';
    return isPaid ? AppColors.paidBlue : AppColors.freeWhite;
  }

  /// Status Label Text
  String _getPinLabel() {
    if (report['disabled_facility'] == true) return 'Disabled Parking';
    if (report['electric_charging'] == true) return 'Electric Charging';
    final cost = report['parking_cost'];
    final isPaid = cost != null && cost != 0 && cost != '0' && cost != '';
    return isPaid ? 'Paid Parking' : 'Free Parking';
  }

  /// Free parking হলে icon/text কালো দেখাবে কারণ background white
  bool get _isFree {
    if (report['disabled_facility'] == true) return false;
    if (report['electric_charging'] == true) return false;
    final cost = report['parking_cost'];
    return cost == null || cost == 0 || cost == '0' || cost == '';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final pinLabel = _getPinLabel();

    // Free হলে icon ও badge text কালো দেখাবে (white bg-তে contrast এর জন্য)
    final Color iconAndBadgeTextColor = _isFree ? const Color(0xFF1E293B) : statusColor;

    const Color cardBgColor = Colors.white;
    const Color titleColor = Color(0xFF0F172A);
    final Color borderColor = _isFree
        ? const Color(0xFFE2E8F0) // Free হলে light slate border
        : statusColor.withOpacity(0.3);

    const Color textDark = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);

    return Container(
      margin: ResponsiveHelper.symmetric(horizontal: 16, vertical: 8),
      padding: ResponsiveHelper.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
        border: Border.all(
          color: borderColor,
          width: ResponsiveHelper.borderWidth(1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.15),
            blurRadius: ResponsiveHelper.spacing(30),
            spreadRadius: 2,
            offset: Offset(0, ResponsiveHelper.spacing(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: ResponsiveHelper.all(10),
                decoration: BoxDecoration(
                  // Free হলে white bg, তাই icon container-এ হালকা grey ব্যবহার
                  color: _isFree
                      ? const Color(0xFFF1F5F9)
                      : statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_parking_rounded,
                  color: iconAndBadgeTextColor,
                  size: ResponsiveHelper.iconSize(22),
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'map_selected_report'.tr,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveHelper.titleFontSize(16),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        // Free হলে badge bg হালকা grey, অন্যগুলো statusColor tint
                        color: _isFree
                            ? const Color(0xFFF1F5F9)
                            : statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        // Free হলে border দিলে badge আলাদা বোঝা যায়
                        border: _isFree
                            ? Border.all(color: const Color(0xFFE2E8F0))
                            : null,
                      ),
                      child: Text(
                        pinLabel,
                        style: TextStyle(
                          color: iconAndBadgeTextColor,
                          fontSize: ResponsiveHelper.fontSize(11),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Close Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: onClose,
                  child: Container(
                    padding: ResponsiveHelper.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF475569),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.spacing(16)),

          // Info Box
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: ResponsiveHelper.all(14),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.paidBlue,
                  key: 'map_parking_cost',
                  value: controller.parkingCostText(report),
                  textDark: textDark,
                  textSecondary: textSecondary,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(10)),
                  child: const Divider(color: Color(0xFFE2E8F0), height: 1),
                ),
                _buildInfoRow(
                  icon: Icons.electric_car_rounded,
                  iconColor: AppColors.chargingGreen,
                  key: 'map_electric_charging',
                  value: controller.boolFlag(report['electric_charging']),
                  textDark: textDark,
                  textSecondary: textSecondary,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(10)),
                  child: const Divider(color: Color(0xFFE2E8F0), height: 1),
                ),
                _buildInfoRow(
                  icon: Icons.accessible_rounded,
                  iconColor: AppColors.disableOrange,
                  key: 'map_disabled_facility',
                  value: controller.boolFlag(report['disabled_facility']),
                  textDark: textDark,
                  textSecondary: textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String key,
    required String value,
    required Color textDark,
    required Color textSecondary,
  }) {
    final bool isNo = value.toLowerCase() == 'no';
    final Color valueColor = isNo ? const Color(0xFFEF4444) : textDark;

    return Row(
      children: [
        Container(
          padding: ResponsiveHelper.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
          ),
          child: Icon(icon, color: iconColor, size: ResponsiveHelper.iconSize(18)),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Text(
            key.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textSecondary,
              fontSize: ResponsiveHelper.fontSize(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveHelper.fontSize(13),
          ),
        ),
      ],
    );
  }
}

extension ColorDarken on Color {
  Color withDarkness(double amount) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}