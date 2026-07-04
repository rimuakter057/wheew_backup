// // lib/controllers/parking_controller.dart
// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class ParkingController extends GetxController {
//   // Parking Mode active kina (Scenario A)
//   var isParkingModeActive = false.obs;
//
//   // Keu parking chhare jachche kina (Scenario B)
//   var isLeavingSpot = false.obs;
//
//   // Mock Users and Spots data
//   var parkingSpots = <Marker>[].obs;
//   var leavingCars = <Marker>[].obs;
//
//   Timer? _rippleTimer;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _loadMockData();
//   }
//
//   void _loadMockData() {
//     // Mock Available Parking Spots (Scenario A er jonno)
//     parkingSpots.assignAll([
//       Marker(
//         markerId: const MarkerId('spot_1'),
//         position: const LatLng(23.8103, 90.4125), // Example Coord
//         infoWindow: const InfoWindow(title: 'Available Slot - A1'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       ),
//     ]);
//   }
//
//   // Scenario A: Looking for parking
//   void startLookingForParking() {
//     isParkingModeActive.value = true;
//     isLeavingSpot.value = false;
//     Get.snackbar(
//       "Parking Mode Active",
//       "Showing nearby available parking spots within 300m.",
//       snackPosition: SnackPosition.TOP,
//     );
//   }
//
//   // Scenario B: Leaving parking spot (Triggering 5 mins mock simulation)
//   void startLeavingParkingCircle() {
//     isParkingModeActive.value = false;
//     isLeavingSpot.value = true;
//
//     // Mock Notification Simulation (As if sent to 300m radius active users)
//     Future.delayed(const Duration(seconds: 2), () {
//       Get.snackbar(
//         "Alert Sent!",
//         "Nearby users within 300m in Parking Mode have been notified.",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     });
//
//     // 5 minutes por ripple/glowing off hobe (Simulation)
//     _rippleTimer?.cancel();
//     _rippleTimer = Timer(const Duration(minutes: 5), () {
//       isLeavingSpot.value = false;
//     });
//   }
//
//   @override
//   void onClose() {
//     _rippleTimer?.cancel();
//     super.onClose();
//   }
// }