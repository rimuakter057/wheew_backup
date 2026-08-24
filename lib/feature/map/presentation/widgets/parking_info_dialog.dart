import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/feature/auth/view/widgets/vehicle_submit_button.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class ParkingInfoDialog extends StatelessWidget {
  final ParkingReportController controller;
  final VoidCallback onSubmit;
  final LatLng? pickedLocation; // âš ï¸ à¦®à§à¦¯à¦¾à¦ªà§‡ à¦ªà¦¿à¦• à¦•à¦°à¦¾ location (null à¦¹à¦²à§‡ current GPS à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦¹à¦¬à§‡)
  final VoidCallback onPickOnMap; // âš ï¸ "Pick on map" à¦šà¦¾à¦ªà¦²à§‡ à¦•à¦² à¦¹à¦¬à§‡

  const ParkingInfoDialog({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.pickedLocation,
    required this.onPickOnMap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          left: ResponsiveHelper.padding(20),
          right: ResponsiveHelper.padding(20),
          top: ResponsiveHelper.padding(12),
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              ResponsiveHelper.padding(24),
        ),
        decoration: BoxDecoration(
         gradient:AppColors.primaryBackgroundGradient,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveHelper.borderRadius(28)),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Drag handle ------------------------------------------
              Center(
                child: Container(
                  width: ResponsiveHelper.width(40),
                  height: ResponsiveHelper.height(4),
                  margin: EdgeInsets.only(
                    bottom: ResponsiveHelper.spacing(16),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              Text(
                AppStrings.mapParkingDetails.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.titleFontSize(20),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(18)),

              // -- Location source row ----------------------------------
              GestureDetector(
                onTap: onPickOnMap,
                child: Container(
                  padding: ResponsiveHelper.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(30),
                    ),
                    border: Border.all(
                      color: pickedLocation == null
                          ? AppColors.transparent
                          : const Color(0xFF3D72E8).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveHelper.width(32),
                        height: ResponsiveHelper.height(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D72E8).withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            pickedLocation == null
                                ? Icons.my_location_rounded
                                : Icons.location_on_rounded,
                            color: const Color(0xFF3D72E8),
                            size: ResponsiveHelper.iconSize(16),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(10)),
                      Expanded(
                        child: Text(
                          pickedLocation == null
                              ? AppStrings.usingCurrentLocation.tr
                              : '${AppStrings.selectedLocation.tr}: ${pickedLocation!.latitude.toStringAsFixed(5)}, '
                                    '${pickedLocation!.longitude.toStringAsFixed(5)}',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(12),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(8)),
                      Text(
                        pickedLocation == null
                            ? AppStrings.pickOnMap.tr
                            : AppStrings.change.tr,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(12),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D72E8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(20)),

              // -- Parking Name ------------------------------------------
              Text(
                'Parking Name',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(15),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(10)),
              Container(
                padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(16),
                  ),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextField(
                  controller: controller.nameController,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter parking area name',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(20)),

              // -- Parking Cost ------------------------------------------
              Text(
                AppStrings.mapParkingCost.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(15),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(10)),
              Row(
                children: [
                  Expanded(
                    child: _CostOption(
                      label: AppStrings.free.tr,
                      selected: controller.parkingCost.value == 'FREE',
                      onTap: () => controller.parkingCost.value = 'FREE',
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Expanded(
                    child: _CostOption(
                      label: AppStrings.paid.tr,
                      selected: controller.parkingCost.value == 'PAID',
                      onTap: () => controller.parkingCost.value = 'PAID',
                    ),
                  ),
                ],
              ),

              if (controller.parkingCost.value == 'PAID') ...[
                SizedBox(height: ResponsiveHelper.spacing(16)),
                Text(
                  AppStrings.parkingFeePerHour.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(15),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(10)),
                TextField(
                  controller: controller.feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(14)),
                  decoration: InputDecoration(
                    hintText: '5.00',
                    hintStyle: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(14)),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FB),
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                      borderSide: BorderSide(
                        color: const Color(0xFF3D72E8),
                        width: ResponsiveHelper.borderWidth(1.4),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: ResponsiveHelper.spacing(20)),

              // -- Electric Charging + Disabled Facility (grouped card) --
              Container(
                decoration: BoxDecoration(
               gradient: AppColors.containerGradient,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(16),
                  ),
                  border: Border.all(color: AppColors.white)
                ),
                child: Column(
                  children: [
                    ToggleRow(
                      icon: AssetsPath.electricCharging,
                      iconColor: const Color(0xFFF59E0B),
                      label: AppStrings.mapElectricCharging.tr,
                      value: controller.electricCharging.value,
                      onTap: () => controller.electricCharging.toggle(),
                      subtitle: AppStrings.showElectricCharging.tr,
                      showCard: false,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFFE5E7EB),
                      indent: ResponsiveHelper.width(14),
                      endIndent: ResponsiveHelper.width(14),
                    ),
                    ToggleRow(
                      icon: AssetsPath.disabledFacility,
                      iconColor: const Color(0xFF10B981),
                      label: AppStrings.mapDisabledFacility.tr,
                      value: controller.disabledFacility.value,
                      subtitle: AppStrings.showDisabledParking.tr,
                      onTap: controller.toggleDisabledFacility,
                      showCard: false,
                    ),
                  ],
                ),
              ),

              if (controller.disabledFacility.value) ...[
                SizedBox(height: ResponsiveHelper.spacing(20)),
                Text(
                  AppStrings.mapDisabledParkingLocation.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(10)),
                DisabledLocationPicker(controller: controller),
              ],
              SizedBox(height: ResponsiveHelper.spacing(24)),

              // -- Drop Pin ----------------------------------------------
              CustomGradientButton(
                onPressed: onSubmit,
                isLoading: controller.isLoading.value,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.white),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    Text(
                      AppStrings.dropPin.tr,
                      style: context.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ===== _CostOption (Free / Paid pill) =====

class _CostOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CostOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? AppColors.buttonGradient
              : null,
          color: selected ? null : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.blu.withValues(
                alpha: 0.28,
              ),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImage(imageSrc: AssetsPath.dolar,
            imageColor: selected ? AppColors.white : AppColors.black,
            ),
            SizedBox(width: ResponsiveHelper.spacing(4)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
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
    _DLocOption(DisabledLocation.all, AppStrings.mapAll.tr, AssetsPath.all),
    _DLocOption(DisabledLocation.back, AppStrings.mapBack.tr, AssetsPath.back),
    _DLocOption(DisabledLocation.right, AppStrings.mapRight.tr, AssetsPath.right),
    _DLocOption(DisabledLocation.left, AppStrings.mapLeft.tr, AssetsPath.left),
    _DLocOption(DisabledLocation.none, AppStrings.mapNone.tr, AssetsPath.none),
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
              padding: ResponsiveHelper.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected
                    ? AppColors.buttonGradient
                    : null,
                color: selected ? null : const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(50),
                ),
                border: Border.all(
                  color: selected
                      ? AppColors.transparent
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    opt.icon,
                    width: ResponsiveHelper.iconSize(20),
                    height: ResponsiveHelper.iconSize(20),
                    colorFilter: ColorFilter.mode(
                      selected ? AppColors.white : AppColors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(4)),
                  Text(
                    opt.label.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(12),
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : const Color(0xFF6B7280),
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

// ===== ToggleRow =====

class ToggleRow extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String label;
  final bool value;
  final VoidCallback onTap;
  final bool showCard;
  final String subtitle;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
    this.showCard = true, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveHelper.symmetric(horizontal: 14, vertical: 12),
        decoration: showCard
            ? BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(12),
                ),
                border: Border.all(
                  color: AppColors.white
                ),
              )
            : null,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: ResponsiveHelper.iconSize(16),
              height: ResponsiveHelper.iconSize(16),
             // colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.bodyMedium.copyWith(color: AppColors.black)
                  ),
                  Text(
                      subtitle,
                      style: context.bodySmall.copyWith(color: AppColors.black.withValues(alpha: 0.5))
                  ),
                ],
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
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: ResponsiveHelper.width(18),
                  height: ResponsiveHelper.height(18),
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.spacing(3),
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
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


