
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/config/app_config.dart';
import 'package:platchatapp/core/router/routes.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/map/presentation/widgets/location_search_overlay.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
import 'package:platchatapp/feature/parking/controller/add_parking_flow_controller.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
import 'package:platchatapp/feature/parking/presentation/screens/save_parking_screen.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_location_off_prompt.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_location_card.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_map_bottom_actions.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_map_left_action_buttons.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_map_loading_banner.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/wavy_gradient_border_painter.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/pick_on_map_confirmation_card.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/map_side_controls.dart';
import 'package:platchatapp/share/widgets/map_top_bar.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../../utils/color/app_colors.dart';

class ParkingMapScreen extends StatefulWidget {

  const ParkingMapScreen({super.key});

  static const LatLng kInitialMapTarget =
      ParkingShowController.kApproxDefaultLocation;

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // -- Google Map instance for this screen --
  GoogleMapController? _mapController;
  MapType _selectedMapType = MapType.normal;

  // -- Logic lives in these controllers, not here --
  // Map/status/markers/search/exit-parking logic.
  late final ParkingShowController parkingShowCtrl;
  // "Add Parking" flow (report-a-spot / park-my-car / pick-on-map).
  late final AddParkingFlowController addParkingFlowCtrl;

  // -- Location pulse animation + (read-only) search field controller --
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _cameraIdleTimer;
  LatLng? _searchedLocation;

  Future<void> _openLocationSearch() async {
    final result = await LocationSearchOverlay.show(
      context,
      apiKey: AppConfig.mapsApiKey,
      userLocation: parkingShowCtrl.gpsPosition.value,
    );
    if (result == null || !mounted) return;

    final target = LatLng(result.latitude, result.longitude);

    setState(() {
      _searchedLocation = target;
      _searchController.text = result.name;
    });

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 16.5),
    );

    await parkingShowCtrl.fetchNearbyParkingAreasOnly(
      result.latitude,
      result.longitude,
      animate: false,
    );
    if (parkingShowCtrl.status.value == 'SEARCHING') {
      await parkingShowCtrl.fetchNearbyHandoffsOnly(
        result.latitude,
        result.longitude,
        animate: false,
      );
    }
  }

  void _onCameraIdle() {
    _cameraIdleTimer?.cancel();
    _cameraIdleTimer = Timer(const Duration(milliseconds: 600), () async {
      final ctrl = _mapController;
      if (ctrl == null || !mounted) return;
      try {
        final bounds = await ctrl.getVisibleRegion();
        final double centerLat =
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
        final double centerLng =
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

        await parkingShowCtrl.fetchNearbyParkingAreasOnly(
          centerLat,
          centerLng,
          animate: false,
        );
        if (parkingShowCtrl.status.value == 'SEARCHING') {
          await parkingShowCtrl.fetchNearbyHandoffsOnly(
            centerLat,
            centerLng,
            animate: false,
          );
        }
      } catch (_) {}
    });
  }

  // -- Register controllers, start the pulse animation, run the initial
  // parking-mode flow (approx map -> /parking-mode/me -> branch) --
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    parkingShowCtrl = Get.isRegistered<ParkingShowController>()
        ? Get.find<ParkingShowController>()
        : Get.put(ParkingShowController());

    addParkingFlowCtrl = Get.isRegistered<AddParkingFlowController>()
        ? Get.find<AddParkingFlowController>()
        : Get.put(AddParkingFlowController());

    parkingShowCtrl.clearSpotDetailsCard();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    mapDebug('_initializeMap: running initializeFlow');
    parkingShowCtrl.initializeFlow();
  }

  // -- Release the map controller reference + dispose animation/text
  // controllers owned by this screen --
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraIdleTimer?.cancel();
    if (parkingShowCtrl.mapController == _mapController) {
      parkingShowCtrl.mapController = null;
    }
    parkingShowCtrl.clearSpotDetailsCard();
    _mapController?.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // -- Re-check parking status whenever the app comes back to foreground --
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      parkingShowCtrl.refreshStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            // -- Main reactive block: reads ParkingShowController's
            // location/status state and decides which view to show --
            Obx(() {

              final isLocating = parkingShowCtrl.isLocating.value;
              final gpsPosition = parkingShowCtrl.gpsPosition.value;
              final showLocationPulse = parkingShowCtrl.showLocationPulse.value;
              final isLoading = parkingShowCtrl.isLoading.value;
              final status = parkingShowCtrl.status.value;
              final isSearching = status == 'SEARCHING';

              final isTransitioningSearch =
                  parkingShowCtrl.isTransitioningSearch.value;

              if (!isLocating && gpsPosition == null) {
                return const ParkingLocationOffPrompt();
              } else if (isLocating && gpsPosition == null) {
                return const MapInitialShimmer();
              }


              return Stack(
                children: [
                  // -- Google Map: markers/polygons/circles/polylines from
                  // ParkingShowController, tap-to-pick-location handled by
                  // AddParkingFlowController --
                  Obx(() {
                    final currentMarkers = parkingShowCtrl.markers.toSet();

                    // ── Searched Location: Standard RED pin marker ────
                    if (_searchedLocation != null) {
                      currentMarkers.add(
                        Marker(
                          markerId: const MarkerId('searched_location_red_pin'),
                          position: _searchedLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                          infoWindow: InfoWindow(
                            title: _searchController.text.isNotEmpty
                                ? _searchController.text
                                : 'Searched Location',
                          ),
                        ),
                      );
                    }

                    final pickedLoc = addParkingFlowCtrl.pickedAddParkingLocation.value;
                    if (pickedLoc != null) {
                      currentMarkers.add(
                        Marker(
                          markerId: const MarkerId('picked_add_parking_location'),
                          position: pickedLoc,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                        ),
                      );
                    }
                    final currentPolygons = parkingShowCtrl.polygons.toSet();
                    final currentCircles = parkingShowCtrl.circles.toSet();
                    final currentPolylines = parkingShowCtrl.polylines.toSet();

                    return GoogleMap(
                      mapType: _selectedMapType,
                      key: const ValueKey<Object>('wheew_google_map'),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        parkingShowCtrl.onMapCreated(controller);
                      },
                      onTap: addParkingFlowCtrl.onMapTappedForAddParking,
                      onCameraIdle: _onCameraIdle,
                      initialCameraPosition: CameraPosition(
                        target: gpsPosition ?? ParkingMapScreen.kInitialMapTarget,
                        zoom: 18,
                      ),
                      markers: currentMarkers,
                      polygons: currentPolygons,
                      circles: currentCircles,
                      polylines: currentPolylines,
                      myLocationEnabled: parkingShowCtrl.isRealLocationLoaded.value,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    );
                  }),


                  // -- Loading banner hidden as per requirement --
                  const SizedBox.shrink(),

                  // -- Top search bar + notification bell (Always static & permanently visible) --
                  MapTopBar(
                    searchController: _searchController,
                    onSearchTap: _openLocationSearch,
                    onFilterTap: parkingShowCtrl.openRadiusFilterSheet,
                  ),


                  // -- Pulsing gradient glow around the map edge, shown
                  // while status is SEARCHING --
                  if (showLocationPulse && gpsPosition != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final t = _pulseController.value < 0.5
                                ? _pulseController.value * 2
                                : (1.0 - _pulseController.value) * 2;
                            final wavePhase = _pulseController.value * 2 * pi;

                            return CustomPaint(
                              size: Size.infinite,
                              painter: WavyGradientBorderPainter(
                                t: t,
                                wavePhase: wavePhase,
                              ),
                            );
                          },
                        ),
                      ),
                    ),


                  // -- Bottom row: Find Parking (or Stop Searching) + Exit
                  // Parking, always shown together (hidden when picking location) --
                  Obx(() {
                    if (addParkingFlowCtrl.isPickingAddParkingLocation.value) {
                      return const SizedBox.shrink();
                    }
                    return ParkingMapBottomActions(
                      isSearching: isSearching,
                      isTransitioningSearch: isTransitioningSearch,
                      onFindParkingTap: isSearching
                          ? parkingShowCtrl.stopSearching
                          : parkingShowCtrl.onLeavingPopupNo,
                      onExitParkingTap:
                          parkingShowCtrl.showExitParkingConfirmation,
                    );
                  }),

                  // -- Pick-on-map confirmation card overlay --
                  Obx(() {
                    if (!addParkingFlowCtrl.isPickingAddParkingLocation.value) {
                      return const SizedBox.shrink();
                    }
                    return PickOnMapConfirmationCard(
                      pickedLocation:
                          addParkingFlowCtrl.pickedAddParkingLocation.value,
                      onConfirm: addParkingFlowCtrl.confirmPickedLocation,
                      onCancel: addParkingFlowCtrl.cancelPicking,
                      onUseCurrentLocation:
                          addParkingFlowCtrl.useCurrentLocation,
                    );
                  }),

                  /// -- Active spot details card overlay (floating above bottom nav) --
                  Obx(() {
                    if (addParkingFlowCtrl.isPickingAddParkingLocation.value) {
                      return const SizedBox.shrink();
                    }
                    final cardData = parkingShowCtrl.activeSpotDetailsCard.value;
                    if (cardData == null) return const SizedBox.shrink();

                    return Positioned(
                      bottom: ResponsiveHelper.bottomNavOffset(context),
                      left: ResponsiveHelper.padding(16),
                      right: ResponsiveHelper.padding(16),
                      child: ParkingLocationCard(
                        title: (cardData.title == null || cardData.title!.trim().isEmpty)
                            ? AppStrings.unknown.tr
                            : cardData.title!,
                        subtitle: cardData.subtitle,
                        badgeLabel: cardData.badgeLabel,
                        badgeIcon: cardData.badgeIcon,
                        badgeIconAsset: cardData.badgeIconAsset,
                        badgeColor: cardData.badgeColor,
                        distanceLabel: cardData.distanceLabel,
                        ratingLabel: cardData.ratingLabel,
                        leftStatLabel: cardData.leftStatLabel,
                        rightStatLabel: cardData.rightStatLabel,
                        rightStatIcon: cardData.rightStatIcon,
                        onSavePark: cardData.onSavePark == null
                            ? null
                            : () {
                                final onSave = cardData.onSavePark!;
                                parkingShowCtrl.clearSpotDetailsCard();
                                onSave();
                              },
                        onNavigate: cardData.destination == null
                            ? null
                            : () {
                                final dest = cardData.destination!;
                                final knownDistanceMeters = cardData.distanceMeters;
                                parkingShowCtrl.clearSpotDetailsCard();
                                AppRouter.router.pushNamed(
                                  RouteName.inAppNavigation,
                                  extra: {
                                    'destination': dest,
                                    if (knownDistanceMeters != null)
                                      'knownDistanceMeters': knownDistanceMeters,
                                    'parkingAreaTypes': cardData.parkingAreaTypes,
                                    'isHandoff': cardData.isHandoff,
                                  },
                                );
                              },
                      ),
                    );
                  }),
                ],
              );
            }),


            ///map type and current location combined container =============================================================
            Obx(() {
              final navStatus = parkingShowCtrl.status.value;
              if (navStatus.isEmpty) {
                return const SizedBox.shrink();
              }
              return MapSideControls(
                selectedMapType: _selectedMapType,
                onMapTypeChanged: (type) {
                  setState(() => _selectedMapType = type);
                },
                onLocationTap: () => parkingShowCtrl.getUserLocation(),
              );
            }),

            /// -- Left-side action buttons: Add Location / Save Parking ----
            Obx(() {
              if (addParkingFlowCtrl.isPickingAddParkingLocation.value) {
                return const SizedBox.shrink();
              }
              return ParkingMapLeftActionButtons(
                onAddParkingTap: addParkingFlowCtrl.showAddParkingOptions,
                onSaveParkingTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SaveParkingScreen()),
                ),
              );
            }),


          ],
        ),
      ),
    );
  }
}
