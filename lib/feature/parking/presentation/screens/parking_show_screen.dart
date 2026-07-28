
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

                  ///search=======================================================
                  if (showLocationPulse)
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
                                      _parkingShowCtrl.fetchNearbyData(lat, lng);
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


                  if (showLocationPulse)
                  Positioned(
                    bottom:
                        ResponsiveHelper.padding(120),
                    left: ResponsiveHelper.padding(100),
                    right: ResponsiveHelper.padding(100),
                    child: CustomGradientButton(
                     // label: "Find Parking",
                      onPressed: (){},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        
                        children: [
                       CustomImage(imageSrc: AssetsPath.pNav),
                          SizedBox(width: ResponsiveHelper.width(4),),
                          Text("Find Parking Spot",style: context.bodyMedium.copyWith(color: AppColors.white),)
                        
                      ],),

                    )
                  ),
                ],
              );
            }),


            ///map type and current location combined container (Gradient & Glassmorphism Effect)=============================================================

            Obx(() {
              if (!_parkingShowCtrl.showLocationPulse.value) {
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
                          MapTypeDropdown(
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


  void _showParkingConfirmationPopup() {
    mapDebug('Showing Parking Confirmation Dialog');

    ParkingConfirmationDialog.show(
      context,
      onYes: _onParkingYes,
      onNo: _onParkingNo,
    );
  }



  // void _showParkingConfirmationPopup() {
  //   mapDebug('Showing Parking Confirmation Dialog Overlay');
  //   _showConfirmationPopup.value = true;
  // }

  void _onParkingNo() {
    mapDebug('Parking Confirmation: User clicked NO');
    _parkingShowCtrl.onLeavingPopupNo();
  }

  void _onParkingYes() {
    mapDebug('Parking Confirmation: User clicked YES');
    _parkingShowCtrl.onLeavingPopupYes();
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