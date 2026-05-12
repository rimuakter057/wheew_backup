import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';   // your ApiUrl path

/// Disabled facility location options
enum DisabledLocation { all, top, back, right, left, none }

extension DisabledLocationX on DisabledLocation {
  String get value => name.toUpperCase(); // ALL, TOP, BACK, RIGHT, LEFT, NONE
}

class ParkingReportController extends GetxController {
  // ── Form State ───────────────────────────────────────────────────────────────
  final RxString parkingCost          = 'FREE'.obs;   // FREE | PAID
  final RxBool   electricCharging     = false.obs;
  final RxBool   disabledFacility     = false.obs;
  final Rx<DisabledLocation> disabledLocation = DisabledLocation.none.obs;

  // ── UI State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;

  // ── Reset ────────────────────────────────────────────────────────────────────
  void reset() {
    parkingCost.value      = 'FREE';
    electricCharging.value = false;
    disabledFacility.value = false;
    disabledLocation.value = DisabledLocation.none;
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<bool> submitParkingReport({
    required double latitude,
    required double longitude,
  }) async
  {
    isLoading.value = true;

    final Map<String, dynamic> body = {
      'latitude'         : latitude,
      'longitude'        : longitude,
      'parking_cost'     : parkingCost.value,
      'electric_charging': electricCharging.value,
      'disabled_facility': disabledFacility.value,
      if (disabledFacility.value)
        'disabled_facility_location': disabledLocation.value.value,
    };

    try {
      final response = await ApiClient.postData(
        uri : ApiUrl.parkingReport, // '/parking-report'
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          '✅ Success',
          'Parking report submitted!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Something went wrong';
        Get.snackbar('❌ Error', msg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('❌ Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  ///===============================get parking







  // ─── State ───────────────────────────────────────────────
  final RxBool isLoadingShowDetails = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> parkingList = <Map<String, dynamic>>[].obs;

  // Map controller & markers
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;

  // Initial camera position (Dhaka default)
  final Rx<CameraPosition> initialCameraPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 12,
  ).obs;


  // ─── Fetch Data ──────────────────────────────────────────
  Future<void> fetchParkingReport() async {
    try {
      isLoadingShowDetails.value = true;
      errorMessage.value = '';

      final response = await ApiClient.getData(
        uri: ApiUrl.showDetails, // তোমার endpoint
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // Response list অথবা single object — দুটোই handle করে
        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // যদি { data: [...] } wrapped হয়
          rawList = decoded['data'] ?? [decoded];
        }

        parkingList.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();

        _buildMarkers();
      } else {
        errorMessage.value =
        'Failed to load parking data (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoadingShowDetails.value = false;
    }
  }

  // ─── Build Map Markers ───────────────────────────────────
  void _buildMarkers() {
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < parkingList.length; i++) {
      final parking = parkingList[i];

      final double? lat = _toDouble(parking['latitude']);
      final double? lng = _toDouble(parking['longitude']);

      // lat/lng না থাকলে skip
      if (lat == null || lng == null) continue;

      final bool isPaid = parking['parking_cost'] == 'PAID';
      final bool hasCharging = parking['electric_charging'] == true;
      final bool isDisabled = parking['disabled_facility'] == true;
      final bool isActive = parking['is_active'] == true;

      newMarkers.add(
        Marker(
          markerId: MarkerId(parking['id'] ?? 'parking_$i'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            !isActive
                ? BitmapDescriptor.hueRed
                : isPaid
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: isPaid ? '💰 Paid Parking' : '🆓 Free Parking',
            snippet: [
              if (hasCharging) '⚡ EV Charging',
              if (isDisabled) '♿ Disabled Facility',
              if (!isActive) '🔴 Inactive',
            ].join('  |  '),
          ),
          onTap: () => _onMarkerTap(parking),
        ),
      );
    }

    markers.value = newMarkers;

    // প্রথম marker-এ camera move করো
    if (newMarkers.isNotEmpty) {
      final first = newMarkers.first.position;
      mapController.value?.animateCamera(
        CameraUpdate.newLatLngZoom(first, 13),
      );
    }
  }

  // ─── Marker Tap ──────────────────────────────────────────
  void _onMarkerTap(Map<String, dynamic> parking) {
    // চাইলে bottom sheet বা dialog খুলতে পারো
    Get.snackbar(
      'Parking Info',
      'Cost: ${parking['parking_cost']}  |  '
          'EV: ${parking['electric_charging']}  |  '
          'Disabled: ${parking['disabled_facility']}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // ─── Map Ready Callback ──────────────────────────────────
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    // Markers আগে load হয়ে থাকলে camera move করো
    if (markers.isNotEmpty) {
      final first = markers.first.position;
      controller.animateCamera(CameraUpdate.newLatLngZoom(first, 13));
    }
  }

  // ─── Helper ──────────────────────────────────────────────
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }





}