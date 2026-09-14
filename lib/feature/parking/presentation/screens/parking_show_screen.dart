//
// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:platchatapp/core/router/route_path.dart';
// import 'package:platchatapp/core/router/routes.dart';
// import 'package:platchatapp/core/router/routes_name.dart';
// import 'package:platchatapp/feature/main/data/main_nav_.dart';
// import 'package:platchatapp/feature/map/controller/map_controller.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/parking_added_success_dialog.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/save_parking_dialog.dart';
// import 'package:platchatapp/feature/map/utils/map_debug.dart';
// import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
// import 'package:platchatapp/helper/custom_image/custom_image.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';
// import 'package:platchatapp/feature/parking/presentation/screens/save_parking_screen.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
// import 'package:platchatapp/feature/parking/presentation/widgets/parking_location_off_prompt.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/parking_location_card.dart';
// import 'package:platchatapp/feature/parking/presentation/widgets/parked_session_card.dart';
// import 'package:platchatapp/feature/parking/presentation/widgets/parking_confirmation_overlay.dart';
// import 'package:platchatapp/share/widgets/bottom_sheet_aware/tracked_bottom_sheet.dart';
// import 'package:platchatapp/share/widgets/map_side_controls.dart';
// import 'package:platchatapp/utils/assets_path/assets_path.dart';
// import 'package:platchatapp/utils/extension/base_extension.dart';
// import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
// import 'package:platchatapp/feature/parking/presentation/widgets/pick_on_map_confirmation_card.dart';
// import 'package:platchatapp/utils/language/app_string.dart';
// import 'package:platchatapp/utils/toast_message/toast_message.dart';
//
// import '../../../../helper/custom_gradient_button/custom_gradient_button.dart';
// import '../../../../utils/color/app_colors.dart';
//
// enum _AddParkingPurpose { report, save }
//
// class ParkingShowScreen extends StatefulWidget {
//
//   const ParkingShowScreen({super.key});
//
//   static const LatLng kInitialMapTarget =
//       ParkingShowController.kApproxDefaultLocation;
//
//   @override
//   State<ParkingShowScreen> createState() => _ParkingShowScreenState();
// }
//
// class _ParkingShowScreenState extends State<ParkingShowScreen>
//     with WidgetsBindingObserver, SingleTickerProviderStateMixin {
//   GoogleMapController? _mapController;
//   MapType _selectedMapType = MapType.normal;
//
//   late final ParkingShowController _parkingShowCtrl;
//
//
//   late final ParkingReportController _parkingReportCtrl;
//   LatLng? _pickedAddParkingLocation;
//   bool _isPickingAddParkingLocation = false;
//   _AddParkingPurpose? _addParkingPickingPurpose;
//
//   late AnimationController _pulseController;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     print("PARKING_SHOW_SCREEN_INIT_STATE (screen mounted/re-mounted)");
//     WidgetsBinding.instance.addObserver(this);
//
//     _parkingShowCtrl = Get.isRegistered<ParkingShowController>()
//         ? Get.find<ParkingShowController>()
//         : Get.put(ParkingShowController());
//
//     // Same controller instance Home's map screen uses for "Add Parking" —
//     // shared singleton via GetX, so the flow behaves identically.
//     _parkingReportCtrl = Get.isRegistered<ParkingReportController>()
//         ? Get.find<ParkingReportController>()
//         : Get.put(ParkingReportController());
//
//     _parkingShowCtrl.clearSpotDetailsCard();
//
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..repeat();
//
//     // Runs the full flow (approx map -> /parking-mode/me -> branch)
//     // every time this screen is entered.
//     _initializeMap();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     // Clear the controller's reference so its existing `mapController != null`
//     // guards correctly skip animateCamera calls once this GoogleMap widget is
//     // gone — otherwise in-flight async work (e.g. fetchNearbyData) still
//     // holds a stale, non-null controller and crashes trying to use it.
//     if (_parkingShowCtrl.mapController == _mapController) {
//       _parkingShowCtrl.mapController = null;
//     }
//     _parkingShowCtrl.clearSpotDetailsCard();
//     _mapController?.dispose();
//     _pulseController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//
//     if (state == AppLifecycleState.resumed) {
//       _parkingShowCtrl.refreshStatus();
//     }
//   }
//
//   Future<void> _initializeMap() async {
//     mapDebug('_initializeMap: running initializeFlow');
//     await _parkingShowCtrl.initializeFlow();
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     _parkingShowCtrl.onMapCreated(controller);
//     mapDebug('GoogleMap created');
//   }
//
//   // ── "Add Parking" flow — ported as-is from the Home map screen ─────────
//   // (_MapScreenState._showAddParkingOptions / _toggleParkingPin /
//   // _showParkingDialog / _showSaveParkingSheet / _startPickingLocation),
//   // reusing the exact same ParkingReportController, ParkingInfoDialog and
//   // SaveParkingDialog — only the trigger (this screen's top-left button
//   // instead of Home's) and the picked-location plumbing (this screen's own
//   // fields/map instead of Home's) are new.
//
//   void _showAddParkingOptions() {
//     HapticFeedback.selectionClick();
//     showTrackedBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.transparent,
//       builder: (sheetContext) {
//         return Container(
//           decoration: BoxDecoration(
//             gradient: AppColors.containerGradient,
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(ResponsiveHelper.borderRadius(24)),
//             ),
//           ),
//           padding: EdgeInsets.only(
//             left: ResponsiveHelper.padding(16),
//             right: ResponsiveHelper.padding(16),
//             top: ResponsiveHelper.padding(12),
//             bottom: ResponsiveHelper.padding(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Center(
//                 child: Container(
//                   width: ResponsiveHelper.width(40),
//                   height: ResponsiveHelper.height(4),
//                   margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(18)),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD1D5DB),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//               CustomGradientButton(
//                 prefixIcon: const Icon(
//                   Icons.add_location_alt_rounded,
//                   color: AppColors.white,
//                 ),
//                 label: AppStrings.addParkingSpot.tr,
//                 onPressed: () {
//                   Navigator.of(sheetContext).pop();
//                   _toggleAddParkingPin();
//                 },
//               ),
//               SizedBox(height: ResponsiveHelper.spacing(14)),
//               CustomGradientButton(
//                 prefixIcon: const Icon(
//                   Icons.add_circle_outline,
//                   color: AppColors.white,
//                 ),
//                 label: AppStrings.parkMyCar.tr,
//                 onPressed: () {
//                   Navigator.of(sheetContext).pop();
//                   _showSaveParkingSheet();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _toggleAddParkingPin() {
//     HapticFeedback.mediumImpact();
//     _pickedAddParkingLocation = null;
//     _stopPickingAddParkingLocation();
//     _showParkingReportDialog();
//   }
//
//   void _showParkingReportDialog() {
//     _parkingReportCtrl.reset();
//
//     // Explicit actions (pick-on-map / submit) set this so the sheet-dismiss
//     // cleanup below doesn't double-run the same reset when they pop it.
//     bool handled = false;
//
//     showTrackedBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.transparent,
//       builder: (_) => ParkingInfoDialog(
//         controller: _parkingReportCtrl,
//         pickedLocation: _pickedAddParkingLocation,
//         onPickOnMap: () {
//           handled = true;
//           Navigator.of(context).pop();
//           _startPickingAddParkingLocation(purpose: _AddParkingPurpose.report);
//         },
//         onSubmit: () async {
//           handled = true;
//           Navigator.of(context).pop();
//           _stopPickingAddParkingLocation();
//
//           final gps = _parkingShowCtrl.gpsPosition.value;
//           if (_pickedAddParkingLocation == null && gps == null) {
//             showCustomSnackBar(
//               AppStrings.locationNotAvailable.tr,
//               isError: true,
//             );
//             return;
//           }
//
//           final LatLng useLocation = _pickedAddParkingLocation ?? gps!;
//
//           final createdArea = await _parkingReportCtrl.addParking(
//             latitude: useLocation.latitude,
//             longitude: useLocation.longitude,
//           );
//           if (!mounted) return;
//           if (createdArea != null) {
//             // Instantly pin the new spot on the map — no refresh needed.
//             if (Get.isRegistered<ParkingShowController>()) {
//               Get.find<ParkingShowController>()
//                   .addParkingAreaInstantly(createdArea);
//             }
//             await ParkingAddedSuccessDialog.show(context);
//             if (!mounted) return;
//             _pickedAddParkingLocation = null;
//           } else {
//             showCustomSnackBar(
//               _parkingReportCtrl.submitMessage.value.isNotEmpty
//                   ? _parkingReportCtrl.submitMessage.value
//                   : AppStrings.mapFailedToSubmitParkingReport.tr,
//               isError: true,
//             );
//           }
//         },
//       ),
//     ).whenComplete(() {
//       // User swiped the sheet down / tapped outside without picking a
//       // location or dropping the pin — same cleanup as the old Cancel button.
//       if (!handled) {
//         _pickedAddParkingLocation = null;
//         _stopPickingAddParkingLocation();
//       }
//     });
//   }
//
//   void _showSaveParkingSheet() {
//     showTrackedBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.transparent,
//       builder: (context) {
//         return SaveParkingDialog(
//           pickedLocation: _pickedAddParkingLocation,
//           gpsPosition: _parkingShowCtrl.gpsPosition.value,
//           parkingCtrl: _parkingReportCtrl,
//           onPickOnMap: () {
//             Navigator.of(context).pop();
//             _startPickingAddParkingLocation(purpose: _AddParkingPurpose.save);
//           },
//           onSaveSuccess: (location) {
//             setState(() {
//               _pickedAddParkingLocation = null;
//             });
//           },
//           showCustomSnackBar: showCustomSnackBar,
//         );
//       },
//     );
//   }
//
//   void _startPickingAddParkingLocation({required _AddParkingPurpose purpose}) {
//     if (!mounted) return;
//     isPickingOnMap.value = true;
//     setState(() {
//       _addParkingPickingPurpose = purpose;
//       _isPickingAddParkingLocation = true;
//       if (_pickedAddParkingLocation == null && _parkingShowCtrl.gpsPosition.value != null) {
//         _pickedAddParkingLocation = _parkingShowCtrl.gpsPosition.value;
//       }
//     });
//   }
//
//   void _stopPickingAddParkingLocation() {
//     if (!mounted) return;
//     isPickingOnMap.value = false;
//     if (_isPickingAddParkingLocation) {
//       setState(() {
//         _isPickingAddParkingLocation = false;
//         _pickedAddParkingLocation = null;
//       });
//     }
//     _addParkingPickingPurpose = null;
//   }
//
//   void _confirmPickedLocation() {
//     if (!mounted) return;
//     isPickingOnMap.value = false;
//     final purpose = _addParkingPickingPurpose;
//     setState(() {
//       _isPickingAddParkingLocation = false;
//     });
//     _addParkingPickingPurpose = null;
//
//     if (purpose == _AddParkingPurpose.save) {
//       _showSaveParkingSheet();
//     } else {
//       _showParkingReportDialog();
//     }
//   }
//
//   void _onMapTappedForAddParking(LatLng position) {
//     if (!_isPickingAddParkingLocation) {
//       _parkingShowCtrl.clearSpotDetailsCard();
//       return;
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       _pickedAddParkingLocation = position;
//     });
//
//     HapticFeedback.selectionClick();
//   }
//
//   /// -- Left-side action buttons: Add Location / Save Parking -------------
//   /// Same circular buttonGradient style used elsewhere. "Add Location"
//   /// opens the report-a-spot / Park-My-Car choice sheet above; "Save
//   /// Parking" just navigates to SaveParkingScreen.
//   Widget _buildLeftActionButtons() {
//     return Positioned(
//       left: ResponsiveHelper.padding(16),
//       top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(68),
//       child: Column(
//         children: [
//           _circleGradientButton(
//             iconAsset: AssetsPath.addLocation,
//             onTap: _showAddParkingOptions,
//           ),
//           SizedBox(height: ResponsiveHelper.height(12)),
//           _circleGradientButton(
//             iconAsset: AssetsPath.savePNav,
//             onTap: () => Navigator.of(context)
//                 .push(MaterialPageRoute(builder: (_) => const SaveParkingScreen()))
//                 .then((_) {
//               // Re-fetch saved-parking so the purple pin stays visible
//               // after the user presses back from SaveParkingScreen.
//               _parkingShowCtrl.fetchSavedParkingMe();
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _circleGradientButton({
//     required String iconAsset,
//     required VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: ResponsiveHelper.width(52),
//         height: ResponsiveHelper.height(52),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: AppColors.buttonGradient,
//           border: Border.all(color: AppColors.darBlue, width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.black.withValues(alpha: 0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: CustomImage(
//           imageSrc: iconAsset,
//           imageColor: AppColors.white,
//           width: ResponsiveHelper.iconSize(24),
//           height: ResponsiveHelper.iconSize(24),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         body: Stack(
//           children: [
//             Obx(() {
//
//               final isLocating = _parkingShowCtrl.isLocating.value;
//               final gpsPosition = _parkingShowCtrl.gpsPosition.value;
//               final showLocationPulse = _parkingShowCtrl.showLocationPulse.value;
//               final isLoading = _parkingShowCtrl.isLoading.value;
//               final status = _parkingShowCtrl.status.value;
//               // Empty until /parking-mode/me resolves & not loading — treat that as
//               // "still loading" so nothing here defaults to the IDLE view or shows buttons while loading.
//               final statusResolved = status.isNotEmpty && !isLoading;
//               final isParked = status == 'PARKED';
//               final isSearching = status == 'SEARCHING';
//               // Search bar / notification bell / layers+location header —
//               // stays visible in every resolved state (including PARKED),
//               // same as the map (home tab). Never shown during the initial
//               // loading window.
//               final showHeader = statusResolved;
//
//               final showSearchUi = statusResolved && !isParked;
//               final isTransitioningSearch =
//                   _parkingShowCtrl.isTransitioningSearch.value;
//
//               if (!isLocating && gpsPosition == null) {
//                 return const ParkingLocationOffPrompt();
//               } else if (isLocating && gpsPosition == null) {
//                 return const MapInitialShimmer();
//               }
//
//
//               return Stack(
//                 children: [
//                   Obx(() {
//                     final currentMarkers = _parkingShowCtrl.markers.toSet();
//                     if (_pickedAddParkingLocation != null) {
//                       currentMarkers.add(
//                         Marker(
//                           markerId: const MarkerId('picked_add_parking_location'),
//                           position: _pickedAddParkingLocation!,
//                           icon: BitmapDescriptor.defaultMarkerWithHue(
//                             BitmapDescriptor.hueAzure,
//                           ),
//                         ),
//                       );
//                     }
//                     final currentPolygons = _parkingShowCtrl.polygons.toSet();
//                     final currentCircles = _parkingShowCtrl.circles.toSet();
//                     final currentPolylines = _parkingShowCtrl.polylines.toSet();
//
//                     return GoogleMap(
//                       mapType: _selectedMapType,
//                       key: const ValueKey<Object>('wheew_google_map'),
//                       onMapCreated: _onMapCreated,
//                       onTap: _onMapTappedForAddParking,
//                       initialCameraPosition: CameraPosition(
//                         target: gpsPosition ?? ParkingShowScreen.kInitialMapTarget,
//                         zoom: 18,
//                       ),
//                       markers: currentMarkers,
//                       polygons: currentPolygons,
//                       circles: currentCircles,
//                       polylines: currentPolylines,
//                       myLocationEnabled: _parkingShowCtrl.isRealLocationLoaded.value,
//                       myLocationButtonEnabled: false,
//                       zoomControlsEnabled: false,
//                       mapToolbarEnabled: false,
//                       compassEnabled: false,
//                       rotateGesturesEnabled: false,
//                       tiltGesturesEnabled: false,
//                     );
//                   }),
//
//
//                   if (isLocating) const LocatingBanner(),
//
//                   if (isLoading) const FetchingParkingBanner(),
//
//
//                   ///search=======================================================
//                   if (showHeader)
//                     Positioned(
//                       top: MediaQuery.of(context).padding.top +
//                           ResponsiveHelper.padding(16),
//                       left: ResponsiveHelper.padding(16),
//                       right: ResponsiveHelper.padding(16),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               behavior: HitTestBehavior.opaque,
//                               onTap: () {
//                                 // -- enter search mode: show the floating button --
//                                 showFindParkingButton.value = true;
//
//                                 RadiusFilterSheet.show(
//                                   context,
//                                   initialRadiusMeter: _parkingShowCtrl.selectedRadiusMeter.value,
//                                   onApply: (radius) {
//                                     _parkingShowCtrl.selectedRadiusMeter.value = radius;
//                                     final lat = _parkingShowCtrl.gpsPosition.value?.latitude;
//                                     final lng = _parkingShowCtrl.gpsPosition.value?.longitude;
//                                     if (lat != null && lng != null) {
//                                       // Radius filter only affects the handoffs
//                                       // radius — parking areas use a fixed radius.
//                                       _parkingShowCtrl.fetchNearbyHandoffsOnly(lat, lng);
//                                     }
//                                     // -- sheet applied: hide the floating button --
//                                     showFindParkingButton.value = false;
//
//                                   },
//                                 ).then((_) {
//                                   // -- sheet dismissed (swipe/tap outside): hide button --
//                                   showFindParkingButton.value = false;
//                                 });
//                               },
//                               child: Builder(
//                                 builder: (context) {
//                                   final double barHeight = ResponsiveHelper.padding(50);
//                                   return ClipRRect(
//                                     borderRadius: BorderRadius.circular(barHeight / 2), // <-- height/2 = perfect pill
//                                     child: BackdropFilter(
//                                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // frosted glass effect
//                                       child: Container(
//                                         height: barHeight,
//                                         decoration: BoxDecoration(
//                                           color: AppColors.white, // <-- alpha à¦ªà§à¦°à§‹à¦ªà§à¦°à¦¿ à¦¬à¦¾à¦¦, solid à¦¸à¦¾à¦¦à¦¾
//                                           borderRadius: BorderRadius.circular(barHeight / 2),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: AppColors.black.withValues(alpha: 0.08),
//                                               blurRadius: 12,
//                                               offset: const Offset(0, 4),
//                                             ),
//                                           ],
//                                         ),
//                                         child: AbsorbPointer(
//                                           absorbing: true,
//                                           child: TextField(
//                                             readOnly: true,
//                                             controller: _searchController,
//                                             style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
//                                             decoration: InputDecoration(
//                                               hintText: AppStrings.searchHere.tr,
//                                               hintStyle: TextStyle(
//                                                 fontSize: ResponsiveHelper.fontSize(14),
//                                                 color: AppColors.grey,
//                                               ),
//                                               prefixIcon: Icon(
//                                                 Icons.search,
//                                                 color: AppColors.black,
//                                                 size: ResponsiveHelper.iconSize(20),
//                                               ),
//                                               suffixIcon: Icon(
//                                                 Icons.tune,
//                                                 color: AppColors.black,
//                                                 size: ResponsiveHelper.iconSize(20),
//                                               ),
//                                               border: InputBorder.none,
//                                               contentPadding: ResponsiveHelper.symmetric(vertical: 12),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: ResponsiveHelper.spacing(8)),
//                           _NotificationBellButton(),
//                         ],
//                       ),
//                     ),
//
//                   // Same solid pulsing frame as before (width breathes the
//                   // same way), just: (1) gradient-colored instead of solid
//                   // blue, (2) the stroke width waves irregularly around the
//                   // perimeter instead of being uniform, per the reference.
//                   if (showLocationPulse && gpsPosition != null)
//                     Positioned.fill(
//                       child: IgnorePointer(
//                         child: AnimatedBuilder(
//                           animation: _pulseController,
//                           builder: (context, child) {
//                             final t = _pulseController.value < 0.5
//                                 ? _pulseController.value * 2
//                                 : (1.0 - _pulseController.value) * 2;
//                             final wavePhase = _pulseController.value * 2 * pi;
//
//                             return CustomPaint(
//                               size: Size.infinite,
//                               painter: _WavyGradientBorderPainter(
//                                 t: t,
//                                 wavePhase: wavePhase,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//
//                   if (_isPickingAddParkingLocation)
//                     PickOnMapConfirmationCard(
//                       pickedLocation: _pickedAddParkingLocation,
//                       onConfirm: _confirmPickedLocation,
//                       onCancel: _stopPickingAddParkingLocation,
//                       onUseCurrentLocation: () {
//                         final gps = _parkingShowCtrl.gpsPosition.value;
//                         if (gps != null) {
//                           setState(() => _pickedAddParkingLocation = gps);
//                           HapticFeedback.selectionClick();
//                         }
//                       },
//                     )
//                   else if (isParked)
//                     Positioned(
//                       bottom: ResponsiveHelper.bottomNavOffset(context),
//                       left: ResponsiveHelper.padding(20),
//                       right: ResponsiveHelper.padding(20),
//                       child: Obx(() => ParkedSessionCard(
//                         locationName: _parkingShowCtrl.parkedLocationName.value.isNotEmpty
//                             ? _parkingShowCtrl.parkedLocationName.value
//                             : AppStrings.yourParkingSpot.tr,
//                         spotCode: _parkingShowCtrl.parkedSpotCode.value,
//                         onExitPressed: _showExitParkingConfirmation,
//                       )),
//                     )
//                   else if (showSearchUi)
//                     Positioned(
//                       bottom: ResponsiveHelper.bottomNavOffset(context),
//                       left: ResponsiveHelper.padding(80),
//                       right: ResponsiveHelper.padding(80),
//                       child: CustomGradientButton(
//                         onPressed: isSearching
//                             ? _parkingShowCtrl.stopSearching
//                             : _parkingShowCtrl.onLeavingPopupNo,
//                         isLoading: isTransitioningSearch,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             if (!isSearching) ...[
//                               CustomImage(imageSrc: AssetsPath.pNav),
//                               SizedBox(width: ResponsiveHelper.width(4)),
//                             ],
//                             Text(
//                              isSearching ? AppStrings.stopSearching.tr : AppStrings.findParkingSpot.tr,
//                               style: context.bodyMedium.copyWith(color: AppColors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                   /// -- Active spot details card overlay (floating above bottom nav) --
//                   Obx(() {
//                     if (_isPickingAddParkingLocation) {
//                       return const SizedBox.shrink();
//                     }
//                     final cardData = _parkingShowCtrl.activeSpotDetailsCard.value;
//                     if (cardData == null) return const SizedBox.shrink();
//
//                     return Positioned(
//                       bottom: ResponsiveHelper.bottomNavOffset(context),
//                       left: ResponsiveHelper.padding(16),
//                       right: ResponsiveHelper.padding(16),
//                       child: ParkingLocationCard(
//                         title: (cardData.title == null || cardData.title!.trim().isEmpty)
//                             ? AppStrings.unknown.tr
//                             : cardData.title!,
//                         subtitle: cardData.subtitle,
//                         badgeLabel: cardData.badgeLabel,
//                         badgeIcon: cardData.badgeIcon,
//                         badgeIconAsset: cardData.badgeIconAsset,
//                         badgeColor: cardData.badgeColor,
//                         distanceLabel: cardData.distanceLabel,
//                         ratingLabel: cardData.ratingLabel,
//                         leftStatLabel: cardData.leftStatLabel,
//                         rightStatLabel: cardData.rightStatLabel,
//                         rightStatIcon: cardData.rightStatIcon,
//                         onSavePark: cardData.onSavePark == null
//                             ? null
//                             : () {
//                                 final onSave = cardData.onSavePark!;
//                                 _parkingShowCtrl.clearSpotDetailsCard();
//                                 onSave();
//                               },
//                         onNavigate: cardData.destination == null
//                             ? null
//                             : () {
//                                 final dest = cardData.destination!;
//                                 _parkingShowCtrl.clearSpotDetailsCard();
//                                 AppRouter.router.pushNamed(
//                                   RouteName.inAppNavigation,
//                                   extra: {
//                                     'destination': dest,
//                                     'parkingAreaTypes': cardData.parkingAreaTypes,
//                                     'isHandoff': cardData.isHandoff,
//                                   },
//                                 );
//                               },
//                       ),
//                     );
//                   }),
//                 ],
//               );
//             }),
//
//
//             ///map type and current location combined container =============================================================
//             Obx(() {
//               final navStatus = _parkingShowCtrl.status.value;
//               if (navStatus.isEmpty) {
//                 return const SizedBox.shrink();
//               }
//               return MapSideControls(
//                 selectedMapType: _selectedMapType,
//                 onMapTypeChanged: (type) {
//                   setState(() => _selectedMapType = type);
//                 },
//                 onLocationTap: () => _parkingShowCtrl.getUserLocation(),
//               );
//             }),
//
//             /// -- Left-side action buttons: Add Location / Save Parking ----
//             _buildLeftActionButtons(),
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   // Triggered only by the "Exit Parking" button on the parked-session card.
//   // Yes reuses the existing "I'm leaving this spot" logic unchanged
//   // (createHandoff + set idle, then the rating dialog). No just closes the
//   // dialog and leaves the user on the parked-session view.
//   void _showExitParkingConfirmation() {
//     mapDebug('Showing Exit Parking Confirmation Dialog');
//
//     ParkingConfirmationDialog.show(
//       context,
//       onYes: _parkingShowCtrl.onLeavingPopupYes,
//       onNo: () {},
//     );
//   }
// }
//
// class _NotificationBellButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => context.push(RoutePath.notification),
//       child: Obx(() {
//         final notificationCtrl = Get.find<NotificationController>();
//         final count = notificationCtrl.unreadCount.value;
//         return Stack(
//           clipBehavior: Clip.none,
//           alignment: Alignment.center,
//           children: [
//             Container(
//               height: ResponsiveHelper.width(42),
//               width: ResponsiveHelper.width(42),
//               padding: ResponsiveHelper.all(10),
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.white),
//                 color: AppColors.white.withValues(alpha: 0.5),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.black.withValues(alpha: 0.12),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: CustomImage(
//
//                   imageSrc: AssetsPath.notificationMap,
//                   height: ResponsiveHelper.height(18),
//                   width: ResponsiveHelper.width(18),
//                   boxFit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             if (count > 0)
//               Positioned(
//                 top: -2,
//                 right: -2,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFF2F80ED),
//                     shape: BoxShape.circle,
//                     border: Border.fromBorderSide(
//                       BorderSide(color: AppColors.white, width: 1.5),
//                     ),
//                   ),
//                   child: Text(
//                     '$count',
//                     style: const TextStyle(
//                       fontSize: 9,
//                       color: AppColors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
// // -- SEARCHING-mode glow frame: gradient-colored (blue â†’ white â†’ purple),
// //    stroke width waves irregularly around the perimeter and the wave
// //    travels over time — same base pulsing width/timing as the old solid
// //    Border.all() version, just not a uniform line anymore. --
// class _WavyGradientBorderPainter extends CustomPainter {
//   final double t; // 0..1 "breathing" phase — same as the old glowWidth calc
//   final double wavePhase; // rotates the wave around the perimeter over time
//
//   const _WavyGradientBorderPainter({
//     required this.t,
//     required this.wavePhase,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;
//     final metrics = (Path()..addRect(rect)).computeMetrics().first;
//     final length = metrics.length;
//
//     final gradient = const SweepGradient(
//       colors: [
//         Color(0xFF1E88E5), // blue
//         AppColors.white,
//         Color(0xFF1E88E5), // back to blue
//         AppColors.white,
//         Color(0xFF1E88E5), // back to blue
//       ],
//       stops: [0.0, 0.25, 0.5, 0.75, 1.0],
//     );
//     final shader = gradient.createShader(rect);
//
//     // Modulated by a traveling sine wave so it's thicker/thinner at
//     // different points around the frame instead of uniform.
//     final baseWidth = 14.0 + (t * 10.0);
//     const waveAmplitude = 5.0;
//     const waveCount = 3; // how many "bulges" travel around the perimeter
//
//     const segments = 160;
//     for (int i = 0; i < segments; i++) {
//       final d0 = length * i / segments;
//       final d1 = length * (i + 1) / segments;
//       final segmentPath = metrics.extractPath(d0, d1);
//
//       final wave = sin((d0 / length) * 2 * pi * waveCount + wavePhase);
//       final strokeWidth = (baseWidth + wave * waveAmplitude).clamp(6.0, 30.0);
//
//       // Soft outer halo (blurred, wider) + a tighter, less-blurred core on
//       // top — this combo is what actually reads as "glow" instead of a
//       // crisp painted line, kept narrow so it hugs the edge.
//       final haloPaint = Paint()
//         ..shader = shader
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = strokeWidth * 1.4
//         ..strokeCap = StrokeCap.round
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.5);
//       canvas.drawPath(segmentPath, haloPaint);
//
//       final corePaint = Paint()
//         ..shader = shader
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = strokeWidth * 0.6
//         ..strokeCap = StrokeCap.round
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.15);
//       canvas.drawPath(segmentPath, corePaint);
//
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _WavyGradientBorderPainter oldDelegate) =>
//       oldDelegate.t != t || oldDelegate.wavePhase != wavePhase;
// }
//
//
//
