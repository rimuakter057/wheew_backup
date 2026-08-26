import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_added_success_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/save_parking_dialog.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/bottom_sheet_aware/tracked_bottom_sheet.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

import '../../../core/router/routes.dart';

enum AddParkingPurpose { report, save }

/// Owns the whole "Add Parking" flow (report-a-spot / park-my-car, including
/// the pick-location-on-map handoff) so ParkingMapScreen only has to call
/// into it — no flow logic lives in the screen itself. Same singleton
/// pattern as ParkingShowController / ParkingReportController.
class AddParkingFlowController extends GetxController {
  late final ParkingReportController _parkingReportCtrl;

  final Rxn<LatLng> pickedAddParkingLocation = Rxn<LatLng>();
  final RxBool isPickingAddParkingLocation = false.obs;
  LatLng? _pickedAddParkingLocation;
  AddParkingPurpose? _addParkingPickingPurpose;

  BuildContext? get _dialogContext =>
      AppRouter.navigatorKey.currentState?.overlay?.context ??
      AppRouter.navigatorKey.currentContext;

  @override
  void onInit() {
    super.onInit();
    // Same controller instance Home's map screen uses for "Add Parking" —
    // shared singleton via GetX, so the flow behaves identically.
    _parkingReportCtrl = Get.isRegistered<ParkingReportController>()
        ? Get.find<ParkingReportController>()
        : Get.put(ParkingReportController());
  }

  void showAddParkingOptions() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    HapticFeedback.selectionClick();
    showTrackedBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.containerGradient,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          padding: EdgeInsets.only(
            left: ResponsiveHelper.padding(16),
            right: ResponsiveHelper.padding(16),
            top: ResponsiveHelper.padding(12),
            bottom: ResponsiveHelper.padding(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: ResponsiveHelper.width(40),
                  height: ResponsiveHelper.height(4),
                  margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(18)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              CustomGradientButton(
                prefixIcon: const Icon(
                  Icons.add_location_alt_rounded,
                  color: AppColors.white,
                ),
                label: AppStrings.addParkingSpot.tr,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _toggleAddParkingPin();
                },
              ),
              SizedBox(height: ResponsiveHelper.spacing(14)),
              CustomGradientButton(
                prefixIcon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.white,
                ),
                label: AppStrings.parkMyCar.tr,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  // Fresh open — same reset Add Parking Spot does: always
                  // start from current location, never a location (or
                  // leftover picking-mode) from a previous, already-
                  // dismissed session of this sheet.
                  _pickedAddParkingLocation = null;
                  pickedAddParkingLocation.value = null;
                  _stopPickingAddParkingLocation();
                  _showSaveParkingSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleAddParkingPin() {
    HapticFeedback.mediumImpact();
    _pickedAddParkingLocation = null;
    pickedAddParkingLocation.value = null;
    _stopPickingAddParkingLocation();
    _showParkingReportDialog();
  }

  void _showParkingReportDialog() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    _parkingReportCtrl.reset();

    // Explicit actions (pick-on-map / submit) set this so the sheet-dismiss
    // cleanup below doesn't double-run the same reset when they pop it.
    bool handled = false;

    showTrackedBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ParkingInfoDialog(
        controller: _parkingReportCtrl,
        pickedLocation: _pickedAddParkingLocation,
        onPickOnMap: () {
          handled = true;
          Navigator.of(ctx).pop();
          _startPickingAddParkingLocation(purpose: AddParkingPurpose.report);
        },
        onSubmit: () async {
          handled = true;
          Navigator.of(ctx).pop();
          _stopPickingAddParkingLocation();

          final gps = Get.find<ParkingShowController>().gpsPosition.value;
          if (_pickedAddParkingLocation == null && gps == null) {
            showCustomSnackBar(
              AppStrings.locationNotAvailable.tr,
              isError: true,
            );
            return;
          }

          if (_parkingReportCtrl.parkingCost.value == 'PAID') {
            final feeText = _parkingReportCtrl.feeController.text.trim();
            final fee = num.tryParse(feeText);
            if (feeText.isEmpty) {
              showCustomSnackBar(AppStrings.fieldIsRequired.tr, isError: true);
              return;
            }
            if (fee == null || fee < 0.01) {
              showCustomSnackBar(AppStrings.enterValidNumber.tr, isError: true);
              return;
            }
          }

          final LatLng useLocation = _pickedAddParkingLocation ?? gps!;

          final createdArea = await _parkingReportCtrl.addParking(
            latitude: useLocation.latitude,
            longitude: useLocation.longitude,
          );

          final resultCtx = _dialogContext;
          if (createdArea != null) {
            // Instantly add the new spot's pin to the map — no refresh needed.
            if (Get.isRegistered<ParkingShowController>()) {
              Get.find<ParkingShowController>()
                  .addParkingAreaInstantly(createdArea);
            }
            if (resultCtx != null) {
              await ParkingAddedSuccessDialog.show(ctx);
            }
            _pickedAddParkingLocation = null;
            pickedAddParkingLocation.value = null;
          } else {
            showCustomSnackBar(
              _parkingReportCtrl.submitMessage.value.isNotEmpty
                  ? _parkingReportCtrl.submitMessage.value
                  : AppStrings.mapFailedToSubmitParkingReport.tr,
              isError: true,
            );
          }
        },
      ),
    ).whenComplete(() {
      // User swiped the sheet down / tapped outside without picking a
      // location or dropping the pin — same cleanup as the old Cancel button.
      if (!handled) {
        _pickedAddParkingLocation = null;
        pickedAddParkingLocation.value = null;
        _stopPickingAddParkingLocation();
      }
    });
  }

  void _showSaveParkingSheet() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    // Explicit actions (pick-on-map / save) set this so the sheet-dismiss
    // cleanup below doesn't wipe a location that's mid-handoff or already
    // saved.
    bool handled = false;

    showTrackedBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) {
        return SaveParkingDialog(
          pickedLocation: _pickedAddParkingLocation,
          gpsPosition: Get.find<ParkingShowController>().gpsPosition.value,
          parkingCtrl: _parkingReportCtrl,
          onPickOnMap: () {
            handled = true;
            Navigator.of(sheetContext).pop();
            _startPickingAddParkingLocation(purpose: AddParkingPurpose.save);
          },
          onSaveSuccess: (location) {
            handled = true;
            _pickedAddParkingLocation = null;
            pickedAddParkingLocation.value = null;
          },
          showCustomSnackBar: showCustomSnackBar,
        );
      },
    ).whenComplete(() {
      // User swiped the sheet down / tapped outside / hit Cancel without
      // saving — next fresh open must default back to current location.
      if (!handled) {
        _pickedAddParkingLocation = null;
        pickedAddParkingLocation.value = null;
        _stopPickingAddParkingLocation();
      }
    });
  }

  void _startPickingAddParkingLocation({required AddParkingPurpose purpose}) {
    if (Get.isRegistered<ParkingShowController>()) {
      Get.find<ParkingShowController>().clearSpotDetailsCard();
    }
    _addParkingPickingPurpose = purpose;
    isPickingAddParkingLocation.value = true;
    isPickingOnMap.value = true;
    final gps = Get.find<ParkingShowController>().gpsPosition.value;
    if (pickedAddParkingLocation.value == null && gps != null) {
      pickedAddParkingLocation.value = gps;
      _pickedAddParkingLocation = gps;
    }
  }

  void _stopPickingAddParkingLocation() {
    isPickingAddParkingLocation.value = false;
    isPickingOnMap.value = false;
    _addParkingPickingPurpose = null;
  }

  void cancelPicking() {
    isPickingAddParkingLocation.value = false;
    isPickingOnMap.value = false;
    _addParkingPickingPurpose = null;
    pickedAddParkingLocation.value = null;
    _pickedAddParkingLocation = null;
  }

  void useCurrentLocation() {
    final gps = Get.find<ParkingShowController>().gpsPosition.value;
    if (gps != null) {
      pickedAddParkingLocation.value = gps;
      _pickedAddParkingLocation = gps;
      HapticFeedback.selectionClick();
    }
  }

  void confirmPickedLocation() {
    final purpose = _addParkingPickingPurpose;
    isPickingAddParkingLocation.value = false;
    isPickingOnMap.value = false;
    _addParkingPickingPurpose = null;

    if (purpose == AddParkingPurpose.save) {
      _showSaveParkingSheet();
    } else {
      _showParkingReportDialog();
    }
  }

  void onMapTappedForAddParking(LatLng position) {
    if (!isPickingAddParkingLocation.value) {
      Get.find<ParkingShowController>().clearSpotDetailsCard();
      return;
    }

    _pickedAddParkingLocation = position;
    pickedAddParkingLocation.value = position;

    HapticFeedback.selectionClick();
  }
}
