
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_location_off_prompt.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_confirmation_overlay.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class ParkingShowScreen extends StatefulWidget {
  const ParkingShowScreen({super.key});

  static const LatLng kInitialMapTarget =
      ParkingShowController.kApproxDefaultLocation;

  @override
  State<ParkingShowScreen> createState() => _ParkingShowScreenState();
}

class _ParkingShowScreenState extends State<ParkingShowScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  MapType _selectedMapType = MapType.normal;

  late final ParkingShowController _parkingShowCtrl;
  final RxBool _showConfirmationPopup = false.obs;

  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _parkingShowCtrl = Get.isRegistered<ParkingShowController>()
        ? Get.find<ParkingShowController>()
        : Get.put(ParkingShowController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Runs the full flow (approx map -> /parking-mode/me -> branch)
    // every time this screen is entered.
    _initializeMap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On resume, just re-check status/branching without resetting the
    // map back to the approximate default location.
    if (state == AppLifecycleState.resumed) {
      _parkingShowCtrl.refreshStatus(
        onShowPopup: () {
          if (mounted) {
            _showParkingConfirmationPopup();
          }
        },
      );
    }
  }

  Future<void> _initializeMap() async {
    mapDebug('_initializeMap: running initializeFlow');
    await _parkingShowCtrl.initializeFlow(
      onShowPopup: () {
        if (mounted) {
          mapDebug('_initializeMap: show popup callback triggered');
          _showParkingConfirmationPopup();
        }
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _parkingShowCtrl.onMapCreated(controller);
    mapDebug('GoogleMap created');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Obx(() {
              final isLocating = _parkingShowCtrl.isLocating.value;
              final gpsPosition = _parkingShowCtrl.gpsPosition.value;
              final showLocationPulse = _parkingShowCtrl.showLocationPulse.value;
              final isLoading = _parkingShowCtrl.isLoading.value;

              if (!isLocating && gpsPosition == null) {
                return const ParkingLocationOffPrompt();
              } else if (isLocating && gpsPosition == null) {
                return const MapInitialShimmer();
              }


              return Stack(
                children: [
                  Obx(() {
                    final currentMarkers = _parkingShowCtrl.markers.toSet();
                    final currentPolygons = _parkingShowCtrl.polygons.toSet();
                    final currentCircles = _parkingShowCtrl.circles.toSet();
                    final currentPolylines = _parkingShowCtrl.polylines.toSet();

                    return GoogleMap(
                      mapType: _selectedMapType,
                      key: const ValueKey<Object>('wheew_google_map'),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: gpsPosition ?? ParkingShowScreen.kInitialMapTarget,
                        zoom: 18,
                      ),
                      markers: currentMarkers,
                      polygons: currentPolygons,
                      circles: currentCircles,
                      polylines: currentPolylines,
                      myLocationEnabled: _parkingShowCtrl.isRealLocationLoaded.value,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    );
                  }),

                  if (isLocating) const LocatingBanner(),

                  if (isLoading) const FetchingParkingBanner(),

                  if (showLocationPulse)
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          ResponsiveHelper.padding(16),
                      left: ResponsiveHelper.padding(42),
                      right: ResponsiveHelper.padding(42),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          RadiusFilterSheet.show(
                            context,
                            initialRadiusMeter: _parkingShowCtrl.selectedRadiusMeter.value,
                            onApply: (radius) {
                              _parkingShowCtrl.selectedRadiusMeter.value = radius;
                              final lat = _parkingShowCtrl.gpsPosition.value?.latitude;
                              final lng = _parkingShowCtrl.gpsPosition.value?.longitude;
                              if (lat != null && lng != null) {
                                _parkingShowCtrl.fetchNearbyData(lat, lng);
                              }
                            },
                          );
                        },
                        child: Container(
                          height: ResponsiveHelper.padding(45),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AbsorbPointer(
                            absorbing: true,
                            child: TextField(
                              readOnly: true,
                              controller: _searchController,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(14),
                              ),
                              decoration: InputDecoration(
                                hintText: AppStrings.searchHere.tr,
                                hintStyle: TextStyle(
                                  fontSize: ResponsiveHelper.fontSize(14),
                                  color: Colors.grey,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: const Color(0xFF185FA5),
                                  size: ResponsiveHelper.iconSize(20),
                                ),
                                suffixIcon: Icon(
                                  Icons.tune,
                                  color: const Color(0xFF185FA5),
                                  size: ResponsiveHelper.iconSize(20),
                                ),
                                border: InputBorder.none,
                                contentPadding: ResponsiveHelper.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (showLocationPulse && gpsPosition != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final t = _pulseController.value < 0.5
                                ? _pulseController.value * 2
                                : (1.0 - _pulseController.value) * 2;


                            final glowWidth = 8.0 + (t * 10.0);
                            final glowOpacity = 0.4 + (t * 0.6);

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF185FA5)
                                      .withValues(alpha: glowOpacity),
                                  width: glowWidth,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            }),

            Obx(() {
              if (!_parkingShowCtrl.showLocationPulse.value) {
                return const SizedBox.shrink();
              }
              return MapTypeDropdown(
                selectedType: _selectedMapType,
                onChanged: (type) {
                  setState(() => _selectedMapType = type);
                },
              );
            }),

            ParkingConfirmationOverlay(
              visible: _showConfirmationPopup,
              onYes: _onParkingYes,
              onNo: _onParkingNo,
            ),

          ],
        ),
      ),
    );
  }



  void _showParkingConfirmationPopup() {
    mapDebug('Showing Parking Confirmation Dialog Overlay');
    _showConfirmationPopup.value = true;
  }

  void _onParkingNo() {
    mapDebug('Parking Confirmation: User clicked NO');
    _parkingShowCtrl.onLeavingPopupNo();
  }

  void _onParkingYes() {
    mapDebug('Parking Confirmation: User clicked YES');
    _parkingShowCtrl.onLeavingPopupYes();
  }
}