import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platchatapp/feature/auth/repository/user_location_controller.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/map/model/saved_parking_model.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_added_success_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_report_dropdown.dart';
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/map/presentation/widgets/radius_filter_button.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/bottom_sheet_aware/bottom_overlay_height_reporter.dart';
import 'package:platchatapp/share/widgets/bottom_sheet_aware/bottom_sheet_aware_positioned.dart';
import 'package:platchatapp/share/widgets/bottom_sheet_aware/tracked_bottom_sheet.dart';
import 'package:platchatapp/share/widgets/map_side_controls.dart';
import 'package:platchatapp/share/widgets/map_top_bar.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/pick_on_map_confirmation_card.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

import '../../../../utils/color/app_colors.dart';
import '../widgets/location_of_promt.dart';
import '../widgets/picking-location_banner.dart';
import '../widgets/save_parking_dialog.dart';
import '../widgets/saved_parking_details_bottom_sheet.dart';

/// Which flow triggered "pick on map" mode, so we know which UI to
/// reopen once the user actually taps a point on the map.
enum _PickingPurpose { report, save }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const LatLng kInitialMapTarget = LatLng(34.052235, -118.243683);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  int _selectedRadiusMeter = 250;
  final TextEditingController _searchController = TextEditingController();

  LatLng _mapCenter = MapScreen.kInitialMapTarget;
  LatLng? _gpsPosition;
  bool _isLocating = true;
  LatLng? _pickedLocation;
  bool _isPickingLocation = false;
  BitmapDescriptor? _parkedCarIcon;

  /// Tracks which flow (report-a-spot vs save-my-parking) started the
  /// "pick on map" mode, so _onMapTapped knows which UI to reopen.
  _PickingPurpose? _pickingPurpose;

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;





  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parkingCtrl = Get.isRegistered<ParkingReportController>()
        ? Get.find<ParkingReportController>()
        : Get.put(ParkingReportController());
    mapDebug('screen init â†’ resolve GPS and fetch parking');
    _loadCustomMarkerIcon();   // ðŸ‘ˆ à¦¨à¦¤à§à¦¨
    _initializeMap();


    final locationController = Get.isRegistered<UserLocationController>()
        ? Get.find<UserLocationController>()
        : Get.put(UserLocationController());
    locationController.initLocationTracking();
  }

  Future<void> _loadCustomMarkerIcon() async {
    final icon = await MapMarkerIcons.parkingPin();

    if (!mounted) return;
    setState(() {
      _parkedCarIcon = icon;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _searchController.dispose();
    // Close the "Selected Report" dropdown when leaving this tab — otherwise
    // it reappears next time Home is reopened, since selectedReport lives on
    // the (find-or-put) controller past this widget's own lifecycle.
    _parkingCtrl.clearSelectedReport();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _gpsPosition == null) {
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();

    // Fetch the user's own saved parking spot (GET /park-relay/saved-parking/me)
    await _parkingCtrl.fetchMySavedParking();

    if (!mounted) return;

    final location = _gpsPosition;

    if (location == null) {
      mapDebug('No GPS — skipping parking fetch');
      return;
    }

    // Fetch nearby reported parking spots
    await _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
      radius: _selectedRadiusMeter,
    );

    // Small delay so map controller is ready after GPS camera animation
    await Future.delayed(const Duration(milliseconds: 600));

    // Auto-fit camera to show all fetched parking areas
    await _fitCameraToParking();
  }

  double? _initialZoomLevel;

  Future<void> _getUserLocation() async {
    mapDebug('location: start');

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      if (!serviceEnabled) {
        setState(() => _isLocating = false);

        showCustomSnackBar(
          AppStrings.pleaseEnableLocationService.tr,
          isError: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!mounted) return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);

        showCustomSnackBar(
          AppStrings.locationPermissionDenied.tr,
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      mapDebug(
        'location: GPS ok '
            'lat=${position.latitude.toStringAsFixed(6)} '
            'lng=${position.longitude.toStringAsFixed(6)}',
      );

      setState(() {
        _gpsPosition = latLng;
        _mapCenter = latLng;
        _isLocating = false;
      });

      if (_mapController != null) {
        // Keep the exact same zoom level established during initial load/fit
        final zoomToUse = _initialZoomLevel ?? 16.5;
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            latLng,
            zoomToUse,
          ),
        );
      }

      mapDebug('location: camera animated');
    } catch (e, st) {
      mapDebug('location: error $e');
      mapDebug('location: stack $st');

      if (!mounted) return;

      setState(() {
        _isLocating = false;
      });
    }
  }


  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    _pickedLocation = null;
    _stopPickingLocation();
    mapDebug('parking report dialog open');
    _showParkingDialog();
  }

  // -- "Add Parking" button â†’ choose between the two existing flows -------
  // (FLOW 1 report-a-spot / FLOW 2 save-my-parking) instead of the old
  // always-visible two-pill layout.
  // ignore: unused_element
  void _showAddParkingOptions() {
    HapticFeedback.selectionClick();
    showTrackedBottomSheet(
      context: context,
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
                  _toggleParkingPin();
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
                  _showSaveParkingSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showParkingDialog() {
    _parkingCtrl.reset();

    // Explicit actions (pick-on-map / submit) set this so the sheet-dismiss
    // cleanup below doesn't double-run the same reset when they pop it.
    bool handled = false;

    showTrackedBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ParkingInfoDialog(
        controller: _parkingCtrl,
        pickedLocation: _pickedLocation,
        onPickOnMap: () {
          handled = true;
          Navigator.of(context).pop();
          _startPickingLocation(purpose: _PickingPurpose.report);
        },
        onSubmit: () async {
          handled = true;
          Navigator.of(context).pop();
          _stopPickingLocation();

          if (_pickedLocation == null && _gpsPosition == null) {
            showCustomSnackBar(
              AppStrings.locationNotAvailable.tr,
              isError: true,
            );
            return;
          }

          final LatLng useLocation = _pickedLocation ?? _gpsPosition!;

          final createdArea = await _parkingCtrl.addParking(
            latitude: useLocation.latitude,
            longitude: useLocation.longitude,
          );
          if (!mounted) return;
          if (createdArea != null) {
            await ParkingAddedSuccessDialog.show(context);
            if (!mounted) return;
            await _parkingCtrl.fetchParkingReport(
              latitude: useLocation.latitude,
              longitude: useLocation.longitude,
              radius: _selectedRadiusMeter,
            );
            _pickedLocation = null;
          } else {
            showCustomSnackBar(

              _parkingCtrl.submitMessage.value.isNotEmpty
                  ? _parkingCtrl.submitMessage.value
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
        _pickedLocation = null;
        _stopPickingLocation();
      }
    });
  }

  void _showSavedParkingDetailsSheet(SavedParkingModel parking) {
    showTrackedBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
      ),
      backgroundColor: AppColors.white,
      builder: (context) {
        return SavedParkingDetailsBottomSheet(
          parking: parking,
          showCustomSnackBar: showCustomSnackBar,
        );
      },
    );
  }

///add my save paring ====================================
  void _showSaveParkingSheet() {
    showTrackedBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return SaveParkingDialog(
          pickedLocation: _pickedLocation,
          gpsPosition: _gpsPosition,
          parkingCtrl: _parkingCtrl,
          onPickOnMap: () {
            Navigator.of(context).pop();
            _startPickingLocation(purpose: _PickingPurpose.save);
          },
          onSaveSuccess: (location) {
            setState(() {
              _pickedLocation = null;
            });
            final mySaved = _parkingCtrl.mySavedParking.value;
            if (mySaved != null &&
                mySaved.latitude != null &&
                mySaved.longitude != null &&
                _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(mySaved.latitude!, mySaved.longitude!),
                  20,
                ),
              );
            }
          },
          showCustomSnackBar: showCustomSnackBar,
        );
      },
    );
  }


  void _startPickingLocation({required _PickingPurpose purpose}) {
    if (!mounted) return;

    _pickingPurpose = purpose;
    isPickingOnMap.value = true;

    setState(() {
      _isPickingLocation = true;
      if (_pickedLocation == null && _gpsPosition != null) {
        _pickedLocation = _gpsPosition;
      }
    });
  }

  void _stopPickingLocation() {
    if (!mounted) return;
    isPickingOnMap.value = false;
    if (_isPickingLocation) {
      setState(() {
        _isPickingLocation = false;
        _pickedLocation = null;
      });
    }
    _pickingPurpose = null;
  }

  void _confirmPickedLocation() {
    if (!mounted) return;
    isPickingOnMap.value = false;
    final purpose = _pickingPurpose;
    setState(() {
      _isPickingLocation = false;
    });
    _pickingPurpose = null;

    if (purpose == _PickingPurpose.save) {
      _showSaveParkingSheet();
    } else {
      _showParkingDialog();
    }
  }

  void _onMapTapped(LatLng position) {
    if (!_isPickingLocation) {
      _parkingCtrl.clearSelectedReport();
      return;
    }

    if (!mounted) return;

    setState(() {
      _pickedLocation = position;
    });

    HapticFeedback.selectionClick();

    mapDebug(
      'picked location '
          'lat=${position.latitude.toStringAsFixed(6)} '
          'lng=${position.longitude.toStringAsFixed(6)}',
    );
  }


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _parkingCtrl.mapController.value = controller;
    mapDebug('GoogleMap created');

    if (_gpsPosition != null) {
      final zoomToUse = _initialZoomLevel ?? 16.5;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_gpsPosition!, zoomToUse),
      );
      mapDebug('onMapCreated: camera synced to GPS');
    }
  }

  void _showRadiusFilterSheet() {
    HapticFeedback.lightImpact();

    RadiusFilterSheet.show(
      context,
      initialRadiusMeter: _selectedRadiusMeter,
      onApply: (radiusMeter) {
        if (!mounted) return;

        setState(() {
          _selectedRadiusMeter = radiusMeter;
        });

        _applyRadiusFilter();
      },
    );
  }

  Future<void> _applyRadiusFilter() async {
    final location = _gpsPosition ?? _mapCenter;

    await _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
      radius: _selectedRadiusMeter,
    );

    // Auto-fit camera to show all fetched parking areas
    await _fitCameraToParking();

    if (!mounted) return;
    showCustomSnackBar(
      '${AppStrings.showingParking.tr} $_selectedRadiusMeter m',
      isError: false,
    );
  }

  /// Animate the camera to fit user location + all fetched parking area
  /// centers in the viewport, so the user can see every result at once.
  Future<void> _fitCameraToParking() async {
    final ctrl = _mapController;
    if (ctrl == null || !mounted) return;

    final list = _parkingCtrl.parkingList;
    final user = _gpsPosition;

    if (list.isEmpty && user == null) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    // Include user's GPS position
    if (user != null) {
      minLat = min(minLat, user.latitude);
      maxLat = max(maxLat, user.latitude);
      minLng = min(minLng, user.longitude);
      maxLng = max(maxLng, user.longitude);
    }

    // Include every parking area center + its polygon vertices
    for (final area in list) {
      final cLat = _toDouble(area['centerLat'] ?? area['latitude']);
      final cLng = _toDouble(area['centerLng'] ?? area['longitude']);
      if (cLat != null && cLng != null) {
        minLat = min(minLat, cLat);
        maxLat = max(maxLat, cLat);
        minLng = min(minLng, cLng);
        maxLng = max(maxLng, cLng);
      }

      final rawPoly = area['polygon'];
      if (rawPoly is List) {
        for (final pt in rawPoly) {
          if (pt is Map) {
            final pLat = _toDouble(pt['latitude']);
            final pLng = _toDouble(pt['longitude']);
            if (pLat != null && pLng != null) {
              minLat = min(minLat, pLat);
              maxLat = max(maxLat, pLat);
              minLng = min(minLng, pLng);
              maxLng = max(maxLng, pLng);
            }
          }
        }
      }
    }

    if (minLat == double.infinity) return;

    // Add a small buffer so markers aren't clipped to the edge
    const buffer = 0.0008;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - buffer, minLng - buffer),
      northeast: LatLng(maxLat + buffer, maxLng + buffer),
    );

    try {
      await ctrl.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 70),
      );
      _initialZoomLevel = await ctrl.getZoomLevel();
      mapDebug('camera: fit to ${list.length} parking areas (zoom=$_initialZoomLevel)');
    } catch (e) {
      mapDebug('camera: fit error $e');
    }
  }

  /// Parse any numeric type to double
  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _parkingCtrl.clearSelectedReport();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            /// -- Map ------------------------------------------------------
            if (!_isLocating && _gpsPosition == null)
              LocationOffPrompt(
                onEnableLocation: () async {
                  await Geolocator.openLocationSettings();
                },
              )
            else if (_isLocating && _gpsPosition == null)
              const MapInitialShimmer()
            else
              Obx(() {
                final mySaved = _parkingCtrl.mySavedParking.value;
                // .toSet() forces GetX to track dependency on the RxSet
                final parkingMarkers = _parkingCtrl.markers.toSet();
                // final parkingPolylines = _parkingCtrl.areaPolylines.toSet();
                final parkingPolygons = _parkingCtrl.areaPolygons.toSet();

                final markers = {
                  ..._markers,
                  ...parkingMarkers,
                  if (_pickedLocation != null)
                    Marker(
                      markerId: const MarkerId('picked_location'),
                      position: _pickedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                    ),
                  if (mySaved != null &&
                      mySaved.latitude != null &&
                      mySaved.longitude != null)
                    Marker(
                      markerId: const MarkerId('my_saved_parking'),
                      position: LatLng(mySaved.latitude!, mySaved.longitude!),
                      icon: _parkedCarIcon ??
                          BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(
                        title: AppStrings.mySavedParking.tr,
                        snippet: AppStrings.tapToViewDetailsRoute.tr,
                      ),
                      onTap: () {
                        _showSavedParkingDetailsSheet(mySaved);
                      },
                    ),
                };

                return GoogleMap(
                  mapType: _parkingCtrl.selectedMapType.value,
                  key: const ValueKey<Object>('wheew_google_map'),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: MapScreen.kInitialMapTarget,
                    zoom: 16.5,
                  ),
                  markers: markers,
                  // polylines: parkingPolylines,
                  polygons: parkingPolygons,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  onTap: _onMapTapped,
                );
              }),

            /// -- GPS locating banner ---------------------------------------
            if (_isLocating) const LocatingBanner(),

            /// -- Pick location mode confirmation card ---------------------
            if (_isPickingLocation)
              PickOnMapConfirmationCard(
                pickedLocation: _pickedLocation,
                onConfirm: _confirmPickedLocation,
                onCancel: _stopPickingLocation,
                onUseCurrentLocation: () {
                  if (_gpsPosition != null) {
                    setState(() => _pickedLocation = _gpsPosition);
                    HapticFeedback.selectionClick();
                  }
                },
              ),

            /// -- Parking fetching indicator --------------------------------
            Obx(
                  () => _parkingCtrl.isLoadingShowDetails.value
                  ? const FetchingParkingBanner()
                  : const SizedBox.shrink(),
            ),

            /// -- Selected reported parking info card ---------------------
            Obx(() {
              final selected = _parkingCtrl.selectedReport.value;
              if (selected == null) return const SizedBox.shrink();
              final double cardBottomOffset = ResponsiveHelper.bottomNavOffset(context);
              return Positioned(
                left:  ResponsiveHelper.padding(8),
                right:  ResponsiveHelper.padding(8),
                bottom: cardBottomOffset,
                child: BottomOverlayHeightReporter(
                  extraBottomOffset: cardBottomOffset,
                  child: ParkingReportDropdown(
                    report: selected,
                    onClose: _parkingCtrl.clearSelectedReport,
                  ),
                ),
              );
            }),

            /// -- Top-bar: search pill + notification bell -----------------
            if (_gpsPosition != null)
              MapTopBar(
                searchController: _searchController,
                onSearchTap: _showRadiusFilterSheet,
              ),

            /// -- Side controls: map type + current location ----------------
            if (_gpsPosition != null)
              Obx(() => MapSideControls(
                selectedMapType: _parkingCtrl.selectedMapType.value,
                onMapTypeChanged: _parkingCtrl.changeMapType,
                onLocationTap: _getUserLocation,
              )),


         ///add parking===============================================
            BottomSheetAwarePositioned(
              defaultBottom: ResponsiveHelper.bottomNavOffset(context),
              gap: ResponsiveHelper.spacing(16),
              left: 0,
              right: 0,
              builder: (context, isSheetOpen) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionPillButton(
                    label: AppStrings.addParking.tr,
                    icon: "assets/icons/add_circle.svg",

                    onPressed: _toggleParkingPin,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ActionPillButton extends StatelessWidget {
  final String label;
  final String icon;

  final VoidCallback onPressed;

  const _ActionPillButton({
    required this.label,
    required this.icon,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.blackGradient,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(28),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyBorder,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: ResponsiveHelper.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
       CustomImage(imageSrc: icon),
              SizedBox(
                width: ResponsiveHelper.spacing(6),
              ),

              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.fontSize(13),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



