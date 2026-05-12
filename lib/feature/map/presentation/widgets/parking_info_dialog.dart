import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Parking Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const SectionLabel(icon: Icons.local_parking_rounded, label: 'Parking Cost'),
              const SizedBox(height: 8),
              Row(
                children: ['FREE', 'PAID'].map((val) {
                  final selected = controller.parkingCost.value == val;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.parkingCost.value = val,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: val == 'FREE' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF3D72E8) : const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? const Color(0xFF3D72E8) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              val == 'FREE' ? Icons.money_off_rounded : Icons.attach_money_rounded,
                              color: selected ? Colors.white : const Color(0xFF6B7280),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              val,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ToggleRow(
                icon: Icons.electric_bolt_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'Electric Charging',
                value: controller.electricCharging.value,
                onTap: () => controller.electricCharging.toggle(),
              ),
              const SizedBox(height: 12),
              ToggleRow(
                icon: Icons.accessible_rounded,
                iconColor: const Color(0xFF10B981),
                label: 'Disabled Facility',
                value: controller.disabledFacility.value,
                onTap: () => controller.disabledFacility.toggle(),
              ),
              if (controller.disabledFacility.value) ...[
                const SizedBox(height: 16),
                const SectionLabel(icon: Icons.location_on_rounded, label: 'Disabled Parking Location'),
                const SizedBox(height: 10),
                DisabledLocationPicker(controller: controller),
              ],
              const SizedBox(height: 24),
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D72E8)))
                    : Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onCancel,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F6FB),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: onSubmit,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3D72E8).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.pin_drop_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Drop Pin',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
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

///disable====================================

class DisabledLocationPicker extends StatelessWidget {
  final ParkingReportController controller;

  const DisabledLocationPicker({super.key, required this.controller});

  static final _options = [
    _DLocOption(DisabledLocation.all, 'ALL', AssetsPath.all),
    _DLocOption(DisabledLocation.back, 'BACK', AssetsPath.back),
    _DLocOption(DisabledLocation.right, 'RIGHT', AssetsPath.left),
    _DLocOption(DisabledLocation.left, 'LEFT', AssetsPath.right),
    _DLocOption(DisabledLocation.none, 'NONE', AssetsPath.all),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _options.map((opt) {
          final selected = controller.disabledLocation.value == opt.location;
          return GestureDetector(
            onTap: () => controller.disabledLocation.value = opt.location,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF10B981) : const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(opt.icon, width: 24, height: 24),
                  const SizedBox(width: 4),
                  Text(
                    opt.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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

class SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const SectionLabel({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF3D72E8).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(icon, size: 18)),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? iconColor.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value ? iconColor : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
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
