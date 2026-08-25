import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
import 'package:platchatapp/feature/parking/presentation/screens/save_parking_screen.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class SaveParkingDialog extends StatefulWidget {
  final LatLng? pickedLocation;
  final LatLng? gpsPosition;
  final ParkingReportController parkingCtrl;
  final VoidCallback onPickOnMap;
  final Function(LatLng) onSaveSuccess;
  final Function(String, {bool isError}) showCustomSnackBar;

  const SaveParkingDialog({
    super.key,
    required this.pickedLocation,
    required this.gpsPosition,
    required this.parkingCtrl,
    required this.onPickOnMap,
    required this.onSaveSuccess,
    required this.showCustomSnackBar,
  });

  @override
  State<SaveParkingDialog> createState() => _SaveParkingDialogState();
}

class _SaveParkingDialogState extends State<SaveParkingDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedParkingType = 'FREE';
  bool _nameHasError = false;
  bool _durationHasError = false;
  String _durationErrorText = '';

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Widget _buildTypeButton(String type) {
    bool isSelected = _selectedParkingType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedParkingType = type),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.padding(14)),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D72E8) : AppColors.transparent,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(10),
            ),
          ),
          child: Center(
            child: Text(
              type == 'FREE' ? AppStrings.free.tr : AppStrings.paid.tr,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.fontSize(14),
                color: isSelected ? AppColors.white : const Color(0xFF8F9BB3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitParking() async {
    final location = widget.pickedLocation ?? widget.gpsPosition;
    if (location == null) {
      widget.showCustomSnackBar(
        AppStrings.locationNotAvailableWait.tr,
        isError: true,
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameHasError = true);
      widget.showCustomSnackBar(AppStrings.fieldIsRequired.tr, isError: true);
      return;
    }

    int? durationMin;
    if (_selectedParkingType == 'PAID') {
      final input = _durationController.text.trim();
      if (input.isEmpty) {
        widget.showCustomSnackBar(AppStrings.timeIsRequired.tr, isError: true);
        return;
      }
      durationMin = int.tryParse(input);
      if (durationMin == null || durationMin <= 0) {
        widget.showCustomSnackBar(
          AppStrings.enterValidNumber.tr,
          isError: true,
        );
        return;
      }
      if (durationMin < 15) {
        widget.showCustomSnackBar(
          AppStrings.minimum15MinutesRequired.tr,
          isError: true,
        );
        return;
      }
    }

    final success = await widget.parkingCtrl.saveMyParking(
      latitude: location.latitude,
      longitude: location.longitude,
      parkingType: _selectedParkingType,
      durationMin: durationMin,
      name: _nameController.text,
    );

    if (success) {
      // Immediately update the purple "myParked" pin on the map so the user
      // can see it right away (without waiting for a full re-init).
      if (Get.isRegistered<ParkingShowController>()) {
        Get.find<ParkingShowController>().fetchSavedParkingMe();
      }

      if (mounted) {
        Navigator.of(context).pop();
        // Take the user straight to the Save Parking screen — its own
        // initState fetches a fresh history list, so the just-saved spot
        // shows up immediately. When the user presses back, refresh the
        // purple pin again so it stays visible on the map.
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SaveParkingScreen()))
            .then((_) {
          // Re-fetch when returning from SaveParkingScreen so the purple
          // pin is still visible after the user presses back.
          if (Get.isRegistered<ParkingShowController>()) {
            Get.find<ParkingShowController>().fetchSavedParkingMe();
          }
        });
      }
      widget.showCustomSnackBar(
        AppStrings.parkingLocationSavedSuccessfully.tr,
        isError: false,
      );
      _nameController.clear();
      _durationController.clear();
      widget.onSaveSuccess(location);
    } else {
      widget.showCustomSnackBar(
        widget.parkingCtrl.submitMessage.value.isNotEmpty
            ? widget.parkingCtrl.submitMessage.value
            : AppStrings.failedToSaveParkingLocation.tr,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: ResponsiveHelper.padding(20),
          right: ResponsiveHelper.padding(20),
          top: ResponsiveHelper.padding(20),
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              ResponsiveHelper.padding(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: ResponsiveHelper.width(40),
                height: ResponsiveHelper.height(4),
                margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(16)),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.parkMyCar.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.padding(6)),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF475569),
                      size: ResponsiveHelper.iconSize(16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.spacing(18)),

            // Location source row — same widget/behavior as Add Parking
            // Spot's ParkingInfoDialog: shows the picked lat/lng once set,
            // with a "Change" link to pick again.
            GestureDetector(
              onTap: widget.onPickOnMap,
              child: Container(
                padding: ResponsiveHelper.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
                  border: Border.all(
                    color: widget.pickedLocation == null
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
                          widget.pickedLocation == null
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
                        widget.pickedLocation == null
                            ? AppStrings.usingCurrentLocation.tr
                            : '${AppStrings.selectedLocation.tr}: ${widget.pickedLocation!.latitude.toStringAsFixed(5)}, '
                                  '${widget.pickedLocation!.longitude.toStringAsFixed(5)}',
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
                      widget.pickedLocation == null
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

            Text(
              AppStrings.name.tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(13),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameHasError) {
                  setState(() => _nameHasError = false);
                }
              },
              style: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(14)),
              decoration: InputDecoration(
                hintText: AppStrings.name.tr,
                hintStyle: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(14)),
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
                errorText: _nameHasError ? AppStrings.fieldIsRequired.tr : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                  borderSide: _nameHasError
                      ? BorderSide(
                          color: const Color(0xFFEF4444),
                          width: ResponsiveHelper.borderWidth(1),
                        )
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                  borderSide: BorderSide(
                    color: _nameHasError
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3D72E8),
                    width: ResponsiveHelper.borderWidth(1.4),
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),

            Text(
              AppStrings.parkingType.tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(13),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.padding(4)),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(12),
                ),
              ),
              child: Row(
                children: [
                  _buildTypeButton('FREE'),
                  SizedBox(width: ResponsiveHelper.spacing(4)),
                  _buildTypeButton('PAID'),
                ],
              ),
            ),

            if (_selectedParkingType == 'PAID') ...[
              SizedBox(height: ResponsiveHelper.spacing(16)),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  if (_durationHasError) {
                    setState(() => _durationHasError = false);
                  }
                },
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(14),
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.durationMin15Minutes.tr,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  errorText: _durationHasError ? _durationErrorText : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                    borderSide: _durationHasError
                        ? BorderSide(
                            color: const Color(0xFFEF4444),
                            width: ResponsiveHelper.borderWidth(1),
                          )
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                    borderSide: BorderSide(
                      color: _durationHasError
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF3D72E8),
                      width: ResponsiveHelper.borderWidth(1.4),
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: ResponsiveHelper.spacing(24)),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.padding(14),
                      ),
                      side: BorderSide(color: AppColors.greyShade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(14),
                        ),
                      ),
                    ),
                    child: Text(
                      AppStrings.cancel.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.spacing(12)),
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final isSaving =
                        widget.parkingCtrl.isLoadingSaveParking.value;
                    return ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              if (_selectedParkingType == 'PAID') {
                                final input = _durationController.text.trim();
                                final parsed = int.tryParse(input);
                                if (input.isEmpty) {
                                  setState(() {
                                    _durationHasError = true;
                                    _durationErrorText =
                                        AppStrings.timeIsRequired.tr;
                                  });
                                  widget.showCustomSnackBar(
                                    AppStrings.timeIsRequired.tr,
                                    isError: true,
                                  );
                                  return;
                                }
                                if (parsed == null || parsed <= 0) {
                                  setState(() {
                                    _durationHasError = true;
                                    _durationErrorText =
                                        AppStrings.enterValidNumber.tr;
                                  });
                                  widget.showCustomSnackBar(
                                    AppStrings.enterValidNumber.tr,
                                    isError: true,
                                  );
                                  return;
                                }
                                if (parsed < 15) {
                                  setState(() {
                                    _durationHasError = true;
                                    _durationErrorText =
                                        AppStrings.minimum15MinutesRequired.tr;
                                  });
                                  widget.showCustomSnackBar(
                                    AppStrings.minimum15MinutesRequired.tr,
                                    isError: true,
                                  );
                                  return;
                                }
                              }
                              _submitParking();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D72E8),
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.padding(14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.borderRadius(14),
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? SizedBox(
                              width: ResponsiveHelper.iconSize(18),
                              height: ResponsiveHelper.iconSize(18),
                              child: CircularProgressIndicator(
                                strokeWidth: ResponsiveHelper.borderWidth(2),
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              widget.pickedLocation != null
                                  ? AppStrings.savePickedLocation.tr
                                  : AppStrings.saveMyLocation.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

