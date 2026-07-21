import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
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
  final TextEditingController _durationController = TextEditingController();
  String _selectedParkingType = 'FREE';
  bool _durationHasError = false;
  String _durationErrorText = '';

  @override
  void dispose() {
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
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.padding(14),
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D72E8) : Colors.transparent,
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
          ),
          child: Center(
            child: Text(
              type == 'FREE' ? AppStrings.free.tr : AppStrings.paid.tr,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.fontSize(14),
                color: isSelected ? Colors.white : const Color(0xFF8F9BB3),
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

    int? durationMin;
    if (_selectedParkingType == 'PAID') {
      final input = _durationController.text.trim();
      if (input.isEmpty) {
        widget.showCustomSnackBar(AppStrings.timeIsRequired.tr, isError: true);
        return;
      }
      durationMin = int.tryParse(input);
      if (durationMin == null || durationMin <= 0) {
        widget.showCustomSnackBar(AppStrings.enterValidNumber.tr, isError: true);
        return;
      }
      if (durationMin < 15) {
        widget.showCustomSnackBar(AppStrings.minimum15MinutesRequired.tr, isError: true);
        return;
      }
    }

    final success = await widget.parkingCtrl.saveMyParking(
      latitude: location.latitude,
      longitude: location.longitude,
      parkingType: _selectedParkingType,
      durationMin: durationMin,
    );

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      widget.showCustomSnackBar(AppStrings.parkingLocationSavedSuccessfully.tr, isError: false);
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(20),
        vertical: ResponsiveHelper.padding(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(20),
            vertical: ResponsiveHelper.padding(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: ResponsiveHelper.spacing(4)),
              Text(
                widget.pickedLocation != null
                    ? 'Using picked location'
                    : 'Using current location',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),

              // Location row with "Pick on map" action
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(12),
                  vertical: ResponsiveHelper.padding(10),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.pickedLocation != null
                          ? Icons.location_on_rounded
                          : Icons.gps_fixed_rounded,
                      color: const Color(0xFF3D72E8),
                      size: ResponsiveHelper.iconSize(18),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    Expanded(
                      child: Text(
                        widget.pickedLocation != null
                            ? 'Picked location set'
                            : 'Using current location',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onPickOnMap,
                      child: Text(
                        AppStrings.pickOnMap.tr,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(13),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D72E8),
                        ),
                      ),
                    ),
                  ],
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
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
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
                    errorText:
                    _durationHasError ? _durationErrorText : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                      borderSide: _durationHasError
                          ? BorderSide(
                          color: const Color(0xFFEF4444), width: ResponsiveHelper.borderWidth(1))
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
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
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
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
                            final input = _durationController.text
                                .trim();
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
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
                          ),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? SizedBox(
                          width: ResponsiveHelper.iconSize(18),
                          height: ResponsiveHelper.iconSize(18),
                          child: CircularProgressIndicator(
                            strokeWidth: ResponsiveHelper.borderWidth(2),
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          widget.pickedLocation != null
                              ? AppStrings.savePickedLocation.tr
                              : AppStrings.saveMyLocation.tr,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ),
    );
  }
}
