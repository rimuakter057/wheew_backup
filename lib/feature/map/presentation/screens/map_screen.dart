import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platchatapp/feature/auth/repository/user_location_controller.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/map/model/saved_parking_model.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_report_dropdown.dart';
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/map/presentation/widgets/radius_filter_button.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
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
  int _selectedRadiusMeter = 100;

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
    mapDebug('screen init → resolve GPS and fetch parking');
    _loadCustomMarkerIcon();   // 👈 নতুন
    _initializeMap();

    // Home screen is where location/Maps permission is requested — also
    // bootstraps the background location tracking used for parking handoff
    // matching. Denial here only disables location-based features; it
    // can't crash the app (see UserLocationController.initLocationTracking).
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
  }

  Future<void> _getUserLocation() async {
    mapDebug('location: start');

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      if (!serviceEnabled) {
        setState(() => _isLocating = false);

        showCustomSnackBar(
          'Please enable location service',
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
          'Location permission denied',
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
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            latLng,
            20,
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

  // ══════════════════════════════════════════════════════════════════════
  // FLOW 1 — "Report a parking spot" (ParkingInfoDialog: free/paid/electric/
  //          disabled facility) → GET fetchParkingReport / POST addParking
  // ══════════════════════════════════════════════════════════════════════

  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    _pickedLocation = null;
    _stopPickingLocation();
    mapDebug('parking report dialog open');
    _showParkingDialog();
  }

  void _showParkingDialog() {
    _parkingCtrl.reset();

    // Explicit actions (pick-on-map / submit) set this so the sheet-dismiss
    // cleanup below doesn't double-run the same reset when they pop it.
    bool handled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
            showCustomSnackBar('Location not available', isError: true);
            return;
          }

          final LatLng useLocation = _pickedLocation ?? _gpsPosition!;

          final success = await _parkingCtrl.addParking(
            latitude: useLocation.latitude,
            longitude: useLocation.longitude,
          );
          if (!mounted) return;
          if (success) {
            showCustomSnackBar(
              _parkingCtrl.submitMessage.value.isNotEmpty
                  ? _parkingCtrl.submitMessage.value
                  : AppStrings.mapParkingReportSubmitted.tr,
              isError: false,
            );
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

  // ══════════════════════════════════════════════════════════════════════
  // FLOW 2 — "Save my parking" (bottom sheet: FREE/PAID + duration) →
  //          GET fetchMySavedParking / POST saveMyParking
  // ══════════════════════════════════════════════════════════════════════

  void _showSavedParkingDetailsSheet(SavedParkingModel parking) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
      ),
      backgroundColor: Colors.white,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  // ══════════════════════════════════════════════════════════════════════
  // Shared "pick a location on the map" mechanics (used by both flows)
  // ══════════════════════════════════════════════════════════════════════

  void _startPickingLocation({required _PickingPurpose purpose}) {
    if (!mounted) return;

    _pickingPurpose = purpose;

    setState(() {
      _isPickingLocation = true;
    });

    showCustomSnackBar(
      'Tap on the map to select a location',
      isError: false,
    );
  }

  void _stopPickingLocation() {
    if (!mounted) return;
    if (_isPickingLocation) {
      setState(() {
        _isPickingLocation = false;
      });
    }
    _pickingPurpose = null;
  }

  void _onMapTapped(LatLng position) {
    if (!_isPickingLocation) {
      _parkingCtrl.clearSelectedReport();
      return;
    }

    if (!mounted) return;

    final purpose = _pickingPurpose;

    setState(() {
      _pickedLocation = position;
      _isPickingLocation = false;
    });
    _pickingPurpose = null;

    HapticFeedback.selectionClick();

    mapDebug(
      'picked location '
          'lat=${position.latitude.toStringAsFixed(6)} '
          'lng=${position.longitude.toStringAsFixed(6)}',
    );

    // Reopen whichever flow started the picking mode.
    if (purpose == _PickingPurpose.save) {
      _showSaveParkingSheet();
    } else {
      _showParkingDialog();
    }
  }


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _parkingCtrl.mapController.value = controller;
    mapDebug('GoogleMap created');

    if (_gpsPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_gpsPosition!, 20),
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

    if (!mounted) return;
    showCustomSnackBar(
      '${AppStrings.showingParking.tr} $_selectedRadiusMeter m',
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _parkingCtrl.clearSelectedReport();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            /// ── Map ──────────────────────────────────────────────────────
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
                final markers = {
                  ..._markers,
                  ..._parkingCtrl.markers,
                  if (_pickedLocation != null)
                    Marker(
                      markerId: const MarkerId('picked_location'),
                      position: _pickedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
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
                      infoWindow: const InfoWindow(
                        title: 'My Saved Parking',
                        snippet: 'Tap to view details & route',
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
                    zoom: 20,
                  ),
                  markers: markers,
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

            /// ── GPS locating banner ───────────────────────────────────────
            if (_isLocating) const LocatingBanner(),

            /// ── Pick location mode banner ─────────────────────────────────
            if (_isPickingLocation) const PickingLocationBanner(),

            /// ── Parking fetching indicator ────────────────────────────────
            Obx(
                  () => _parkingCtrl.isLoadingShowDetails.value
                  ? const FetchingParkingBanner()
                  : const SizedBox.shrink(),
            ),

            /// ── Selected reported parking info card ─────────────────────
            Obx(() {
              final selected = _parkingCtrl.selectedReport.value;
              if (selected == null) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.top +
                    ResponsiveHelper.padding(52),
                child: ParkingReportDropdown(
                  report: selected,
                  onClose: _parkingCtrl.clearSelectedReport,
                ),
              );
            }),

            /// ── Map Type Dropdown ───────────────────────────────────────
            Obx(
                  () => MapTypeDropdown(
                selectedType: _parkingCtrl.selectedMapType.value,
                onChanged: _parkingCtrl.changeMapType,
              ),
            ),

            /// ── Radius filter button ──────────────────────────────────────
            RadiusFilterButton(onPressed: _showRadiusFilterSheet),

            /// ── Action buttons cluster (Report Spot / Save My Parking) ─────
            Positioned(
              right: 0,
              left: 0,
              bottom: ResponsiveHelper.padding(340),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionPillButton(
                    label: AppStrings.addParkingSpot.tr,
                    icon: Icons.add_location_alt_rounded,
                    gradientColors: const [
                      Color(0xFFFF8A3D),
                      Color(0xFFF5590B),
                    ],
                    onPressed: _toggleParkingPin,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(14)),
                  _ActionPillButton(
                    label: AppStrings.parkMyCar.tr,
                    icon: Icons.add_circle_outline,
                    gradientColors:  [
                    AppColors.blackGrey,
                    AppColors.black,
                    ],
                    onPressed: _showSaveParkingSheet,
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
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _ActionPillButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(28),
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.35),
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
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.padding(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: ResponsiveHelper.iconSize(16),
                ),
              ),

              SizedBox(
                width: ResponsiveHelper.spacing(10),
              ),

              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
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