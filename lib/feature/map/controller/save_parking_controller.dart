import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';

/// Standalone controller for the plain Save-Parking map tab.
///
/// Hits the exact same nearby-spots / spot-details endpoints as the Home
/// screen's ParkingReportController (map_controller.dart), but is a fully
/// separate GetX instance — its own markers, loading state and selected
/// report never touch the Home screen's controller, and vice versa.
class SaveParkingController extends GetxController {
  static const int _radiusMeters = 20000;

  final RxBool isLocating = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSpotDetails = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<LatLng> gpsPosition = Rxn<LatLng>();
  final RxList<Map<String, dynamic>> parkingList = <Map<String, dynamic>>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rxn<Map<String, dynamic>> selectedReport = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> spotDetails = Rxn<Map<String, dynamic>>();

  GoogleMapController? mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> init() async {
    isLocating.value = true;
    final position = await _resolveLocation();
    isLocating.value = false;

    if (position == null) {
      mapDebug('SaveParkingController: no GPS, skipping fetch');
      return;
    }

    gpsPosition.value = position;
    await mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 20),
    );
    await fetchNearbySpots(latitude: position.latitude, longitude: position.longitude);
  }

  Future<LatLng?> _resolveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      mapDebug('SaveParkingController: location error $e');
      return null;
    }
  }

  // ── GET nearby parking spots — same endpoint Home uses ────────────────
  Future<void> fetchNearbySpots({
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.searchParkingAreas(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: _radiusMeters,
        ),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];

        if (decoded is Map<String, dynamic>) {
          final dynamic nested = decoded['areas'] ??
              decoded['parkingAreas'] ??
              decoded['spots'] ??
              decoded['reports'] ??
              decoded['data'] ??
              decoded['items'];
          if (nested is List) {
            rawList = nested;
          } else if (nested is Map<String, dynamic>) {
            rawList = [nested];
          }
        } else if (decoded is List) {
          rawList = decoded;
        }

        parkingList.value = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        await _buildMarkers();
        mapDebug('SaveParkingController: loaded ${parkingList.length} spot(s)');
      } else {
        errorMessage.value = 'Failed to load parking data (${response.statusCode})';
        mapDebug('SaveParkingController: HTTP ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      mapDebug('SaveParkingController: exception $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── GET single spot details — same endpoint Home uses ─────────────────
  Future<void> fetchSpotDetails(String spotId) async {
    try {
      isLoadingSpotDetails.value = true;
      spotDetails.value = null;

      final response = await ApiClient.getData(
        uri: ApiUrl.spotDetails(spotId: spotId),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        spotDetails.value = Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      mapDebug('SaveParkingController: spot details exception $e');
    } finally {
      isLoadingSpotDetails.value = false;
    }
  }

  void _onMarkerTap(Map<String, dynamic> parking) {
    selectedReport.value = parking;
    final spotId = parking['id']?.toString();
    if (spotId != null) {
      fetchSpotDetails(spotId);
    }
  }

  void clearSelectedReport() => selectedReport.value = null;

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _buildMarkers() async {
    final icon = await MapMarkerIcons.parkingPin();
    final Set<Marker> newMarkers = {};

    for (var i = 0; i < parkingList.length; i++) {
      final parking = parkingList[i];
      final double? lat = _toDouble(parking['latitude'] ?? parking['centerLat']);
      final double? lng = _toDouble(parking['longitude'] ?? parking['centerLng']);
      if (lat == null || lng == null) continue;

      newMarkers.add(
        Marker(
          markerId: MarkerId(parking['id']?.toString() ?? 'save_parking_$i'),
          position: LatLng(lat, lng),
          icon: icon,
          infoWindow: InfoWindow.noText,
          onTap: () => _onMarkerTap(parking),
        ),
      );
    }

    markers.value = newMarkers;
  }
}
