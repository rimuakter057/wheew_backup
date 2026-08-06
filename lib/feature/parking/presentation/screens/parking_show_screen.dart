
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_location_off_prompt.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_location_card.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parked_session_card.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_confirmation_overlay.dart';
import 'package:platchatapp/share/widgets/map_side_controls.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../helper/custom_gradient_button/custom_gradient_button.dart';
import '../../../../utils/color/app_colors.dart';

class ParkingShowScreen extends StatefulWidget {

  const ParkingShowScreen({super.key});

  static const LatLng kInitialMapTarget =
      ParkingShowController.kApproxDefaultLocation;

  @override
  State<ParkingShowScreen> createState() => _ParkingShowScreenState();
}

class _ParkingShowScreenState extends State<ParkingShowScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  MapType _selectedMapType = MapType.normal;

  late final ParkingShowController _parkingShowCtrl;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("PARKING_SHOW_SCREEN_INIT_STATE (screen mounted/re-mounted)");
    WidgetsBinding.instance.addObserver(this);

    _parkingShowCtrl = Get.isRegistered<ParkingShowController>()
        ? Get.find<ParkingShowController>()
        : Get.put(ParkingShowController());

    // Runs the full flow (approx map -> /parking-mode/me -> branch)
    // every time this screen is entered.
    _initializeMap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clear the controller's reference so its existing `mapController != null`
    // guards correctly skip animateCamera calls once this GoogleMap widget is
    // gone — otherwise in-flight async work (e.g. fetchNearbyData) still
    // holds a stale, non-null controller and crashes trying to use it.
    if (_parkingShowCtrl.mapController == _mapController) {
      _parkingShowCtrl.mapController = null;
    }
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On resume, just re-check status/branching without resetting the
    // map back to the approximate default location.
    if (state == AppLifecycleState.resumed) {
      _parkingShowCtrl.refreshStatus();
    }
  }

  Future<void> _initializeMap() async {
    mapDebug('_initializeMap: running initializeFlow');
    await _parkingShowCtrl.initializeFlow();
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
              final isLoading = _parkingShowCtrl.isLoading.value;
              final status = _parkingShowCtrl.status.value;
              // Empty until /parking-mode/me resolves & not loading — treat that as
              // "still loading" so nothing here defaults to the IDLE view or shows buttons while loading.
              final statusResolved = status.isNotEmpty && !isLoading;
              final isParked = status == 'PARKED';
              final isSearching = status == 'SEARCHING';
              // Search bar / notification bell / layers+location header —
              // stays visible in every resolved state (including PARKED),
              // same as the map (home tab). Never shown during the initial
              // loading window.
              final showHeader = statusResolved;

              final showSearchUi = statusResolved && !isParked;
              final isTransitioningSearch =
                  _parkingShowCtrl.isTransitioningSearch.value;

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
                      onTap: (_) => _parkingShowCtrl.clearSpotDetailsCard(),
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


                  ///search=======================================================
                  if (showHeader)
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          ResponsiveHelper.padding(16),
                      left: ResponsiveHelper.padding(16),
                      right: ResponsiveHelper.padding(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                // ── enter search mode: show the floating button ──
                                showFindParkingButton.value = true;

                                RadiusFilterSheet.show(
                                  context,
                                  initialRadiusMeter: _parkingShowCtrl.selectedRadiusMeter.value,
                                  onApply: (radius) {
                                    _parkingShowCtrl.selectedRadiusMeter.value = radius;
                                    final lat = _parkingShowCtrl.gpsPosition.value?.latitude;
                                    final lng = _parkingShowCtrl.gpsPosition.value?.longitude;
                                    if (lat != null && lng != null) {
                                      // Radius filter only affects the handoffs
                                      // radius — parking areas use a fixed radius.
                                      _parkingShowCtrl.fetchNearbyHandoffsOnly(lat, lng);
                                    }
                                    // ── sheet applied: hide the floating button ──
                                    showFindParkingButton.value = false;

                                  },
                                ).then((_) {
                                  // ── sheet dismissed (swipe/tap outside): hide button ──
                                  showFindParkingButton.value = false;
                                });
                              },
                              child: Builder(
                                builder: (context) {
                                  final double barHeight = ResponsiveHelper.padding(50);
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(barHeight / 2), // <-- height/2 = perfect pill
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // frosted glass effect
                                      child: Container(
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          color: Colors.white, // <-- alpha পুরোপুরি বাদ, solid সাদা
                                          borderRadius: BorderRadius.circular(barHeight / 2),
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
                                            style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                                            decoration: InputDecoration(
                                              hintText: AppStrings.searchHere.tr,
                                              hintStyle: TextStyle(
                                                fontSize: ResponsiveHelper.fontSize(14),
                                                color: Colors.grey,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: AppColors.black,
                                                size: ResponsiveHelper.iconSize(20),
                                              ),
                                              suffixIcon: Icon(
                                                Icons.tune,
                                                color: AppColors.black,
                                                size: ResponsiveHelper.iconSize(20),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: ResponsiveHelper.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.spacing(8)),
                          _NotificationBellButton(),
                        ],
                      ),
                    ),

                  if (isParked)
                    Positioned(
                      bottom: ResponsiveHelper.bottomNavOffset(context),
                      left: ResponsiveHelper.padding(20),
                      right: ResponsiveHelper.padding(20),
                      child: Obx(() => ParkedSessionCard(
                        locationName: _parkingShowCtrl.parkedLocationName.value.isNotEmpty
                            ? _parkingShowCtrl.parkedLocationName.value
                            : 'Your Parking Spot',
                        spotCode: _parkingShowCtrl.parkedSpotCode.value,
                        onExitPressed: _showExitParkingConfirmation,
                      )),
                    )
                  else if (showSearchUi)
                    Positioned(
                      bottom: ResponsiveHelper.bottomNavOffset(context),
                      left: ResponsiveHelper.padding(80),
                      right: ResponsiveHelper.padding(80),
                      child: CustomGradientButton(
                        onPressed: isSearching
                            ? _parkingShowCtrl.stopSearching
                            : _parkingShowCtrl.onLeavingPopupNo,
                        isLoading: isTransitioningSearch,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isSearching) ...[
                              CustomImage(imageSrc: AssetsPath.pNav),
                              SizedBox(width: ResponsiveHelper.width(4)),
                            ],
                            Text(
                              isSearching ? "Stop Searching" : "Find Parking Spot",
                              style: context.bodyMedium.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// ── Active spot details card overlay (floating above bottom nav) ──
                  Obx(() {
                    final cardData = _parkingShowCtrl.activeSpotDetailsCard.value;
                    if (cardData == null) return const SizedBox.shrink();

                    return Positioned(
                      bottom: ResponsiveHelper.bottomNavOffset(context),
                      left: ResponsiveHelper.padding(16),
                      right: ResponsiveHelper.padding(16),
                      child: ParkingLocationCard(
                        title: (cardData.title == null || cardData.title!.trim().isEmpty)
                            ? "Unknown"
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
                                _parkingShowCtrl.clearSpotDetailsCard();
                                onSave();
                              },
                        onNavigate: cardData.destination == null
                            ? null
                            : () {
                                final dest = cardData.destination!;
                                _parkingShowCtrl.clearSpotDetailsCard();
                                AppRouter.router.pushNamed(
                                  RouteName.inAppNavigation,
                                  extra: {'destination': dest},
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
              final navStatus = _parkingShowCtrl.status.value;
              if (navStatus.isEmpty) {
                return const SizedBox.shrink();
              }
              return MapSideControls(
                selectedMapType: _selectedMapType,
                onMapTypeChanged: (type) {
                  setState(() => _selectedMapType = type);
                },
                onLocationTap: () => _parkingShowCtrl.getUserLocation(),
              );
            }),




          ],
        ),
      ),
    );
  }


  // Triggered only by the "Exit Parking" button on the parked-session card.
  // Yes reuses the existing "I'm leaving this spot" logic unchanged
  // (createHandoff + set idle, then the rating dialog). No just closes the
  // dialog and leaves the user on the parked-session view.
  void _showExitParkingConfirmation() {
    mapDebug('Showing Exit Parking Confirmation Dialog');

    ParkingConfirmationDialog.show(
      context,
      onYes: _parkingShowCtrl.onLeavingPopupYes,
      onNo: () {},
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RoutePath.notification),
      child: Obx(() {
        final notificationCtrl = Get.find<NotificationController>();
        final count = notificationCtrl.unreadCount.value;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              height: ResponsiveHelper.width(42),
              width: ResponsiveHelper.width(42),
              padding: ResponsiveHelper.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white),
                color: AppColors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CustomImage(

                  imageSrc: AssetsPath.notificationMap,
                  height: ResponsiveHelper.height(18),
                  width: ResponsiveHelper.width(18),
                  boxFit: BoxFit.contain,
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F80ED),
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

