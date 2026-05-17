import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

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

  /// Core Status Color based on report data (Premium & High Contrast Palette)
  Color _getStatusColor() {
    if (report['disabled_facility'] == true) {
      return const Color(0xFFD97706); // Darker Amber/Orange for better visibility
    }
    if (report['electric_charging'] == true) {
      return const Color(0xFF059669); // Deep Emerald Green
    }
    final cost = report['parking_cost'];
    final isPaid = cost != null && cost != 0 && cost != '0' && cost != '';
    return isPaid ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563); // Deep Royal Blue or Slate Grey
  }

  /// Status Label Text
  String _getPinLabel() {
    if (report['disabled_facility'] == true) return 'Disabled Parking';
    if (report['electric_charging'] == true) return 'Electric Charging';
    final cost = report['parking_cost'];
    final isPaid = cost != null && cost != 0 && cost != '0' && cost != '';
    return isPaid ? 'Paid Parking' : 'Free Parking';
  }

  @override
  Widget build(BuildContext context) {


    final statusColor = _getStatusColor();
    final pinLabel = _getPinLabel();
    final bool isFree = statusColor == const Color(0xFF4B5563);

    // ম্যাপের ওপর শতভাগ ভিজিবিলিটি নিশ্চিত করার জন্য সলিড ব্যাকগ্রাউন্ড
    final Color cardBgColor = Colors.white;
    final Color titleColor = const Color(0xFF0F172A); // Slate 900 (High Contrast)
    final Color borderColor = statusColor.withOpacity(0.3);

    // ভেতরের টেক্সটের জন্য আরও ডার্ক কালার টোন
    const Color textDark = Color(0xFF1E293B); // Slate 800
    const Color textSecondary = Color(0xFF64748B); // Slate 500

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
        // ম্যাপের হিজিবিজি ভাব থেকে উইজেটকে আলাদা করতে স্ট্রং ব্লার শ্যাডো
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
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle, // সার্কেল শেপ আইকনকে বেশি প্রিমিয়াম লুক দেয়
                ),
                child: Icon(
                  Icons.local_parking_rounded,
                  color: statusColor,
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
                        fontWeight: FontWeight.w600 ,
                        fontSize: ResponsiveHelper.titleFontSize(16),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(2)),
                    // স্ট্যাটাসকে হাইলাইট করার জন্য একটি ছোট ব্যাজ ডিজাইন
                    Container(
                      padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pinLabel,
                        style: TextStyle(
                          color: statusColor,
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Slate 100
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF475569), // Slate 600
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
              color: const Color(0xFFF8FAFC), // হালকা গ্রে-হোয়াইট ব্যাকগ্রাউন্ড যা ভেতরের রো-গুলোকে ম্যাপ থেকে সম্পূর্ণ আলাদা করে
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
              border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
            ),
            padding: ResponsiveHelper.all(14),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.payments_rounded,
                  iconColor: const Color(0xFF2563EB),
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
                  iconColor: const Color(0xFF10B981),
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
                  iconColor: const Color(0xFFF59E0B),
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
    // ডানপাশের ভ্যালু অনুযায়ী ছোট ব্যাজ কালার (PAID/NO সহজে চেনার জন্য)
    final bool isNo = value.toLowerCase() == 'no';
    final Color valueColor = isNo ? const Color(0xFFEF4444) : textDark; // 'NO' হলে লাল রঙ দেখাবে

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
    return hslDark.toColor ();
  }
}