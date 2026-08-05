
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/router/route_path.dart';
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
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parked_session_card.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_confirmation_overlay.dart';
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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  MapType _selectedMapType = MapType.normal;

  late final ParkingShowController _parkingShowCtrl;

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
      duration: const Duration(milliseconds: 800),
    )..repeat();

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
    _pulseController.dispose();
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
              final showLocationPulse = _parkingShowCtrl.showLocationPulse.value;
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
              // Find Parking Spot / Stop Searching button — only for the
              // plain-idle and active-search states; PARKED shows the
              // "You're Parked" card in that spot instead. Stays visible
              // while transitioning (shows a spinner instead of vanishing —
              // see isTransitioningSearch below).
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
                      left: ResponsiveHelper.padding(42),
                      right: ResponsiveHelper.padding(42),
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

                  // Same solid pulsing frame as before (width breathes the
                  // same way), just: (1) gradient-colored instead of solid
                  // blue, (2) the stroke width waves irregularly around the
                  // perimeter instead of being uniform, per the reference.
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
                              painter: _WavyGradientBorderPainter(
                                t: t,
                                wavePhase: wavePhase,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  if (isParked)
                    Positioned(
                      bottom: ResponsiveHelper.padding(120),
                      left: ResponsiveHelper.padding(20),
                      right: ResponsiveHelper.padding(20),
                      child: ParkedSessionCard(
                        // No "current session" API/data source exists yet —
                        // placeholder details, ready to bind once it does.
                        locationName: 'Green Park Mall',
                        spotCode: 'B2 • A-27',
                        onExitPressed: _showExitParkingConfirmation,
                      ),
                    )
                  else if (showSearchUi)
                    Positioned(
                      bottom: ResponsiveHelper.padding(120),
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
                ],
              );
            }),


            ///map type and current location combined container (Gradient & Glassmorphism Effect)=============================================================

            Obx(() {
              final navStatus = _parkingShowCtrl.status.value;
              // Stays visible while PARKED too, same as the map (home tab).
              if (navStatus.isEmpty) {
                return const SizedBox.shrink();
              }
              return Positioned(
                right: ResponsiveHelper.padding(30),
                top: ResponsiveHelper.padding(110), // আগের মতোই পজিশন রাখা হয়েছে
                child: Container(
                  padding: ResponsiveHelper.symmetric(horizontal: 4,vertical: 4),
                  decoration: BoxDecoration(

                    // ফিগমা ডিজাইন অনুযায়ী হোয়াইট কালারের সাথে 32% অপাসিটি
                    color: Colors.white.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(68)),
                    // ১ পিক্সেল লিনিয়ার স্ট্রোক (বর্ডার)
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(68)),
                    child: BackdropFilter(
                      // ব্যাকগ্রাউন্ড ব্লার ইফেক্ট
                      filter: ColorFilter.mode(Colors.transparent, BlendMode.src), // অথবা ui.ImageFilter.blur ব্যবহার করতে পারেন নিচে দেখানো নিয়মে
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ১. ম্যাপ টাইপ ড্রপডাউন বা লেয়ার উইজেট
                          MapTypeLayersButton(
                            selectedType: _selectedMapType,
                            onChanged: (type) {
                              setState(() => _selectedMapType = type);
                            },
                          ),

                          // মাঝখানের ডিভাইডার লাইন (যদি প্রয়োজন হয়)
                      SizedBox(height: ResponsiveHelper.height(4),),
                          // ২. কারেন্ট লোকেশন বাটন
                          GestureDetector(
                            onTap: () => _parkingShowCtrl.getUserLocation(),
                            child: Container(
                         padding: ResponsiveHelper.all(8),
                              decoration:  BoxDecoration(


                                shape: BoxShape.circle,
                                color: AppColors.white.withValues(alpha: 0.5),
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                color: Color(0xFF185FA5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
              height: ResponsiveHelper.height(44),
              width: ResponsiveHelper.width(44),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF185FA5),
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

// ── SEARCHING-mode glow frame: gradient-colored (blue → white → purple),
//    stroke width waves irregularly around the perimeter and the wave
//    travels over time — same base pulsing width/timing as the old solid
//    Border.all() version, just not a uniform line anymore. ──
class _WavyGradientBorderPainter extends CustomPainter {
  final double t; // 0..1 "breathing" phase — same as the old glowWidth calc
  final double wavePhase; // rotates the wave around the perimeter over time

  const _WavyGradientBorderPainter({
    required this.t,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metrics = (Path()..addRect(rect)).computeMetrics().first;
    final length = metrics.length;

    final gradient = const SweepGradient(
      colors: [
        Color(0xFF1E88E5), // blue
        Colors.white,
        Color(0xFF1E88E5), // back to blue
        Colors.white,
        Color(0xFF1E88E5), // back to blue
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    );
    final shader = gradient.createShader(rect);

    // Modulated by a traveling sine wave so it's thicker/thinner at
    // different points around the frame instead of uniform.
    final baseWidth = 14.0 + (t * 10.0);
    const waveAmplitude = 5.0;
    const waveCount = 3; // how many "bulges" travel around the perimeter

    const segments = 160;
    for (int i = 0; i < segments; i++) {
      final d0 = length * i / segments;
      final d1 = length * (i + 1) / segments;
      final segmentPath = metrics.extractPath(d0, d1);

      final wave = sin((d0 / length) * 2 * pi * waveCount + wavePhase);
      final strokeWidth = (baseWidth + wave * waveAmplitude).clamp(6.0, 30.0);

      // Soft outer halo (blurred, wider) + a tighter, less-blurred core on
      // top — this combo is what actually reads as "glow" instead of a
      // crisp painted line, kept narrow so it hugs the edge.
      final haloPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.4
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.5);
      canvas.drawPath(segmentPath, haloPaint);

      final corePaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.15);
      canvas.drawPath(segmentPath, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyGradientBorderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.wavePhase != wavePhase;
}