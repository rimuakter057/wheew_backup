import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';

class ParkingInfoDialog extends StatelessWidget {
  final ParkingReportController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const ParkingInfoDialog({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {


    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(20),
        vertical: ResponsiveHelper.padding(24),
      ),
      child: Obx(
            () => SingleChildScrollView(
          padding: ResponsiveHelper.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: ResponsiveHelper.width(36),
                    height: ResponsiveHelper.height(36),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: ResponsiveHelper.fontSize(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(10)),
                  Text(
                    'map_parking_details'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.titleFontSize(16),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.spacing(20)),
              const Divider(height: 1),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              SectionLabel(
                icon: Icons.local_parking_rounded,
                label: 'map_parking_cost'.tr,
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),
              Row(
                children: ['FREE', 'PAID'].map((val) {
                  final selected = controller.parkingCost.value == val;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.parkingCost.value = val,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: val == 'FREE' ? ResponsiveHelper.spacing(8) : 0,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.padding(12),
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF3D72E8)
                              : const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.borderRadius(12),
                          ),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF3D72E8)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              val == 'FREE'
                                  ? Icons.money_off_rounded
                                  : Icons.attach_money_rounded,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                              size: ResponsiveHelper.iconSize(18),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(6)),
                            Text(
                              (val == 'FREE'
                                      ? 'map_free'
                                      : 'map_paid')
                                  .tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(13),
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              ToggleRow(
                icon: Icons.electric_bolt_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'map_electric_charging'.tr,
                value: controller.electricCharging.value,
                onTap: () => controller.electricCharging.toggle(),
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              ToggleRow(
                icon: Icons.accessible_rounded,
                iconColor: const Color(0xFF10B981),
                label: 'map_disabled_facility'.tr,
                value: controller.disabledFacility.value,
                onTap: () => controller.disabledFacility.toggle(),
              ),
              if (controller.disabledFacility.value) ...[
                SizedBox(height: ResponsiveHelper.spacing(16)),
                SectionLabel(
                  icon: Icons.location_on_rounded,
                  label: 'map_disabled_parking_location'.tr,
                ),
                SizedBox(height: ResponsiveHelper.spacing(10)),
                DisabledLocationPicker(controller: controller),
              ],
              SizedBox(height: ResponsiveHelper.spacing(24)),
              Obx(
                    () => controller.isLoading.value
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3D72E8),
                  ),
                )
                    : Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCancel,
                        child: Container(
                          height: ResponsiveHelper.buttonHeight(48),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FB),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(14),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'map_cancel'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: onSubmit,
                        child: Container(
                          height: ResponsiveHelper.buttonHeight(48),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3D72E8),
                                Color(0xFF2557D6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(14),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3D72E8,
                                ).withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pin_drop_rounded,
                                color: Colors.white,
                                size: ResponsiveHelper.iconSize(18),
                              ),
                              SizedBox(width: ResponsiveHelper.spacing(6)),
                              Text(
                                'map_drop_pin'.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveHelper.fontSize(14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== DisabledLocationPicker =====

class DisabledLocationPicker extends StatelessWidget {
  final ParkingReportController controller;

  const DisabledLocationPicker({super.key, required this.controller});

  static final _options = [
    _DLocOption(DisabledLocation.all, 'map_all'.tr, AssetsPath.all),
    _DLocOption(DisabledLocation.back, 'map_back'.tr, AssetsPath.back),
    _DLocOption(DisabledLocation.right, 'map_right'.tr, AssetsPath.right),
    _DLocOption(DisabledLocation.left, 'map_left'.tr, AssetsPath.left),
    _DLocOption(DisabledLocation.none, 'map_none'.tr, AssetsPath.none),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Wrap(
        spacing: ResponsiveHelper.spacing(8),
        runSpacing: ResponsiveHelper.spacing(8),
        children: _options.map((opt) {
          final selected = controller.disabledLocation.value == opt.location;
          return GestureDetector(
            onTap: () => controller.disabledLocation.value = opt.location,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: ResponsiveHelper.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(10),
                ),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    opt.icon,
                    width: ResponsiveHelper.iconSize(24),
                    height: ResponsiveHelper.iconSize(24),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(4)),
                  Text(
                    opt.label.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(12),
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DLocOption {
  final DisabledLocation location;
  final String label;
  final String icon;

  const _DLocOption(this.location, this.label, this.icon);
}

// ===== SectionLabel =====

class SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const SectionLabel({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.width(32),
          height: ResponsiveHelper.height(32),
          decoration: BoxDecoration(
            color: const Color(0xFF3D72E8).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(8),
            ),
          ),
          child: Center(
            child: Icon(icon, size: ResponsiveHelper.iconSize(18)),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(10)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(13),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// ===== ToggleRow =====

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final VoidCallback onTap;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveHelper.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          border: Border.all(
            color: value
                ? iconColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.width(32),
              height: ResponsiveHelper.height(32),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: ResponsiveHelper.iconSize(16),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(13),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: ResponsiveHelper.width(44),
              height: ResponsiveHelper.height(24),
              decoration: BoxDecoration(
                color: value ? iconColor : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(12),
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: ResponsiveHelper.width(18),
                  height: ResponsiveHelper.height(18),
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.spacing(3),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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