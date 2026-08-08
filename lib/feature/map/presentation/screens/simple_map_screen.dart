// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:platchatapp/feature/map/controller/save_parking_controller.dart';
// import 'package:platchatapp/feature/map/presentation/screens/map_screen.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
// import 'package:platchatapp/feature/map/presentation/widgets/parking_report_dropdown.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/share/widgets/map_side_controls.dart';
// import 'package:platchatapp/share/widgets/map_top_bar.dart';
//
// /// Standalone Google Map tab — fetches nearby parking spots the same way
// /// Home does and shows the same tap-to-details card, but through its own
// /// SaveParkingController instance so nothing is shared with Home's screen.
// class SimpleMapScreen extends StatefulWidget {
//   const SimpleMapScreen({super.key});
//
//   @override
//   State<SimpleMapScreen> createState() => _SimpleMapScreenState();
// }
//
// class _SimpleMapScreenState extends State<SimpleMapScreen> {
//   late final SaveParkingController _controller;
//
//   MapType _selectedMapType = MapType.normal;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = Get.put(SaveParkingController());
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _controller.init();
//     });
//   }
//
//   @override
//   void dispose() {
//     Get.delete<SaveParkingController>();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   /// Animate camera back to the user's current GPS position.
//   void _goToMyLocation() {
//     final pos = _controller.gpsPosition.value;
//     if (pos == null) return;
//     _controller.mapController?.animateCamera(
//       CameraUpdate.newLatLngZoom(pos, 20),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // ── Map ──────────────────────────────────────────────────────────
//           Obx(
//             () => GoogleMap(
//               key: const ValueKey<Object>('save_parking_google_map'),
//               mapType: _selectedMapType,
//               onMapCreated: _controller.onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _controller.gpsPosition.value ??
//                     MapScreen.kInitialMapTarget,
//                 zoom: 20,
//               ),
//               markers: {..._controller.markers},
//               myLocationEnabled: _controller.gpsPosition.value != null,
//               myLocationButtonEnabled: false,
//               zoomControlsEnabled: false,
//               mapToolbarEnabled: false,
//               compassEnabled: false,
//               rotateGesturesEnabled: false,
//               tiltGesturesEnabled: false,
//             ),
//           ),
//
//           // ── GPS locating banner ────────────────────────────────────────
//           Obx(
//             () => _controller.isLocating.value
//                 ? const LocatingBanner()
//                 : const SizedBox.shrink(),
//           ),
//
//           // ── Fetching-spots banner ──────────────────────────────────────
//           Obx(
//             () => _controller.isLoading.value
//                 ? const FetchingParkingBanner()
//                 : const SizedBox.shrink(),
//           ),
//
//           // ── Selected-spot detail card ──────────────────────────────────
//           Obx(() {
//             final selected = _controller.selectedReport.value;
//             if (selected == null) return const SizedBox.shrink();
//             return Positioned(
//               left: 8,
//               right: 8,
//               bottom: ResponsiveHelper.spacing(115),
//               child: ParkingReportDropdown(
//                 report: selected,
//                 onClose: _controller.clearSelectedReport,
//               ),
//             );
//           }),
//
//           // ── Top-bar: search pill + notification bell ──────────────────
//           Obx(
//             () => _controller.gpsPosition.value != null
//                 ? MapTopBar(
//                     searchController: _searchController,
//                     onSearchTap: null, // extend with search logic if needed
//                   )
//                 : const SizedBox.shrink(),
//           ),
//
//           // ── Side controls: map type + current location ────────────────
//           Obx(
//             () => _controller.gpsPosition.value != null
//                 ? MapSideControls(
//                     selectedMapType: _selectedMapType,
//                     onMapTypeChanged: (type) {
//                       setState(() => _selectedMapType = type);
//                     },
//                     onLocationTap: _goToMyLocation,
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }
